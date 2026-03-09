# React Doctor → Anti-Pattern Mapping

> Cross-reference table for mapping React Doctor diagnostics to existing
> `.claude/fe-antipatterns/` files. Used by Phase 5 of `/react-doctor`.

## Mapping Table

| React Doctor Rule | Anti-Pattern File | Match | Notes |
|-------------------|-------------------|-------|-------|
| `unnecessary-useeffect` | `react/unnecessary-useeffect.md` | Direct | useEffect for derived state or data fetching |
| `useeffect-missing-deps` | `react/useeffect-no-deps.md` | Partial | React Doctor covers missing deps; anti-pattern covers missing array entirely |
| `array-index-as-key` | `react/key-as-index.md` | Direct | `key={index}` in dynamic lists |
| `state-mutation` | `react/usestate-object-mutation.md` | Direct | Direct mutation of state objects |
| `missing-error-boundary` | `common/missing-error-boundary.md` | Direct | Async/lazy components without Error Boundary |
| `missing-loading-state` | `common/missing-loading-state.md` | Direct | Async component without loading indicator |
| `heavy-library-import` | `common/heavy-imports.md` | Direct | Non-tree-shakeable imports (moment, lodash root) |
| `dead-export` | `react/dead-code.md` | Direct | Unused exports, components, types |
| `missing-alt-attribute` | `a11y/missing-alt-text.md` | Direct | `<img>` without `alt` attribute |
| `div-as-button` | `a11y/div-as-button.md` | Direct | Clickable div/span without role="button" |
| `missing-aria-label` | `a11y/missing-aria-labels.md` | Direct | Interactive element without accessible name |
| `direct-dom-access` | `react/direct-dom-mutation.md` | Direct | document.querySelector in component |
| `context-overuse` | `react/context-overuse.md` | Partial | Frequently-changing values in Context |
| `inline-styles` | `common/inline-styles.md` | Partial | style={{}} for layout |

## Unmapped Rules (React Doctor only)

These React Doctor rules have no corresponding anti-pattern file.
If frequently triggered, consider creating new anti-pattern files.

- `unsafe-spread` — spreading unknown props onto DOM elements
- `redundant-fragment` — unnecessary `<>...</>` wrapper
- `missing-display-name` — forwardRef without displayName
- `unsafe-target-blank` — `target="_blank"` without `rel="noopener"`
