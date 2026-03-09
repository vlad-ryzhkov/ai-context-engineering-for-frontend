# TanStack Query Patterns — Vue

## useQuery (read data)

```typescript
import { useQuery } from '@tanstack/vue-query';

export function useUsers() {
  return useQuery<User[], Error>({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await fetch(
        `${import.meta.env.VITE_API_BASE_URL}/users`
      );
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: Failed to fetch users`);
      }
      return response.json() as Promise<User[]>;
    },
    staleTime: 5 * 60 * 1000,
    retry: 2,
  });
}
```

## useMutation (write data)

```typescript
import { useMutation, useQueryClient } from '@tanstack/vue-query';

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation<User, Error, CreateUserRequest>({
    mutationFn: async (request) => {
      const response = await fetch(
        `${import.meta.env.VITE_API_BASE_URL}/users`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(request),
        }
      );
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.json() as Promise<User>;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

## VueQueryPlugin Setup

```typescript
// main.ts
import { VueQueryPlugin, QueryClient } from '@tanstack/vue-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { staleTime: 60_000, retry: 2 },
  },
});

app.use(VueQueryPlugin, { queryClient });
```

## Reactive Query Keys

```typescript
// Reactive filtering
const status = ref<'active' | 'inactive'>('active');

const { data } = useQuery({
  queryKey: computed(() => ['users', { status: status.value }]),
  queryFn: () => fetchUsers({ status: status.value }),
});
// Query re-runs automatically when status.value changes
```

## Parameterized Hook

Use `MaybeRef` so the composable accepts both plain values and reactive refs.

```typescript
import { useQuery } from '@tanstack/vue-query';
import { computed, unref, type MaybeRef } from 'vue';

export function useUser(id: MaybeRef<string>) {
  return useQuery<User, Error>({
    queryKey: computed(() => ['users', unref(id)]),
    queryFn: () => getUser(unref(id)),
  });
}
```

- `computed()` wraps the key so Vue Query re-fetches when the ref changes.
- `unref()` unwraps the value whether it is a plain value or a `Ref`.
- For optional params use `MaybeRef<Params | undefined>` and include `enabled: computed(() => unref(params) !== undefined)`.

## Connect (gRPC) Integration

### useQuery with Connect client

```typescript
import { useQuery } from '@tanstack/vue-query';
import { computed, unref, type MaybeRef } from 'vue';
import { getUser } from './userApi'; // Connect client function

export function useUser(userId: MaybeRef<string>) {
  return useQuery({
    queryKey: computed(() => ['users', unref(userId)]),
    queryFn: () => getUser(unref(userId)),
    enabled: computed(() => Boolean(unref(userId))),
  });
}
```

### useMutation with Connect client

```typescript
import { useMutation, useQueryClient } from '@tanstack/vue-query';
import { createUser } from './userApi';
import type { CreateUserRequest } from './userTypes';

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserRequest) => createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

### Server Streaming Composable (useServerStream)

```typescript
import { ref, watchEffect, type Ref } from 'vue';

export function useServerStream<TRequest, TItem>(
  method: (request: TRequest, options: { signal: AbortSignal }) => AsyncIterable<TItem>,
  request: Ref<TRequest>,
  enabled: Ref<boolean> = ref(true) as Ref<boolean>,
) {
  const items = ref<TItem[]>([]) as Ref<TItem[]>;
  const isStreaming = ref(false);
  const error = ref<Error | null>(null);

  watchEffect((onCleanup) => {
    if (!enabled.value) return;
    const abortController = new AbortController();
    onCleanup(() => abortController.abort());

    isStreaming.value = true;
    error.value = null;
    items.value = [];

    (async () => {
      try {
        for await (const item of method(request.value, { signal: abortController.signal })) {
          items.value = [...items.value, item];
        }
      } catch (err) {
        if (!abortController.signal.aborted) {
          error.value = err instanceof Error ? err : new Error(String(err));
        }
      } finally {
        isStreaming.value = false;
      }
    })();
  });

  return { items, isStreaming, error };
}
```
