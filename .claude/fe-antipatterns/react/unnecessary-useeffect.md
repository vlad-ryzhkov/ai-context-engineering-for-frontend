# Anti-Pattern: unnecessary-useeffect

## Problem

`useEffect` used to compute derived state or fetch data when better alternatives exist.
Distinct from `useeffect-no-deps.md` (which covers missing dependency array).

## Why It's Bad

- Extra render cycle: state updates inside useEffect cause a re-render after the initial render
- Race conditions in data fetching without cancellation logic
- Stale closure bugs when dependencies are incomplete
- Violates React's "you might not need an effect" guidance

## Detection

```bash
# useEffect that sets state based on other state (derived state)
grep -rn "useEffect" src/ -A5 | grep "setState\|set[A-Z]"
```

## Bad Example — Derived State

```tsx
// ❌ useEffect to compute derived state
function ProductList({ products }: { products: Product[] }) {
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    setFilteredProducts(products.filter(p => p.name.includes(search)));
  }, [products, search]); // unnecessary re-render

  return <ul>{filteredProducts.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}
```

## Good Example — Derived State

```tsx
// ✅ useMemo — no extra render, computed inline
function ProductList({ products }: { products: Product[] }) {
  const [search, setSearch] = useState('');

  const filteredProducts = useMemo(
    () => products.filter(p => p.name.includes(search)),
    [products, search]
  );

  return <ul>{filteredProducts.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}
```

## Bad Example — Data Fetching

```tsx
// ❌ useEffect for data fetching — manual loading/error/cleanup
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    fetchUser(userId)
      .then(data => { if (!cancelled) setUser(data); })
      .catch(err => { if (!cancelled) setError(err); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [userId]);
}
```

## Good Example — Data Fetching

```tsx
// ✅ TanStack Query — handles loading, error, caching, cancellation
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });
}
```

## Rule

BANNED: `useEffect` + `setState` for values computable from existing state/props — use `useMemo`.
BANNED: `useEffect` for data fetching in components — use TanStack Query or a data-fetching library.
ALLOWED: `useEffect` for genuine side effects: subscriptions, DOM measurements, third-party library init.
