# Quality Gates: SPA (React / Vue)

## Mandatory Checks

### 1. State Coverage (`--type feature`)

```bash
# React
grep -n "isLoading\|isError\|\.length === 0\|isEmpty" {component-file}
# Vue
grep -n "isLoading\|isError\|isEmpty" {component-file}
```

All 4 branches required. Missing branch = FAIL.

**`--type ui`:** No `useQuery`, `useFetch`, store imports, or async logic allowed.

### 2. TypeScript Strict

```bash
grep -n ": any\b\|as any\b" {output-path}/
grep -n "\w\+\[\w\+\]\.\w\+" {component-file}  # unsafe index access
```

- `: any` / `as any` = CRITICAL → auto-fix or BLOCKER
- Unsafe index access (`arr[i].prop`) = BLOCKER → use `arr[i]?.prop`
- Optional props: use `value?: T` (not `value: T | undefined`)

#### Discriminated Union (REQUIRED)

Nullable fields that switch shape = BANNED. Use discriminated unions.

**BANNED:**

```typescript
interface OrderState {
  status: string;
  data: Order | null;
  error: Error | null;
}
```

**REQUIRED:**

```typescript
type OrderState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: Order };
```

Discriminated union replaced with nullable fields = MINOR.

### 3. No Console / No Hardcoded URLs

```bash
grep -rn "console\.log\|console\.error\|console\.warn" {output-path}/
grep -rn "https://\|http://localhost" {output-path}/
```

- `console.*` = AUTO-FIX (remove, re-verify)
- Hardcoded URL in component = MAJOR FAIL

### 4. Accessibility

- **Loading:** `aria-busy="true"` or skeleton in `aria-live="polite"` region
- **Error (form):** `aria-invalid="true"` on input + `aria-describedby` linking error text
- **Error (global):** `aria-live="assertive"` on error container
- **Empty:** `role="status"` + `aria-label`
- **Interactive:** `<button>` not `<div onClick>` — icon-only buttons need `aria-label`
- **Forms:** every input associated with `<label>`

### 5. UX Copywriting

```bash
grep -n '"Failed to load\|"Error:\|"Something went wrong' {component-file}
```

- Error text = [what happened] + [how to fix it] — no raw `error.message`
- Error state MUST include CTA (retry/link/next step)
- Empty state copy MUST differ from error state

### 6. Tailwind Hygiene

- `h-screen` → `h-dvh`
- Square `w-N h-N` → `size-N`
- Headings → `text-balance`; paragraphs → `text-pretty`
- Numeric data → `tabular-nums`

### 7. Lint (Auto-Detected)

```bash
if [ -f "biome.json" ]; then
  npx biome check {output-path}/ 2>&1 | grep -E "error|warning" | head -20
elif [ -f ".eslintrc*" ] || [ -f "eslint.config*" ]; then
  npx eslint {output-path}/ --max-warnings=0 2>&1 | head -20
elif npm run lint --if-present 2>/dev/null; then
  # run project lint
fi
```

### 8. Browser-First Sizing

```bash
grep -n "offsetWidth\|offsetHeight\|getBoundingClientRect\|clientWidth\|clientHeight" {component-file}
grep -n "useState.*[Ww]idth\|useState.*[Hh]eight\|ref(0).*[Ww]idth\|ref(0).*[Hh]eight" {component-file}
grep -n 'w-\[[0-9]*px\]\|h-\[[0-9]*px\]' {component-file}
grep -n 'mt-\[[0-9]*px\]\|mb-\[[0-9]*px\]\|gap-\[[0-9]*px\]\|p-\[[0-9]*px\]' {component-file}
```

- JS dimension calculation for layout → MAJOR → use CSS Flexbox/Grid/`aspect-ratio`
- `useState`/`ref` storing pixel width/height → MAJOR → CSS handles responsive layout
- `w-[Npx]`/`h-[Npx]` for structural sizing → MAJOR → use responsive scale (`w-full`, `max-w-lg`)
- Magic spacing (`mt-[13px]`, `gap-[7px]`) → MINOR → use standard Tailwind spacing scale

