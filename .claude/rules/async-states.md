---
globs: "*.tsx, *.vue"
---

# Async Component State Management

MANDATORY for ALL async/data-fetching components — implement all 4 states:

1. **Loading** — skeleton or spinner while data loads
2. **Error** — user-facing error message with retry option
3. **Empty** — meaningful empty state (not blank screen)
4. **Success** — render data

- Each state must be visually distinct and testable
- Error state must show user-friendly message, never raw error objects
- Loading state should match layout dimensions to prevent CLS
