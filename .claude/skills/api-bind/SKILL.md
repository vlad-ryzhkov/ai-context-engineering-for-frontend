---
name: api-bind
description: >
  Generate typed API client + query hook from OpenAPI spec or Protobuf (.proto) file.
  Requires framework parameter [react|vue]. Output: types + client function + TanStack Query hook.
  Do not use without an OpenAPI spec file or .proto file.
allowed-tools: "Read Write Edit Glob Grep Bash(npx tsc*) Bash(npx openapi-ts*) Bash(npx @hey-api/openapi-ts*)"
agent: agents/engineer.md
context: fork
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# API Bind — OpenAPI / Protobuf → Types + Client + Hook

<purpose>
Given an OpenAPI specification (URL or local file) or a Protobuf (.proto) file, generates:
1. TypeScript types (request/response)
2. Typed client function (fetch for OpenAPI, Connect for proto)
3. TanStack Query hook (react-query or vue-query)
The hook is ready to drop into a component with all 4 states.
For proto input, uses `@connectrpc/connect-web` (Connect protocol) by default.
</purpose>

## Phase Checkpoints

```text
STOP  if: framework param missing or not react/vue | no spec provided | spec file not found | .proto file has no service block
WARN  if: .claude/conventions/api-layer.md stub unfilled (no VITE_API_BASE_URL / VITE_GRPC_BASE_URL defined)
INFORM: framework=[react|vue], source=[openapi|proto], endpoint=[METHOD /path | RPC name], output-path=[resolved path]
```

## Input Validation (MANDATORY)

```text
Usage: /api-bind [react|vue] [spec-path-or-url] [endpoint-or-rpc]
Example: /api-bind react ./openapi.json GET /users
         /api-bind vue ./swagger.yaml POST /orders
         /api-bind react ./proto/user.proto UserService.GetUser
         /api-bind vue ./proto/order.proto OrderService.ListOrders --transport=grpc-web
```

Auto-detect format by file extension: `.json`/`.yaml`/`.yml` → OpenAPI, `.proto` → Protobuf.

Optional flags: `--transport=connect` (default) | `--transport=grpc-web` | `--transport=rest`

BLOCKER if:

- Framework not `react` or `vue`
- No spec provided (OpenAPI or proto)
- Spec file does not exist (check with Glob)
- Proto file has no `service` block

## Protocol

### BANNED

- Raw `fetch` in component body — FORBIDDEN (use hook)
- `axios` without type generation — use HeyAPI or typed fetch
- `: any` for request/response types — FORBIDDEN
- Catching errors silently — errors MUST propagate to query state
- Hardcoded base URLs — use env var `import.meta.env.VITE_API_BASE_URL` (OpenAPI) or `VITE_GRPC_BASE_URL` (proto)
- Hardcoded gRPC URL — FORBIDDEN, use `import.meta.env.VITE_GRPC_BASE_URL`
- Raw `grpc-web` calls without typed stubs — use Connect client with typed service definition

### MANDATORY

- **OpenAPI:** `@hey-api/openapi-ts` is used ONLY to extract TypeScript interfaces into `{feature}Types.ts`. The fetch client `{feature}Api.ts` MUST be written manually per the reference templates.
- **Proto:** Types are parsed from proto `message` blocks (no openapi-ts). Enums use `as const` object pattern. Type mapping from `references/proto-grpc.md`.
- Assume `import.meta.env.VITE_API_BASE_URL` (OpenAPI) or `VITE_GRPC_BASE_URL` (proto) exists. NEVER create or modify `.env` files unless explicitly instructed.
- If the endpoint has path params, query params, or a request body — the client function MUST accept a typed params object. The hook MUST include params in `queryKey` and pass them to the client function.

## Hook Routing

### OpenAPI — Map HTTP method to TanStack Query hook type

| HTTP Method | Hook | Notes |
|---|---|---|
| GET | `useQuery` | see `references/react-query.md` or `vue-query.md` |
| POST \| PUT \| PATCH \| DELETE | `useMutation` | with `queryClient.invalidateQueries` on success |

### Proto — Map RPC pattern to TanStack Query hook type

| RPC Pattern | Hook | Notes |
|---|---|---|
| `Get*` / `List*` / `Fetch*` / `Search*` (unary) | `useQuery` | Read operations |
| `Create*` / `Update*` / `Delete*` / `Set*` / `Remove*` (unary) | `useMutation` | Write operations |
| Server streaming RPC | `useServerStream` | Custom hook — see `references/proto-grpc.md` |
| Client streaming / Bidi streaming | WARN | Not supported in browser — emit warning and skip |

## Workflow

1. **Validate** — framework param + spec file exists. Apply Phase Checkpoints above.
1a. **Pre-Load Context** — read API layer conventions before generating:

    ```bash
    cat .claude/conventions/api-layer.md 2>/dev/null || true
    ```

    Use discovered base URL pattern and auth header conventions in generated client.
