# Anti-Pattern: useeffect-no-deps

## Problem

`useEffect` called without a dependency array — runs on EVERY render.

## Why It's Bad

- Creates infinite render loops when state is set inside the effect
- Causes excessive API calls (fetching on every keystroke, scroll, etc.)
- Makes component behavior unpredictable and hard to debug

## Detection

```bash
grep -n "useEffect(" src/ -r | grep -v "\[\]"
# Inspect results for useEffect without closing array
```

## Bad Example

```tsx
// ❌ Runs on every render
function UserList() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }); // ← no dependency array = infinite loop

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Good Example

```tsx
// ✅ Runs once on mount
function UserList() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []); // ← empty array = runs once

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}

// ✅ Better: use TanStack Query (no useEffect needed)
function UserList() {
  const { data: users = [] } = useQuery({
    queryKey: ['users'],
    queryFn: () => fetch('/api/users').then(r => r.json()),
  });
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

## Stale Closure — Incomplete Dependency Array

A missing dependency array is obvious, but an *incomplete* dependency array is a silent bug.
When a variable from the outer scope is used inside `useEffect` but not listed in deps,
React captures its initial value forever (stale closure).

### Detection (Stale Closure)

```bash
# ESLint rule (if configured): react-hooks/exhaustive-deps
# Manual scan — look for variables used inside useEffect not in the deps array
grep -n "useEffect" src/ -r -A10
```

### Bad Example (Stale Closure)

```tsx
// ❌ Stale closure — userId used inside but not in deps
function UserProfile({ userId }: { userId: string }) {
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setProfile); // userId captured at mount time only
  }, []); // ← WRONG: userId changes are ignored after initial render
}
```

### Good Example (Stale Closure)

```tsx
// ✅ userId in deps — effect re-runs when userId changes
function UserProfile({ userId }: { userId: string }) {
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    const controller = new AbortController();
    fetchUser(userId, { signal: controller.signal }).then(setProfile);
    return () => controller.abort(); // cleanup on userId change or unmount
  }, [userId]); // ← REQUIRED: every closure variable listed
}

// ✅ Best: TanStack Query — handles deps, caching, cleanup automatically
function UserProfile({ userId }: { userId: string }) {
  const { data: profile } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });
}
```

## Rule

BANNED: `useEffect` without a dependency array.
BANNED: `useEffect` with an incomplete dependency array (stale closure) — every variable from the closure that can change MUST be in the deps array.
REQUIRED: Explicit dependency array `[]` (empty) or `[dep1, dep2]` (with all dependencies).
REQUIRED: Enable ESLint rule `react-hooks/exhaustive-deps` to catch incomplete arrays automatically.
PREFERRED: Replace data-fetching `useEffect` with TanStack Query (eliminates deps management entirely).
