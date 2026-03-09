# Anti-Pattern: template-complexity

## Problem

Vue template contains complex logic expressions: nested ternaries, method chains, or 3+ conditions.

## Why It's Bad

- Templates are not testable in isolation
- Complex templates are hard to read and maintain
- Rerendering on unrelated changes because of inline function calls

## Detection

Look for nested ternaries or long expressions in templates:

```bash
grep -n "? .* : .* : " src/**/*.vue
```

## Bad Example

```vue
<!-- ❌ Complex template logic -->
<template>
  <div>
    {{ user.firstName + ' ' + (user.lastName ? user.lastName.toUpperCase() : '') }}
    <span v-if="items.filter(i => i.active && i.stock > 0).length > 0">
      {{ items.filter(i => i.active && i.stock > 0).length }} items available
    </span>
  </div>
</template>
```

## Good Example

```vue
<!-- ✅ Logic extracted to computed -->
<script setup lang="ts">
const fullName = computed(() =>
  [user.value.firstName, user.value.lastName?.toUpperCase()].filter(Boolean).join(' ')
);

const availableItems = computed(() =>
  items.value.filter(i => i.active && i.stock > 0)
);
</script>

<template>
  <div>
    {{ fullName }}
    <span v-if="availableItems.length > 0">
      {{ availableItems.length }} items available
    </span>
  </div>
</template>
```

## Rule

BANNED: Template expressions with 2+ method chains or ternaries.
REQUIRED: Extract to `computed` — testable, cached, readable.
