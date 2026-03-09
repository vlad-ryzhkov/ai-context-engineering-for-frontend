# Vue Component Patterns

## SFC Template (with TanStack Query)

```vue
<!-- UserList.vue -->
<script setup lang="ts">
import { computed } from 'vue';
import { useQuery } from '@tanstack/vue-query';
import type { UserListProps } from './UserList.types';

const props = defineProps<UserListProps>();

const { data, isLoading, isError, refetch } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
});

const isEmpty = computed(() => !data.value || data.value.length === 0);
</script>

<template>
  <div>
    <!-- Loading -->
    <UserListSkeleton v-if="isLoading" />

    <!-- Error -->
    <div
      v-else-if="isError"
      role="alert"
      class="rounded-lg bg-red-50 p-4 text-red-800"
    >
      <p>Failed to load users. Please try again.</p>
      <button class="mt-2 text-sm underline" @click="refetch()">Retry</button>
    </div>

    <!-- Empty -->
    <div v-else-if="isEmpty" class="py-12 text-center text-gray-500">
      <p>No users found.</p>
    </div>

    <!-- Success -->
    <section v-else :aria-label="props.title">
      <h2 class="text-xl font-semibold">{{ props.title }}</h2>
      <ul class="mt-4 space-y-2">
        <li
          v-for="user in data"
          :key="user.id"
          class="rounded border p-3"
        >
          {{ user.name }}
        </li>
      </ul>
    </section>
  </div>
</template>
```

## Types Template

```typescript
// UserList.types.ts
export interface UserListProps {
  title: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
}
```

## Skeleton Component

```vue
<!-- UserListSkeleton.vue -->
<script setup lang="ts" />

<template>
  <div role="status" aria-label="Loading users" class="space-y-2">
    <div
      v-for="n in 3"
      :key="n"
      class="h-12 animate-pulse rounded bg-gray-200"
    />
    <span class="sr-only">Loading...</span>
  </div>
</template>
```

## Barrel Export

```typescript
// index.ts
export { default } from './UserList.vue';
export type { UserListProps, User } from './UserList.types';
```

## Composable Pattern

```typescript
// useUsers.ts
import { useQuery } from '@tanstack/vue-query';
import type { User } from './UserList.types';

export function useUsers() {
  return useQuery<User[]>({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await fetch('/api/users');
      if (!response.ok) throw new Error('Failed to fetch users');
      return response.json() as Promise<User[]>;
    },
    staleTime: 5 * 60 * 1000,
  });
}
```

## Key Rules

- `<script setup lang="ts">` — always (no Options API)
- `defineProps<T>()` — always with TypeScript generic, never `defineProps({ ... })`
- `defineEmits<{ ... }>()` — typed emits always
- `v-for` — always `:key` with stable unique ID, never index
- `computed` for derived state — never mutate in template
- Template complexity: max 2 conditions, else extract to component
- **NEVER destructure TanStack Query return** — `const { data } = useQuery(...)` silently breaks reactivity; keep the result object and use `query.data`, `query.isLoading`, etc.
- **NEVER destructure `reactive()` without `toRefs()`** — use `toRefs(state)` or switch to individual `ref()` values
- **NEVER put `v-if` and `v-for` on the same element** — `v-if` evaluates before `v-for`; filter with `computed` instead

## defineModel — Two-way Binding (Vue 3.4+)

Use `defineModel()` instead of the manual `props + emit` pattern for v-model components.

```ts
// ✅ Vue 3.4+ — defineModel() (preferred)
const model = defineModel<string>(); // auto-generates modelValue prop + update:modelValue emit
// In template: <input :value="model" @input="model = $event.target.value" />
// Or with modifiers:
const [model, modifiers] = defineModel<string, 'trim' | 'uppercase'>();

// ❌ Old pattern (Vue < 3.4) — verbose, still valid but unnecessary in 3.4+
const props = defineProps<{ modelValue: string }>();
const emit = defineEmits<{ 'update:modelValue': [string] }>();
```

```text
REQUIRED: Use defineModel() for any component that implements v-model (Vue 3.4+).
BANNED: Manual props.modelValue + emit('update:modelValue') pattern in new Vue 3.4+ code.
```

## Form Handling

Use VeeValidate + Zod for complex forms; native Composition API for simple forms.

```vue
<!-- Simple form — native Composition API -->
<script setup lang="ts">
import { ref, reactive } from 'vue';
import { useMutation } from '@tanstack/vue-query';

interface LoginForm {
  email: string;
  password: string;
}

const form = reactive<LoginForm>({ email: '', password: '' });
const errors = reactive<Partial<LoginForm>>({});

function validate(): boolean {
  errors.email = form.email.includes('@') ? undefined : 'Valid email required';
  errors.password = form.password.length >= 8 ? undefined : 'Min 8 characters';
  return !errors.email && !errors.password;
}

const { mutate: login, isPending, isError } = useMutation({
  mutationFn: (data: LoginForm) =>
    fetch('/api/auth/login', { method: 'POST', body: JSON.stringify(data) }),
});

function handleSubmit() {
  if (!validate()) return;
  login(form);
}
</script>

<template>
  <form data-testid="login-form" @submit.prevent="handleSubmit">
    <div>
      <label for="email">Email</label>
      <input id="email" v-model="form.email" type="email" data-testid="email-input" />
      <p v-if="errors.email" role="alert" class="text-sm text-red-600">{{ errors.email }}</p>
    </div>
    <div>
      <label for="password">Password</label>
      <input id="password" v-model="form.password" type="password" data-testid="password-input" />
      <p v-if="errors.password" role="alert" class="text-sm text-red-600">{{ errors.password }}</p>
    </div>
    <button type="submit" :disabled="isPending" data-testid="submit-button">
      {{ isPending ? 'Signing in…' : 'Sign in' }}
    </button>
    <p v-if="isError" role="alert" class="text-red-600">Sign-in failed. Check your credentials and try again.</p>
  </form>
</template>
```

