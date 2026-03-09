# Anti-Pattern: animation-layout-thrashing

## Problem

Animating layout properties (`width`, `height`, `margin`, `padding`, `top`, `left`) instead of compositing-only properties (`transform`, `opacity`).
AI generates CSS transitions on layout properties because they're more intuitive.

## Why It's Bad

- Layout properties trigger browser reflow on EVERY animation frame
- Reflow recalculates geometry of entire subtree — 60fps becomes 10-20fps
- Causes visible jank, especially on mobile devices with limited CPU
- Reading layout props (`offsetHeight`) + writing styles in same frame = forced synchronous reflow

## Severity

HIGH

## Detection

```bash
# CSS transitions/animations on layout properties
grep -rn "transition.*width\|transition.*height\|transition.*margin\|transition.*padding\|transition.*top\|transition.*left\|animate-.*width\|animate-.*height" src/
# JS layout thrashing
grep -rn "offsetHeight\|offsetWidth\|getBoundingClientRect\|clientHeight\|scrollTop" src/ | grep -v "// read-only"
```

## Bad Example

```tsx
// ❌ Animating width — triggers reflow every frame
<div className="transition-all duration-300" style={{ width: isOpen ? '300px' : '0px' }}>
  <Sidebar />
</div>

// ❌ Animating height for accordion
<div className="transition-[height] duration-200" style={{ height: isExpanded ? '200px' : '0' }}>
  {content}
</div>
```

## Good Example

```tsx
// ✅ Transform-based slide — compositing only, no reflow
<div
  className="w-[300px] transition-transform duration-300"
  style={{ transform: isOpen ? 'translateX(0)' : 'translateX(-100%)' }}
>
  <Sidebar />
</div>

// ✅ Grid-based accordion — let browser handle layout
<div
  className="grid transition-[grid-template-rows] duration-200"
  style={{ gridTemplateRows: isExpanded ? '1fr' : '0fr' }}
>
  <div className="overflow-hidden">{content}</div>
</div>
```

## Safe Animation Properties

| Safe (compositing) | Unsafe (layout) |
|---|---|
| `transform` (translate, scale, rotate) | `width`, `height` |
| `opacity` | `margin`, `padding` |
| `filter` (static, not animated) | `top`, `left`, `right`, `bottom` |
| `clip-path` | `font-size` |
| `background-color` | `border-width` |

## Rule

BANNED: Animating `width`, `height`, `margin`, `padding`, `top`, `left` via CSS transitions or JS.
REQUIRED: Use `transform` (translate/scale) and `opacity` for animations.
REQUIRED: For accordion/collapse effects, use `grid-template-rows: 0fr → 1fr` pattern.
REQUIRED: Batch layout reads before writes — never interleave in same frame.
