# FE Code Generation Templates

> Referenced by `SKILL.md` Phases F1–F3 and `phase3-analysis.md` §3.2, §3.6.
> Use these templates when generating TypeScript interfaces, Zod schemas, and error maps.
> Replace all `{placeholder}` values with actual data extracted from the repository.

---

## TypeScript Interface Template

### Request Interface

```typescript
// Source: {file:line}
/**
 * {Description of when this is used}
 * @endpoint {METHOD /path}
 */
export interface {EntityName}Request {
  /** @example "{realistic_example_value}" */
  {requiredField}: {string | number | boolean};

  /** @example "{realistic_example_value}"
   * @format {uuid | iso8601 | email | uri} */
  {formattedField}: string;

  /** @example {N} */
  {optionalField}?: {string | number | boolean};

  /** @example ["{VALUE_A}", "{VALUE_B}"] */
  {enumField}: {EnumTypeName};
}
```

### Response Interface

```typescript
// Source: {file:line}
/**
 * {Description — what entity/resource this represents}
 * @endpoint {METHOD /path} response
 */
export interface {EntityName}Response {
  /**
   * @example "{uuid_or_number_example}"
   * @note {[TYPE_MISMATCH]: proto says int32 but code returns int64} — omit if no mismatch
   */
  id: {string | number};

  /** @example "{realistic_example_value}" */
  {field}: {type};

  /** ISO 8601 timestamp
   * @example "2024-01-15T10:30:00Z" */
  createdAt: string;

  /** ISO 8601 timestamp
   * @example "2024-01-15T10:30:00Z" */
  updatedAt: string;
}
```

### Paginated Response Wrapper

```typescript
// Use this wrapper when endpoint returns a list with pagination
export interface PaginatedResponse<T> {
  data: T[];
  /** Total number of items across all pages
   * @example 250 */
  total: number;
}

// Cursor-based pagination variant
export interface CursorPaginatedResponse<T> {
  items: T[];
  /** Cursor for the next page. null = last page.
   * @example "eyJpZCI6MTAwfQ==" */
  nextCursor: string | null;
}

// Offset-based pagination variant
export interface OffsetPaginatedResponse<T> {
  items: T[];
  /** @example 250 */
  total: number;
  /** @example 1 */
  page: number;
  /** @example 20 */
  pageSize: number;
}
```

### Enum / Status Type Template

```typescript
// Source: {file:line} — {enum name in backend code}
export type {EntityName}Status =
  | "{STATUS_A}"   // {description of this state}
  | "{STATUS_B}"   // {description of this state}
  | "{STATUS_C}";  // {description of this state}

// Valid transitions map — from §9 State Transition Matrix
// Use to control UI button/action visibility
export const VALID_TRANSITIONS: Record<{EntityName}Status, {EntityName}Status[]> = {
  {STATUS_A}: ["{STATUS_B}"],
  {STATUS_B}: ["{STATUS_C}"],
  {STATUS_C}: [],
};

/** Returns true if the action button/control should be shown */
export function canTransition(
  current: {EntityName}Status,
  target: {EntityName}Status
): boolean {
  return VALID_TRANSITIONS[current].includes(target);
}

// Exhaustive switch helper — TypeScript will error if a case is missing
export function assertNever(x: never): never {
  throw new Error(`Unhandled {EntityName}Status: ${String(x)}`);
}
```

---

## Zod Schema Template

### Basic Object Schema

```typescript
import { z } from "zod";

// Source: {file:line}
// Endpoint: {POST /path}
// [UNDOCUMENTED] rules are marked — not present in OpenAPI/proto spec
export const {entityName}Schema = z.object({
  // string fields
  {stringField}: z.string()
    .min({N}, "{Field} must be at least {N} characters")
    .max({M}, "{Field} cannot exceed {M} characters"),

  // email
  {emailField}: z.string().email("Invalid email address"),

  // UUID
  {uuidField}: z.string().uuid("Must be a valid UUID"),

  // regex-validated string [UNDOCUMENTED]
  {regexField}: z.string()
    .regex(/{pattern}/, "{Field} format is invalid"),

  // enum
  {enumField}: z.enum(["{VALUE_A}", "{VALUE_B}", "{VALUE_C}"]),

  // number with constraints
  {numberField}: z.number()
    .int("{Field} must be a whole number")
    .min({N}, "{Field} must be at least {N}")
    .max({M}, "{Field} cannot exceed {M}"),

  // optional field
  {optionalField}: z.string().optional(),

  // nullable field
  {nullableField}: z.string().nullable(),

  // boolean
  {boolField}: z.boolean(),

  // nested object
  {nestedField}: z.object({
    {innerField}: z.string(),
  }),

  // array
  {arrayField}: z.array(z.string()).min(1, "At least one {item} is required"),
});

export type {EntityName}Input = z.infer<typeof {entityName}Schema>;
```

