# Motion & Composition Directives [`--design` only]

## Motion Budget

- ONE primary entrance animation per component — do not animate every element
- Staggered reveals for list/grid items: `animation-delay` increments (50ms per item, max 5)
- FORBIDDEN: looping decorative animations unless core UI metaphor — causes battery drain and layout jank
- Animate only `transform` and `opacity` — `width`/`height`/`margin`/`top`/`left` trigger layout reflow and jank
- Scroll-reveal: `IntersectionObserver` or CSS `animation-timeline: view()` — JS scroll handlers block main thread

## Spatial Composition

- Vary spatial rhythm: at least 2 different spacing scales
- Prefer asymmetry for editorial layouts: CSS grid with unequal column spans (7+5, 8+4)
- Avoid every section having identical `py-16 px-4` padding — monotonous rhythm kills visual hierarchy
