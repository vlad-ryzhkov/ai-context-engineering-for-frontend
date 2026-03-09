# Anti-Pattern: magic-numbers

## Problem

Numeric constants used directly in code without a named variable explaining their meaning.

## Why It's Bad

- Readers don't know what `42`, `1000`, or `0.15` mean
- Changing the value requires finding all occurrences
- Different occurrences of the same value may mean different things

## Detection

```bash
grep -rn "\b\d{3,}\b" src/ | grep -v "test\|spec\|px\|ms\|rem"
```

## Bad Example

```typescript
// ❌ Magic numbers
if (price > 10000) applyDiscount(0.15);
await new Promise(resolve => setTimeout(resolve, 3000));
const limit = 50;
```

## Good Example

```typescript
// ✅ Named constants
const BULK_ORDER_THRESHOLD_CENTS = 10_000;
const BULK_DISCOUNT_RATE = 0.15;
const TOAST_DISPLAY_DURATION_MS = 3_000;
const MAX_SEARCH_RESULTS = 50;

if (price > BULK_ORDER_THRESHOLD_CENTS) applyDiscount(BULK_DISCOUNT_RATE);
await new Promise(resolve => setTimeout(resolve, TOAST_DISPLAY_DURATION_MS));
const limit = MAX_SEARCH_RESULTS;
```

## Rule

BANNED: Bare numeric literals (>2 digits) without named constant.
EXCEPTION: 0, 1, -1, 100 in obvious mathematical contexts.
REQUIRED: Named constant in `SCREAMING_SNAKE_CASE` with unit suffix (`_MS`, `_CENTS`, `_PX`).
