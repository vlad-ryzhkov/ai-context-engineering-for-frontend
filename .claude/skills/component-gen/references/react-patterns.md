# React Component Patterns

## Component Template (with TanStack Query)

```tsx
// UserList.tsx
import { useQuery } from '@tanstack/react-query';
import type { UserListProps } from './UserList.types';

export default function UserList({ title }: UserListProps) {
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  });

  if (isLoading) {
    return <UserListSkeleton />;
  }

  if (isError) {
    return (
      <div role="alert" className="rounded-lg bg-red-50 p-4 text-red-800">
        <p>Failed to load users. Please try again.</p>
        <button onClick={() => refetch()} className="mt-2 text-sm underline">
          Retry
        </button>
      </div>
    );
  }

  if (!data || data.length === 0) {
    return (
      <div className="py-12 text-center text-gray-500">
        <p>No users found.</p>
      </div>
    );
  }

  return (
    <section aria-label={title}>
      <h2 className="text-xl font-semibold">{title}</h2>
      <ul className="mt-4 space-y-2">
        {data.map((user) => (
          <li key={user.id} className="rounded border p-3">
            {user.name}
          </li>
        ))}
      </ul>
    </section>
  );
}
```

## Types Template

```typescript
// UserList.types.ts
export interface UserListProps {
  title: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
}
```

## Skeleton Component

```tsx
// UserListSkeleton.tsx
export function UserListSkeleton() {
  return (
    <div role="status" aria-label="Loading users" className="space-y-2">
      {Array.from({ length: 3 }).map((_, i) => (
        <div key={i} className="h-12 animate-pulse rounded bg-gray-200" />
      ))}
      <span className="sr-only">Loading...</span>
    </div>
  );
}
```

## Barrel Export

```typescript
// index.ts
export { default } from './UserList';
export type { UserListProps, User } from './UserList.types';
```

## Hook Pattern (custom hook for data fetching)

```typescript
// useUsers.ts
import { useQuery } from '@tanstack/react-query';
import type { User } from './UserList.types';

export function useUsers() {
  return useQuery<User[]>({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await fetch('/api/users');
      if (!response.ok) throw new Error('Failed to fetch users');
      return response.json() as Promise<User[]>;
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}
```

## Key Rules

- Function components only (no class components)
- `useCallback` for event handlers passed as props
- `useMemo` only when computation is measurably expensive
- Dependency arrays in `useEffect` — explicit and complete
- `key` in lists — stable unique ID, never `index`
- Error Boundary wraps async/lazy components at the page level

```typescript
// BANNED: useEffect to sync derived state
// BAD
useEffect(() => {
  setFiltered(items.filter(i => i.active));
}, [items]);

// GOOD: derive during render with useMemo
const filtered = useMemo(() => items.filter(i => i.active), [items]);
```

## useEffect Cleanup

Any `useEffect` with a fetch, timer, subscription, or event listener MUST return a cleanup function.

```tsx
// ✅ Fetch with AbortController (prevents state update after unmount)
useEffect(() => {
  const controller = new AbortController();
  fetch(url, { signal: controller.signal })
    .then((r) => r.json())
    .then(setData)
    .catch((err) => {
      if (err.name !== 'AbortError') setError(err);
    });
  return () => controller.abort();
}, [url]);

// ✅ Timer cleanup
useEffect(() => {
  const id = setInterval(() => setTick((t) => t + 1), 1000);
  return () => clearInterval(id);
}, []);

// ✅ Event listener cleanup
useEffect(() => {
  const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
  window.addEventListener('keydown', handler);
  return () => window.removeEventListener('keydown', handler);
}, [onClose]);
```

```text
BANNED: useEffect with fetch and no AbortController cleanup — causes setState on unmounted component.
BANNED: useEffect with setInterval/setTimeout and no clearInterval/clearTimeout return.
BANNED: useEffect with addEventListener and no removeEventListener return.
NOTE: TanStack Query handles cleanup automatically — useEffect + fetch is only for non-query side effects.
```

## Form Handling

Use `react-hook-form` for all forms. It avoids per-field `useState`, provides built-in validation,
and integrates with Zod via `@hookform/resolvers`.

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation } from '@tanstack/react-query';

const loginSchema = z.object({
  email: z.string().email('Valid email required'),
  password: z.string().min(8, 'Min 8 characters'),
});
type LoginForm = z.infer<typeof loginSchema>;

