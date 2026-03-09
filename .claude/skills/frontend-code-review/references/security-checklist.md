# Security Checklist — Frontend Code Review

> Reference for Phase 2 of `/frontend-code-review`.
> Scan **added lines only** in the diff.

## XSS Prevention

| Pattern | Grep Signature | Severity | Recommendation |
|---------|---------------|----------|----------------|
| React raw HTML | `dangerouslySetInnerHTML` | CRITICAL | Use DOMPurify or structured rendering. Never pass user input directly. |
| Vue raw HTML | `v-html` | CRITICAL | Use DOMPurify or text interpolation `{{ }}`. Never bind user input to `v-html`. |
| Direct innerHTML | `\.innerHTML\s*=` | CRITICAL | Use framework rendering. If unavoidable, sanitize with DOMPurify. |
| Document write | `document\.write` | CRITICAL | Remove entirely. Use DOM APIs or framework rendering. |
| Unescaped URL params | `location\.search\|location\.hash` used in rendering | HIGH | Sanitize and validate before rendering. Use `URL` / `URLSearchParams` API. |

## Secrets in Source

| Pattern | Grep Signature | Severity | Recommendation |
|---------|---------------|----------|----------------|
| API keys | `api[_-]?key\s*[:=]\s*['"]` | CRITICAL | Move to environment variable. Use `import.meta.env.VITE_*`. |
| Bearer tokens | `Bearer\s+[A-Za-z0-9\-._~+/]+=*` | CRITICAL | Never hardcode tokens. Use auth flow with httpOnly cookies or secure storage. |
| Passwords | `password\s*[:=]\s*['"][^'"]+['"]` | CRITICAL | Remove immediately. Use environment variables or vault. |
| Private keys | `-----BEGIN (RSA\|EC\|OPENSSH) PRIVATE KEY-----` | CRITICAL | Remove immediately. Must never exist in frontend code. |
| AWS credentials | `AKIA[0-9A-Z]{16}` | CRITICAL | Remove and rotate immediately. |
| Generic secret | `secret\s*[:=]\s*['"][^'"]{8,}['"]` | HIGH | Verify if actual secret. Move to environment variable if so. |

## Insecure Storage

| Pattern | Grep Signature | Severity | Recommendation |
|---------|---------------|----------|----------------|
| Token in localStorage | `localStorage\.setItem.*token\|localStorage\.setItem.*auth` | HIGH | Use httpOnly cookies for auth tokens. localStorage is XSS-accessible. |
| Sensitive data in localStorage | `localStorage\.setItem.*password\|localStorage\.setItem.*secret` | CRITICAL | Never store secrets in localStorage. Use secure server-side sessions. |
| sessionStorage for auth | `sessionStorage\.setItem.*token` | MEDIUM | Prefer httpOnly cookies. sessionStorage is still XSS-accessible. |

## Dynamic Code Execution

| Pattern | Grep Signature | Severity | Recommendation |
|---------|---------------|----------|----------------|
| eval | `\beval\s*\(` | CRITICAL | Remove. Use JSON.parse for data, structured logic for code. |
| new Function | `new\s+Function\s*\(` | CRITICAL | Remove. Use predefined functions. |
| setTimeout with string | `setTimeout\s*\(\s*['"]` | HIGH | Pass a function reference, not a string. |
| setInterval with string | `setInterval\s*\(\s*['"]` | HIGH | Pass a function reference, not a string. |

## Network Security

| Pattern | Grep Signature | Severity | Recommendation |
|---------|---------------|----------|----------------|
| HTTP URL | `http://(?!localhost\|127\.0\.0\.1)` | HIGH | Use HTTPS. HTTP exposes data in transit. |
| CORS wildcard | `Access-Control-Allow-Origin.*\*` | HIGH | Restrict to specific origins. Wildcard disables CORS protection. |
| Fetch without error handling | `fetch\([^)]+\)\s*\.then` without `.catch` | MEDIUM | Add error handling. Unhandled fetch errors hide failures. |
| Disabled SSL verification | `rejectUnauthorized.*false` | CRITICAL | Never disable SSL verification in production code. |
