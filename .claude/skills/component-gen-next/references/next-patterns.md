# Next.js App Router Patterns

Reference for `/component-gen next` — Next.js 15+ App Router specifics.
Load alongside `react-patterns.md` and `common-states.md`.

---

## A. RSC Boundary Rules

**Default:** Every generated component is a Server Component. No directive = RSC.

**Add `'use client'` only when the component needs:**

- `useState`, `useEffect`, `useRef`, or any React state/lifecycle hooks
- Browser APIs (`window`, `document`, `navigator`, `localStorage`)
- Event handlers attached to DOM elements (`onClick`, `onChange`, `onSubmit`)
- Next.js client-only hooks: `useRouter`, `usePathname`, `useSearchParams`

**Isolation rule:** Push `'use client'` as deep as possible — create small interactive islands, keep the outer shell as RSC.

```tsx
// ✅ Correct: RSC shell + Client island
// UserCard.tsx (RSC — no directive)
import { UserCardActions } from './UserCardActions'

export async function UserCard({ userId }: UserCardProps) {
  const user = await fetchUser(userId)
  return (
    <article>
      <h2>{user.name}</h2>
      <UserCardActions userId={userId} /> {/* client island */}
    </article>
  )
}

// UserCardActions.tsx (Client island)
'use client'
import { useState } from 'react'

export function UserCardActions({ userId }: { userId: string }) {
  const [following, setFollowing] = useState(false)
  return <button onClick={() => setFollowing(f => !f)}>{following ? 'Unfollow' : 'Follow'}</button>
}
```

```tsx
// ❌ Wrong: making the whole component a Client Component unnecessarily
'use client'
export async function UserCard({ userId }: UserCardProps) { ... }
```

---

## B. 4 States in App Router

### Loading State — `<Suspense>` + Skeleton

Loading is NOT a spinner inside the component body. Use `<Suspense>` at the **call site** with a skeleton fallback.

```tsx
// page.tsx or parent RSC
import { Suspense } from 'react'
import { UserCard } from '@/features/user/ui/UserCard'
import { UserCardSkeleton } from '@/features/user/ui/UserCard/UserCard.loading'

export default function Page({ params }: { params: { id: string } }) {
  return (
    <Suspense fallback={<UserCardSkeleton />}>
      <UserCard userId={params.id} />
    </Suspense>
  )
}
```

```tsx
// UserCard.loading.tsx — skeleton component
export function UserCardSkeleton() {
  return (
    <div className="animate-pulse space-y-3" aria-busy="true" aria-label="Loading user…">
      <div className="h-6 w-48 rounded bg-gray-200" />
      <div className="h-4 w-32 rounded bg-gray-200" />
    </div>
  )
}
```

### Error State — `error.tsx` boundary + component re-throw

Route-segment errors are caught by `error.tsx` (must be `'use client'`).
Component-level errors: re-throw to nearest boundary — do NOT silently swallow.

```tsx
// app/{route}/error.tsx
'use client'
import { useEffect } from 'react'

export default function ErrorPage({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    console.error(error)
  }, [error])
  return (
    <div role="alert" aria-live="assertive">
      <p>Something went wrong.</p>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

```tsx
// In RSC — re-throw so boundary catches it
export async function UserCard({ userId }: UserCardProps) {
  const user = await fetchUser(userId) // throws on 404/500 → caught by error.tsx
  ...
}
```

### Empty State — returned from RSC after await

```tsx
export async function UserCard({ userId }: UserCardProps) {
  const user = await fetchUser(userId)

  if (!user) {
    return (
      <div role="status">
        <p>User not found.</p>
      </div>
    )
  }

  return <article>...</article>
}
```

### Success State — direct `await` in RSC body

No TanStack Query for RSC. `await` the data directly in the async function body.

```tsx
export async function UserCard({ userId }: UserCardProps) {
  const user = await db.user.findUnique({ where: { id: userId } })
  // or: const user = await fetch(`/api/users/${userId}`).then(r => r.json())

  if (!user) return <EmptyState />

  return (
    <article>
      <h2>{user.name}</h2>
      <p>{user.bio}</p>
    </article>
  )
}
```

> **TanStack Query** remains valid only inside `'use client'` components for client-side data needs.

---

## C. Server Actions (Mutations)

For `--type feature` components with forms: generate `actions.ts` with `'use server'` directive.

### `actions.ts` template

```ts
// actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function submitUserAction(formData: FormData): Promise<{ error?: string }> {
  const name = formData.get('name')
  if (typeof name !== 'string' || name.trim() === '') {
    return { error: 'Name is required.' }
  }

  try {
    await db.user.update({ where: { id: '...' }, data: { name: name.trim() } })
    revalidateTag('user')
    return {}
  } catch {
    return { error: 'Failed to save. Please try again.' }
  }
}
```

### Form with Server Action + `useActionState`

```tsx
// UserCardForm.tsx (Client island — needs useActionState)
'use client'