export default function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginForm>({ resolver: zodResolver(loginSchema) });

  const { mutate: login, isError } = useMutation({
    mutationFn: (data: LoginForm) =>
      fetch('/api/auth/login', { method: 'POST', body: JSON.stringify(data) }),
  });

  return (
    <form data-testid="login-form" onSubmit={handleSubmit((data) => login(data))}>
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" type="email" data-testid="email-input" {...register('email')} />
        {errors.email && <p role="alert" className="text-sm text-red-600">{errors.email.message}</p>}
      </div>
      <div>
        <label htmlFor="password">Password</label>
        <input id="password" type="password" data-testid="password-input" {...register('password')} />
        {errors.password && <p role="alert" className="text-sm text-red-600">{errors.password.message}</p>}
      </div>
      <button type="submit" disabled={isSubmitting} data-testid="submit-button">
        {isSubmitting ? 'Signing in…' : 'Sign in'}
      </button>
      {isError && <p role="alert" className="text-red-600">Sign-in failed. Check your credentials and try again.</p>}
    </form>
  );
}
```

```text
BANNED: Multiple useState per form field — use react-hook-form.
BANNED: Form submission without loading/error/success states.
REQUIRED: Every input has an associated <label> (htmlFor or wrapping label).
REQUIRED: Errors displayed with role="alert" for screen reader announcement.
REQUIRED: Zod schema for validation — no inline regex or manual string checks.
```

### INP — Interaction to Next Paint

- Wrap non-urgent state updates (e.g. filter/search on input) in `useTransition` to keep
  the UI responsive:

  ```tsx
  const [isPending, startTransition] = useTransition();
  const handleFilter = (value: string) =>
    startTransition(() => setFilter(value));
  ```

- Use `useDeferredValue` for expensive computations on incoming data (filtering, search results):

  ```tsx
  // useTransition — wraps state UPDATES (user-triggered actions)
  // useDeferredValue — wraps VALUES that are expensive to process (incoming data)
  const deferredFilter = useDeferredValue(filter);
  const filtered = useMemo(
    () => items.filter((i) => i.name.toLowerCase().includes(deferredFilter.toLowerCase())),
    [items, deferredFilter],
  );
  const isStale = filter !== deferredFilter; // show dimming while deferred
  ```

- Wrap handlers passed to child components in `useCallback` to avoid unnecessary
  re-renders.

### Code Splitting — Heavy Dependencies

- `React.lazy` + `<Suspense>` for any component that imports a library > ~50 kB:

  ```tsx
  const HeavyChart = React.lazy(() => import('./HeavyChart'));
  // Use the component's standard Loading skeleton as fallback
  <Suspense fallback={<ChartSkeleton />}>
    <HeavyChart data={data} />
  </Suspense>
  ```

## State Management

```typescript
// Local: useState
const [isOpen, setIsOpen] = useState(false);

// Derived state: useMemo (not useState)
const filteredItems = useMemo(
  () => items.filter((item) => item.active),
  [items]
);

// Server state: TanStack Query (not useState)
const { data } = useQuery({ queryKey: ['items'], queryFn: fetchItems });

// Global client state: Zustand
import { useStore } from '@/shared/store';
const user = useStore((state) => state.user);
```

## Class Merging — `cn` Utility

Always use `cn()` (clsx + tailwind-merge) for conditional class composition.

Install: `clsx` + `tailwind-merge`, then create `src/shared/lib/cn.ts`:

```typescript
// src/shared/lib/cn.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

Usage in component:

```tsx
<div className={cn('base-classes', isActive && 'active-class', className)} />
```

```text
BANNED: template literals with manual dedup — `base ${condition ? 'a' : ''}`
BANNED: classnames without tailwind-merge (produces duplicate Tailwind class conflicts)
REQUIRED: cn() for any conditional or prop-merged className
```

## Optimistic Mutation Pattern (useMutation + rollback)

Use when the component contains a write action (like, follow, save, delete, submit).

```tsx
// LikeButton.tsx
import { useMutation, useQueryClient } from '@tanstack/react-query';

interface LikeButtonProps {
  postId: string;
  initialLiked: boolean;
  initialCount: number;
}

export default function LikeButton({ postId, initialLiked, initialCount }: LikeButtonProps) {
  const queryClient = useQueryClient();

  const { mutate: toggleLike, isPending } = useMutation({
    mutationFn: (liked: boolean) => fetch(`/api/posts/${postId}/like`, {
      method: liked ? 'DELETE' : 'POST',
    }),

    // 1. Snapshot + optimistic update
    onMutate: async (liked) => {
      await queryClient.cancelQueries({ queryKey: ['post', postId] });
      const snapshot = queryClient.getQueryData(['post', postId]);

      queryClient.setQueryData(['post', postId], (old: { liked: boolean; likeCount: number }) => ({
        ...old,
        liked: !liked,
        likeCount: liked ? old.likeCount - 1 : old.likeCount + 1,
      }));

      return { snapshot };
    },

    // 2. Rollback on error
    onError: (_err, _liked, context) => {
      if (context?.snapshot) {
        queryClient.setQueryData(['post', postId], context.snapshot);
      }
    },

    // 3. Sync with server truth
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['post', postId] });
    },
  });

  return (
    <button
      data-testid="like-button"
      type="button"
      aria-label={initialLiked ? 'Unlike post' : 'Like post'}
      aria-pressed={initialLiked}
      disabled={isPending}
      onClick={() => toggleLike(initialLiked)}
      className={cn(
        'flex items-center gap-1 rounded-full px-3 py-1 text-sm transition-colors',
        initialLiked ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-600',
        isPending && 'opacity-50 cursor-not-allowed',
      )}
    >
      {isPending ? (
        <span aria-hidden="true" className="size-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
      ) : (
        <span aria-hidden="true">{initialLiked ? '♥' : '♡'}</span>
      )}
      <span className="tabular-nums">{initialCount}</span>
    </button>
  );
}
```

```text
REQUIRED: onMutate → snapshot → optimistic update
REQUIRED: onError → restore snapshot (rollback)
REQUIRED: onSettled → invalidateQueries (server sync)
REQUIRED: button disabled + inline spinner during isPending
REQUIRED: "Saving…" / "Liking…" copy — NEVER "Loading…" for mutations
BANNED: full loading overlay during mutation
BANNED: no rollback on error
```
