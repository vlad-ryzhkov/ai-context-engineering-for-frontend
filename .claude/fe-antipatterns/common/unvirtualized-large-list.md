# Anti-Pattern: unvirtualized-large-list

## Problem

Rendering lists with 100+ items without virtualization, causing all DOM nodes to exist simultaneously.

## Why It's Bad

- Thousands of DOM nodes degrade scroll performance
- Initial render takes seconds for large datasets
- Memory usage grows linearly with list size
- Mobile devices become unresponsive

## Detection

```bash
grep -rn "\.map(" src/ | grep -v "react-window\|react-virtuoso\|react-virtual\|vue-virtual-scroller"
```

Grep signatures:

- `\.map(` in JSX with no virtualization import
- Look for list components without `react-window`, `react-virtuoso`, `@tanstack/react-virtual`, or `vue-virtual-scroller`

## Bad Example

```tsx
// ❌ Renders all 10,000 items at once
export function ProductList({ products }: { products: Product[] }) {
  return (
    <ul>
      {products.map((product) => (
        <li key={product.id}>
          <ProductCard product={product} />
        </li>
      ))}
    </ul>
  );
}
```

## Good Example

```tsx
// ✅ Only renders visible items + buffer
import { useVirtualizer } from '@tanstack/react-virtual';

export function ProductList({ products }: { products: Product[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: products.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 80,
    overscan: 5,
  });

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: 0,
              transform: `translateY(${virtualItem.start}px)`,
              width: '100%',
            }}
          >
            <ProductCard product={products[virtualItem.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

## When to Apply

- Lists with >50 items that could grow
- Infinite scroll feeds
- Data tables with >100 rows
- Any list where user can search/filter large datasets

## Rule

BANNED: Rendering 100+ items via `.map()` without virtualization.
REQUIRED: Use `@tanstack/react-virtual`, `react-virtuoso`, `react-window` (React) or `vue-virtual-scroller` (Vue) for large lists.

## References

- [@tanstack/react-virtual](https://tanstack.com/virtual/latest)
- [react-virtuoso](https://virtuoso.dev/)
- [vue-virtual-scroller](https://github.com/Akryum/vue-virtual-scroller)
