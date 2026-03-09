# Protobuf / gRPC Patterns for Frontend

## Proto → TypeScript Type Mapping

| Proto Type | TypeScript Type | Notes |
|-----------|-----------------|-------|
| `string` | `string` | |
| `int32` / `sint32` / `sfixed32` | `number` | Safe for all values |
| `int64` / `sint64` / `sfixed64` | `string` | ⚠️ Values > 2^53 lose precision — transmit as string |
| `uint32` / `fixed32` | `number` | |
| `uint64` / `fixed64` | `string` | Same as int64 |
| `float` / `double` | `number` | |
| `bool` | `boolean` | |
| `bytes` | `string` | Base64 encoded |
| `enum` | `as const` object | See enum pattern below |
| `repeated T` | `T[]` | |
| `map<K, V>` | `Record<K, V>` | K must be string or number |
| `optional T` | `T \| undefined` | Use `?` in interface |
| `oneof` | Discriminated union | See oneof pattern below |
| Nested message | Separate interface | PascalCase concatenation |

## Well-Known Types

| Proto Type | TypeScript Type | Notes |
|-----------|-----------------|-------|
| `google.protobuf.Timestamp` | `string` | ISO 8601 format (`2024-01-15T10:30:00Z`) |
| `google.protobuf.Duration` | `string` | Duration string (`300s`) |
| `google.protobuf.Any` | `unknown` | Requires runtime type narrowing |
| `google.protobuf.Struct` | `Record<string, unknown>` | JSON-compatible object |
| `google.protobuf.Value` | `unknown` | Any JSON value |
| `google.protobuf.Empty` | `void` | No payload |
| `google.protobuf.StringValue` | `string \| null` | Nullable wrapper |
| `google.protobuf.Int32Value` | `number \| null` | Nullable wrapper |
| `google.protobuf.BoolValue` | `boolean \| null` | Nullable wrapper |
| `google.protobuf.FieldMask` | `string[]` | List of field paths |

## Proto Enum → `as const` Object

```typescript
// Proto:
// enum UserStatus {
//   USER_STATUS_UNSPECIFIED = 0;
//   USER_STATUS_ACTIVE = 1;
//   USER_STATUS_INACTIVE = 2;
// }

export const UserStatus = {
  UNSPECIFIED: 0,
  ACTIVE: 1,
  INACTIVE: 2,
} as const;

export type UserStatus = (typeof UserStatus)[keyof typeof UserStatus];
```

Strip the enum name prefix (e.g., `USER_STATUS_`) for cleaner TS names.

## Proto `oneof` → Discriminated Union

```typescript
// Proto:
// message Notification {
//   oneof payload {
//     EmailPayload email = 1;
//     SmsPayload sms = 2;
//   }
// }

export interface EmailPayload {
  subject: string;
  body: string;
}

export interface SmsPayload {
  phoneNumber: string;
  text: string;
}

export type NotificationPayload =
  | { kind: 'email'; email: EmailPayload }
  | { kind: 'sms'; sms: SmsPayload };
```

## Nested Messages → Separate Interfaces

```typescript
// Proto:
// message Order {
//   message Item {
//     string product_id = 1;
//     int32 quantity = 2;
//   }
//   repeated Item items = 1;
// }

export interface OrderItem {
  productId: string;
  quantity: number;
}

export interface Order {
  items: OrderItem[];
}
```

Convention: `{ParentMessage}{NestedMessage}` in PascalCase. Convert `snake_case` fields to `camelCase`.

## Connect Transport Setup

```typescript
// transport.ts
import { createConnectTransport } from '@connectrpc/connect-web';

export const transport = createConnectTransport({
  baseUrl: import.meta.env.VITE_GRPC_BASE_URL,
});
```

## gRPC-Web Transport (Fallback)

```typescript
// transport.ts
import { createGrpcWebTransport } from '@connectrpc/connect-web';

export const transport = createGrpcWebTransport({
  baseUrl: import.meta.env.VITE_GRPC_BASE_URL,
});
```

Use `--transport=grpc-web` flag to generate this variant.

## Unary RPC Client Function

```typescript
// {feature}Api.ts
import { createClient } from '@connectrpc/connect';
import { transport } from '@/shared/api/transport';
import type { {ServiceName} } from './{feature}Types';

const client = createClient({ServiceName}, transport);

export async function getUser(userId: string): Promise<User> {
  const response = await client.getUser({ id: userId });
  return response;
}

export async function createUser(data: CreateUserRequest): Promise<User> {
  const response = await client.createUser(data);
  return response;
}
```

## Server Streaming Hook — React

```typescript
import { useState, useEffect, useCallback } from 'react';
import { createClient } from '@connectrpc/connect';
import { transport } from '@/shared/api/transport';

interface UseServerStreamOptions<TItem> {
  enabled?: boolean;
  onError?: (error: Error) => void;
  onComplete?: (items: TItem[]) => void;
}

export function useServerStream<TRequest, TItem>(
  method: (request: TRequest, options: { signal: AbortSignal }) => AsyncIterable<TItem>,
  request: TRequest,
  options: UseServerStreamOptions<TItem> = {},
) {
  const { enabled = true, onError, onComplete } = options;
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
        onComplete?.(items);
      } catch (err) {
        if (!abortController.signal.aborted) {
          const error = err instanceof Error ? err : new Error(String(err));
          setError(error);
          onError?.(error);
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

## Server Streaming Composable — Vue

```typescript
import { ref, watchEffect, type Ref } from 'vue';

interface UseServerStreamOptions {
  enabled?: Ref<boolean> | boolean;
}

export function useServerStream<TRequest, TItem>(
  method: (request: TRequest, options: { signal: AbortSignal }) => AsyncIterable<TItem>,
  request: Ref<TRequest>,
  options: UseServerStreamOptions = {},
) {
  const items = ref<TItem[]>([]) as Ref<TItem[]>;
  const isStreaming = ref(false);
  const error = ref<Error | null>(null);

  watchEffect((onCleanup) => {
    const enabled = typeof options.enabled === 'object'
      ? options.enabled.value
      : options.enabled ?? true;
    if (!enabled) return;

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

## gRPC Error Codes → HTTP Status

| gRPC Code | HTTP Status | When to use |
|-----------|-------------|-------------|
| `OK` | 200 | Success |
| `Cancelled` | 499 | Client cancelled request |
| `InvalidArgument` | 400 | Validation error |
| `NotFound` | 404 | Resource not found |
| `AlreadyExists` | 409 | Duplicate resource |
| `PermissionDenied` | 403 | Authorization failure |
| `Unauthenticated` | 401 | Missing/invalid credentials |
| `ResourceExhausted` | 429 | Rate limited |
| `FailedPrecondition` | 400 | State precondition failed |
| `Unimplemented` | 501 | RPC not implemented |
| `Internal` | 500 | Server error |
| `Unavailable` | 503 | Service unavailable |
| `DeadlineExceeded` | 504 | Timeout |

## RPC Name → Hook Type Convention

| RPC Name Pattern | Hook Type | Notes |
|-----------------|-----------|-------|
| `Get*` / `List*` / `Fetch*` / `Search*` | `useQuery` | Read operations |
| `Create*` / `Update*` / `Delete*` / `Set*` / `Remove*` | `useMutation` | Write operations |
| Server streaming RPC | `useServerStream` | Custom hook (see patterns above) |
| Client streaming / Bidi streaming | WARN | Not supported in browser — emit warning |
