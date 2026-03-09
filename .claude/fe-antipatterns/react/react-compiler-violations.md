# Anti-Pattern: react-compiler-violations

## Problem

Code patterns that break React Compiler's automatic memoization: mutations during render, ref reads in render body, and non-idempotent render functions.

## Why It's Bad

- React Compiler assumes render functions are **pure and idempotent** — violations produce incorrect memoization or silent bugs
- Mutating objects during render breaks compiler's value tracking — cached results become stale
- Reading `ref.current` during render is a side effect — compiler cannot safely cache the component output
- Non-idempotent renders (Math.random, Date.now in JSX) produce different results on re-render vs cached render

## Detection

```bash
# Mutation in render body (outside useEffect/handlers)
grep -rn '\.push(\|\.splice(\|\.sort(\|\.reverse(' src/ --include='*.tsx'

# ref.current read in render (outside useEffect/handlers)
grep -rn 'ref\.current' src/ --include='*.tsx'

# Direct object field mutation
grep -rn '\.\w\+ = ' src/ --include='*.tsx'
```

Manual review: confirm matches are in the **render body** (not inside `useEffect`, event handlers, or callbacks).

## Applicability

**All React 19+ projects.** These patterns are bugs regardless of whether React Compiler is enabled — they violate React's rules of rendering. React Compiler simply makes the bugs more visible.

## Bad Example

```tsx
// ❌ Mutation during render
function UserList({ users }: { users: User[] }) {
  // Mutates the prop array — breaks React Compiler memoization
  users.sort((a, b) => a.name.localeCompare(b.name));
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}

// ❌ ref.current read in render
function AutoFocusInput() {
  const inputRef = useRef<HTMLInputElement>(null);
  // Side effect: reading ref in render body
  const width = inputRef.current?.offsetWidth ?? 0;
  return <input ref={inputRef} style={{ minWidth: width }} />;
}

// ❌ Non-idempotent render
function Greeting() {
  return <p>Rendered at {Date.now()}</p>; // Different result each render
}
```

## Good Example

```tsx
// ✅ Create sorted copy — no mutation
function UserList({ users }: { users: User[] }) {
  const sorted = [...users].sort((a, b) => a.name.localeCompare(b.name));
  return <ul>{sorted.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}

// ✅ ref.current in useEffect
function AutoFocusInput() {
  const inputRef = useRef<HTMLInputElement>(null);
  const [width, setWidth] = useState(0);

  useEffect(() => {
    if (inputRef.current) {
      setWidth(inputRef.current.offsetWidth);
    }
  }, []);

  return <input ref={inputRef} style={{ minWidth: width }} />;
}

// ✅ Timestamp via state, set in effect
function Greeting() {
  const [timestamp, setTimestamp] = useState<number>(0);
  useEffect(() => { setTimestamp(Date.now()); }, []);
  return <p>Rendered at {timestamp}</p>;
}
```

## Rule

BANNED: Mutating arrays/objects in render body (`.push()`, `.splice()`, `.sort()`, `.reverse()`, direct field assignment).
BANNED: Reading `ref.current` in render body — move to `useEffect` or event handlers.
BANNED: Non-idempotent expressions in JSX (`Date.now()`, `Math.random()`, `crypto.randomUUID()`).
REQUIRED: Create copies before mutation (`[...arr].sort()`, `{...obj, field: value}`).
