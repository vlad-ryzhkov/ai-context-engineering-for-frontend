# Anti-Pattern: missing-defineprops-types

## Problem

`defineProps()` called without TypeScript type annotation — props have no type safety.

## Why It's Bad

- No TypeScript validation on prop values
- No IDE autocompletion for component consumers
- Misused props are detected only at runtime

## Detection

```bash
grep -rn "defineProps({" src/
```

## Bad Example

```vue
<!-- ❌ Runtime declaration — no TypeScript -->
<script setup lang="ts">
const props = defineProps({
  title: String,
  count: Number,
  items: Array,
});
</script>
```

## Good Example

```vue
<!-- ✅ TypeScript generic — full type safety -->
<script setup lang="ts">
interface Item {
  id: string;
  name: string;
}

interface Props {
  title: string;
  count?: number;
  items: Item[];
}

const props = defineProps<Props>();

// Or with defaults:
const props = withDefaults(defineProps<Props>(), {
  count: 0,
});
</script>
```

## Rule

BANNED: `defineProps({ key: Type })` runtime declaration in `.vue` files with `lang="ts"`.
REQUIRED: `defineProps<{ key: Type }>()` TypeScript generic declaration.