```text
BANNED: Multiple individual ref() per form field (ref email, ref password, ref name…) — use reactive({}) for the form object.
BANNED: Form submission without loading/error/success states.
REQUIRED: Every input has an associated <label> (htmlFor/for or wrapping label).
REQUIRED: Errors displayed with role="alert" for screen reader announcement.
PREFERRED: VeeValidate + Zod for forms with 5+ fields or complex cross-field validation.
```

### INP — Interaction to Next Paint

- Use `v-memo` on expensive list items to skip re-renders when unrelated state changes:

  ```html
  <ListItem v-for="item in items" :key="item.id" v-memo="[item.id, item.selected]" />
  ```

- Use `v-once` for nodes that render once and never change.

### Code Splitting — Heavy Dependencies

- Use `defineAsyncComponent` for any component that imports a library > ~50 kB:

  ```ts
  const HeavyChart = defineAsyncComponent({
    loader: () => import('./HeavyChart.vue'),
    loadingComponent: ChartSkeleton,
    errorComponent: ChartError,
  });
  ```

## Watch Guidelines

Use `watch` when you need the old value, lazy execution, or explicit source control.
Use `watchEffect` when the effect depends on multiple reactive sources and runs immediately.

```ts
// ✅ watch — explicit source, access to old value
watch(
  () => props.userId,
  (newId, oldId) => {
    if (newId !== oldId) fetchUserProfile(newId);
  },
);

// ✅ watchEffect — multiple sources, runs immediately on mount
watchEffect(() => {
  document.title = `${route.params.id} — ${appName}`;
});

// ❌ ANTI-PATTERN: deep watch on large object — traverses entire tree on every mutation
watch(largeConfig, () => syncSettings(), { deep: true });

// ✅ Watch a specific property instead
watch(() => largeConfig.value.theme, () => syncTheme());
```

```text
BANNED: { deep: true } on large objects or arrays with >20 items — severe performance regression.
BANNED: watch() used to sync derived state — use computed() instead.
REQUIRED: Always specify explicit watch sources; avoid implicit watchEffect for expensive side effects.
PREFERRED: TanStack Query for server state; watch/watchEffect for local reactive side effects only.
```

## State Management

```typescript
// Local reactive state
const count = ref(0);
const user = reactive({ name: '', email: '' });

// Derived state: computed (not ref with watcher)
const fullName = computed(() => `${user.name} ${user.surname}`);

// Server state: TanStack Query (not ref + onMounted)
const { data } = useQuery({ queryKey: ['items'], queryFn: fetchItems });

// Global client state: Pinia
import { useUserStore } from '@/shared/stores/user';
const userStore = useUserStore();
```

## Pinia Store Pattern

```typescript
// stores/user.ts
import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', () => {
  const currentUser = ref<User | null>(null);

  function setUser(user: User) {
    currentUser.value = user;
  }

  return { currentUser, setUser };
});
```

## Optimistic Mutation Pattern (useMutation + rollback)

Use when the component contains a write action (like, follow, save, delete, submit).

```vue
<!-- LikeButton.vue -->
<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query';

interface LikeButtonProps {
  postId: string;
  initialLiked: boolean;
  initialCount: number;
}

const props = defineProps<LikeButtonProps>();
const queryClient = useQueryClient();

const { mutate: toggleLike, isPending } = useMutation({
  mutationFn: (liked: boolean) =>
    fetch(`/api/posts/${props.postId}/like`, {
      method: liked ? 'DELETE' : 'POST',
    }),

  // 1. Snapshot + optimistic update
  onMutate: async (liked: boolean) => {
    await queryClient.cancelQueries({ queryKey: ['post', props.postId] });
    const snapshot = queryClient.getQueryData(['post', props.postId]);

    queryClient.setQueryData(
      ['post', props.postId],
      (old: { liked: boolean; likeCount: number }) => ({
        ...old,
        liked: !liked,
        likeCount: liked ? old.likeCount - 1 : old.likeCount + 1,
      }),
    );

    return { snapshot };
  },

  // 2. Rollback on error
  onError: (_err, _liked, context) => {
    if (context?.snapshot) {
      queryClient.setQueryData(['post', props.postId], context.snapshot);
    }
  },

  // 3. Sync with server truth
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['post', props.postId] });
  },
});
</script>

<template>
  <button
    data-testid="like-button"
    type="button"
    :aria-label="initialLiked ? 'Unlike post' : 'Like post'"
    :aria-pressed="initialLiked"
    :disabled="isPending"
    class="flex items-center gap-1 rounded-full px-3 py-1 text-sm transition-colors"
    :class="[
      initialLiked ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-600',
      isPending && 'cursor-not-allowed opacity-50',
    ]"
    @click="toggleLike(initialLiked)"
  >
    <span
      v-if="isPending"
      aria-hidden="true"
      class="size-4 animate-spin rounded-full border-2 border-current border-t-transparent"
    />
    <span v-else aria-hidden="true">{{ initialLiked ? '♥' : '♡' }}</span>
    <span class="tabular-nums">{{ initialCount }}</span>
  </button>
</template>
```

```text
REQUIRED: onMutate → snapshot → optimistic update
REQUIRED: onError → restore snapshot (rollback)
REQUIRED: onSettled → invalidateQueries (server sync)
REQUIRED: button :disabled + inline spinner during isPending
REQUIRED: "Saving…" / "Liking…" copy — NEVER "Loading…" for mutations
BANNED: full loading overlay during mutation
BANNED: no rollback on error
```