import { useActionState } from 'react'
import { submitUserAction } from '../actions'

const initialState = { error: undefined }

export function UserCardForm() {
  const [state, formAction, isPending] = useActionState(submitUserAction, initialState)

  return (
    <form action={formAction}>
      <input name="name" aria-label="Name" required />
      {state.error && (
        <p role="alert" aria-live="assertive">{state.error}</p>
      )}
      <button type="submit" disabled={isPending} aria-busy={isPending}>
        {isPending ? 'Saving…' : 'Save'}
      </button>
    </form>
  )
}
```

**Rules:**

- Pass action to `<form action={serverAction}>` — NEVER `onSubmit` + `fetch()`
- `useActionState` in the client wrapper for pending/error feedback
- Server Action file lives at `{feature}/actions.ts` (not inside `api/`)

---

## D. Native Next.js Primitives

### Navigation

```tsx
// ✅ Correct
import Link from 'next/link'
import Image from 'next/image'
import { useRouter, usePathname, redirect, notFound } from 'next/navigation'

// ❌ Banned
// <a href="/about">           → use <Link href="/about">
// <img src="..." />           → use <Image src="..." width={} height={} alt="..." />
// import { useRouter } from 'next/router'  → must be next/navigation
```

### `redirect` and `notFound` in RSC

```tsx
import { redirect, notFound } from 'next/navigation'

export async function UserCard({ userId }: UserCardProps) {
  const user = await fetchUser(userId)
  if (!user) notFound()           // renders nearest not-found.tsx
  if (!user.active) redirect('/') // server-side redirect
  return <article>...</article>
}
```

---

## E. Caching (Next.js 15+)

**Banned pattern:**

```ts
// ❌ Old Next.js 13/14 pattern — FORBIDDEN in Next.js 15+
export const revalidate = 60
```

**Use `'use cache'` directive on async server functions:**

```ts
// lib/data.ts
'use cache'

import { unstable_cacheTag as cacheTag, unstable_cacheLife as cacheLife } from 'next/cache'

export async function getUserData(userId: string) {
  cacheTag(`user-${userId}`)
  cacheLife('hours') // 'seconds' | 'minutes' | 'hours' | 'days' | 'weeks' | 'max'
  return await db.user.findUnique({ where: { id: userId } })
}
```

**On-demand invalidation with `revalidateTag`:**

```ts
// actions.ts
'use server'
import { revalidateTag } from 'next/cache'

export async function updateUser(userId: string, data: UserUpdateInput) {
  await db.user.update({ where: { id: userId }, data })
  revalidateTag(`user-${userId}`)
}
```

**Rules:**

- `'use cache'` directive goes at the top of the file or function
- `cacheTag()` must be called synchronously at the top of the cached function
- Never combine `'use cache'` with `'use client'`

---

## F. Component Templates

### RSC Async Feature Component

```tsx
// {ComponentName}.tsx
import { notFound } from 'next/navigation'
import type { {ComponentName}Props } from './{ComponentName}.types'

export async function {ComponentName}({ id }: {ComponentName}Props) {
  const data = await fetch{EntityName}(id)

  if (!data) notFound()

  if (data.items.length === 0) {
    return (
      <section role="status">
        <p>No {entityName} found.</p>
      </section>
    )
  }

  return (
    <section>
      {data.items.map(item => (
        <article key={item.id}>
          <h2>{item.name}</h2>
        </article>
      ))}
    </section>
  )
}
```

### Client Island Wrapper

```tsx
// {ComponentName}Client.tsx
'use client'

import { useState } from 'react'
import type { {ComponentName}ClientProps } from './{ComponentName}.types'

export function {ComponentName}Client({ initialData }: {ComponentName}ClientProps) {
  const [localState, setLocalState] = useState(initialData)

  return (
    <div>
      {/* interactive UI only */}
    </div>
  )
}
```

### Skeleton Component (`{ComponentName}.loading.tsx`)

```tsx
// {ComponentName}.loading.tsx
export function {ComponentName}Skeleton() {
  return (
    <div className="animate-pulse space-y-4" aria-busy="true" aria-label="Loading…">
      <div className="h-6 w-3/4 rounded bg-gray-200" />
      <div className="h-4 w-1/2 rounded bg-gray-200" />
      <div className="h-32 w-full rounded bg-gray-200" />
    </div>
  )
}
```

### `actions.ts` with Server Action

```ts
// actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function create{EntityName}Action(
  _prevState: { error?: string },
  formData: FormData
): Promise<{ error?: string }> {
  const name = formData.get('name')

  if (typeof name !== 'string' || !name.trim()) {
    return { error: 'Name is required.' }
  }

  try {
    await db.{entityName}.create({ data: { name: name.trim() } })
    revalidateTag('{entityName}')
    return {}
  } catch {
    return { error: 'Failed to create. Please try again.' }
  }
}
```
