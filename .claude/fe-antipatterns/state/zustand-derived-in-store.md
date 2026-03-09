# Anti-Pattern: zustand-derived-in-store

## Problem

Computing derived state inside a Zustand store action instead of using selectors.
Causes stale derived values, unnecessary re-renders, and duplicated state.

## Why It's Bad

- Derived state stored as a separate field gets out of sync with source state
- Every update to source state must manually update derived state — easy to forget
- Components subscribed to derived field re-render even when source didn't change
- Violates single source of truth — same data in two places

## Detection

```bash
# Look for stores where one field is clearly derived from another
grep -rn "create<" src/ | xargs grep -l "set({.*,.*})" | \
  xargs grep -n "get()\..*\." 2>/dev/null
```

## Bad Example

```typescript
// ❌ Derived state stored in the store
interface CartStore {
  items: CartItem[];
  totalPrice: number;      // derived from items — will go stale
  totalCount: number;      // derived from items — will go stale
  addItem: (item: CartItem) => void;
}

const useCartStore = create<CartStore>((set, get) => ({
  items: [],
  totalPrice: 0,
  totalCount: 0,
  addItem: (item) => {
    const items = [...get().items, item];
    set({
      items,
      totalPrice: items.reduce((sum, i) => sum + i.price, 0),
      totalCount: items.length,
    });
  },
}));
```

## Good Example

```typescript
// ✅ Selectors for derived state — always in sync, no duplication
interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
}

const useCartStore = create<CartStore>((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) =>
    set((state) => ({ items: state.items.filter((i) => i.id !== id) })),
}));

// Derived state via selectors (computed on read, always fresh)
export const useTotalPrice = (): number =>
  useCartStore((state) => state.items.reduce((sum, i) => sum + i.price, 0));

export const useTotalCount = (): number =>
  useCartStore((state) => state.items.length);

export const useItemById = (id: string): CartItem | undefined =>
  useCartStore((state) => state.items.find((i) => i.id === id));
```

## Rule

BANNED: Storing computed/derived values as separate state fields in Zustand stores.
REQUIRED: Use selectors (functions that derive from state) for any computed value.
EXCEPTION: Expensive computations that need memoization — use `createSelector` from `reselect`.
