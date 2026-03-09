/**
 * Types for StreamingFeature — Phase state machine + SSE/ReadableStream pattern.
 * Referenced by /component-gen when generating streaming/realtime/live features.
 */

// ---------------------------------------------------------------------------
// Stream events (discriminated union — exhaustive switch is enforced by TS)
// ---------------------------------------------------------------------------

export interface StreamEventConnecting {
  type: "connecting";
}

export interface StreamEventProgress {
  type: "progress";
  message: string;
  percent?: number;
}

export interface StreamEventDone {
  type: "done";
  summary: string;
}

export interface StreamEventError {
  type: "error";
  message: string;
}

export type StreamEvent =
  | StreamEventConnecting
  | StreamEventProgress
  | StreamEventDone
  | StreamEventError;

// ---------------------------------------------------------------------------
// Component stream status
// ---------------------------------------------------------------------------

export type StreamStatus = "idle" | "connecting" | "streaming" | "done" | "error";

// ---------------------------------------------------------------------------
// Rendered log entry
// ---------------------------------------------------------------------------

export interface StreamEntry {
  id: string;
  message: string;
  timestamp: number;
}

// ---------------------------------------------------------------------------
// Phase state machine
// idle  → user can start
// running → user can cancel
// done  → user can restart
// ---------------------------------------------------------------------------

export type Phase = "idle" | "running" | "done";

export const PHASE_ACTIONS: Record<Phase, Set<"start" | "cancel">> = {
  idle:    new Set(["start"]),
  running: new Set(["cancel"]),
  done:    new Set(["start"]),
};

// ---------------------------------------------------------------------------
// Component state (maps to the 4-state pattern)
// idle      → empty state   (no data, "Start" CTA)
// connecting → loading state (skeleton/spinner)
// streaming → success state (live entries + in-progress badge)
// done      → success state (complete badge + reset CTA)
// error     → error state   (message + retry button)
// ---------------------------------------------------------------------------

export type StreamingFeatureState =
  | { status: "idle" }
  | { status: "connecting" }
  | { status: "streaming"; entries: StreamEntry[]; summary: string }
  | { status: "done"; entries: StreamEntry[]; summary: string }
  | { status: "error"; message: string };
