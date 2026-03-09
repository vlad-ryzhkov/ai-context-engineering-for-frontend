# Anti-Pattern: sensitive-data-in-storage

## Problem

Storing authentication tokens, passwords, or sensitive data in `localStorage` or `sessionStorage`.
AI-generated auth tutorials almost always use `localStorage.setItem('token', ...)`.

## Why It's Bad

- `localStorage`/`sessionStorage` is accessible to ANY JavaScript on the page
- A single XSS vulnerability exposes all stored tokens to the attacker
- Tokens persist across tabs/sessions in localStorage — wider attack window
- No expiration mechanism — stolen tokens remain valid until server-side revocation

## Severity

HIGH

## Detection

```bash
grep -rn "localStorage\.setItem.*token\|localStorage\.setItem.*auth\|localStorage\.setItem.*password\|localStorage\.setItem.*secret\|sessionStorage\.setItem.*token" src/
```

## Bad Example

```tsx
// ❌ JWT in localStorage — XSS-accessible
async function login(credentials: Credentials): Promise<void> {
  const { token } = await authApi.login(credentials);
  localStorage.setItem('access_token', token);
}

// ❌ Reading token from localStorage for API calls
function getAuthHeader(): Record<string, string> {
  const token = localStorage.getItem('access_token');
  return { Authorization: `Bearer ${token}` };
}
```

## Good Example

```tsx
// ✅ Auth tokens in httpOnly cookies — not accessible via JS
async function login(credentials: Credentials): Promise<void> {
  // Server sets httpOnly cookie in response
  await authApi.login(credentials);
  // No client-side token storage needed
}

// ✅ Cookie sent automatically with requests
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true, // sends httpOnly cookies
});
```

## When localStorage Is Acceptable

- UI preferences (theme, language, sidebar collapsed)
- Non-sensitive cached data (last search query, pagination state)
- Feature flags or A/B test assignments

## Rule

BANNED: Storing auth tokens, passwords, secrets, or PII in `localStorage`/`sessionStorage`.
REQUIRED: Use httpOnly cookies for authentication tokens (set by server, not accessible via JS).
ALLOWED: `localStorage` for non-sensitive UI preferences only.
