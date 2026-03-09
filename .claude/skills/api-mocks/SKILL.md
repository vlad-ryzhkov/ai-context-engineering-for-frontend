---
name: api-mocks
description: >
  Generate MSW v2 request handlers + typed fixtures from OpenAPI spec or /api-bind output.
  Framework-agnostic. Output: handlers.ts, server.ts, browser.ts (optional), typed fixtures.
allowed-tools: "Read Write Edit Glob Grep Bash(npx tsc*) Bash(npx vitest*)"
agent: agents/engineer.md
context: fork
auto-invoke: false
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# API Mocks — MSW v2 Handlers + Typed Fixtures

<purpose>
Given an OpenAPI specification, /api-bind output, or manual endpoint list, generates:
1. Typed fixture factories (`createUser()`, `createUserList()`) with `Partial<T>` overrides
2. MSW v2 request handlers (success + error variants per endpoint)
3. `server.ts` for Vitest integration
4. `browser.ts` for dev mode (optional, `--browser` flag)
Framework-agnostic — MSW intercepts at network level, handlers are identical for React and Vue.
</purpose>

## Phase Checkpoints

```text
STOP  if: no source provided and no openapi/swagger file auto-detected | spec file not found
WARN  if: msw not in devDependencies | @mswjs/interceptors not installed
INFORM: source=[openapi|api-bind|manual], endpoints=[N], output-path=[resolved path]
```

## Input Validation (MANDATORY)

```text
Usage: /api-mocks [source] [options]

Mode 1 — OpenAPI spec:
  /api-mocks ./openapi.json
  /api-mocks ./swagger.yaml --entity User

Mode 2 — From /api-bind output:
  /api-mocks --from-api-bind src/features/user/api/
  /api-mocks --from-api-bind src/features/order/api/ --entity Order

Mode 3 — Manual endpoint list:
  /api-mocks manual GET /api/users POST /api/users PUT /api/users/:id DELETE /api/users/:id

Options:
  --browser          Generate setupWorker() for dev mode
  --entity <Name>    Filter to specific entity (e.g., User, Order, Product)
  --output <path>    Override output directory (default: src/shared/mocks/)
```

Auto-detect: glob for `openapi.*`, `swagger.*`, `*.openapi.json`, `*.openapi.yaml` if no source given.

BLOCKER if:

- No source provided AND auto-detect finds nothing
- Spec file path provided but does not exist (check with Glob)
- `--from-api-bind` path has no `*Types.ts` files

## Protocol

### BANNED

- MSW v1 API (`rest.*`, `res(ctx.json(...))`) — FORBIDDEN, use `http.*` + `HttpResponse`
- `: any` in response types — FORBIDDEN
- Hardcoded base URLs in handlers — use relative paths or `*` prefix
- Inline fixture data for entities with 3+ fields — use factory functions
- Mutable shared state across handlers without reset — each handler returns fresh data
- `onUnhandledRequest: 'bypass'` in test server — use `'error'` to catch missing handlers
- Wildcard `http.all('*', ...)` catch-all handlers — be explicit per endpoint
- `faker` or `@faker-js/faker` dependency — use deterministic static values

### MANDATORY

- All handlers use MSW v2 API: `import { http, HttpResponse } from 'msw'`
- Handlers MUST use generic type arguments for strict typing when types are available: `http.get<never, never, UserResponse>('/api/users/:id', ...)`
- Always destructure path parameters from `({ params })` with explicit typing
- Fixture factories return fresh objects: `createUser(overrides?)` pattern
- Every GET endpoint has both success and error handler variants
- Every mutation endpoint (POST/PUT/PATCH/DELETE) has success + validation error + server error variants
- `server.ts` uses `onUnhandledRequest: 'error'`
- Error handlers are exported separately for per-test `server.use()` overrides
- All response types reference existing TypeScript interfaces (from spec or api-bind output)

**MSW v2 Golden Standard** (use this syntax, never deviate):

```typescript
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    const { id } = params;
    return HttpResponse.json(createUser({ id: String(id) }));
  }),
];
```

## Workflow

### Phase 1: Validate + Environment Check

1. Validate input mode (OpenAPI / api-bind / manual)
2. Check source exists (Glob for spec files, Read for api-bind types)
3. Check `msw` in `devDependencies`:

    ```bash
    grep -q '"msw"' package.json && echo "OK" || echo "WARN: msw not in devDependencies — run: npm i -D msw"
    ```

4. Determine output path (default: `src/shared/mocks/`)

### Phase 2: Parse Source + Derive Endpoints

**OpenAPI mode:**

- Read spec file (JSON/YAML)
- Extract all paths + methods + request/response schemas
- If `--entity` flag: filter to endpoints matching entity name

**api-bind mode:**

- Read `*Types.ts` files from the provided path
- Read `*Api.ts` files to extract endpoint URLs and HTTP methods
- Derive entity names from type names

**Manual mode:**

- Parse `METHOD /path` pairs from command arguments
- Infer entity name from path segments (e.g., `/api/users` → `User`)

### Phase 3: Generate Types (if needed)

