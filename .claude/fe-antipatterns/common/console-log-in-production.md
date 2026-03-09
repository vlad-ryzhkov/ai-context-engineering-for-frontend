# Anti-Pattern: console-log-in-production

## Problem

Leaving `console.log` statements in production code.
AI generates `console.log` for debugging and never removes them.

## Why It's Bad

- Leaks internal state, API responses, and user data to browser DevTools
- Performance overhead on high-frequency paths (render loops, scroll handlers)
- Clutters browser console — masks real warnings and errors
- Security risk — may expose tokens, PII, or internal API structure

## Severity

MEDIUM

## Detection

```bash
grep -rn "console\.log\|console\.debug\|console\.info" src/ | grep -v "\.test\.\|\.spec\.\|__tests__"
```

## Bad Example

```tsx
// ❌ Debug logs left in production code
function UserProfile({ userId }: { userId: string }) {
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  console.log('user data:', data);           // ← leaks user data
  console.log('rendering UserProfile');       // ← noise

  return <div>{data?.name}</div>;
}
```

## Good Example

```tsx
// ✅ Use structured logger that respects environment
import { logger } from '@/shared/lib/logger';

function UserProfile({ userId }: { userId: string }) {
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  // Logger is no-op in production, sends to monitoring in staging
  logger.debug('UserProfile loaded', { userId });

  return <div>{data?.name}</div>;
}
```

## Acceptable Uses

- `console.error` / `console.warn` for unexpected runtime errors (prefer structured logger)
- Test files (`.test.ts`, `.spec.ts`) — not shipped to production
- Development-only debug utilities gated by `import.meta.env.DEV`

```tsx
// ✅ Development-only logging
if (import.meta.env.DEV) {
  console.log('Debug:', data);
}
```

## Rule

BANNED: `console.log`, `console.debug`, `console.info` in production source code.
REQUIRED: Use a structured logger or remove debug statements before committing.
ALLOWED: `console.error`/`console.warn` for unexpected errors; `console.log` in test files.
