# Anti-Pattern: missing-usecallback

## Problem

Event handler functions recreated on every render and passed as props to memoized child components.

## Why It's Bad

- Defeats `React.memo` — child re-renders even though props are "the same"
- Breaks referential equality checks in `useEffect` dependencies

## Detection

Manual review: look for inline function definitions in JSX when children use `React.memo`.

## Bad Example

```tsx
// ❌ New function reference on every render
const ItemList = React.memo(({ onDelete }: { onDelete: (id: string) => void }) => (
  <ul>{items.map(item => <li key={item.id}><button onClick={() => onDelete(item.id)}>Delete</button></li>)}</ul>
));

function Parent() {
  const [items, setItems] = useState([...]);
  // ❌ New function on every Parent render → ItemList always re-renders
  const handleDelete = (id: string) => setItems(prev => prev.filter(i => i.id !== id));
  return <ItemList onDelete={handleDelete} />;
}
```

## Good Example

```tsx
// ✅ Stable reference with useCallback
function Parent() {
  const [items, setItems] = useState([...]);
  const handleDelete = useCallback(
    (id: string) => setItems(prev => prev.filter(i => i.id !== id)),
    [] // setItems is stable, no deps needed
  );
  return <ItemList onDelete={handleDelete} />;
}
```

## Rule

REQUIRED: Wrap event handlers in `useCallback` when passed to `React.memo` children.
FORBIDDEN: Premature `useCallback` on handlers not passed to memoized children (adds cost with no benefit).

## React Compiler (19+)

**If React Compiler is enabled** (`babel-plugin-react-compiler` or `react-compiler-runtime` in dependencies) — this anti-pattern is **OBSOLETE**. The compiler auto-memoizes all callbacks. Manual `useCallback` becomes redundant noise. See `react/unnecessary-memoization.md` instead.
