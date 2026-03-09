# Anti-Pattern: usestate-object-mutation

## Problem

Directly mutating a state object field instead of calling `setState` with a new object.

## Why It's Bad

- React does NOT detect the mutation — component does not re-render
- Stale state causes UI to drift from actual data
- Debugging is impossible — mutation leaves no trace

## Detection

Manual review — look for patterns where state is set via field assignment:

```bash
grep -rn "\.\w\+ = " src/ | grep -v "current\.\|ref\.\|const \|let "
```

## Bad Example

```tsx
// ❌ Direct mutation — React won't re-render
const [user, setUser] = useState({ name: 'Alice', role: 'admin' });

function updateRole(newRole: string) {
  user.role = newRole; // ← BANNED: state mutation without setState
  setUser(user);       // ← Same reference, React skips re-render
}
```

## Good Example

```tsx
// ✅ New object via spread
const [user, setUser] = useState({ name: 'Alice', role: 'admin' });

function updateRole(newRole: string) {
  setUser((prev) => ({ ...prev, role: newRole })); // ← New object reference
}
```

## Rule

BANNED: `state.field = value` followed by `setState(state)` with the same reference.
REQUIRED: `setState(prev => ({ ...prev, field: newValue }))` — always create new object.
