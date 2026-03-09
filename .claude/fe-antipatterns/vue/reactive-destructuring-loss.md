# Anti-Pattern: reactive-destructuring-loss

## Problem

Destructuring a reactive object or TanStack Query result breaks Vue 3 reactivity.
This is the #1 Vue 3 "silent bug" — the code looks correct, but updates stop propagating.

## Why It's Bad

- `ref` values wrapped in `reactive()` lose their ref identity on destructure
- Destructuring `useQuery()` return breaks reactivity of `data`, `isLoading`, etc.
- Vue template stops updating; no error thrown — the bug is invisible

## Detection

```bash
grep -n "const {" src/ -r | grep -E "useQuery|useInfiniteQuery|reactive\("
```

## Bad Examples

```ts
// ❌ Destructuring TanStack Query result — data/isLoading lose reactivity
const { isLoading, data, isError } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
});
// isLoading is now a plain boolean snapshot — template will NOT update

// ❌ Destructuring reactive() — count loses reactivity
const state = reactive({ count: 0 });
const { count } = state; // count is now 0 (number), not a ref
count; // always 0, never updates
```

## Good Examples

```ts
// ✅ Keep the result object — access via .value or direct property
const query = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
});
// In template: query.isLoading, query.data — reactive accessors preserved

// ✅ Use toRefs() if you need destructured refs from reactive()
import { toRefs } from 'vue';
const state = reactive({ count: 0 });
const { count } = toRefs(state); // count is now a Ref<number> — reactive

// ✅ Or use ref() directly for individual values
const count = ref(0); // no destructuring needed
```

## Rule

BANNED: Destructuring `useQuery()`, `useMutation()`, `useInfiniteQuery()`, or any TanStack Vue Query return.
BANNED: Destructuring `reactive()` object without `toRefs()`.
REQUIRED: Access query results as `query.data`, `query.isLoading`, etc.
REQUIRED: When destructuring `reactive()`, wrap with `toRefs()` first.
