# Quality Gates: Next.js App Router

## Mandatory Checks (run before SKILL COMPLETE)

### 1. RSC Boundary

```bash
grep -rn "'use client'" {output-path}/
```

- Default = Server Component. `'use client'` only when hooks/events/browser APIs needed.
- `'use client'` must be the very first line of the file.
- NEVER make an async data-fetching component a Client Component.

### 2. Next.js Imports

```bash
grep -rn "from 'next/router'" {output-path}/
grep -rn "<a href\|<img src" {output-path}/ | grep -v "next/link\|next/image"
```

- Must use `next/navigation` (not `next/router`)
- Must use `next/link` and `next/image` (not raw `<a>` / `<img>`)

### 3. Caching

```bash
grep -rn "export const revalidate" {output-path}/
```

- BANNED: `export const revalidate = N` (Next.js 13/14 pattern)
- Use `'use cache'` directive + `cacheTag()` + `cacheLife()` instead

### 4. Server Actions

```bash
grep -rn "'use server'" {output-path}/
grep -rn "onSubmit.*fetch\|onClick.*fetch.*POST\|onClick.*fetch.*PUT\|onClick.*fetch.*DELETE" {output-path}/
```

- Mutations must use Server Actions in `actions.ts` — not `fetch()` in client handler
- `useActionState` for pending/error feedback in client island
- `<form action={serverAction}>` — NEVER `onSubmit` + `fetch()`

### 5. State Coverage (`--type feature`)

| State | Mechanism | Check |
|-------|-----------|-------|
| Loading | `.loading.tsx` skeleton + `<Suspense>` at call site | File exists |
| Error | Thrown from RSC → caught by `error.tsx` | No swallowed errors |
| Empty | Null-check after `await` → empty UI or `notFound()` | `if (!data)` present |
| Success | Direct `await` in RSC body | No `useQuery` in RSC |

```bash
# Verify no TanStack Query in RSC files (only allowed in 'use client' files)
grep -rn "useQuery\|useSuspenseQuery" {output-path}/ | grep -v "'use client'"
```

### 6. TypeScript Strict

```bash
grep -n ": any\b\|as any\b" {output-path}/
grep -n "\w\+\[\w\+\]\.\w\+" {output-path}/  # unsafe index access
```

- `: any` / `as any` = CRITICAL → auto-fix or BLOCKER
- Unsafe index access = BLOCKER

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

### 7. Accessibility

- Loading skeleton: `aria-busy="true"` in `.loading.tsx`
- Error boundary: `role="alert"` + `aria-live="assertive"` in `error.tsx`
- Empty state: `role="status"` on container
- Icon-only buttons: `aria-label` required
- Form inputs: associated `<label>`

### 8. UX Copywriting

```bash
grep -n '"Failed to load\|"Error:\|"Something went wrong' {output-path}/
```

- Error text = [what happened] + [how to fix it] — no raw `error.message`
- Error state MUST include CTA (retry/link/next step)
- Empty state copy MUST differ from error state
- Use plain-language: "We couldn't load your orders" not "Failed to fetch /api/orders"

### 9. Tailwind Hygiene

- `h-screen` → `h-dvh`
- Square `w-N h-N` → `size-N`
- Headings → `text-balance`; paragraphs → `text-pretty`
- Numeric data → `tabular-nums`

### 10. Lint (Auto-Detected)

```bash
if [ -f "biome.json" ]; then
  npx biome check {output-path}/ 2>&1 | grep -E "error|warning" | head -20
elif [ -f ".eslintrc*" ] || [ -f "eslint.config*" ]; then
  npx eslint {output-path}/ --max-warnings=0 2>&1 | head -20
elif npm run lint --if-present 2>/dev/null; then
  # run project lint
fi
```

### 11. Browser-First Sizing

```bash
grep -n "offsetWidth\|offsetHeight\|getBoundingClientRect\|clientWidth\|clientHeight" {output-path}/
grep -n "useState.*[Ww]idth\|useState.*[Hh]eight\|ref(0).*[Ww]idth\|ref(0).*[Hh]eight" {output-path}/
grep -n 'w-\[[0-9]*px\]\|h-\[[0-9]*px\]' {output-path}/
grep -n 'mt-\[[0-9]*px\]\|mb-\[[0-9]*px\]\|gap-\[[0-9]*px\]\|p-\[[0-9]*px\]' {output-path}/
```

