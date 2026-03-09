# Anti-Pattern: div-as-button

## Problem

`<div>` or `<span>` used as a clickable element without proper accessibility attributes.

## Why It's Bad

- Not reachable via keyboard (Tab key skips it)
- Screen readers don't announce it as interactive
- No default keyboard activation (Enter/Space)
- WCAG 2.2 violation — Level A (4.1.2 Name, Role, Value)
- Touch target too small when unstyled: minimum 44×44px required (WCAG 2.5.8 Level AA)

## Detection

```bash
grep -rn "onClick\|@click" src/ | grep "div\|span"
```

## Bad Example (React)

```tsx
// ❌ div as button
<div onClick={handleDelete} className="cursor-pointer text-red-500">
  Delete
</div>
```

## Good Example (React)

```tsx
// ✅ Use <button>
<button
  type="button"
  onClick={handleDelete}
  className="text-red-500 hover:text-red-700"
>
  Delete
</button>
```

## If You Must Use div (rare)

```tsx
// ✅ Accessible div (only when button styling is truly impossible)
<div
  role="button"
  tabIndex={0}
  onClick={handleDelete}
  onKeyDown={(e) => (e.key === 'Enter' || e.key === ' ') && handleDelete()}
  aria-label="Delete item"
  className="cursor-pointer"
>
  Delete
</div>
```

## Quantified Constraints

| Constraint | Minimum | WCAG Reference |
|------------|---------|---------------|
| Touch target size | 44×44px | 2.5.8 (Level AA, WCAG 2.2) |
| Focus indicator contrast | 3:1 against adjacent colors | 2.4.11 (Level AA, WCAG 2.2) |
| Keyboard activation | Enter + Space | 4.1.2 (Level A) |

## Rule

BANNED: `<div onClick>` or `<span @click>` without `role="button"`, `tabIndex`, and keyboard handler.
REQUIRED: Use `<button type="button">` for all clickable non-link elements.
EXCEPTION: Clickable card/row → wrap in `<button>` or add `role="button"` + full keyboard support.
