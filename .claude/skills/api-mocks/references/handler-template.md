# Handler + Fixture Templates

## Fixture Factory Template

```typescript
// fixtures/user.ts
import type { User } from '@/features/user/api/userTypes';

export function createUser(overrides?: Partial<User>): User {
  return {
    id: '1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    avatar: 'https://example.com/avatars/1.png',
    role: 'user',
    createdAt: '2024-01-15T10:30:00Z',
    ...overrides,
  };
}

export function createUserList(
  count: number = 3,
  overrides?: Partial<User>,
): User[] {
  return Array.from({ length: count }, (_, i) =>
    createUser({
      id: String(i + 1),
      name: `User ${i + 1}`,
      email: `user${i + 1}@example.com`,
      ...overrides,
    }),
  );
}
```

## OpenAPI Field → Realistic Value Mapping

| Type + Format | Field name hint | Default value |
|---------------|-----------------|---------------|
| `string` | `id` | `'1'` |
| `string` | `name`, `fullName` | `'John Doe'` |
| `string` + `email` | `email` | `'john.doe@example.com'` |
| `string` + `uri` | `url`, `avatar`, `image` | `'https://example.com/image.png'` |
| `string` + `date-time` | `createdAt`, `updatedAt` | `'2024-01-15T10:30:00Z'` |
| `string` + `date` | `birthDate` | `'1990-05-20'` |
| `string` + `uuid` | `uuid`, `externalId` | `'550e8400-e29b-41d4-a716-446655440000'` |
| `string` (enum) | `status`, `role` | First enum value |
| `integer` | `age` | `30` |
| `integer` | `count`, `total` | `10` |
| `integer` | `page` | `1` |
| `number` | `price`, `amount` | `29.99` |
| `boolean` | `isActive`, `enabled` | `true` |
| `boolean` | `isDeleted`, `archived` | `false` |
| `array` | `items`, `tags` | `[]` (empty or 2-3 items) |
| `object` | `address`, `metadata` | Nested object with defaults |

## Handler Templates

### GET List Handler

```typescript
http.get('/api/users', ({ request }) => {
  const url = new URL(request.url);
  const page = Number(url.searchParams.get('page') ?? '1');
  const limit = Number(url.searchParams.get('limit') ?? '10');

  return HttpResponse.json({
    data: createUserList(limit),
    meta: { page, limit, total: 25 },
  });
})
```

### GET By ID Handler

```typescript
http.get('/api/users/:id', ({ params }) => {
  return HttpResponse.json(createUser({ id: String(params.id) }));
})
```

### POST Handler

```typescript
http.post('/api/users', async ({ request }) => {
  const body = await request.json() as CreateUserRequest;
  return HttpResponse.json(
    createUser({ ...body, id: '99', createdAt: new Date().toISOString() }),
    { status: 201 },
  );
})
```

### PUT Handler

```typescript
http.put('/api/users/:id', async ({ params, request }) => {
  const body = await request.json() as UpdateUserRequest;
  return HttpResponse.json(
    createUser({ id: String(params.id), ...body }),
  );
})
```

### PATCH Handler

```typescript
http.patch('/api/users/:id', async ({ params, request }) => {
  const body = await request.json() as Partial<UpdateUserRequest>;
  return HttpResponse.json(
    createUser({ id: String(params.id), ...body }),
  );
})
```

### DELETE Handler

```typescript
http.delete('/api/users/:id', () => {
  return new HttpResponse(null, { status: 204 });
})
```

## Error Handler Variants Template

```typescript
// Error handlers for per-test server.use() overrides
export const userErrorHandlers = {
  unauthorized: http.get('/api/users', () => {
    return HttpResponse.json(
      { message: 'Unauthorized' },
      { status: 401 },
    );
  }),

  forbidden: http.get('/api/users', () => {
    return HttpResponse.json(
      { message: 'Forbidden' },
      { status: 403 },
    );
  }),

  notFound: http.get('/api/users/:id', () => {
    return HttpResponse.json(
      { message: 'User not found' },
      { status: 404 },
    );
  }),

  validationError: http.post('/api/users', () => {
    return HttpResponse.json(
      {
        message: 'Validation failed',
        errors: [
          { field: 'email', message: 'Invalid email format' },
          { field: 'name', message: 'Name is required' },
        ],
      },
      { status: 422 },
    );
  }),

  serverError: http.get('/api/users', () => {
    return HttpResponse.json(
      { message: 'Internal server error' },
      { status: 500 },
    );
  }),

  networkError: http.get('/api/users', () => {
    return HttpResponse.error();
  }),
};
```

## server.ts Template

```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

## browser.ts Template

```typescript
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

## Vitest Setup Snippet

```typescript
// Add to vitest.setup.ts or setupTests.ts
import { server } from '@/shared/mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Barrel Exports

### fixtures/index.ts

```typescript
export { createUser, createUserList } from './user';
export { createOrder, createOrderList } from './order';
```

### index.ts (root barrel)

```typescript
export { handlers } from './handlers';
export { server } from './server';
export * from './fixtures';
```
