# React Client Island Patterns (Next.js)

Subset of React patterns for `'use client'` components inside Next.js App Router.
These patterns apply ONLY to client islands — NOT to RSC data fetching.

---

## State Management (Client Only)

```typescript
// Local state
const [isOpen, setIsOpen] = useState(false);

// Derived state: useMemo (not useState + useEffect)
const filtered = useMemo(() => items.filter(i => i.active), [items]);

// Global client state: Zustand
import { useStore } from '@/shared/store';
const user = useStore((state) => state.user);
```

> TanStack Query is valid in `'use client'` components for client-side data needs (e.g., polling, optimistic updates). But RSC data fetching uses `await` — NOT `useQuery`.

## Key Rules

- Function components only (no class components)
- `useCallback` for event handlers passed as props
- `useMemo` only when computation is measurably expensive
- Dependency arrays in `useEffect` — explicit and complete
- `key` in lists — stable unique ID, never `index`

## INP — Interaction to Next Paint

```tsx
const [isPending, startTransition] = useTransition();
const handleFilter = (value: string) =>
  startTransition(() => setFilter(value));
```

- Wrap non-urgent state updates in `useTransition`
- Wrap handlers passed to children in `useCallback`

## Code Splitting — Heavy Dependencies

```tsx
const HeavyChart = React.lazy(() => import('./HeavyChart'));
<Suspense fallback={<ChartSkeleton />}>
  <HeavyChart data={data} />
</Suspense>
```

## Class Merging — `cn` Utility

```typescript
import { cn } from '@/shared/lib/cn';

<div className={cn('base-classes', isActive && 'active-class', className)} />
```

```text
BANNED: template literals with manual dedup
BANNED: classnames without tailwind-merge
REQUIRED: cn() for any conditional or prop-merged className
```

## useActionState Pattern (Server Action Forms)

```tsx
'use client'

import { useActionState } from 'react'
import { submitAction } from '../actions'

export function FormComponent() {
  const [state, formAction, isPending] = useActionState(submitAction, { error: undefined })

  return (
    <form action={formAction}>
      <input name="field" required />
      {state.error && <p role="alert">{state.error}</p>}
      <button type="submit" disabled={isPending} aria-busy={isPending}>
        {isPending ? 'Saving…' : 'Save'}
      </button>
    </form>
  )
}
```

**Rules:**

- `<form action={serverAction}>` — NEVER `onSubmit` + `fetch()`
- `useActionState` for pending/error feedback
- "Saving…" copy during mutation — NEVER "Loading…"
