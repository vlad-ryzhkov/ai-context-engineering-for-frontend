# Anti-Pattern: missing-error-boundary

## Problem

Async or lazy-loaded components not wrapped in an Error Boundary.
An unhandled error in any child component crashes the entire React tree.

## Why It's Bad

- One failing component can blank out the entire page
- User sees a broken white screen with no recovery option
- Errors from child components are uncatchable without boundaries

## Detection (React)

Look for `lazy()` or async data components without `<ErrorBoundary>` ancestor:

```bash
grep -rn "React.lazy\|lazy(" src/ | grep -v "ErrorBoundary\|Suspense"
```

## Good Example (React)

```tsx
// ✅ Error boundary at page level
import { Suspense, lazy } from 'react';
import { ErrorBoundary } from 'react-error-boundary';

const UserDashboard = lazy(() => import('./UserDashboard'));

function App() {
  return (
    <ErrorBoundary fallback={<div role="alert">Something went wrong.</div>}>
      <Suspense fallback={<PageSkeleton />}>
        <UserDashboard />
      </Suspense>
    </ErrorBoundary>
  );
}
```

## Vue Note

Vue uses `onErrorCaptured` composable or `errorCaptured` lifecycle hook.
For async components, use `defineAsyncComponent` with `errorComponent` option.

## Rule

BANNED: `React.lazy()` without parent `<ErrorBoundary>`.
REQUIRED: Every async/lazy component has an Error Boundary ancestor.
RECOMMENDED: Use `react-error-boundary` package for production-ready boundaries.
