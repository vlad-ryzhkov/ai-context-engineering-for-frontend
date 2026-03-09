# Anti-Pattern: mixed-concerns

## Problem

Business logic (data transformation, validation, calculation) placed directly inside the component's JSX/template return.

## Why It's Bad

- Logic cannot be unit tested without rendering the component
- Component becomes a monolith — hard to read, harder to maintain
- Logic cannot be reused across components

## Bad Example (React)

```tsx
// ❌ Business logic in JSX
function OrderSummary({ items }: { items: OrderItem[] }) {
  return (
    <div>
      <p>Total: ${items.reduce((sum, item) => sum + item.price * item.qty, 0).toFixed(2)}</p>
      <p>Items: {items.filter(i => i.qty > 0).length}</p>
    </div>
  );
}
```

## Good Example (React)

```tsx
// ✅ Logic in hook, view is clean
function useOrderSummary(items: OrderItem[]) {
  const total = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const activeCount = items.filter(i => i.qty > 0).length;
  return { total: total.toFixed(2), activeCount };
}

function OrderSummary({ items }: { items: OrderItem[] }) {
  const { total, activeCount } = useOrderSummary(items);
  return (
    <div>
      <p>Total: ${total}</p>
      <p>Items: {activeCount}</p>
    </div>
  );
}
```

## Rule

BANNED: Complex expressions (reduce, filter, map chains, conditionals) directly inside JSX return or Vue template.
REQUIRED: Extract to custom hook (React) or composable (Vue), then unit-test the logic separately.
