# Anti-Pattern: optimistic-update-no-rollback

## Problem

Optimistic UI update (immediately showing the assumed result) without rolling back on API error.

## Why It's Bad

- If the mutation fails, UI shows data that doesn't match server state
- User thinks the action succeeded when it didn't
- No way to recover without full page refresh

## Good Example (TanStack Query useMutation)

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  // ✅ Optimistic update
  onMutate: async (newData) => {
    await queryClient.cancelQueries({ queryKey: ['user', userId] });
    const previousUser = queryClient.getQueryData(['user', userId]);
    queryClient.setQueryData(['user', userId], newData);
    return { previousUser }; // ← snapshot for rollback
  },
  // ✅ Rollback on error
  onError: (err, newData, context) => {
    queryClient.setQueryData(['user', userId], context?.previousUser);
  },
  // ✅ Always refetch to sync with server
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['user', userId] });
  },
});
```

## Rule

BANNED: Optimistic update via `queryClient.setQueryData` without `onError` rollback.
REQUIRED: `onMutate` saves snapshot → `onError` restores it → `onSettled` invalidates cache.
