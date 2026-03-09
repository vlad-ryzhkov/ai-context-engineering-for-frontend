# Anti-Pattern: empty-catch-block

## Problem

Catching errors and silently swallowing them with an empty `catch` block or `catch(() => {})`.
AI generates these constantly to "handle errors" without actually handling them.

## Why It's Bad

- Silent failures — bugs become invisible, impossible to debug
- User sees no feedback when operations fail (broken UX)
- Error monitoring tools (Sentry, Datadog) never see the error
- Masks root causes — downstream bugs appear unrelated

## Severity

HIGH

## Detection

```bash
grep -rn "catch\s*(\s*)\s*{}\|catch\s*(\s*[a-z_]*\s*)\s*{}\|\.catch\s*(\s*(\s*)\s*=>\s*{}\s*)\|\.catch\s*(\s*(\s*)\s*=>\s*undefined\s*)" src/
```

## Bad Example

```tsx
// ❌ Silent swallow — error vanishes
async function saveUser(data: UserData): Promise<void> {
  try {
    await api.users.update(data);
  } catch (e) {}
}

// ❌ Promise chain with empty catch
api.users.delete(id).catch(() => {});
```

## Good Example

```tsx
// ✅ Log + user feedback
async function saveUser(data: UserData): Promise<boolean> {
  try {
    await api.users.update(data);
    return true;
  } catch (error) {
    logger.error('Failed to save user', { error, userId: data.id });
    toast.error('Could not save changes. Please try again.');
    return false;
  }
}
```

## When Minimal Catch Is Acceptable

```tsx
// ✅ AbortController — expected to throw on abort, safe to ignore
try {
  await fetch(url, { signal: controller.signal });
} catch (error) {
  if (error instanceof DOMException && error.name === 'AbortError') {
    return; // Expected — component unmounted
  }
  throw error; // Re-throw unexpected errors
}
```

## Rule

BANNED: Empty `catch` blocks — `catch (e) {}`, `.catch(() => {})`.
REQUIRED: Every `catch` must either (1) log the error, (2) show user feedback, (3) re-throw, or (4) handle a specific expected error type with a comment explaining why silence is safe.