- If types already exist (from `/api-bind` output) — reuse, do not regenerate
- If OpenAPI mode and no existing types — extract response interfaces into `fixtures/{entity}.ts`
- If manual mode — generate minimal request/response interfaces

### Phase 4: Generate Fixture Factories

For each entity, generate factory in `fixtures/{entity}.ts`:

- `create{Entity}(overrides?: Partial<{Entity}>): {Entity}` — single entity
- `create{Entity}List(count?: number, overrides?: Partial<{Entity}>): {Entity}[]` — list
- Use deterministic static values based on field name heuristics (see `references/handler-template.md`)
- CRITICAL: For `id` or `uuid` fields, use an auto-incrementing counter or index-based sequence to guarantee uniqueness across `create{Entity}List()` calls (prevents UI framework key collisions)
- All fields populated with realistic defaults — no empty strings or zero values

### Phase 5: Generate MSW v2 Handlers

For each endpoint, generate handlers in `handlers.ts`:

**Success handlers** — per endpoint:

| Method | Handler pattern |
|--------|----------------|
| GET (list) | Inspect response schema. If API uses a wrapper object (`{ data, total }`), wrap `create{Entity}List()` accordingly. Otherwise return raw array |
| GET (by ID) | Return `create{Entity}()` with ID from params |
| POST | Return `create{Entity}()` merged with request body, status 201 |
| PUT/PATCH | Return `create{Entity}()` merged with request body |
| DELETE | Return empty response, status 204 |

**Error handlers** — export `{entity}ErrorHandlers` strictly as a key-value object (dictionary), NOT an array:

| Variant | Status | Body |
|---------|--------|------|
| `unauthorized` | 401 | `{ message: 'Unauthorized' }` |
| `forbidden` | 403 | `{ message: 'Forbidden' }` |
| `notFound` | 404 | `{ message: '{Entity} not found' }` |
| `validationError` | 422 | `{ message: 'Validation failed', errors: [...] }` |
| `serverError` | 500 | `{ message: 'Internal server error' }` |
| `networkError` | — | `HttpResponse.error()` |

Example export shape:

```typescript
export const userErrorHandlers = {
  notFound: http.get('/api/users/:id', () =>
    HttpResponse.json({ message: 'User not found' }, { status: 404 }),
  ),
  validationError: http.post('/api/users', () =>
    HttpResponse.json(
      { message: 'Validation failed', errors: [{ field: 'email', message: 'Invalid email' }] },
      { status: 422 },
    ),
  ),
  // ... other variants
};
```

### Phase 6: Generate Server + Browser Setup

**`server.ts`** (always generated):

```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

**`browser.ts`** (only with `--browser` flag):

```typescript
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

### Phase 7: Generate Vitest Setup Snippet

Output a setup snippet for `vitest.setup.ts` integration:

```typescript
import { server } from '@/shared/mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

If `vitest.setup.ts` or `setupTests.ts` already exists — output the snippet as a comment in `server.ts` with instructions to add manually.

### Phase 8: Type Check

```bash
npx tsc --noEmit
```

### Phase 9: Quality Gate + Gardener → SKILL COMPLETE

Run quality gate checklist, then Gardener protocol.

## Output Structure

```text
src/shared/mocks/
├── handlers.ts           # All MSW request handlers + error variants
├── server.ts             # setupServer() for Vitest
├── browser.ts            # setupWorker() for dev mode (--browser only)
├── fixtures/
│   ├── {entity}.ts       # create{Entity}() + create{Entity}List() factories
│   └── index.ts          # barrel
└── index.ts              # barrel
```

## References

- MSW v2 patterns: `references/msw-patterns.md`
- Handler + fixture templates: `references/handler-template.md`

## Cross-Skill Integration

- `/component-tests` — can import fixture factories for consistent test data
- `/api-bind` → `/api-mocks` pipeline — `--from-api-bind` consumes existing types
- `/e2e-tests` — can reuse fixture factories for Playwright `page.route()` mock data

## Quality Gate

- [ ] MSW v2 API used (`http.*`, `HttpResponse`) — no v1 patterns
- [ ] No `: any` in handler responses or fixtures
- [ ] Fixtures use typed factory functions with `Partial<T>` overrides
- [ ] Every GET endpoint has success + error handler variants
- [ ] Every mutation endpoint has success + validation error + server error variants
- [ ] Error handlers exported separately as `{entity}ErrorHandlers`
- [ ] `server.ts` uses `onUnhandledRequest: 'error'` in setup snippet
- [ ] `server.resetHandlers()` documented in afterEach
- [ ] No hardcoded base URLs in handlers
- [ ] No mutable shared state across handlers
- [ ] `tsc --noEmit` PASS

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /api-mocks
├─ Source: [openapi | api-bind | manual]
├─ Entities: [list of entity names]
├─ Handlers: [N success + N error variants]
├─ Artifacts: [handlers.ts, server.ts, browser.ts?, fixtures/*.ts]
├─ Browser: [yes | no]
├─ Type Check: [PASS | FAIL]
└─ Coverage: [N endpoints × (success + error variants)]
```
