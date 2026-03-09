# Anti-Pattern: env-variable-misuse

## Problem

Using `process.env` in Vite projects (silently returns `undefined`) or accessing environment variables without validation.
AI copies Node.js patterns (`process.env.API_URL`) into Vite frontends.

## Why It's Bad

- `process.env` is undefined in Vite — no error, just `undefined` propagated silently
- API calls go to `undefined/api/users` — confusing 404 errors
- Missing env vars discovered at runtime in production, not at build time
- No type safety — typos in variable names produce silent failures

## Severity

HIGH

## Detection

```bash
# process.env in Vite project (should be import.meta.env)
grep -rn "process\.env\." src/
# Env vars without VITE_ prefix (won't be exposed to client)
grep -rn "import\.meta\.env\." src/ | grep -v "VITE_\|MODE\|DEV\|PROD\|SSR\|BASE_URL"
```

## Bad Example

```tsx
// ❌ process.env in Vite — always undefined
const API_URL = process.env.API_URL;
const apiKey = process.env.REACT_APP_API_KEY; // CRA pattern, not Vite

// ❌ No validation — silently undefined if .env missing
const config = {
  apiUrl: import.meta.env.VITE_API_URL, // might be undefined
};
```

## Good Example

```tsx
// ✅ Validated env config with type safety
// src/shared/config/env.ts

function requireEnv(key: string): string {
  const value = import.meta.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const env = {
  apiUrl: requireEnv('VITE_API_URL'),
  appName: import.meta.env.VITE_APP_NAME ?? 'My App',
  isDev: import.meta.env.DEV,
  isProd: import.meta.env.PROD,
} as const;
```

```tsx
// ✅ Usage — typed, validated, single source of truth
import { env } from '@/shared/config/env';

const apiClient = axios.create({
  baseURL: env.apiUrl,
});
```

## Vite Env Variable Rules

| Pattern | Works in Vite? | Notes |
|---------|:-:|-------|
| `import.meta.env.VITE_*` | Yes | Must have `VITE_` prefix |
| `import.meta.env.MODE` | Yes | 'development' \| 'production' |
| `import.meta.env.DEV` | Yes | Boolean |
| `import.meta.env.PROD` | Yes | Boolean |
| `process.env.*` | No | Always `undefined` |
| `import.meta.env.API_KEY` | No | Missing `VITE_` prefix — not exposed |

## Rule

BANNED: `process.env` in Vite projects — use `import.meta.env`.
BANNED: Direct `import.meta.env` access scattered across codebase.
REQUIRED: Centralized env config module (`src/shared/config/env.ts`) with validation.
REQUIRED: `VITE_` prefix for all client-exposed environment variables.
