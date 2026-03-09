# MSW v2 Patterns Reference

## Imports

```typescript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';       // Vitest / Node.js
import { setupWorker } from 'msw/browser';     // Browser dev mode
```

## Handler Signatures

### GET (list)

```typescript
http.get('/api/users', () => {
  return HttpResponse.json(createUserList());
})
```

### GET (by ID)

```typescript
http.get('/api/users/:id', ({ params }) => {
  const { id } = params;
  return HttpResponse.json(createUser({ id: String(id) }));
})
```

### POST

```typescript
http.post('/api/users', async ({ request }) => {
  const body = await request.json() as CreateUserRequest;
  return HttpResponse.json(createUser(body), { status: 201 });
})
```

### PUT / PATCH

```typescript
http.put('/api/users/:id', async ({ params, request }) => {
  const { id } = params;
  const body = await request.json() as UpdateUserRequest;
  return HttpResponse.json(createUser({ id: String(id), ...body }));
})
```

### DELETE

```typescript
http.delete('/api/users/:id', () => {
  return new HttpResponse(null, { status: 204 });
})
```

## Error Responses

```typescript
// 401 Unauthorized
HttpResponse.json({ message: 'Unauthorized' }, { status: 401 })

// 403 Forbidden
HttpResponse.json({ message: 'Forbidden' }, { status: 403 })

// 404 Not Found
HttpResponse.json({ message: 'User not found' }, { status: 404 })

// 422 Validation Error
HttpResponse.json(
  { message: 'Validation failed', errors: [{ field: 'email', message: 'Invalid email' }] },
  { status: 422 },
)

// 500 Internal Server Error
HttpResponse.json({ message: 'Internal server error' }, { status: 500 })

// Network Error
HttpResponse.error()
```

## Anti-Patterns

| Pattern (BANNED) | Why | Correct |
|------------------|-----|---------|
| `rest.get(...)` | MSW v1 API | `http.get(...)` |
| `res(ctx.json(...))` | MSW v1 response | `HttpResponse.json(...)` |
| `res(ctx.status(200), ctx.json(...))` | MSW v1 chaining | `HttpResponse.json(data, { status: 200 })` |
| Shared mutable array across handlers | State leaks between tests | Return fresh data from factory |
| `http.all('*', ...)` catch-all | Hides missing handlers | Explicit per-endpoint handlers |
| `onUnhandledRequest: 'bypass'` | Hides gaps in mock coverage | `onUnhandledRequest: 'error'` |
| Missing `server.resetHandlers()` | Handler overrides leak between tests | Always in `afterEach` |

## Per-Test Handler Override

Override specific handlers for error scenarios:

```typescript
import { server } from '@/shared/mocks/server';
import { userErrorHandlers } from '@/shared/mocks/handlers';

it('shows error when unauthorized', async () => {
  server.use(userErrorHandlers.unauthorized);
  // ... render component and assert error state
});
```

## Vitest Lifecycle Integration

```typescript
// vitest.setup.ts (or setupTests.ts)
import { server } from '@/shared/mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Browser Worker Setup (Dev Mode)

```typescript
// src/main.ts or src/app/providers.tsx
async function enableMocking(): Promise<void> {
  if (import.meta.env.DEV) {
    const { worker } = await import('@/shared/mocks/browser');
    await worker.start({ onUnhandledRequest: 'warn' });
  }
}

enableMocking().then(() => {
  // mount app
});
```

## Optional: Zod Runtime Validation

For extra safety, validate mock responses against Zod schemas:

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

http.get('/api/users/:id', ({ params }) => {
  const user = createUser({ id: String(params.id) });
  UserSchema.parse(user); // throws if fixture drifts from contract
  return HttpResponse.json(user);
})
```

This catches fixture drift when API contracts change but factories are not updated.
