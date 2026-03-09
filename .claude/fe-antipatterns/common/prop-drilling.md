# Anti-Pattern: prop-drilling

## Problem

Passing props through 3+ component levels just to reach a deeply nested consumer.

## Why It's Bad

- Every intermediate component becomes tightly coupled to the prop
- Adding or removing the prop requires changing every level
- Intermediate components are polluted with props they don't use

## Good Example (React — Zustand)

```typescript
// ✅ Use global state for widely-needed data
const user = useStore((state) => state.user);
```

## Good Example (Vue — Pinia)

```typescript
// ✅ Use Pinia store
const userStore = useUserStore();
```

## Rule

BANNED: Props passed through more than 2 intermediate components that don't use them.
REQUIRED: Use Zustand (React) or Pinia (Vue) for state needed by distant descendants.
Exception: Explicit prop-passing in small, co-located component trees is fine.
