---
name: ui-tweak
description: >
  Process Agentation visual annotations → targeted code fixes.
  React-favored (full component tree); Vue gets DOM-only context.
allowed-tools: "Read Edit Glob Grep Bash(npx tsc*) Bash(npx biome*) mcp__agentation__*"
context: fork
auto-invoke: false
---

# `/ui-tweak` — Visual Annotation → Code Fix

## Purpose

Process visual annotations from Agentation → locate source code → apply targeted fixes → resolve annotations.
Bottom-Up feedback: **human** points at UI elements, AI fixes the code.

## Owner

**Self (Frontend Lead)** — not Engineer. Edits are small and the annotation-resolve loop needs
persistent session context.

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| `single` | `/ui-tweak` (default) | Fetch all pending → fix → resolve → done |
| `watch` | `/ui-tweak watch` | Blocking loop: poll for new annotations until user interrupt or 30min timeout |
| `session <id>` | `/ui-tweak session abc123` | Fetch annotations for a specific session only |

## Framework Detection

No framework parameter required. Auto-detect from annotation data:

- `reactComponents` array non-empty → **React** (full component tree available)
- `reactComponents` empty/absent → **Vue or plain HTML** (DOM selectors + CSS only)

## Phase 1: MCP Health Check

1. Call `mcp__agentation__agentation_list_sessions`
2. **STOP** if MCP unavailable or returns error:

```text
🛑 STOP: Agentation MCP server not available.
Setup instructions: .claude/skills/ui-tweak/references/agentation-setup.md

Quick start:
  npm install agentation -D
  npx agentation-mcp init
  npx agentation-mcp server
```

1. If sessions returned → proceed to Phase 2

## Phase 2: Fetch Annotations

### Single / Session mode

Call `mcp__agentation__agentation_get_all_pending` (or filter by session ID).

**STOP** if no pending annotations:

```text
✅ No pending annotations found. Nothing to fix.
```

### Watch mode

Call `mcp__agentation__agentation_watch_annotations` to start polling.
Process each annotation as it arrives (Phases 3–5), then loop back.
Hard timeout: **30 minutes**. Token Economy pause rule applies.

## Phase 3: Code Location

For each annotation, locate the source file:

### React (reactComponents available)

1. Extract component names from `reactComponents` array (leaf → root order)
2. `Grep` for component definition: `export (default |const )?{ComponentName}` in `src/**/*.tsx`
3. If grep returns multiple matches → use `elementPath` + `cssClasses` to disambiguate
4. Read the matched file

### Vue (DOM-only)

1. Extract `cssClasses` from annotation
2. `Grep` for class names in `src/**/*.vue` files: search in `<template>` sections
3. Use `elementPath` tag names to narrow results
4. If ambiguous → `Grep` for `selector` value across `.vue` files
5. Read the matched file

### Fallback

If source file cannot be identified after 3 grep attempts:

- Call `mcp__agentation__agentation_reply` with message: "Could not locate source file for this element. Please provide the file path."
- Move to next annotation

## Phase 4: Apply Fix

Branch on `intent`:

| Intent | Action |
|--------|--------|
| `fix` | Read annotation `comment` + `screenshot` → Edit the source file to fix the issue |
| `change` | Read annotation `comment` → Edit the source file to apply the requested change |
| `question` | Call `mcp__agentation__agentation_reply` with answer (no file edits) |
| `approve` | Call `mcp__agentation__agentation_resolve` with status `approved` (no file edits) |

### After each edit

1. **Type check:** `Bash(npx tsc --noEmit --pretty)` — if fail, fix once, then proceed
2. **Lint:** `Bash(npx biome check --write {file})` — auto-fix formatting

### Safety

- FORBIDDEN: `any` type, `console.log`, direct DOM manipulation
- Edits must be surgical — change only what the annotation requests
- Do NOT refactor surrounding code

## Phase 5: Resolve

After successful fix:

1. Call `mcp__agentation__agentation_acknowledge` with the annotation ID
2. Call `mcp__agentation__agentation_resolve` with status `success` and a short summary of what changed

After failed fix (type check fails twice, or code location failed):

1. Call `mcp__agentation__agentation_reply` with explanation of the failure
2. Move to next annotation

## Phase 6: Watch Loop (watch mode only)

1. After processing all current annotations, wait for new ones via `mcp__agentation__agentation_watch_annotations`
2. Repeat Phases 3–5 for each new annotation
3. Exit conditions:
   - User interrupt (Ctrl+C or explicit stop)
   - 30-minute timeout reached
   - Token Economy threshold approached (> 20,000 tokens consumed)

## Checkpoints

| Level | Condition | Action |
|-------|-----------|--------|
| **STOP** | MCP server unavailable | Print setup instructions, halt |
| **STOP** | No pending annotations | Print "nothing to fix", halt |
| **WARN** | Vue project detected (no `reactComponents`) | Print: "Vue project — DOM-only context. Component-level fixes may require manual file identification." |
| **WARN** | `blocking` + `change` intent | Print: "Blocking change request — consider `/component-gen --into` for large structural changes." |
| **DISMISS** | 3 failures on same annotation | Call `agentation_reply` with failure summary, skip to next |

## Loop Guard

After **3 consecutive failures** on the same annotation (grep miss, type check fail, edit fail):

- Call `mcp__agentation__agentation_reply` with: "Unable to resolve after 3 attempts. Skipping."
- Move to next annotation
- If 3 annotations in a row fail: output `🛑 LOOP_GUARD_TRIGGERED: Multiple annotation fixes failing` and PAUSE.

## Gardener Protocol

> SSOT: `.claude/protocols/gardener.md`

After processing all annotations — run Gardener Analysis BEFORE the `SKILL COMPLETE` block.

## Completion

```text
✅ SKILL COMPLETE: /ui-tweak
├─ Mode: [single | watch | session]
├─ Framework: [React (component tree) | Vue (DOM-only) | auto-detected]
├─ Annotations: [X resolved / Y total]
├─ Files Modified: [list]
├─ Type Check: [PASS | FAIL | N/A]
├─ Lint: [PASS | FAIL | N/A]
└─ Skipped: [N annotations (with reasons)]
```

```text
⚠️ SKILL PARTIAL: /ui-tweak
├─ Mode: [single | watch | session]
├─ Framework: [React | Vue | unknown]
├─ Annotations: [X resolved / Y total]
├─ Files Modified: [list (✅/❌)]
├─ Skipped: [N annotations]
└─ Blockers: [description]
```
