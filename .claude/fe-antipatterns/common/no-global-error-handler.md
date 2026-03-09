# Anti-Pattern: no-global-error-handler

## Problem

Application has no top-level error boundary or global error handler.
Unhandled errors crash the entire app with a white screen — no recovery, no logging.

## Why It's Bad

- Single unhandled error in any component takes down the entire UI
- Users see blank white page with no explanation or recovery option
- Errors go unreported — no monitoring, no Sentry/Datadog alerts
- Promise rejections vanish silently without `unhandledrejection` handler

## Severity

HIGH

## Detection

```bash
# React: Check for ErrorBoundary at app level
grep -rn "ErrorBoundary\|componentDidCatch\|getDerivedStateFromError" src/app/
# Vue: Check for errorHandler
grep -rn "app\.config\.errorHandler\|onErrorCaptured" src/app/
# Global handlers
grep -rn "window\.onerror\|addEventListener.*error\|addEventListener.*unhandledrejection" src/
```

## Bad Example (React)

```tsx
// ❌ No error boundary — any error = white screen
function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/users" element={<Users />} />
      </Routes>
    </Router>
  );
}
```

## Good Example (React)

```tsx
// ✅ Global ErrorBoundary + route-level boundaries
import { ErrorBoundary } from 'react-error-boundary';

function GlobalFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <h1>Something went wrong</h1>
      <p>Please try refreshing the page.</p>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

function App() {
  return (
    <ErrorBoundary
      FallbackComponent={GlobalFallback}
      onError={(error, info) => {
        logger.error('Unhandled error', { error, componentStack: info.componentStack });
      }}
    >
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/users" element={
            <ErrorBoundary FallbackComponent={RouteFallback}>
              <Users />
            </ErrorBoundary>
          } />
        </Routes>
      </Router>
    </ErrorBoundary>
  );
}
```

## Good Example (Vue)

```typescript
// ✅ Global error handler in app setup
const app = createApp(App);

app.config.errorHandler = (error, instance, info) => {
  logger.error('Vue error', { error, info });
};

// ✅ Also handle unhandled promise rejections
window.addEventListener('unhandledrejection', (event) => {
  logger.error('Unhandled promise rejection', { reason: event.reason });
});

app.mount('#app');
```

## Error Handler Checklist

| Handler | Purpose | Framework |
|---------|---------|-----------|
| `ErrorBoundary` (app root) | Catch render errors, show fallback | React |
| `ErrorBoundary` (per route) | Isolate route-level failures | React |
| `app.config.errorHandler` | Catch all Vue component errors | Vue |
| `onErrorCaptured` | Catch errors in subtree | Vue |
| `window.onerror` | Catch uncaught JS exceptions | Both |
| `unhandledrejection` listener | Catch unhandled promise rejections | Both |

## Rule

REQUIRED: App-level error boundary (React: `ErrorBoundary`, Vue: `app.config.errorHandler`).
REQUIRED: `window.addEventListener('unhandledrejection', ...)` for async errors.
REQUIRED: Error fallback UI must show user-friendly message with recovery action.
REQUIRED: All caught errors must be sent to monitoring (Sentry, Datadog, custom logger).