- JS dimension calculation for layout → MAJOR → use CSS Flexbox/Grid/`aspect-ratio`
- `useState`/`ref` storing pixel width/height → MAJOR → CSS handles responsive layout
- `w-[Npx]`/`h-[Npx]` for structural sizing → MAJOR → use responsive scale (`w-full`, `max-w-lg`)
- Magic spacing (`mt-[13px]`, `gap-[7px]`) → MINOR → use standard Tailwind spacing scale

### 12. Render Performance [`--design` only]

```bash
grep -rn "getBoundingClientRect\|offsetHeight\|offsetWidth\|offsetTop\|offsetLeft\|clientHeight\|scrollTop" {output-path}/
```

- `getBoundingClientRect` / `offsetX` adjacent to `style.*` writes = MAJOR → batch reads, use `requestAnimationFrame`
- Layout thrashing (DOM read + style write in same frame) = MAJOR → batch ALL reads before writes

### 13. data-testid Coverage

- Empty state container: `data-testid="empty-state"`
- Success state root: `data-testid="content"`
- Every interactive element: `data-testid="{component-name}-{element-role}"`

Note: loading skeleton lives in `.loading.tsx` (add `data-testid="loading-skeleton"`), error in `error.tsx` (add `data-testid="error-state"`).

### 14. Web Vitals

- `<img>` / `<video>` / `<iframe>`: explicit `width` + `height` or `aspect-ratio` (CLS)
- Hero images: `priority={true}` on `next/image` (LCP)
- Heavy libraries: dynamic import with `React.lazy` + `<Suspense>` (bundle size)
- No `useTransition` on large lists (INP) → WARNING

### 15. JSDoc on Props

- Exported Props interface: JSDoc block above
- Non-obvious props: inline `/** */` comment

```typescript
/** Props for the OrderList component. */
interface OrderListProps {
  /** ISO 8601 date string for filtering orders after this date. */
  since: string;
  /** Maximum number of items to display. */
  limit?: number;
}
```

## Score Formula

```text
Score = PASS / (PASS + FAIL) × 100
Required for SKILL COMPLETE: ≥ 80%
Required for APPROVE (Auditor): ≥ 70%
```

## Severity Matrix

| Issue | Severity | Block? |
|-------|----------|--------|
| Entire component as Client Component unnecessarily | CRITICAL | Yes |
| `next/router` instead of `next/navigation` | CRITICAL | Yes |
| Raw `<a>`/`<img>` instead of next/link, next/image | MAJOR | Yes |
| `export const revalidate` | MAJOR | Yes |
| `fetch()` in client handler for mutations | MAJOR | Yes |
| Missing `.loading.tsx` skeleton | CRITICAL | Yes |
| TanStack Query in RSC (non-client) file | CRITICAL | Yes |
| `: any` / `as any` | CRITICAL | Auto-fix; block if cannot infer |
| TypeScript compile error | CRITICAL | Yes |
| Unsafe array index access | BLOCKER | Yes |
| Optional prop `T \| undefined` instead of `?: T` | MINOR | No |
| Discriminated union replaced with nullable | MINOR | No |
| Missing `key` in list | MAJOR | Yes |
| `console.log` | MAJOR → AUTO-FIX | No |
| Hardcoded URL | MAJOR | Yes |
| Biome/ESLint lint warning | MINOR | No |
| Unused import | MINOR | No |
| Missing `aria-busy` on loading skeleton | MAJOR | Yes |
| Missing `data-testid` on interactive element | MAJOR | Yes |
| Error message with no explanation | CRITICAL | Yes |
| Error state with no CTA | CRITICAL | Yes |
| Unescaped dynamic string in meta/aria | MAJOR | Yes |
| JS dimension calculation for layout | MAJOR | Yes |
| `useState`/`ref` storing pixel width/height | MAJOR | Yes |
| `w-[Npx]` for structural sizing | MAJOR | Yes |
| Magic spacing (`mt-[13px]`, `gap-[7px]`) | MINOR | No |
| JS scroll event listener for animation | MAJOR | Yes |
| Layout thrashing (DOM read + style write) | MAJOR | Yes |
| Missing JSDoc on Props | MINOR | No |
| `<img>` missing width+height (CLS) | BLOCKER | Yes |
| Hero image missing `priority` (LCP) | BLOCKER | Yes |
| Heavy library not dynamic import | BLOCKER | Yes |
| No `useTransition` on large lists (INP) | WARNING | No |
