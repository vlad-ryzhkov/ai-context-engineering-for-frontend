# Component Generator — Banned Patterns

## Universal (all frameworks)

- `: any` or `as any` — breaks strict TypeScript; enables silent runtime type errors
- Inline `style={{}}` for layout — use Tailwind classes; inline styles bypass design system
- `console.log` left in generated code — leaks internal state to browser; auto-fix by removing
- `document.querySelector` in component body — bypasses React/Vue reactivity model
- Business logic in template/JSX return — extract to hook/composable for testability
- Hardcoded API URLs or env values — use injected config or env var to support multiple environments
- Props mutation — violates one-way data flow; causes untracked side effects
- `h-screen` — use `h-dvh` instead; `h-screen` ignores mobile browser dynamic address bar, causing layout overflow on iOS/Android Chrome
- Interactive elements (`<button>`, `<input>`, `<a>`, `<form>`, `<select>`, `<textarea>`) without `data-testid` — breaks `/component-tests` handoff; every interactive element MUST have a scoped kebab-case `data-testid`
- Re-implementing a UI primitive that already exists in `src/shared/ui/` — always import from shared; generate a new component only when `src/shared/ui/` does not contain the needed primitive

## Layout & Sizing (universal)

- JS dimension calculations (`offsetWidth`, `offsetHeight`, `getBoundingClientRect` used for layout/sizing, `clientWidth`, `clientHeight`)
  — use CSS Flexbox / Grid / `aspect-ratio` / `min-w` / `max-w` constraints instead
- `useState` / `ref` storing pixel width or height for layout decisions
  — JS-managed dimensions break responsive layout and cause unnecessary re-renders
- Hardcoded arbitrary pixel dimensions in structural Tailwind classes (`w-[437px]`, `h-[312px]`)
  — use responsive scale (`w-full`, `max-w-lg`, `w-1/2`, `size-16`, etc.)
- Magic spacing values (`mt-[13px]`, `gap-[7px]`, `p-[11px]`)
  — use only standard Tailwind spacing scale: `p-1/2/3/4/6/8`, `gap-2/4/6/8`, `m-1/2/4/6`, etc.

## UX Copywriting (universal)

- Raw error strings as user-facing copy with no next-action guidance:
  `"Failed to load"`, `"Invalid input"`, `"Something went wrong"`, `"Error: ..."`, `"Not found"`
  — every error message must include [what happened] + [how to fix it]
- Error state with no CTA — no retry button, no link to settings, no next step for the user
  — orphaned error text that gives the user nothing to do is a UX dead end; BLOCKER

## A11y bans (universal)

- `<div onClick>` / `<span onClick>` — use `<button type="button">` for clickable non-link elements
- `<button>` with icon-only content and no `aria-label` — screen reader reads nothing; always add `aria-label`
- `<svg>` icon without `aria-hidden="true"` inside an interactive element — screen reader reads raw SVG markup
- `<input>`, `<select>`, `<textarea>` without an associated `<label>` (via `htmlFor`/`for` or wrapping `<label>`) — form element has no accessible name

## Design bans (`--design` only)

- Inter, Roboto, system-ui as primary DISPLAY/HEADING font — too generic; use a characterful typeface for headings (body text is fine)
- `font-family: Arial` — default browser font; zero differentiation
- Purple gradient on white background (`from-purple-* to-*`) — overused default AI aesthetic
- "Modern and clean" as aesthetic direction — not a direction; agent MUST decompose to a named direction
- Cookie-cutter card grids (equal-sized, equal-spaced, all same color) without differentiation — bland; vary scale, density, or accent
- Bootstrap-style uniform spacing (every section `py-16 px-4`) as sole rhythm — monotone; vary spatial composition

## Motion & Animation (all frameworks)

- Animating layout properties (`width`, `height`, `margin`, `padding`, `top`, `left`)
  — causes browser reflow on every frame; CRITICAL performance regression
  — ONLY animate `transform` and `opacity` (compositing-only properties)
  — Sliding/collapsing panels: use `translate-x`/`translate-y` not `width`/`height` changes
