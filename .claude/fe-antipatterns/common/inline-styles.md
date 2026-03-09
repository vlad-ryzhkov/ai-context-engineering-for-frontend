# Anti-Pattern: inline-styles

## Problem

Using `style={{}}` (React) or `:style="{}"` (Vue) for layout and visual styling instead of Tailwind classes.

## Why It's Bad

- Bypasses Tailwind purging — increases bundle size
- Cannot be overridden by responsive breakpoints
- Inconsistent with design system tokens
- Harder to maintain — scattered magic values

## Detection

```bash
grep -rn "style={{" src/   # React
grep -rn ":style=\"{" src/ # Vue
```

## Exception

Dynamic values that Tailwind cannot express (e.g., exact pixel offsets from JS calculations):

```tsx
// ✅ Acceptable: dynamic value not expressible as Tailwind class
<div style={{ top: `${scrollOffset}px` }}>
```

## Rule

BANNED: `style={{ color: 'red', margin: '16px' }}` — use Tailwind classes instead.
EXCEPTION: Truly dynamic computed values (pixel calculations, CSS custom properties).
