# Anti-Pattern: missing-loading-state

## Problem

Async component that fetches data but does not render a loading indicator.
The user sees a blank or partial UI while data is being fetched.

## Why It's Bad

- Perceived performance is terrible (blank screen feels broken)
- Cumulative Layout Shift (CLS) when data appears suddenly
- Screen readers announce nothing (accessibility failure)

## Detection

```bash
# Find async components without loading state
grep -rn "useQuery\|useSWR\|useQuery(" src/ | grep -v "isLoading\|isPending"
```

## Bad Example (React)

```tsx
// ❌ No loading state
function UserList() {
  const { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
  return (
    <ul>
      {data?.map((user) => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

## Good Example (React)

```tsx
// ✅ All 4 states present
function UserList() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  });

  if (isLoading) return <UserListSkeleton />;
  if (isError) return <ErrorState message="Failed to load users" />;
  if (!data?.length) return <EmptyState message="No users found" />;

  return (
    <ul>
      {data.map((user) => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

## Good Example (Vue)

```vue
<template>
  <UserListSkeleton v-if="isLoading" />
  <ErrorState v-else-if="isError" message="Failed to load users" />
  <EmptyState v-else-if="isEmpty" message="No users found" />
  <ul v-else>
    <li v-for="user in data" :key="user.id">{{ user.name }}</li>
  </ul>
</template>
```

## Rule

BANNED: Async component that renders data without an explicit loading state branch.
REQUIRED: All 4 states (loading / error / empty / success) — mutually exclusive.