- `window.addEventListener('scroll', ...)` or `element.addEventListener('scroll', ...)` for animation/parallax
  — runs on main thread every scroll event; causes jank even at 60fps
  — MUST use `IntersectionObserver` for reveal effects, or CSS `animation-timeline: view()` for scroll-linked motion
- Animating `blur()` or `backdrop-filter` continuously (transition/keyframe on filter property)
  — triggers GPU repaint every frame; static blur on small, non-moving elements is acceptable
  — NEVER apply animated blur to surfaces larger than ~200px or on surfaces that move
- DOM layout thrashing: reading layout properties (`getBoundingClientRect`, `offsetHeight`, `offsetWidth`,
  `offsetTop`, `clientHeight`, `scrollTop`) and writing style (`style.transform`, `style.height`)
  in the same JS frame — forces synchronous reflow before every frame
  — Batch ALL reads before writes. Use `requestAnimationFrame` for the write phase.
- Custom animations without `prefers-reduced-motion` guard
  — violates WCAG 2.3.3; wrap in `@media (prefers-reduced-motion: reduce)` or
    use Tailwind `motion-safe:` / `motion-reduce:` variants

## React-specific

- `useEffect` without dependency array — causes infinite render loop
- `useEffect` with incomplete dependency array (stale closure) — `useEffect(() => { fetch(url) }, [])` when `url` is used inside but not listed in deps; ALWAYS include every variable from the closure that can change
- `useEffect` with async fetch and no cleanup — memory leak on unmount; REQUIRED: `AbortController` cleanup for every fetch inside `useEffect`:

  ```tsx
  useEffect(() => {
    const controller = new AbortController();
    fetch(url, { signal: controller.signal }).then(setData).catch(() => {});
    return () => controller.abort();
  }, [url]);
  ```

- `key={index}` in dynamic lists — breaks reconciliation on reorder; use stable unique ID
- Class components — use function components + hooks; class components are legacy
- `useContext` overuse for prop drilling — use composition first; context has global re-render cost
- Direct mutation of state object: `state.field = value` — bypasses React diffing; use spread or immer

## SEO & Metadata (universal)

- Invented data in JSON-LD or meta tags — do not invent ratings, reviews, prices, imageUrls,
  organization details, or any entity data for schema.org markup or Open Graph tags.
  Map only what exists in the provided API response or component props. **BLOCKER.**

- Unescaped dynamic strings in meta/aria — escape and sanitize any user-generated or dynamic
  strings before passing to `aria-label`, `alt`, `og:title`, `og:description`, or JSON-LD values.
  Strip HTML tags; truncate to reasonable limits (description ≤ 160 chars, title ≤ 60 chars).
  **MAJOR FAIL** if raw unescaped user input flows into meta tags.

## Web Vitals

- NEVER omit `width`/`height` on `<img>` — causes CLS (layout shift).
- NEVER use `loading="lazy"` on hero images, banners, or any above-the-fold media.
- NEVER import chart/map/editor libraries at the top level in a component file — use
  dynamic imports.
- For hero/banner `<img>` and `next/image`, ALWAYS add `fetchPriority="high"` /
  `priority={true}`.

## Vue-specific

- Options API in new code — use Composition API + `<script setup>`; Options API blocks tree-shaking
- `v-for` without `:key` — breaks virtual DOM diffing on list mutations
- Direct mutation of Pinia state outside actions — bypasses devtools tracking; use actions
- Complex logic in template expressions — extract to `computed`; templates should be declarative
- Props without `defineProps` type annotation — loses TypeScript inference at component boundary
- Destructuring TanStack Query return: `const { data, isLoading } = useQuery(...)` — destroys reactivity; keep full result object and access as `query.data`, `query.isLoading`
- Destructuring `reactive()` without `toRefs()`: `const { count } = reactive({count: 0})` — `count` becomes a plain number; use `toRefs()` or `ref()` directly
- `v-if` and `v-for` on the same element — `v-if` has higher priority in Vue 3, so loop variable is undefined at `v-if` time; ALWAYS filter with `computed` or move `v-if` inside a `<template v-for>` wrapper
