---
globs: "*.tsx, *.jsx"
---

# React Rules

- Hooks must follow Rules of Hooks (no conditional calls)
- useEffect: always specify deps array; prefer cleanup returns for subscriptions
- Derived state: compute in render body or useMemo, NEVER in useEffect + setState
- Event handlers: define outside JSX return, never inline arrow in JSX for complex logic
- Lists: key must be stable unique ID, NEVER array index for dynamic lists
- Ref anti-patterns for React Compiler: no `.current` reads in render, no mutations in render body
- Error Boundaries: every async feature tree must have one
- Prefer composition (children/render props) over inheritance
