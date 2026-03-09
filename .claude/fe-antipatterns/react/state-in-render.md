# Anti-Pattern: state-in-render

## Problem

Derived state computed inside the JSX return / render body using `useState` when it should be a computed value.

## Why It's Bad

- Creates unnecessary state — source of bugs when base data changes but derived state doesn't update
- Extra re-render cycle: state update triggers another render
- Adds complexity (who updates the derived state? when?)

## Bad Example

```tsx
// ❌ Derived state stored in useState
function UserList({ users }: { users: User[] }) {
  const [activeUsers, setActiveUsers] = useState<User[]>([]);

  useEffect(() => {
    setActiveUsers(users.filter(u => u.isActive)); // ← extra re-render
  }, [users]);

  return <ul>{activeUsers.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Good Example

```tsx
// ✅ Derived value — plain const or useMemo
function UserList({ users }: { users: User[] }) {
  // Simple: just a const (no memo needed for cheap operations)
  const activeUsers = users.filter(u => u.isActive);

  // Expensive: useMemo
  const sortedActiveUsers = useMemo(
    () => users.filter(u => u.isActive).sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  );

  return <ul>{sortedActiveUsers.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Rule

BANNED: `useState` + `useEffect` pattern to derive values from props or other state.
REQUIRED: Plain const (cheap), `useMemo` (expensive), or `computed` (Vue) for derived values.

## React Compiler (19+)

**If React Compiler is enabled** (`babel-plugin-react-compiler` or `react-compiler-runtime` in dependencies) — plain `const` is sufficient for all derived values. The compiler auto-memoizes computations, making `useMemo` redundant. See `react/unnecessary-memoization.md` for details.
