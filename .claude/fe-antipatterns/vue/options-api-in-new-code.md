# Anti-Pattern: options-api-in-new-code

## Problem

New Vue 3 components written using the Options API instead of Composition API.

## Why It's Bad

- Options API is deprecated for new Vue 3 code in most modern projects
- Cannot reuse logic across components (no composables)
- TypeScript support is significantly worse
- Inconsistency with Composition API files = harder to maintain

## Detection

```bash
grep -rn "export default {" src/ | grep -v ".test.\|.spec."
grep -rn "methods:\|computed:\|data()\|mounted()" src/
```

## Bad Example

```vue
<!-- ❌ Options API in new code -->
<template>
  <div>{{ greeting }}</div>
</template>

<script>
export default {
  data() {
    return { name: 'World' };
  },
  computed: {
    greeting() {
      return `Hello, ${this.name}!`;
    },
  },
};
</script>
```

## Good Example

```vue
<!-- ✅ Composition API with <script setup> -->
<script setup lang="ts">
import { computed, ref } from 'vue';

const name = ref('World');
const greeting = computed(() => `Hello, ${name.value}!`);
</script>

<template>
  <div>{{ greeting }}</div>
</template>
```

## Rule

BANNED: `export default { methods: {...}, computed: {...} }` in new Vue 3 components.
REQUIRED: `<script setup lang="ts">` with Composition API (ref, computed, watch, composables).
