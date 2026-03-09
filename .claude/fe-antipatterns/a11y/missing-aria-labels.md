# Anti-Pattern: missing-aria-labels

## Problem

Interactive elements (inputs, buttons, icons) without an accessible name.
Screen readers announce them as "button" or "edit text" with no context.

## Why It's Bad

- Users with screen readers cannot understand the purpose of the element
- WCAG 2.2 violation — Level A (1.3.1 Info and Relationships, 4.1.2 Name, Role, Value)

## Detection

```bash
# Inputs without label
grep -rn "<input" src/ | grep -v "aria-label\|aria-labelledby\|id="

# Icon buttons without label
grep -rn "<button" src/ | grep -v "aria-label\|aria-labelledby"
```

## Bad Examples

```tsx
// ❌ Icon button without label
<button onClick={handleClose}>
  <XIcon />
</button>

// ❌ Input without label
<input type="search" placeholder="Search..." />
```

## Good Examples

```tsx
// ✅ Icon button with aria-label
<button type="button" onClick={handleClose} aria-label="Close dialog">
  <XIcon aria-hidden="true" />
</button>

// ✅ Input with visible label (preferred)
<label htmlFor="search">Search</label>
<input id="search" type="search" placeholder="Search users..." />

// ✅ Input with aria-label when no visible label possible
<input
  type="search"
  aria-label="Search users"
  placeholder="Search..."
/>
```

## Quantified Constraints

| Constraint | Minimum | WCAG Reference |
|------------|---------|---------------|
| Focus indicator contrast | 3:1 against adjacent colors | 2.4.11 (Level AA, WCAG 2.2) |
| Visible label preferred over aria-label | Always use visible label when space allows | 2.4.6 (Level AA) |
| `aria-label` string | Must describe the action, not the icon name | 4.1.2 (Level A) |

## Rule

BANNED: `<button>` with icon-only content and no `aria-label`.
BANNED: `<input>` without `<label>`, `aria-label`, or `aria-labelledby`.
REQUIRED: Every interactive element has a programmatic accessible name.
