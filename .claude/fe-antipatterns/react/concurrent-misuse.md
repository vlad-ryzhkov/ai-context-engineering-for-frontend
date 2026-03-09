# Anti-Pattern: concurrent-misuse

## Problem

Misusing `useTransition` and `useDeferredValue` — wrapping fast/synchronous operations, using both together redundantly, or applying transitions where they add no benefit.

## Why It's Bad

- useTransition wrapping fast operations adds overhead without visible benefit
- Combining useTransition + useDeferredValue for the same state is redundant
- Transitions on network requests don't help (Suspense handles that)
- Creates false sense of optimization

## Detection

```bash
grep -rn "useTransition\|useDeferredValue" src/
```

Grep signatures:

- `useTransition` used for simple state updates (no expensive render)
- `useDeferredValue(.*useTransition` — both on same value
- `startTransition` wrapping a fetch call

## Bad Example

```tsx
// ❌ useTransition for a simple boolean toggle — no benefit
function TogglePanel() {
  const [isOpen, setIsOpen] = useState(false);
  const [isPending, startTransition] = useTransition();

  const handleToggle = () => {
    startTransition(() => {
      setIsOpen(!isOpen);
    });
  };

  return <button onClick={handleToggle}>Toggle</button>;
}

// ❌ Both useTransition and useDeferredValue on the same value
function SearchResults({ query }: { query: string }) {
  const [isPending, startTransition] = useTransition();
  const deferredQuery = useDeferredValue(query);

  // Redundant: both defer the same update
  return <ExpensiveList query={deferredQuery} />;
}
```

## Good Example

```tsx
// ✅ useTransition for expensive re-renders (e.g., filtering large list)
function FilterableList({ items }: { items: Item[] }) {
  const [filter, setFilter] = useState('');
  const [filteredItems, setFilteredItems] = useState<Item[]>(items);
  const [isPending, startTransition] = useTransition();

  const handleFilter = (value: string) => {
    setFilter(value); // urgent: update input
    startTransition(() => {
      setFilteredItems(items.filter(item => item.name.includes(value)));
    });
  };

  return (
    <>
      <input value={filter} onChange={(e) => handleFilter(e.target.value)} />
      {isPending && <Spinner />}
      <ItemList items={filteredItems} />
    </>
  );
}

// ✅ useDeferredValue for derived expensive computation
function SearchResults({ query }: { query: string }) {
  const deferredQuery = useDeferredValue(query);
  const isStale = query !== deferredQuery;

  return (
    <div style={{ opacity: isStale ? 0.7 : 1 }}>
      <ExpensiveList query={deferredQuery} />
    </div>
  );
}
```

## Rule

BANNED: `useTransition` wrapping simple/cheap state updates (boolean toggles, single field changes).
BANNED: Using both `useTransition` and `useDeferredValue` on the same value.
REQUIRED: Only use concurrent features when the wrapped render is measurably expensive (>16ms).

## References

- [React useTransition](https://react.dev/reference/react/useTransition)
- [React useDeferredValue](https://react.dev/reference/react/useDeferredValue)
