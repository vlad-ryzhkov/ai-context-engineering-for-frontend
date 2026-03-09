# Quality Gates: `--design` flag

Load this file only when `--design` flag is present.

- [ ] Project palette tokens scanned before generating styles
- [ ] Design brief answered (Purpose / Tone / Constraints / Differentiation)
- [ ] Differentiation is a named aesthetic, not "modern and clean"
- [ ] No banned display fonts (Inter/Roboto/system-ui as headings)
- [ ] No purple-on-white gradient
- [ ] Motion: max 1 primary animation; staggered delays if list/grid present
- [ ] Composition: at least 2 spacing scales; no uniform py-16 px-4 on all sections
- [ ] No JS scroll event listeners (IntersectionObserver or animation-timeline used)
- [ ] No layout thrashing: DOM reads batched before writes
