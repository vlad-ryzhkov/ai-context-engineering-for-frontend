# Anti-Pattern: v-for-no-key

## Problem

`v-for` directive used without a `:key` binding.

## Why It's Bad

- Vue cannot track which DOM node corresponds to which list item
- Re-renders are incorrect when items are added, removed, or reordered
- Causes stale component state (form input values, child component state)

## Detection

```bash
grep -n "v-for" src/ -r | grep -v ":key"
```

## Bad Example

```vue
<!-- ❌ v-for without :key -->
<template>
  <ul>
    <li v-for="user in users">{{ user.name }}</li>
  </ul>
</template>
```

## Good Example

```vue
<!-- ✅ v-for with stable :key -->
<template>
  <ul>
    <li v-for="user in users" :key="user.id">{{ user.name }}</li>
  </ul>
</template>
```

## Rule

BANNED: `v-for` without `:key`.
REQUIRED: `:key="item.id"` — stable, unique identifier from the data (not index).

Note: `:key="index"` has the same problems as React's `key={index}`. Use only for truly static, never-reordered lists with no stateful children.
