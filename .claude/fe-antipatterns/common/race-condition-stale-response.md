# Anti-Pattern: race-condition-stale-response

## Problem

Multiple async requests fired in sequence where a slower earlier response overwrites a faster later response.
Common in search-as-you-type, filter changes, and tab switching.

## Why It's Bad

- User types "abc" → requests for "a", "ab", "abc" fire in order
- Response for "a" arrives AFTER "abc" → UI shows results for "a" instead of "abc"
- Non-deterministic — works in dev, fails in production under load
- Users see data that doesn't match their current input/selection

## Severity

HIGH

## Detection

```bash
# Sequential state updates from async without guard
grep -rn "set[A-Z].*await\|\.value\s*=.*await" src/ | grep -v "AbortController\|signal\|abort\|requestId\|stale"
```

## Bad Example

```tsx
// ❌ Stale response overwrites fresh one
function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Result[]>([]);

  useEffect(() => {
    if (query) {
      // Request for "a" might resolve AFTER request for "abc"
      searchApi(query).then((data) => setResults(data));
    }
  }, [query]);

  return (
    <>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <ResultList results={results} />
    </>
  );
}
```

## Good Example (AbortController)

```tsx
// ✅ AbortController cancels previous request
function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Result[]>([]);

  useEffect(() => {
    if (!query) {
      setResults([]);
      return;
    }

    const controller = new AbortController();

    searchApi(query, { signal: controller.signal })
      .then((data) => setResults(data))
      .catch((error) => {
        if (error.name !== 'AbortError') throw error;
      });

    return () => controller.abort();
  }, [query]);

  return (
    <>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <ResultList results={results} />
    </>
  );
}
```

## Good Example (TanStack Query)

```tsx
// ✅ TanStack Query handles race conditions automatically
function Search() {
  const [query, setQuery] = useState('');

  const { data: results = [] } = useQuery({
    queryKey: ['search', query],
    queryFn: ({ signal }) => searchApi(query, { signal }),
    enabled: !!query,
  });

  return (
    <>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <ResultList results={results} />
    </>
  );
}
```

## Rule

BANNED: Sequential async calls without race condition prevention (AbortController or request ID).
REQUIRED: Use `AbortController` to cancel previous request on new trigger, OR use TanStack Query (handles automatically).
