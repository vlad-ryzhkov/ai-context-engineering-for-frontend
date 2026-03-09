# Streaming / Realtime Feature Patterns

## When to Use This Pattern

Apply when the component description contains any of: **streaming**, **realtime**, **SSE**,
**Server-Sent Events**, **webhook**, **live**, **progress**, **build log**, **AI generation**,
**long-running task**, **import job**.

Examples: AI chat response, build pipeline monitor, file import progress, webhook event log,
real-time analytics feed.

> **Do NOT use** TanStack Query for streaming data — use `fetch` + `ReadableStream` directly.
> TanStack Query is for request/response, not for long-lived streams.

---

## Phase State Machine

Replace ad-hoc `isLoading`/`isRunning`/`isDone` booleans with a typed `Phase` union that
drives which buttons are enabled. This eliminates impossible states (e.g., Start enabled while
running).

```typescript
// StreamFeature.types.ts
type Phase = "idle" | "running" | "done";

const PHASE_ACTIONS: Record<Phase, Set<"start" | "cancel">> = {
  idle:    new Set(["start"]),
  running: new Set(["cancel"]),
  done:    new Set(["start"]),   // restart is also "start"
};
```

Usage in JSX — single source of truth for button disabled state:

```tsx
<button
  type="button"
  onClick={() => void startStream()}
  disabled={!PHASE_ACTIONS[phase].has("start")}
>
  Start
</button>

<button
  type="button"
  onClick={cancelStream}
  disabled={!PHASE_ACTIONS[phase].has("cancel")}
>
  Cancel
</button>
```

**Rules:**

- `Phase` is independent of `StreamStatus` — phase controls actions, status controls UI rendering.
- NEVER use `phase === "running"` as the only guard for buttons — always consult `PHASE_ACTIONS`.
- Add new actions to the `Set` type union when the feature grows (e.g., `"pause"`, `"download"`).

---

## SSE / ReadableStream Consumption

### AbortController in useRef (NOT useState)

```typescript
// CORRECT — ref does not trigger re-renders; value persists across renders
const abortRef = useRef<AbortController | null>(null);

// BANNED — causes extra re-render on start/cancel; stale closure risk
const [abortController, setAbortController] = useState<AbortController | null>(null);
```

### useEffect cleanup — abort on unmount

```typescript
// Always abort the in-flight stream when the component unmounts
useEffect(() => {
  return () => {
    abortRef.current?.abort();
  };
}, []); // empty deps — run only on mount/unmount
```

### Full fetch + ReadableStream template

```typescript
async function startStream() {
  abortRef.current = new AbortController();
  setPhase("running");
  setState({ status: "connecting" });

  try {
    const res = await fetch("/api/stream", {
      signal: abortRef.current.signal,
    });

    if (!res.ok) throw new Error(`Server responded with ${res.status}`);
    if (!res.body) throw new Error("Response body is empty — streaming not supported");

    setState({ status: "streaming", entries: [] });

    const reader = res.body.pipeThrough(new TextDecoderStream()).getReader();
    let buffer = "";

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += value;
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? ""; // keep incomplete last line

        for (const line of lines) {
          const parsed = parseStreamLine(line);
          if (parsed) {
            // update state with new entry
          }
        }
      }
      // Flush remaining buffer after stream ends
      if (buffer.trim()) {
        const parsed = parseStreamLine(buffer);
        if (parsed) { /* handle final entry */ }
      }
    } finally {
      reader.releaseLock(); // MANDATORY — prevents ReadableStream lock errors
    }

    setPhase("done");
    setState({ status: "done", entries: [...accumulatedEntries] });

  } catch (err) {
    // Distinguish intentional abort from real errors
    if (err instanceof DOMException && err.name === "AbortError") {
      setState({ status: "idle" });
      setPhase("idle");
      return;
    }
    const message = err instanceof Error
      ? `Stream failed — ${err.message}`
      : "Stream failed — please try again.";
    setState({ status: "error", message });
    setPhase("idle");
  }
}
```

### Cleanup rules (MANDATORY)

| Rule | Reason |
|---|---|
| `reader.releaseLock()` in `finally` | Prevents "ReadableStream is locked" errors on retry |
| `abortRef.current?.abort()` in `useEffect` cleanup | Prevents memory leak + dangling setState on unmount |
| Check `err.name === "AbortError"` before error state | AbortError is intentional; don't show it as an error to the user |
| `if (!res.body)` guard before `pipeThrough` | Some environments return null body on non-2xx |

---

## State Mapping (common-states.md alignment)

| StreamStatus | 4-state mapping | UI |
|---|---|---|
| `idle` | Empty state | No-data message + "Start" CTA |
| `connecting` | Loading state | Skeleton that mirrors entry list layout |
| `streaming` | Success state | Live entry list + "Live" badge + Cancel button |
| `done` | Success state | Complete entry list + "Complete" badge + restart CTA |
| `error` | Error state | User-friendly message + "Try again" button |

---

## Discriminated Union for Events

Use a discriminated union for incoming stream events — enforces exhaustive handling via
TypeScript `switch`:

```typescript
type StreamEvent =
  | { type: "connecting" }
  | { type: "progress"; message: string; percent?: number }
  | { type: "done"; summary: string }
  | { type: "error"; message: string };
```

---

## Banned Shortcuts

| Pattern | Why Banned | Correct Alternative |
|---|---|---|
| `setInterval` polling instead of stream | Wastes bandwidth; not real-time | `fetch` + `ReadableStream` |
| `useState` for AbortController | Re-renders on start/cancel; stale closure risk | `useRef<AbortController \| null>` |
| Missing `finally { reader.releaseLock() }` | Stream lock never released; retry fails | Always wrap reader in try/finally |
| Showing `AbortError` as an error to the user | Abort is intentional (Cancel button) | Check `err.name === "AbortError"` first |
| `res.body!` without null check | Crashes on environments that return null body | Guard with `if (!res.body) throw new Error(…)` |
| Raw `err.message` in error UI | May expose stack traces or internal URLs | Wrap: `"Stream failed — " + err.message` |

---

## Example Files

- `examples/react/streaming-feature/StreamingFeature.types.ts` — types + phase machine
- `examples/react/streaming-feature/StreamingFeature.tsx` — full component
- `examples/react/streaming-feature/StreamingFeature.test.tsx` — tests with mocked ReadableStream
