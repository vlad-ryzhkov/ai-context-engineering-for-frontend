# Anti-Pattern: open-redirect

## Problem

Redirecting users to a URL taken directly from query parameters or user input without validation.
AI generates `window.location.href = params.get('redirect')` for post-login redirects.

## Why It's Bad

- Attacker crafts link: `app.com/login?redirect=https://evil.com/phishing`
- User logs in, gets redirected to attacker's phishing page
- Phishing page looks identical to real app — user enters credentials again
- Bypasses email/link reputation systems because the initial domain is trusted

## Severity

HIGH

## Detection

```bash
grep -rn "location\.href\s*=.*param\|location\.replace.*param\|location\.assign.*param\|window\.open.*param\|router\.push.*param.*get\|navigate.*param.*get" src/
```

## Bad Example

```tsx
// ❌ Unvalidated redirect from URL parameter
function LoginCallback() {
  const params = new URLSearchParams(window.location.search);
  const redirectUrl = params.get('redirect') || '/';

  useEffect(() => {
    // Attacker: ?redirect=https://evil.com
    window.location.href = redirectUrl;
  }, [redirectUrl]);

  return <Spinner />;
}
```

## Good Example

```tsx
// ✅ Validate redirect is same-origin relative path
function sanitizeRedirectUrl(url: string): string {
  // Only allow relative paths starting with /
  if (url.startsWith('/') && !url.startsWith('//')) {
    return url;
  }
  return '/'; // Fallback to home
}

function LoginCallback() {
  const params = new URLSearchParams(window.location.search);
  const redirectUrl = sanitizeRedirectUrl(params.get('redirect') || '/');

  useEffect(() => {
    window.location.href = redirectUrl;
  }, [redirectUrl]);

  return <Spinner />;
}
```

## Comprehensive Validation

```tsx
// ✅ Allowlist + URL parsing for stricter validation
const ALLOWED_HOSTS = [
  window.location.hostname,
  'app.example.com',
  'docs.example.com',
];

function isAllowedRedirect(url: string): boolean {
  // Allow relative paths
  if (url.startsWith('/') && !url.startsWith('//')) {
    return true;
  }

  try {
    const parsed = new URL(url, window.location.origin);
    return ALLOWED_HOSTS.includes(parsed.hostname);
  } catch {
    return false;
  }
}
```

## Rule

BANNED: `window.location.href = userInput` without validation.
REQUIRED: Validate redirect URLs are relative paths (`/path`) or belong to an allowed-host list.
REQUIRED: Reject URLs starting with `//`, `http://`, `https://` unless host is explicitly allowlisted.
