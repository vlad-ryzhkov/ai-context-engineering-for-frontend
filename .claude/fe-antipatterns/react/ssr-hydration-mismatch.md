# Anti-Pattern: ssr-hydration-mismatch

## Problem

Using browser-only APIs (`window`, `document`, `localStorage`, `navigator`) during SSR or initial render, or using non-deterministic values (`Date.now()`, `Math.random()`, `crypto.randomUUID()`) that differ between server and client.

## Why It's Bad

- React/Next.js throws hydration mismatch errors
- Content flickers on first load
- SEO-rendered HTML doesn't match client-rendered output
- Can cause entire page to re-render client-side, negating SSR benefits

## Detection

```bash
grep -rn "typeof window\|document\.\|localStorage\.\|Date\.now\|Math\.random\|new Date()" src/
```

Grep signatures:

- `typeof window` in render body (not in useEffect)
- `document\.` outside useEffect/event handlers
- `localStorage\.` in component body
- `Date\.now\(\)` or `Math\.random\(\)` in JSX
- `new Date\(\)` in render path (not in useEffect)

## Bad Example

```tsx
// ❌ window access during SSR causes hydration mismatch
export function UserGreeting() {
  const isMobile = window.innerWidth < 768;
  const timestamp = Date.now();

  return (
    <div>
      {isMobile ? <MobileLayout /> : <DesktopLayout />}
      <span>Rendered at: {timestamp}</span>
    </div>
  );
}
```

## Good Example

```tsx
// ✅ Guard browser APIs behind useEffect + state
export function UserGreeting() {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);

    const handler = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);

  return (
    <div>
      {isMobile ? <MobileLayout /> : <DesktopLayout />}
    </div>
  );
}
```

## Rule

BANNED: Direct access to `window`, `document`, `localStorage`, `navigator` in component render body.
BANNED: `Date.now()`, `Math.random()`, `crypto.randomUUID()` in JSX or render path.
REQUIRED: Guard browser-only APIs behind `useEffect` + state, or use `typeof window !== 'undefined'` checks.

## References

- [React Hydration Docs](https://react.dev/reference/react-dom/client/hydrateRoot#handling-different-client-and-server-content)
- [Next.js Hydration Errors](https://nextjs.org/docs/messages/react-hydration-error)
