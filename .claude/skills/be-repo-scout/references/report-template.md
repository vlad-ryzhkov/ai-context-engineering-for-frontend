# Report Template be-repo-scout-report.md

## Table of Contents

**Required (§1–§8):** Repository Profile · API Surface Catalog · Validation Rules · Error Mapping · Auth & Access Control · Specification Inventory · TypeScript Contracts · Zod Schemas

**Conditional (§9–§14):** State Transition Matrix · Entity & Data Model · Behavioral Nuances · Local Dev Setup · BFF Opportunities · Contract Mismatch Report

---

````markdown
# Backend API Contract Report: {repo-name}

> Generated: {date} | Skill: /be-repo-scout

## 1. Repository Profile

| Parameter | Value |
|-----------|-------|
| Language | {Go / Python / Node.js / TypeScript / Java / Kotlin} |
| Runtime/Version | {go 1.21 / python 3.11 / node 20 / jdk 17} |
| Module/Package | {module path / package name / artifact ID} |
| Service Type | {REST API / gRPC / Mixed / CLI / Consumer} |
| API Protocol | {REST / gRPC / REST+gRPC / GraphQL / Mixed} |
| Base URL (dev) | {http://localhost:8080 or from docker-compose / N/A} |
| WebSocket URL | {ws://localhost:8080/ws or "none"} |
| Documentation Language | {English / Russian / Mixed / N/A} |
| Source Files | {N source files} |

### Key Dependencies

| Category | Library |
|----------|---------|
| HTTP Framework | {gin / FastAPI / Express / Spring Boot / none} |
| gRPC | {present / none} |
| DB Driver | {driver name or ORM / none} |
| Auth Library | {JWT lib / OAuth lib / none} |

## 2. API Surface Catalog

**Summary:** {N REST endpoints} + {M gRPC RPCs} + {K GraphQL queries/mutations} = {total}

### Business Domain Map

| # | Domain | Endpoints | Key Entities | FE Pages Likely Affected |
|---|--------|-----------|--------------|--------------------------|
| 1 | {User Management} | {POST /users, GET /users/:id, ...} | {User, Profile} | {Registration, Profile Page} |

### REST Endpoints

| # | Method | Path | Description | Auth | Notes |
|---|--------|------|-------------|------|-------|
| {N} | {GET} | {/users/:id} | {Get user by ID} | {Bearer JWT} | {[HOTSPOT: N changes]} |

### gRPC RPCs

| # | Service | Method | Request → Response | Streaming |
|---|---------|--------|--------------------|-----------|

### Additional Sources

- [ ] HTTP client files: {path or "none"}
- [ ] OpenAPI/Swagger spec: {path or "none"}

## 3. Validation Rules

| # | Endpoint/RPC | Field | Rule | Error Code | Source | Documented |
|---|-------------|-------|------|------------|--------|-----------|
| {N} | {endpoint} | {field} | {rule} | {code} | {PROTO / SWAGGER / CODE / DOCS} | {Y / [UNDOCUMENTED]} |

> **Source:** Where the validation is defined. **Documented:** `[UNDOCUMENTED]` = code-level check with no proto/swagger counterpart.

### Zod Schema Preview

> Quick reference — full schemas in §8.

```typescript
// POST {endpoint} — input validation
const {EntityName}Schema = z.object({
  {field}: z.string().min({N}).max({M}), // {source: CODE [UNDOCUMENTED]}
});
```

## 4. Error Mapping

> **Non-standard choices:** {e.g., returns 400 for auth failures instead of 401} or "none"

| Error Constant | HTTP Code | gRPC Code | Trigger Condition | UI Treatment |
|---------------|-----------|-----------|-------------------|--------------|
| {ERROR_NAME} | {400} | {InvalidArgument(3)} | {when field X is missing} | {field / toast / screen} |

### TypeScript Error Constants

```typescript
export const API_ERRORS = {
  {ERROR_NAME}: { httpStatus: {400}, message: "{Human-readable message}" },
} as const satisfies Record<string, { httpStatus: number; message: string }>;

export type ApiErrorCode = keyof typeof API_ERRORS;
```

> **UI Treatment legend:**
>
> - `field` — display under specific form field
> - `toast` — show as notification/snackbar
> - `screen` — replace current view (401 → login, 403 → forbidden, 404 → not-found, 500 → error page)

## 5. Auth & Access Control

### Auth Mechanisms

| Mechanism | Header Name | Format | Details |
|-----------|-------------|--------|---------|
| {JWT / Session / OAuth / API Key} | {Authorization} | {Bearer {token}} | {library, config location} |

### Auth Flow

> {token extraction method} → {validation step} → {permission check} → {handler dispatch}
> On auth failure: {status code} + {error body}

### Endpoint Auth Matrix

| # | Endpoint/RPC | Auth Required | Role/Permission | FE Note |
|---|-------------|---------------|-----------------|---------|
| {N} | {POST /auth/login} | PUBLIC | none | {call first to obtain token} |
| {N} | {GET /users/:id} | AUTH | authenticated | {include Authorization header} |
| {N} | {DELETE /admin/users/:id} | ADMIN | admin role | {requires admin token} |

### FE Integration Notes

- **Token storage:** {localStorage / httpOnly cookie / memory — from code analysis}
- **Token refresh:** {endpoint or "not found" — manual refresh required}
- **Token expiry:** {duration from config or "not found"}

## 6. Specification Inventory

> Exact relative file paths are MANDATORY — downstream skills read these files directly.

| File (relative path) | Format | Endpoints | Completeness |
|----------------------|--------|-----------|--------------|
| {exact/relative/path/to/file} | {OpenAPI 3.0 / Swagger 2.0 / Proto3} | {N} | {Complete / Partial / Stale} |

**Coverage:** {X}/{total} endpoints have specification = {%}

Formula: covered endpoints / (REST + gRPC) × 100

### Documentation Gaps

| Topic | Spec Says | Code Says | FE Impact |
|-------|-----------|-----------|-----------|
| {topic} | {spec assertion or "not covered"} | {code reality} | {what FE will encounter in practice} |

## 7. TypeScript Contracts

> Generated from Phase 3.6 entity analysis. Use as a starting point — verify against actual API responses.
> Source file references provided for each interface.

### Request Types

```typescript
// Source: {file:line}
/** {Description of what this represents} */
export interface {EntityName}Request {
  /** @example "{example value}" */
  {field}: {type};
  /** @example {N}
   * @format {uuid | iso8601 | email} */
  {optionalField}?: {type};
}
```

### Response Types

```typescript
// Source: {file:line}
/** {Description of what this represents} */
export interface {EntityName}Response {
  /** @example "{example value}" */
  id: {string | number}; // {UUID / int64 — note if mismatch with request}
  {field}: {type};
  createdAt: string; // @format iso8601
}
```

### Enum Types

```typescript
// Source: {file:line} — state machine / status enum
export type {EntityName}Status =
  | "{STATE_A}"
  | "{STATE_B}"
  | "{STATE_C}";

// Exhaustive check helper
export function assertNever(x: never): never {
  throw new Error(`Unhandled status: ${x}`);
}
```

### Paginated Response

```typescript
// Generic pagination wrapper — used by {list of endpoints}
export interface PaginatedResponse<T> {
  data: T[];
  /** @example 100 */
  total: number;
  /** Cursor for next page — null if last page */
  nextCursor: string | null; // or: page: number; pageSize: number;
}
```

> **[TYPE_MISMATCH] flags:** See §14 Contract Mismatch Report for fields with inconsistent types across layers.

## 8. Zod Schemas

> Generated from Phase 3.2 validation rules. Copy-paste ready.
> `[UNDOCUMENTED]` = rule found only in handler code, not in proto/swagger spec.

```typescript
import { z } from "zod";

// {POST /endpoint} — {EntityName} creation
// Source: {file:line}
export const {entityName}Schema = z.object({
  {field}: z.string()
    .min({N}, "{Field} must be at least {N} characters") // {[UNDOCUMENTED] if not in spec}
    .max({M}, "{Field} cannot exceed {M} characters"),
  {enumField}: z.enum(["{VALUE_A}", "{VALUE_B}"]),
  {optionalField}: z.string().optional(),
  {numberField}: z.number().int().positive(),
  {emailField}: z.string().email(),
  {uuidField}: z.string().uuid(),
});

export type {EntityName}Input = z.infer<typeof {entityName}Schema>;
```

```typescript
// {PUT /endpoint/:id} — {EntityName} update (partial)
export const update{EntityName}Schema = {entityName}Schema.partial().required({
  id: true,
});
```

> **Cross-field rules (if found):**

```typescript
// Example: end date must be after start date
export const dateRangeSchema = z.object({
  startDate: z.string().datetime(),
  endDate: z.string().datetime(),
}).refine(
  (data) => new Date(data.endDate) > new Date(data.startDate),
  { message: "End date must be after start date", path: ["endDate"] }
);
```

## 9. State Transition Matrix

> CONDITIONAL: Include only if state machine patterns detected in Phase 3.5.

### State Enum: {EntityName}

| # | From | To | Trigger Endpoint | Guard Condition | Error on Rejection |
|---|------|----|-----------------|-----------------|-------------------|

### TypeScript State Machine Types

```typescript
// Source: {file:line}
export type {EntityName}Status =
  | "PENDING"
  | "ACTIVE"
  | "SUSPENDED"
  | "DELETED";

// Valid transitions — use for UI control visibility
export const VALID_TRANSITIONS: Record<{EntityName}Status, {EntityName}Status[]> = {
  PENDING: ["ACTIVE"],
  ACTIVE: ["SUSPENDED", "DELETED"],
  SUSPENDED: ["ACTIVE", "DELETED"],
  DELETED: [],
};

/** Returns true if the action button should be shown */
export function canTransition(
  from: {EntityName}Status,
  to: {EntityName}Status
): boolean {
  return VALID_TRANSITIONS[from].includes(to);
}
```

### Unreachable States

| State | Why Unreachable | FE Risk |
|-------|----------------|---------|
| {STATE} | {reason} | {UI control incorrectly shown/hidden} |

## 10. Entity & Data Model

> CONDITIONAL: Include only if entity relationship patterns detected in Phase 3.6.

### CRUD Matrix

| # | Entity | ID Type | Create | Read | Update | Delete | Soft Delete |
|---|--------|---------|--------|------|--------|--------|-------------|
| {N} | {entity} | {int32 / int64 / UUID / string} | {✅ / [NO_CREATE]} | {✅} | {✅ / [NO_UPDATE]} | {✅ / [NO_DELETE]} | {✅ / ❌} |

> **[NO_{OP}] tags:** FE should not show the corresponding UI control — the operation does not exist.

### Pagination

| Endpoint | Strategy | Parameters | Default Page Size | Max Page Size |
|----------|----------|------------|-------------------|---------------|
| {GET /items} | {cursor / offset} | {cursor, limit / page, pageSize} | {20} | {100} |

> **FE note:** Use `nextCursor === null` to detect last page (cursor strategy) or `offset + limit >= total` (offset strategy).

### ID Type Reference

| Entity | ID Type | Example | FE Note |
|--------|---------|---------|---------|
| {Entity} | {UUID string} | {"550e8400-..."} | {use string, not number} |
| {Entity} | {int64 number} | {1234567890} | {may exceed JS safe integer — use BigInt or string} |

## 11. Behavioral Nuances

> CONDITIONAL: Include only if nuances detected in Phase 3.7.

### Hidden Query Parameters

| Endpoint | Parameter | Type | Default | Behavior | Source |
|----------|-----------|------|---------|----------|--------|
| {GET /items} | {include_deleted} | {boolean} | {false} | {when true: returns soft-deleted records} | {[HIDDEN_PARAM]} |

### Internal vs External Endpoints

| Endpoint | Visibility | Auth Difference | FE Note |
|----------|-----------|----------------|---------|
| {/internal/users} | INTERNAL | {no JWT required on internal port} | {do not call from browser} |

### Conditional Behavior

| Endpoint | Condition | Behavior A | Behavior B | FE Impact |
|----------|-----------|------------|------------|-----------|

### Non-Existent Resource Handling

| Endpoint | Resource Not Found | Response Code | Response Body |
|----------|--------------------|---------------|---------------|
| {GET /users/:id} | {user deleted} | {404} | `{"error": "not_found"}` |

### Feature Flags

| Parameter | Type | Values | Behavior | Source |
|-----------|------|--------|----------|--------|
| {x-feature-flag} | {header} | {enabled\|disabled} | {enables new checkout flow} | {[FEATURE_FLAG]} |

## 12. Local Dev Setup

> Extracted from Phase 4. Use `audit/fe-local-setup.md` for the full onboarding guide.

### Docker Compose Services

| Service | Image | Port | Required For |
|---------|-------|------|--------------|
| {postgres} | {postgres:15} | {5432} | {all endpoints} |
| {redis} | {redis:7} | {6379} | {auth, rate limiting} |
| {app} | {./Dockerfile} | {8080} | {API} |

### FE Environment Variables

```bash
# .env.local for your frontend project
VITE_API_URL=http://localhost:{8080}
VITE_WS_URL=ws://localhost:{8080}/ws   # if WebSocket found
VITE_API_KEY={from config/.env.example} # if API key auth
```

### Quick Start

```bash
# 1. Clone and start backend
cp .env.example .env
docker-compose up -d

# 2. Verify API is running
curl http://localhost:{8080}/health

# 3. Obtain auth token
curl -X POST http://localhost:{8080}/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "test123"}'
```

### Mock Server Alternative (MSW)

> If you don't want to run the backend locally, use these handlers:

```typescript
// src/mocks/handlers.ts
import { http, HttpResponse } from "msw";

export const handlers = [
  http.get("{BASE_URL}/users/:id", () => {
    return HttpResponse.json({
      id: "550e8400-e29b-41d4-a716-446655440000",
      // ... fields from §7 TypeScript Contracts
    });
  }),
];
```

## 13. BFF Opportunities

> CONDITIONAL: Include only if N+1 endpoint patterns detected in Phase F4.

| # | Feature / Page | Required Endpoints | Entities | Suggested BFF Endpoint | Tag |
|---|---------------|-------------------|----------|----------------------|-----|
| 1 | {Dashboard} | {GET /users/:id, GET /orders?userId=, GET /notifications?userId=} | {User, Order, Notification} | {GET /dashboard/:userId} | [BFF_CANDIDATE] |

> **What to do with `[BFF_CANDIDATE]`:**
>
> - Short term: fetch in parallel with `Promise.all` / `useQueries` — still N requests but non-blocking
> - Long term: propose a BFF aggregation endpoint to the backend team

## 14. Contract Mismatch Report

> CONDITIONAL: Include only if type inconsistencies detected in Phases F1–F5.

### Type Mismatches

| # | Field | Proto/Swagger Type | Code Type | DB Type | Verdict | FE Handling |
|---|-------|-------------------|-----------|---------|---------|-------------|
| 1 | {userId} | {int32} | {int64} | {BIGINT} | [TYPE_MISMATCH] | {parse as number, validate < 2^53} |

### Missing Constants

| # | Error Code | Thrown In | Has Named Constant | FE Impact |
|---|-----------|-----------|-------------------|-----------|
| 1 | {HTTP 422} | {POST /orders:142} | [MISSING_CONSTANT] | {unhandled — will fall through to generic error} |

### Hidden Fields

| # | Endpoint | Field | In Spec? | Type | FE Impact |
|---|----------|-------|----------|------|-----------|
| 1 | {GET /users/:id} | {internalScore} | [HIDDEN_FIELD] | {number} | {can use but may change without notice} |

````
