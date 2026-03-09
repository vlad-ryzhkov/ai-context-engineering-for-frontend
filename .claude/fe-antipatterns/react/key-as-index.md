# Anti-Pattern: key-as-index

## Problem

Using array index as `key` prop in React lists.

## Why It's Bad

- When items are added, removed, or reordered, React uses wrong keys
- Causes incorrect DOM reconciliation → stale state in input fields, animations
- Can cause subtle UI bugs that only appear after mutations

## Detection

```bash
grep -rn "key={index}\|key={i}\b\|\.map((.*,.*index).*key={index" src/
```

## Bad Example

```tsx
// ❌ Index as key
function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map((user, index) => (
        <li key={index}>{user.name}</li>  // ← BANNED
      ))}
    </ul>
  );
}
```

## Good Example

```tsx
// ✅ Stable unique ID as key
function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>  // ← user.id is stable
      ))}
    </ul>
  );
}
```

## When Index is Acceptable

Only when ALL three conditions are true:

1. The list is static (never reordered or filtered)
2. Items have no state (no inputs, no animations)
3. No stable unique ID exists

## Rule

BANNED: `key={index}` or `key={i}` in dynamic lists.
REQUIRED: `key={item.id}` or other stable, unique identifier.
