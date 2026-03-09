# Frontend Anti-Patterns Index

> **Lazy Load Protocol:** Read a file ONLY when a violation is detected.
> Preemptive loading of all files is FORBIDDEN (Token Economy).

## Naming Convention

`{category}/{problem-name}.md` → problem description + Good Example.

## Available Patterns

### common/ — Framework-Agnostic Issues

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `common/prop-drilling.md` | Passing props 3+ levels deep | — | med |
| `common/missing-loading-state.md` | Async component without loading state | `isLoading\|isPending` absent | high |
| `common/missing-error-state.md` | Async component without error handling | `isError\|error` absent | high |
| `common/hardcoded-api-urls.md` | API URL hardcoded in component | `https://\|http://localhost` | med |
| `common/inline-styles.md` | `style={{}}` for layout | `style={{` | med |
| `common/missing-error-boundary.md` | Async component without Error Boundary wrapper | — | med |
| `common/mixed-concerns.md` | Business logic in view component | — | med |
| `common/magic-numbers.md` | Numeric constants without named variable | — | med |
| `common/heavy-imports.md` | Non-tree-shakeable imports (moment, lodash root) | `import moment\|import lodash[^/]` | med |
| `common/unvirtualized-large-list.md` | Large list (100+) without virtualization | `.map(` in JSX without react-window/virtual import | med |
| `common/microfrontend-shared-state.md` | Shared runtime state between micro-frontends | `window.__SHARED_STATE__\|window.__MFE_` | med |
| `common/microfrontend-css-leak.md` | CSS leaking between micro-frontends | Global selectors without scoping, unscoped `@tailwind base` | med |
| `common/memory-leak-subscriptions.md` | addEventListener/setInterval without cleanup on unmount | `addEventListener\|setInterval` without `removeEventListener\|clearInterval` | high |
| `common/empty-catch-block.md` | `catch (e) {}` silently swallows errors | `catch\s*(\s*)\s*{}\|\.catch\s*(\s*(\s*)\s*=>\s*{}\s*)` | high |
| `common/console-log-in-production.md` | `console.log` left in production code | `console\.log\|console\.debug\|console\.info` | med |
| `common/form-validation-missing.md` | Form without client-side validation | `<form` without `handleSubmit\|useForm\|validationSchema` | high |
| `common/fetch-without-abort.md` | fetch in useEffect/onMounted without AbortController | `useEffect.*fetch\|onMounted.*fetch` without `AbortController` | med |
| `common/race-condition-stale-response.md` | Stale async response overwrites fresh one | Sequential `set[A-Z].*await` without abort guard | high |
| `common/no-global-error-handler.md` | No app-level error boundary or global error handler | Missing `ErrorBoundary\|errorHandler` in app root | high |
| `common/images-without-dimensions.md` | `<img>` without width/height — causes CLS | `<img` without `width\|height\|fill\|aspect-ratio` | med |
| `common/env-variable-misuse.md` | `process.env` in Vite (returns undefined) | `process\.env\.` in src/ | high |

### security/ — Frontend Security

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `security/xss-raw-html.md` | `dangerouslySetInnerHTML`/`v-html` without sanitization | `dangerouslySetInnerHTML\|v-html\|\.innerHTML\s*=` | high |
| `security/sensitive-data-in-storage.md` | Auth tokens stored in localStorage | `localStorage\.setItem.*token\|localStorage\.setItem.*auth` | high |
| `security/open-redirect.md` | Unvalidated redirect from URL parameter | `location\.href\s*=.*param\|location\.replace.*param` | med |

### css/ — CSS & Styling

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `css/z-index-wars.md` | Arbitrary high z-index values (`z-[9999]`) | `z-\[9\|z-index:\s*9[0-9]{2,}` | med |
| `css/missing-responsive-handling.md` | Desktop-only layout without breakpoints | Fixed `w-[*px]` without `sm:\|md:\|lg:` variants | med |
| `css/animation-layout-thrashing.md` | Animating width/height instead of transform | `transition.*width\|transition.*height\|transition.*margin` | high |

### testing/ — Testing Anti-Patterns

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `testing/snapshot-overuse.md` | `toMatchSnapshot()` on rendered DOM output | `toMatchSnapshot\|toMatchInlineSnapshot` | med |
| `testing/testing-implementation-details.md` | Testing internal state instead of user behavior | `wrapper\.vm\.\|component\.state\|querySelector` in tests | med |

