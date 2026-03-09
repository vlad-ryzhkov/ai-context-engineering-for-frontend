---
name: browser-check
description: AI self-verification of running UI via agent-browser CLI — live snapshot and optional interaction flow. Use for ad-hoc visual checks of a running dev server without writing test files. Do not use when persistent Playwright spec files are needed — use /e2e-tests instead.
allowed-tools: "Bash(npx *agent-browser*)"
auto-invoke: false
---

# Skill: /browser-check

## Purpose

AI self-verification of running UI via `agent-browser` CLI.
Fast, ad-hoc snapshot + optional interaction flow — no file artifacts written.

**Different from `/e2e-tests`:** e2e-tests generates persistent `.spec.ts` test files.
`/browser-check` is ephemeral: live snapshot → chat-only pass/fail report.

---

## Verbosity Protocol

SILENT MODE: No intermediate chat output. Tool calls first, analysis after.
Output to chat: SKILL COMPLETE block only.

---

## Input

```text
/browser-check [url?] [flow-description?]
```

| Param | Required | Default | Example |
|-------|----------|---------|---------|
| `url` | No | `http://localhost:5173` | `http://localhost:3000` |
| `flow-description` | No | (snapshot only) | `"fill login form and submit"` |

---

## Allowed Tools

`Bash(npx *agent-browser*)` only. No file writes during this skill.

---

## Workflow

### Step 1 — Validate

- If `url` not provided → use `http://localhost:5173`
- If `url` provided without protocol (`http://` or `https://`) → prepend `http://`
- If `url` provided with protocol → use as-is

### Step 2 — Check agent-browser is available

```bash
npx --yes agent-browser --version
```

If command fails (exit code ≠ 0) → STOP. Output ⚠️ SKILL PARTIAL:
  Blockers: "agent-browser not found. Install: npm install -g @vercel-labs/agent-browser"

### Step 3 — Open URL

```bash
npx --yes agent-browser open <url>
```

If fails (connection refused, page load error) → STOP. Output ⚠️ SKILL PARTIAL:
  Blockers: "Could not open <url> — dev server may not be running"

### Step 4 — Snapshot

```bash
npx --yes agent-browser snapshot -i
```

Parse output:

- Count interactive elements (`@eN` refs)
- Note page title / h1

### Step 5 — Execute flow (if flow-description provided)

Translate the natural-language flow into sequential `agent-browser` commands
using refs from Step 4. See `references/commands.md` for command syntax.

**CRITICAL BASH RULE:** Always wrap `fill` text inputs in single quotes (`'...'`) to prevent
bash variable expansion and injection of special characters (`$`, `!`, `` ` ``, `"`).

Examples:

```bash
npx --yes agent-browser fill @e1 'user@example.com'
npx --yes agent-browser fill @e2 'P@ssw$rd!'
npx --yes agent-browser click @e3
```

After each step: take a new snapshot to confirm the result.

**Race Condition Guard:** If the snapshot shows loading indicators (text containing
"loading", "spinner", skeleton placeholders, or disabled submit buttons), wait (`sleep 2`)
and re-snapshot before attempting the next interaction. Do not interact with elements
that are behind a loading overlay.

If expected element absent after snapshot: re-run `snapshot -i` up to 2 times
(run `sleep 2` between retries). If still absent after 2 retries → mark step as failed.
If same step fails 3 times → abort. Output ⚠️ SKILL PARTIAL with LOOP_GUARD blocker.

**Loop Guard:** If the same step fails 3 times → abort the entire flow.
Output ⚠️ SKILL PARTIAL: Blockers: "LOOP_GUARD: step [description] failed 3× — [last error]"

### Step 6 — Assert outcome

Based on flow or snapshot-only:

```bash
npx --yes agent-browser get text @eN
npx --yes agent-browser is visible @eN
```

⚠️ screenshot — LAST RESORT only. Outputs raw base64 (100k+ tokens).
Use ONLY when text/visibility assertions are impossible. Prefer `is visible` + `get text`.

Determine PASS / FAIL:

- **PASS:** Expected elements visible, no error state detected
- **FAIL:** Error message visible, expected element missing, or command failed

### Step 7 — Gardener

Run Gardener Analysis per `.claude/protocols/gardener.md` via silent tool calls.
Do NOT output Gardener text to chat. SKILL COMPLETE block must be the only chat output.

---

## Anti-Patterns

- If same step fails 3 times → abort flow. Output ⚠️ SKILL PARTIAL with Blockers: "LOOP_GUARD: [step] failed 3× — [error]"
- **BANNED:** Re-using `@eN` refs after ANY navigation or click that triggers route change — ALWAYS re-snapshot first. The DOM mutates, invalidating old refs.
- **BANNED:** Using double quotes `"..."` for `fill` inputs containing special characters (`$`, `!`, `` ` ``). Use single quotes `'...'` to prevent bash expansion.
- **BANNED:** Running `npx` without `--yes` flag — causes interactive prompt hang in non-TTY environments.
- Do not use `snapshot` (full DOM) instead of `snapshot -i` — wastes tokens
- Do not interact with elements behind a loading overlay — wait and re-snapshot first

---

## Quality Gate

- [ ] URL was reachable (no connection error)
- [ ] Snapshot returned ≥1 interactive element
- [ ] All flow steps executed without LOOP_GUARD trigger
- [ ] PASS/FAIL determination is explicit

---

## Output Format

```text
✅ SKILL COMPLETE: /browser-check
├─ URL: [url checked]
├─ Flow: [flow-description | "snapshot only"]
├─ Snapshot: [N interactive elements]
├─ Steps: [N/N passed]
└─ Result: [PASS | FAIL]
```

On failure:

```text
⚠️ SKILL PARTIAL: /browser-check
├─ URL: [url]
├─ Flow: [flow-description | "snapshot only"]
├─ Snapshot: [N interactive elements | "failed"]
├─ Steps: [N/N passed]
└─ Blockers: [what failed and why]
```

---

## Notes

- Framework-agnostic: works for React and Vue projects
- No file artifacts written — output is chat-only
- Default URL matches Vite dev server (same as `/e2e-tests`)
- `snapshot -i` only — preserves token economy (93% fewer tokens vs raw DOM)
- Dev server must be running before invoking this skill
