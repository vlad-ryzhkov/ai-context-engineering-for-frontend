# Anti-Pattern: provide-inject-typing

## Problem

Using `provide()` and `inject()` without TypeScript typing via `InjectionKey`, losing type safety across the component tree.

## Why It's Bad

- `inject()` returns `unknown` without proper typing
- Typos in string keys cause silent undefined values
- No IDE autocompletion for injected values
- Refactoring key names breaks silently

## Detection

```bash
grep -rn "inject\(['\"].*['\"]" src/
grep -rn "provide\(['\"].*['\"]" src/
```

Grep signatures:

- `inject\(['"]` — string literal keys without InjectionKey
- `provide\(['"]` — string literal keys without InjectionKey
- `inject(` without `as` or generic type param

## Bad Example

```vue
<!-- ❌ Parent: string key, no type -->
<script setup lang="ts">
import { provide } from 'vue';

provide('user', { name: 'Alice', email: 'alice@example.com' });
</script>

<!-- ❌ Child: inject returns unknown, forced to cast -->
<script setup lang="ts">
import { inject } from 'vue';

const user = inject('user') as { name: string; email: string }; // unsafe cast
const theme = inject('theme'); // type is unknown
</script>
```

## Good Example

```ts
// ✅ Define typed injection keys in shared module
// src/shared/injection-keys.ts
import type { InjectionKey, Ref } from 'vue';

export interface User {
  name: string;
  email: string;
}

export const UserKey: InjectionKey<Ref<User>> = Symbol('user');
export const ThemeKey: InjectionKey<Ref<'light' | 'dark'>> = Symbol('theme');
```

```vue
<!-- ✅ Parent: typed provide -->
<script setup lang="ts">
import { provide, ref } from 'vue';
import { UserKey } from '@/shared/injection-keys';

const user = ref({ name: 'Alice', email: 'alice@example.com' });
provide(UserKey, user);
</script>

<!-- ✅ Child: typed inject with default -->
<script setup lang="ts">
import { inject } from 'vue';
import { UserKey } from '@/shared/injection-keys';

const user = inject(UserKey); // Ref<User> | undefined — type-safe!
</script>
```

## Rule

BANNED: String literal keys in `provide()` / `inject()`.
REQUIRED: Use `InjectionKey<T>` from `vue` for all provide/inject pairs.

## References

- [Vue provide/inject with TypeScript](https://vuejs.org/guide/typescript/composition-api.html#typing-provide-inject)
- [Vue InjectionKey](https://vuejs.org/api/composition-api-dependency-injection.html#provide)