### react/ — React-Specific

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `react/useeffect-no-deps.md` | `useEffect` with no dependency array | `useEffect\(\(\) =>` + no `\[` | med |
| `react/state-in-render.md` | Derived state computed in JSX return | — | med |
| `react/missing-usecallback.md` | Event handler recreated on every render | — | med |
| `react/direct-dom-mutation.md` | `document.querySelector` in component | `document\.querySelector` | med |
| `react/key-as-index.md` | `key={index}` in dynamic lists | `key={index}\|key={i}` | med |
| `react/context-overuse.md` | useContext for frequently-changing state | — | med |
| `react/usestate-object-mutation.md` | `state.field = value` instead of setState | — | med |
| `react/dead-code.md` | Unused exports, components, types (AST-only detection) | — | med |
| `react/unnecessary-useeffect.md` | useEffect for derived state or data fetching | `useEffect` + `setState\|set[A-Z]` | med |
| `react/react-compiler-violations.md` | Mutations/ref reads/side effects in render body | `\.push(\|\.splice(\|ref\.current` in render | high |
| `react/unnecessary-memoization.md` | Manual useMemo/useCallback/React.memo with React Compiler active | `useMemo\|useCallback\|React\.memo` (conditional) | med |
| `react/ssr-hydration-mismatch.md` | SSR hydration mismatch (window/document in render) | `typeof window\|document\.\|localStorage\.\|Date\.now` in render | high |
| `react/concurrent-misuse.md` | useTransition/useDeferredValue misuse | `useTransition` on simple state | med |
| `react/suspense-waterfall.md` | Sequential Suspense causing request waterfalls | Nested `<Suspense>` + sequential `await` | med |

### vue/ — Vue-Specific

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `vue/options-api-in-new-code.md` | Options API in new Vue 3 file | `export default {` + `methods:` | med |
| `vue/v-for-no-key.md` | `v-for` without `:key` | `v-for` without `:key` | med |
| `vue/direct-pinia-mutation.md` | Mutating Pinia state outside store action | — | med |
| `vue/template-complexity.md` | 3+ conditions in template expression | — | med |
| `vue/missing-defineprops-types.md` | `defineProps()` without TypeScript types | `defineProps\(\{` | med |
| `vue/reactive-destructuring-loss.md` | Destructuring reactive/query result breaks reactivity | `const {.*} = useQuery\|const {.*} = reactive` | med |
| `vue/v-for-v-if-same-element.md` | `v-if` and `v-for` on same element — runtime error | `v-for.*v-if\|v-if.*v-for` on same tag | med |
| `vue/vapor-incompatible-patterns.md` | Patterns incompatible with Vue Vapor Mode | `\$el\|\$forceUpdate\|mixins:\|render()` | med |
| `vue/provide-inject-typing.md` | Untyped provide/inject losing type safety | `inject\(['"]` string key | med |

### state/ — State Management

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `state/god-store.md` | Single store with 10+ unrelated slices | — | med |
| `state/server-state-in-client-store.md` | API data stored in Zustand/Pinia | — | med |
| `state/optimistic-update-no-rollback.md` | Optimistic update without error rollback | — | med |
| `state/zustand-derived-in-store.md` | Derived state stored as field instead of selector | `set({.*,.*})` in Zustand + duplicated fields | med |
| `state/pinia-store-coupling.md` | Pinia stores importing each other directly | `use.*Store()` inside `defineStore` | med |

### a11y/ — Accessibility

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `a11y/div-as-button.md` | `<div onClick>` without `role="button"` | `onClick\|@click` on `div\|span` | med |
| `a11y/missing-aria-labels.md` | Interactive element without accessible name | `<input` without `aria-label\|id` | med |
| `a11y/missing-alt-text.md` | `<img>` without `alt` attribute | `<img` without `alt=` | med |

### design/ — Visual Design Quality

| File | Problem | Grep signature | Freq |
|------|---------|----------------|------|
| `design/no-generic-ai-aesthetics.md` | Generic AI fonts, purple gradients, cookie-cutter layouts | `font-family.*Inter\|from-purple` | med |

## Usage (for Engineer)

When a problem is found in code:

1. Determine the category: common / react / vue / state / a11y / security / css / testing
2. Read `.claude/fe-antipatterns/{category}/{name}.md` → apply Good Example → cite `(ref: {category}/{name}.md)`
3. If reference not found → BLOCKER, do not guess the fix

## Usage (for Auditor)

```bash
# Scan for common violations
grep -rn ": any\|as any\|console\.log\|style={{" src/
grep -rn "catch\s*(.*)\s*{}" src/
grep -rn "addEventListener\|setInterval" src/ | grep -v "removeEventListener\|clearInterval"
grep -rn "process\.env\." src/

# Security
grep -rn "dangerouslySetInnerHTML\|v-html\|\.innerHTML\s*=" src/
grep -rn "localStorage\.setItem.*token\|localStorage\.setItem.*auth" src/
grep -rn "location\.href\s*=.*param" src/

# CSS
grep -rn "z-\[9\|z-index:\s*9[0-9]" src/
grep -rn "transition.*width\|transition.*height" src/

# React-specific
grep -rn "key={index}\|key={i}\b\|document\.querySelector" src/

# Vue-specific
grep -rn "defineProps({" src/
grep -rn "const {.*} = useQuery\|const {.*} = useMutation\|const {.*} = useInfiniteQuery" src/
grep -rn "v-for.*v-if\|v-if.*v-for" src/

# Testing
grep -rn "toMatchSnapshot\|wrapper\.vm\.\|component\.state" src/

# A11y
grep -rn "onClick\|@click" src/ | grep "div\|span"
```
