# Anti-Pattern: missing-error-state

## Problem

Async component that fetches data but does not handle fetch failures.
When the API returns an error, the component shows nothing or crashes.

## Detection

```bash
grep -rn "useQuery\|useSWR" src/ | grep -v "isError\|error"
```

## Bad Example

```tsx
// ❌ No error state
function UserList() {
  const { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
  return <ul>{data?.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Good Example

```tsx
// ✅ Error state with retry
function UserList() {
  const { data, isLoading, isError, refetch } = useQuery({...});
  if (isLoading) return <Skeleton />;
  if (isError) return (
    <div role="alert">
      <p>Failed to load. <button onClick={() => refetch()}>Retry</button></p>
    </div>
  );
  return <ul>{data?.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Rule

BANNED: Async component without error state branch.
REQUIRED: `role="alert"` error state with user-friendly message and retry action.
