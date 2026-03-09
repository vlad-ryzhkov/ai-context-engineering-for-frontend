# Anti-Pattern: pinia-store-coupling

## Problem

Pinia stores importing and calling each other directly, creating circular or tight coupling between domain stores.

## Why It's Bad

- Circular imports cause runtime errors or undefined references
- Tight coupling makes stores impossible to test in isolation
- Changes to one store ripple through all coupled stores
- Breaks Feature-Sliced Design — cross-slice imports within same layer are FORBIDDEN

## Detection

```bash
# Look for stores importing other stores
grep -rn "import.*useStore\|import.*Store.*from.*store" src/stores/ src/features/**/model/ 2>/dev/null
grep -rn "use.*Store()" src/stores/ | grep -v "defineStore\|test\|spec"
```

## Bad Example

```typescript
// ❌ stores/useOrderStore.ts — imports useCartStore directly
import { useCartStore } from './useCartStore';
import { useUserStore } from './useUserStore';

export const useOrderStore = defineStore('order', () => {
  const cartStore = useCartStore();
  const userStore = useUserStore();

  async function placeOrder(): Promise<void> {
    // Tight coupling: order store knows cart and user internals
    const order = {
      items: cartStore.items,
      userId: userStore.user?.id,
      total: cartStore.totalPrice,
    };
    await api.createOrder(order);
    cartStore.clearCart();   // Side effect in another store
  }

  return { placeOrder };
});
```

## Good Example

```typescript
// ✅ Composable orchestrates stores — stores stay independent
// composables/useCheckout.ts
import { useCartStore } from '@/entities/cart/model/useCartStore';
import { useUserStore } from '@/entities/user/model/useUserStore';
import { useOrderStore } from '@/entities/order/model/useOrderStore';

export function useCheckout() {
  const cartStore = useCartStore();
  const userStore = useUserStore();
  const orderStore = useOrderStore();

  async function placeOrder(): Promise<void> {
    const userId = userStore.user?.id;
    if (!userId) throw new Error('User not authenticated');

    await orderStore.create({
      items: cartStore.items,
      userId,
    });

    cartStore.clearCart();
  }

  return { placeOrder };
}

// ✅ Each store is independent — no imports of other stores
// entities/cart/model/useCartStore.ts
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);

  function clearCart(): void {
    items.value = [];
  }

  return { items, clearCart };
});
```

## Rule

BANNED: Pinia store importing another Pinia store directly.
REQUIRED: Use a composable or service layer to orchestrate cross-store logic.
EXCEPTION: Shared utility stores (e.g., `useUIStore` for global loading state) may be imported by other stores if no circular dependency exists.
