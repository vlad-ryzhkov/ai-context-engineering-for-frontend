# TanStack Query Patterns — React

## useQuery (read data)

```typescript
import { useQuery } from '@tanstack/react-query';

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
    staleTime: 5 * 60 * 1000,   // 5 minutes
    retry: 2,
  });
}
```

## useMutation (write data)

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';

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

## Query Key Convention

```typescript
// Hierarchical keys — always array
['users']                          // list
['users', userId]                  // single item
['users', userId, 'orders']        // nested resource
['users', { status: 'active' }]    // filtered list
```

## Error Handling

Always throw on non-OK response. Let `isError` and `error` flow to the component.
Never `catch` and return empty data — that hides errors from the user.

## Connect (gRPC) Integration

### useQuery with Connect client

```typescript
import { useQuery } from '@tanstack/react-query';
import { getUser } from './userApi'; // Connect client function

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['users', userId],
    queryFn: () => getUser(userId),
    enabled: Boolean(userId),
  });
}
```

### useMutation with Connect client

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
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

### Server Streaming (useServerStream)

```typescript
import { useState, useEffect } from 'react';

export function useServerStream<TRequest, TItem>(
  method: (request: TRequest, options: { signal: AbortSignal }) => AsyncIterable<TItem>,
  request: TRequest,
  enabled = true,
) {
  const [items, setItems] = useState<TItem[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!enabled) return;
    const abortController = new AbortController();
    setIsStreaming(true);
    setError(null);
    setItems([]);

    (async () => {
      try {
        for await (const item of method(request, { signal: abortController.signal })) {
          setItems((prev) => [...prev, item]);
        }
      } catch (err) {
        if (!abortController.signal.aborted) {
          setError(err instanceof Error ? err : new Error(String(err)));
        }
      } finally {
        setIsStreaming(false);
      }
    })();

    return () => abortController.abort();
  }, [enabled]);

  return { items, isStreaming, error };
}
```
