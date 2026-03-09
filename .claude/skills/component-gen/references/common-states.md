# Common States — The 4-State Pattern

Every component that displays async data MUST implement all 4 states.

## The 4 States

### 1. Loading State

**Purpose:** Communicate that data is being fetched.
**Implementation:** Skeleton UI (preferred) or spinner.

Rules:

- Match the shape of the success state (skeleton mirrors layout)
- Do not show "Loading..." text alone (no accessibility)
- Include `aria-busy="true"` or `role="status"` with screen-reader text

```text
BANNED: Empty div while loading
BANNED: Generic spinner with no context
REQUIRED: Skeleton that matches success layout
```

### 2. Error State

**Purpose:** Communicate that data fetching failed, with an actionable message.
**Implementation:** Error card with message + retry action.

Rules:

- Show user-friendly message, NOT raw error object or stack trace
- Include a retry button or clear next step for the user
- Log technical error details to error monitoring (not to UI)
- `role="alert"` for screen readers

```text
BANNED: Rendering `error.message` directly (may expose internals)
BANNED: Empty/blank component on error
REQUIRED: User-friendly message + retry action
REQUIRED: Error rendered adjacent to the action that caused it (contextual errors).
  - Form field error → below/beside the field, not in a global toast
  - Data-fetching error → inside the component's content area, not a page-level banner
  - Only network/auth errors with no single owner → global notification
BANNED: All errors routed to a single global toast regardless of origin
```

**Guide the Exit (mandatory copywriting rules):**

```text
NEVER output raw error.message or technical strings to the user.
Error text = [what happened] + [how to fix it].

Bad:  "Failed to load data"
Bad:  "Error: 404 Not Found"
Good: "Could not load projects — check your connection and try again."
Good: "Unable to save changes — your session may have expired. Sign in again."

CTA required: retry button OR link to settings/docs.
BANNED: orphaned error text with no next-action button or link.
```

### 3. Empty State

**Purpose:** Communicate that the request succeeded but returned no data.
**Implementation:** Descriptive message with optional call-to-action.

Rules:

- Distinguish from error state (different copy, different icon)
- Provide context: WHY is it empty? WHAT can the user do?
- Never show a blank component

```text
BANNED: Blank component when data is []
BANNED: Same UI as error state
REQUIRED: Meaningful no-data message + optional CTA
REQUIRED: One clear next action (CTA). Examples:
  - "No results. [Clear filters]"
  - "Nothing here yet. [Create your first item]"
  - "No users found. [Invite team members]"
BANNED: Empty state with no actionable path forward
```

**Empty vs Error copy distinction (mandatory):**

```text
Error  = something went wrong → guide the user to fix it
Empty  = no data yet → guide the user to create / invite / explore

Error CTA:  "Try again" / "Refresh" / "Check settings"
Empty CTA:  "Create your first X" / "Invite teammates" / "Browse examples"

BANNED: reusing the same copy or CTA between error and empty states.
```

### 4. Success State

**Purpose:** Display the actual data.
**Implementation:** Data-driven UI.

Rules:

- Handles edge cases: single item, many items, truncated list
- Does not re-implement loading/error/empty — those are separate
- Accessible (proper semantic HTML, ARIA where needed)

**Data display polish (mandatory micro-typography):**

```text
Numbers + units: use non-breaking space or whitespace-nowrap span.
  Bad:  10MB    3items    $1,200USD
  Good: <span class="whitespace-nowrap">10 MB</span>
        <span class="whitespace-nowrap">3 items</span>

Changing/live numbers (counters, prices, stats):
  Add tabular-nums class to prevent layout shift on digit change.

Button labels in app UI:    Title Case  (e.g. "Save API Key", "Add Member")
Button labels in onboarding: Sentence case (e.g. "Get started", "Learn more")
```

## State Priority (rendering order)

```text
if (isLoading) → Loading
else if (isError) → Error
else if (isEmpty) → Empty
else → Success
```

States are **mutually exclusive**. Never show loading + data simultaneously.

## TypeScript State Types

```typescript
type ComponentState =
  | { status: 'loading' }
  | { status: 'error'; message: string }
  | { status: 'empty' }
  | { status: 'success'; data: YourDataType[] };
```

---

## 5th State: Optimistic UI [mutations only]

**Activated when:** the component contains a mutation — `useMutation` (TanStack Query), POST/PUT/DELETE action, or any write operation that modifies remote state.

### Concept

Immediately update local state before the server confirms, then roll back on error.
Result: the UI feels instant; errors are recoverable.

### Rules

- **Micro-feedback, not full overlay:** on submit, disable the button + show inline spinner. Do NOT replace the whole component with a loading overlay.
- **Distinct copy from read-loading:** use "Saving…" / "Liking…" / "Deleting…" — NEVER reuse "Loading…"
- **Rollback on error:** snapshot previous state in `onMutate`, restore in `onError`
- **Invalidate on settled:** call `queryClient.invalidateQueries` in `onSettled` to sync with server truth

### Pattern

```text
onMutate  → snapshot previous cache → apply optimistic update
onError   → restore snapshot (rollback)
onSettled → invalidate query (force server sync)
```

### TypeScript state extension

```typescript
type ComponentState =
  | { status: 'loading' }
  | { status: 'error'; message: string }
  | { status: 'empty' }
  | { status: 'success'; data: YourDataType[] }
  | { status: 'mutating'; optimisticData: YourDataType[] }; // 5th state
```

```text
BANNED: Full loading overlay replacing content during mutation
BANNED: "Loading…" copy during a write operation
BANNED: No rollback on mutation error (leaves stale optimistic state forever)
REQUIRED: Button disabled + inline spinner during mutation
REQUIRED: Previous state snapshot in onMutate for rollback
REQUIRED: queryClient.invalidateQueries in onSettled
```