1b. **Detect format** — auto-detect by file extension: `.json`/`.yaml`/`.yml` → OpenAPI (step 2), `.proto` → Protobuf (step 2p).

### OpenAPI Branch

2. **Parse spec** — read OpenAPI JSON/YAML, extract endpoint schema (request/response)
3. **Generate types** — `{Feature}Types.ts` with request and response interfaces
4. **Generate client** — `{feature}Api.ts` typed fetch function
5. **Generate hook** — `use{Feature}.ts` TanStack Query hook for the framework

### Proto Branch

2p. **Parse proto** — read `.proto` file, extract `service` block + `message` definitions. STOP if no `service` found.
3p. **Generate types** — `{Feature}Types.ts` from `message` blocks using type mapping from `references/proto-grpc.md`. Enums → `as const` objects. `oneof` → discriminated unions. Nested messages → separate interfaces.
4p. **Generate client** — `{feature}Api.ts` with Connect transport setup + typed client functions. Use `--transport` flag to select transport (default: `connect`).
5p. **Generate hook** — `use{Feature}.ts` TanStack Query hook. Unary RPCs → useQuery/useMutation per Hook Routing table. Server streaming → `useServerStream` custom hook.

### Common

6. **Type check** — `npx tsc --noEmit`
7. **Gardener** → SKILL COMPLETE

## Output Structure

```text
src/{layer}/{feature}/api/
├── {feature}Api.ts        # Typed fetch (OpenAPI) or Connect client (proto) function
├── {feature}Types.ts      # Request/response TypeScript types
└── use{Feature}.ts        # TanStack Query hook
```

## Generated Hook Template (React)

```typescript
// useUsers.ts
import { useQuery } from '@tanstack/react-query';
import { getUsers } from './usersApi';
import type { User, UsersParams } from './usersTypes';

export function useUsers(params?: UsersParams) {
  return useQuery<User[], Error>({
    queryKey: ['users', params],
    queryFn: () => getUsers(params),
    staleTime: 5 * 60 * 1000,
  });
}
```

## Generated Hook Template (Vue)

```typescript
// useUsers.ts
import { useQuery } from '@tanstack/vue-query';
import { computed, unref, type MaybeRef } from 'vue';
import { getUsers } from './usersApi';
import type { User, UsersParams } from './usersTypes';

export function useUsers(params?: MaybeRef<UsersParams>) {
  return useQuery<User[], Error>({
    queryKey: computed(() => ['users', unref(params)]),
    queryFn: () => getUsers(unref(params)),
    staleTime: 5 * 60 * 1000,
  });
}
```

## Generated Hook Template — Proto Unary (React)

```typescript
// useUser.ts (proto + Connect)
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getUser, createUser } from './userApi';
import type { CreateUserRequest } from './userTypes';

const userKeys = {
  all: ['users'] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

export function useUser(userId: string) {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => getUser(userId),
    enabled: Boolean(userId),
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateUserRequest) => createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.all });
    },
  });
}
```

## Generated Hook Template — Proto Unary (Vue)

```typescript
// useUser.ts (proto + Connect)
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query';
import { computed, unref, type MaybeRef } from 'vue';
import { getUser, createUser } from './userApi';
import type { CreateUserRequest } from './userTypes';

const userKeys = {
  all: ['users'] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

export function useUser(userId: MaybeRef<string>) {
  return useQuery({
    queryKey: computed(() => userKeys.detail(unref(userId))),
    queryFn: () => getUser(unref(userId)),
    enabled: computed(() => Boolean(unref(userId))),
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateUserRequest) => createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.all });
    },
  });
}
```

## References

- React hook patterns: `references/react-query.md`
- Vue hook patterns: `references/vue-query.md`
- Proto/gRPC patterns: `references/proto-grpc.md`

## Quality Gate

- [ ] Framework param validated (`react`/`vue`)
- [ ] Spec file found and parsed (OpenAPI or proto)
- [ ] Types file generated with no `: any`
- [ ] Client function uses `import.meta.env.VITE_API_BASE_URL` (OpenAPI) or `VITE_GRPC_BASE_URL` (proto)
- [ ] Hook uses correct TanStack Query hook for HTTP method (OpenAPI) or RPC pattern (proto)
- [ ] `tsc --noEmit` PASS
- [ ] (Proto) Service block extracted from `.proto` file
- [ ] (Proto) All `message` types mapped to TypeScript interfaces
- [ ] (Proto) Enums use `as const` object pattern
- [ ] (Proto) Connect transport configured with env var

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /api-bind
├─ Framework: [react | vue]
├─ Source: [openapi | proto]
├─ Transport: [fetch | connect | grpc-web]
├─ Artifacts: [{feature}Types.ts, {feature}Api.ts, use{Feature}.ts]
├─ Endpoint: [METHOD /path | ServiceName.RpcName]
├─ Type Check: [PASS | FAIL]
└─ Coverage: [types + client + hook]
```
