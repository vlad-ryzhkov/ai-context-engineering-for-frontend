# Anti-Pattern: vapor-incompatible-patterns

## Problem

Vue patterns that are incompatible with Vue Vapor Mode — a compilation strategy that bypasses the Virtual DOM for better performance.

## Why It's Bad

- Vapor Mode compiles templates to direct DOM operations — patterns relying on VDOM internals will break
- `$el` accesses the component's root element via VDOM node — unavailable in Vapor
- `$forceUpdate()` forces VDOM re-render — no VDOM in Vapor means no effect
- `mixins` are legacy composition — Vapor optimizes for Composition API only
- Manual `render()` functions bypass template compilation — Vapor cannot optimize them

## Applicability

**CONDITIONAL:** Flag as WARNING for all Vue 3.5+ projects. Flag as BLOCKER only when Vapor Mode is explicitly enabled (check for `vapor: true` in `vite.config.ts` or `@vue/vapor` in dependencies).

## Detection

```bash
# $el and $forceUpdate usage
grep -rn '\$el\|\$forceUpdate' src/ --include='*.vue' --include='*.ts'

# mixins in components
grep -rn 'mixins:' src/ --include='*.vue' --include='*.ts'

# Manual render functions in .vue SFC
grep -rn 'defineComponent.*render\|render()' src/ --include='*.vue' --include='*.ts'

# Check if Vapor is active
grep -rn 'vapor.*true\|@vue/vapor' vite.config.* package.json 2>/dev/null
```

## Bad Example

```vue
<script setup lang="ts">
import { getCurrentInstance } from 'vue';

// ❌ $el — relies on VDOM root element
const instance = getCurrentInstance();
const rootWidth = instance?.proxy?.$el?.offsetWidth;

// ❌ $forceUpdate — forces VDOM reconciliation
instance?.proxy?.$forceUpdate();
</script>
```

```ts
// ❌ mixins — not optimizable by Vapor
import { type Component } from 'vue';
import { LoggingMixin } from '@/mixins/logging';

export default defineComponent({
  mixins: [LoggingMixin],
  // ...
});
```

```ts
// ❌ Manual render function — bypasses template compilation
export default defineComponent({
  render() {
    return h('div', { class: 'card' }, this.title);
  }
});
```

## Good Example

```vue
<script setup lang="ts">
import { ref, useTemplateRef } from 'vue';

// ✅ Template ref — works with Vapor
const cardRef = useTemplateRef<HTMLDivElement>('card');

// ✅ No $forceUpdate needed — reactive system handles updates
const counter = ref(0);
const increment = () => { counter.value++; };
</script>

<template>
  <div ref="card">{{ counter }}</div>
  <button @click="increment">+1</button>
</template>
```

```ts
// ✅ Composable instead of mixin
import { ref, onMounted } from 'vue';

export function useLogging(context: string) {
  onMounted(() => { console.info(`[${context}] mounted`); });
}
```

## Rule

BANNED (Vapor Mode active): `$el`, `$forceUpdate()`, `mixins:`, manual `render()` in SFC.
WARNING (Vue 3.5+ without Vapor): Same patterns — flag for migration readiness.
REQUIRED: Use `useTemplateRef()` instead of `$el`, composables instead of mixins, `<template>` instead of `render()`.
