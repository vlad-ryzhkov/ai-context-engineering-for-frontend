# Anti-Pattern: hardcoded-api-urls

## Problem

API base URL or endpoint URL is hardcoded directly in the component or hook.

## Why It's Bad

- Breaks across environments (dev / staging / prod)
- Cannot be overridden in tests without modifying source code
- Security risk if internal URLs leak to public bundle

## Detection

```bash
grep -rn "https://\|http://localhost\|http://api\." src/
```

## Bad Example

```typescript
// ❌ Hardcoded URL
async function fetchUsers() {
  const response = await fetch('https://api.myapp.com/users');
  return response.json();
}
```

## Good Example

```typescript
// ✅ Environment variable
const BASE_URL = import.meta.env.VITE_API_BASE_URL;

async function fetchUsers() {
  const response = await fetch(`${BASE_URL}/users`);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json();
}
```

```env
# .env.local (not committed)
VITE_API_BASE_URL=http://localhost:3000

# .env.production
VITE_API_BASE_URL=https://api.myapp.com
```

## Rule

BANNED: Hardcoded `http://` or `https://` URLs in `src/` code.
REQUIRED: `import.meta.env.VITE_API_BASE_URL` (Vite) or equivalent env variable.
