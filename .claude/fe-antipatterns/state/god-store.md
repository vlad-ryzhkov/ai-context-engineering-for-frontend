# Anti-Pattern: god-store

## Problem

A single Zustand/Pinia store that contains all application state — 10+ unrelated slices.

## Why It's Bad

- Every component that uses any state subscribes to the entire store — causes unnecessary re-renders
- God store grows without bound — becomes impossible to understand
- Impossible to lazy-load or code-split

## Good Example

```typescript
// ✅ Separate stores per domain
const useUserStore = create<UserState>(...);   // auth, profile
const useCartStore = create<CartState>(...);   // cart items
const useUIStore = create<UIState>(...);       // sidebar, modal, theme
```

## Rule

BANNED: Single store with 10+ unrelated state slices.
REQUIRED: One store per business domain (user, cart, notifications, UI).
EXCEPTION: Small apps with <5 state slices — single store is fine.
