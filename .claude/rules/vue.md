---
globs: "*.vue"
---

# Vue Rules

- Composition API only (`<script setup lang="ts">`), Options API is FORBIDDEN in new code
- `defineProps` must use TypeScript generic: `defineProps<{ name: string }>()`
- `defineEmits` must be typed: `defineEmits<{ (e: 'update', value: string): void }>()`
- v-for: always bind `:key` with stable unique ID
- v-for + v-if: NEVER on same element (use `<template v-for>` with v-if on child)
- Reactivity: NEVER destructure reactive/ref without `toRefs()` — reactivity loss
- Watchers: prefer `watchEffect` for simple derived side effects, `watch` for specific sources
- Vapor Mode readiness: avoid `$el`, `$forceUpdate`, mixins, render functions
- `computed` vs function: use `computed()` for cached derived state, plain functions only for side-effect-free transforms called in templates with arguments
