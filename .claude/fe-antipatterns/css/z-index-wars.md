# Anti-Pattern: z-index-wars

## Problem

AI generates arbitrary high `z-index` values (`z-[9999]`, `z-[99999]`) to force elements above others.
Results in an unmanageable stacking context where every new component needs a higher value.

## Why It's Bad

- No predictable layering — new overlays require ever-higher values
- Stacking context isolation breaks parent-child z-index relationships
- Debugging becomes impossible when 5+ components compete for top layer
- Tooltips/modals/dropdowns appear behind or above each other randomly

## Severity

MEDIUM

## Detection

```bash
grep -rn "z-\[9\|z-\[99\|z-index:\s*9[0-9]\{2,\}" src/
```

## Bad Example

```tsx
// ❌ Arbitrary z-index escalation
<div className="z-[9999]">  {/* Modal */}
  <div className="z-[99999]">  {/* Modal overlay toast */}
    <div className="z-[999999]">  {/* Tooltip inside toast */}
```

## Good Example

```tsx
// ✅ Defined z-index scale in Tailwind config
// tailwind.config.ts
export default {
  theme: {
    extend: {
      zIndex: {
        dropdown: '100',
        sticky: '200',
        overlay: '300',
        modal: '400',
        popover: '500',
        toast: '600',
        tooltip: '700',
      },
    },
  },
};

// Usage — semantic, predictable
<div className="z-modal">...</div>
<div className="z-toast">...</div>
<div className="z-tooltip">...</div>
```

## Rule

BANNED: Arbitrary `z-index` values above 50 (`z-[9999]`, `z-[100]`, `z-index: 9999`).
REQUIRED: Define a z-index scale in Tailwind config with semantic names (dropdown, modal, toast, tooltip).
REQUIRED: Use semantic z-index classes (`z-modal`, `z-tooltip`) instead of numeric values.