### 9. Render Performance [`--design` only]

```bash
grep -rn "getBoundingClientRect\|offsetHeight\|offsetWidth\|offsetTop\|offsetLeft\|clientHeight\|scrollTop" {output-path}/
```

- `getBoundingClientRect` / `offsetX` adjacent to `style.*` writes = MAJOR → batch reads, use `requestAnimationFrame`
- Layout thrashing (DOM read + style write in same frame) = MAJOR → batch ALL reads before writes

### 10. data-testid Coverage

- State containers: `loading-skeleton`, `error-state`, `empty-state`, `content`
- Interactive elements: `{component-name}-{element-role}` in kebab-case

```bash
grep -n "<button\|<input\|<a href\|<form\|<select\|<textarea" {component-file} | grep -v "data-testid"
```

### 11. Web Vitals

- `<img>`/`<video>`/`<iframe>`: `width`+`height` or `aspect-ratio` (CLS)
- No `loading="lazy"` on above-fold media (LCP)
- Hero images: `fetchPriority="high"` (LCP)
- Heavy libraries: dynamic import (`React.lazy` / `defineAsyncComponent`)
- No `useTransition` on large lists (INP) → WARNING

### 12. JSDoc

- Exported Props interface: JSDoc block above
- Non-obvious props: inline `/** */` comment

## Score Formula

```text
Score = PASS / (PASS + FAIL) × 100
Required for SKILL COMPLETE: ≥ 80%
Required for APPROVE (Auditor): ≥ 70%
```

## Severity Matrix

| Issue | Severity | Block? |
|-------|----------|--------|
| Missing state (loading/error/empty/success) | CRITICAL | Yes |
| Async logic in `--type ui` | MAJOR | Yes |
| `: any` / `as any` | CRITICAL | Auto-fix; block if cannot infer |
| TypeScript compile error | CRITICAL | Yes |
| Unsafe array index access | BLOCKER | Yes |
| Optional prop `T \| undefined` instead of `?: T` | MINOR | No |
| Discriminated union replaced with nullable | MINOR | No |
| Missing `key` in list (React/Vue) | MAJOR | Yes |
| `console.log` | MAJOR → AUTO-FIX | No |
| Hardcoded URL | MAJOR | Yes |
| Biome/ESLint lint warning | MINOR | No |
| Unused import | MINOR | No |
| Missing ARIA on states | MAJOR | Yes |
| `<div onClick>` / `<span onClick>` | CRITICAL | Yes |
| Error message with no explanation | CRITICAL | Yes |
| Error state with no CTA | CRITICAL | Yes |
| Missing metadata on page-level component | MAJOR | Yes |
| Error/empty without noindex meta | MAJOR | Yes |
| Invented data in JSON-LD | CRITICAL | Yes |
| Unescaped dynamic string in meta/aria | MAJOR | Yes |
| JS dimension calculation for layout | MAJOR | Yes |
| `useState`/`ref` storing pixel width/height | MAJOR | Yes |
| `w-[Npx]` for structural sizing | MAJOR | Yes |
| Magic spacing (`mt-[13px]`, `gap-[7px]`) | MINOR | No |
| JS scroll event listener for animation | MAJOR | Yes |
| Layout thrashing (DOM read + style write) | MAJOR | Yes |
| Missing `data-testid` on interactive element | MAJOR | Yes |
| Missing JSDoc on Props | MINOR | No |
| Missing JSDoc inline comment on non-obvious prop | MINOR | No |
| `<img>` missing width+height (CLS) | BLOCKER | Yes |
| `loading="lazy"` on above-fold (LCP) | BLOCKER | Yes |
| Hero image missing fetchPriority (LCP) | BLOCKER | Yes |
| Heavy library not dynamic import | BLOCKER | Yes |
| No `useTransition` on large lists (INP) | WARNING | No |
