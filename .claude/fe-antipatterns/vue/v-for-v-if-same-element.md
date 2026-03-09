# Anti-Pattern: v-for-v-if-same-element

## Problem

Using `v-if` and `v-for` on the same element. In Vue 3, `v-if` has higher priority than `v-for`,
so `v-if` evaluates before the loop variable exists — causing a runtime error or incorrect behavior.

## Why It's Bad

- `v-if="item.active"` evaluates before `v-for` defines `item` → runtime `ReferenceError`
- Even when it doesn't crash, the intent is wrong: the condition should filter, not gate the loop
- Forces Vue to evaluate `v-if` on every iteration instead of computing a filtered list once

## Detection

```bash
grep -n "v-for" src/ -r -A1 | grep "v-if"
# Or single-line detection:
grep -rn 'v-for.*v-if\|v-if.*v-for' src/
```

## Bad Example

```html
<!-- ❌ v-if evaluates before v-for — item is undefined at v-if time -->
<li
  v-for="item in items"
  v-if="item.active"
  :key="item.id"
>
  {{ item.name }}
</li>
```

## Good Examples

```html
<!-- ✅ Option 1: filter with computed property (preferred) -->
<script setup lang="ts">
import { computed } from 'vue';
const activeItems = computed(() => items.value.filter(i => i.active));
</script>

<template>
  <li v-for="item in activeItems" :key="item.id">
    {{ item.name }}
  </li>
</template>

<!-- ✅ Option 2: wrap with <template> to separate concerns -->
<template v-for="item in items" :key="item.id">
  <li v-if="item.active">{{ item.name }}</li>
</template>
```

## Rule

BANNED: `v-if` and `v-for` on the same element.
REQUIRED: Pre-filter with a `computed` property, OR wrap with `<template v-for>` and apply `v-if` to the inner element.
PREFERRED: `computed` filter — clearer intent, better performance (computed caches).