### Partial Update Schema

```typescript
// Source: {file:line}
// Endpoint: {PUT/PATCH /path/:id}
export const update{EntityName}Schema = {entityName}Schema
  .partial()
  .required({ id: true });

export type Update{EntityName}Input = z.infer<typeof update{EntityName}Schema>;
```

### Cross-Field Validation Schema

```typescript
// Source: {file:line} — cross-field rule [UNDOCUMENTED]
export const {entityName}WithConstraintsSchema = z.object({
  {fieldA}: z.string(),
  {fieldB}: z.string(),
})
.refine(
  (data) => {/* validation condition */},
  {
    message: "{Error message shown to user}",
    path: ["{fieldB}"], // which field the error appears under
  }
);
```

### Discriminated Union Schema (for polymorphic payloads)

```typescript
// Source: {file:line}
// Use when payload shape depends on a type/kind discriminator field
export const {entityName}Schema = z.discriminatedUnion("type", [
  z.object({
    type: z.literal("{TYPE_A}"),
    {fieldSpecificToA}: z.string(),
  }),
  z.object({
    type: z.literal("{TYPE_B}"),
    {fieldSpecificToB}: z.number(),
  }),
]);
```

---

## Error Constants Template

```typescript
// Source: Phase 3.3 error mapping from {file:line}
// UI Treatment:
//   "field"  — display under specific form field
//   "toast"  — show as notification/snackbar
//   "screen" — replace current view (401 → login, 403 → forbidden, 404 → not-found, 500 → error page)

export const API_ERRORS = {
  // Auth errors → screen treatment
  {UNAUTHORIZED}: {
    httpStatus: 401,
    message: "Authentication required. Please log in.",
    uiTreatment: "screen" as const,
  },
  {FORBIDDEN}: {
    httpStatus: 403,
    message: "You don't have permission to perform this action.",
    uiTreatment: "screen" as const,
  },

  // Validation errors → field treatment
  {VALIDATION_ERROR}: {
    httpStatus: 400,
    message: "Please check your input.",
    uiTreatment: "field" as const,
  },
  {FIELD_REQUIRED}: {
    httpStatus: 400,
    message: "{Field} is required.",
    uiTreatment: "field" as const,
  },

  // Business logic errors → toast treatment
  {CONFLICT}: {
    httpStatus: 409,
    message: "This {resource} already exists.",
    uiTreatment: "toast" as const,
  },
  {NOT_FOUND}: {
    httpStatus: 404,
    message: "{Resource} not found.",
    uiTreatment: "screen" as const,
  },

  // Server errors → screen treatment
  {INTERNAL_ERROR}: {
    httpStatus: 500,
    message: "Something went wrong. Please try again.",
    uiTreatment: "screen" as const,
  },
} as const satisfies Record<
  string,
  { httpStatus: number; message: string; uiTreatment: "field" | "toast" | "screen" }
>;

export type ApiErrorCode = keyof typeof API_ERRORS;

/** Type guard for checking if an error code is known */
export function isKnownErrorCode(code: string): code is ApiErrorCode {
  return code in API_ERRORS;
}

/** Get error config — falls back to generic error for unknown codes */
export function getErrorConfig(code: string) {
  if (isKnownErrorCode(code)) {
    return API_ERRORS[code];
  }
  return API_ERRORS.INTERNAL_ERROR;
}
```

---

## Type Mapping Reference

Use this table when converting backend types to TypeScript:

| Backend Type | TypeScript Type | Notes |
|-------------|-----------------|-------|
| `string` | `string` | |
| `int32` | `number` | Safe for all values |
| `int64` | `number` | ⚠️ Values > 2^53 lose precision — use `string` or `BigInt` if IDs are large |
| `float32` / `float64` | `number` | |
| `bool` | `boolean` | |
| `timestamp` / `datetime` | `string` | Add `@format iso8601` JSDoc |
| `uuid` | `string` | Add `@format uuid` JSDoc |
| `bytes` | `string` | Usually base64 encoded |
| `enum` | TypeScript string literal union | `type Status = "ACTIVE" \| "INACTIVE"` |
| `repeated T` | `T[]` | |
| `map<K, V>` | `Record<K, V>` | |
| `optional T` / `T?` | `T \| undefined` or `T?` | |
| `nullable T` | `T \| null` | |
| `any` / `object` | `unknown` | Never use `any` — use `unknown` and narrow |
