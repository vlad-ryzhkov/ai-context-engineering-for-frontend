# Anti-Pattern: direct-pinia-mutation

## Problem

Modifying Pinia store state directly from a component, outside of a store action.

## Why It's Bad

- Breaks the unidirectional data flow
- State changes are untraceable in Vue DevTools
- Impossible to add validation or side effects to the mutation
- With strict mode enabled: throws runtime error

## Detection

```bash
grep -rn "Store\(\)\." src/ | grep -v "\.action\|= use\|const\b"
```

## Bad Example

```vue
<script setup lang="ts">
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();

// ❌ Direct mutation outside store
function logout() {
  userStore.user = null;     // BANNED
  userStore.isLoggedIn = false; // BANNED
}
</script>
```

## Good Example

```typescript
// stores/user.ts
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null);
  const isLoggedIn = computed(() => Boolean(user.value));

  function logout() {
    user.value = null; // ✅ Inside action — tracked by DevTools
  }

  return { user, isLoggedIn, logout };
});
```

```vue
<script setup lang="ts">
const userStore = useUserStore();
// ✅ Call action
function handleLogout() { userStore.logout(); }
</script>
```

## Rule

BANNED: `store.field = value` from outside the store definition.
REQUIRED: All state mutations go through store actions (`defineStore` → function inside `setup()`).
