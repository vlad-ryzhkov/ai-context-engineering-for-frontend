# Anti-Pattern: missing-responsive-handling

## Problem

AI generates desktop-only layouts with fixed widths, no breakpoints, and no mobile considerations.
Components look correct at 1440px but break or overflow on mobile viewports.

## Why It's Bad

- Mobile users (60%+ of web traffic) see broken layouts, horizontal scroll, or clipped content
- Fixed pixel widths overflow small screens — content becomes unreachable
- Touch targets too small on mobile — fails WCAG 2.5.8 (44x44px minimum)
- Missing viewport meta tag causes desktop layout on mobile browsers

## Severity

MEDIUM

## Detection

```bash
# Fixed widths without responsive variants
grep -rn "w-\[.*px\]\|width:\s*[0-9]\+px" src/ | grep -v "max-w\|min-w\|sm:\|md:\|lg:"
# Grid layouts without responsive breakpoints
grep -rn "grid-cols-[3-9]\|grid-cols-1[0-9]" src/ | grep -v "sm:\|md:\|lg:\|xl:"
```

## Bad Example

```tsx
// ❌ Desktop-only fixed layout
function Dashboard() {
  return (
    <div className="w-[1200px] mx-auto">
      <div className="grid grid-cols-4 gap-6">
        <Card className="w-[280px]" />
        <Card className="w-[280px]" />
        <Card className="w-[280px]" />
        <Card className="w-[280px]" />
      </div>
    </div>
  );
}
```

## Good Example

```tsx
// ✅ Mobile-first responsive layout
function Dashboard() {
  return (
    <div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        <Card />
        <Card />
        <Card />
        <Card />
      </div>
    </div>
  );
}
```

## Mobile-First Checklist

- Use `w-full` + `max-w-*` instead of fixed pixel widths
- Start with single-column layout, add columns at breakpoints (`sm:`, `md:`, `lg:`)
- Add horizontal padding (`px-4`) to prevent edge-to-edge content on mobile
- Ensure touch targets are at least 44x44px (`min-h-11 min-w-11`)
- Test at 320px, 375px, 768px, 1024px, 1440px viewports

## Rule

BANNED: Fixed pixel widths (`w-[1200px]`) on layout containers without responsive alternatives.
BANNED: Multi-column grids (`grid-cols-3+`) without mobile breakpoint (`grid-cols-1` base).
REQUIRED: Mobile-first approach — base styles for mobile, `sm:`/`md:`/`lg:` for larger screens.
