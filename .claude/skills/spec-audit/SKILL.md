---
name: spec-audit
description: Performs a deep QA audit of a UI/UX specification based on WCAG, Core Web Vitals, and robust UI state management standards. Identifies gaps in UI/UX states, data mapping (Design vs API), accessibility, form interactions, and layout edge cases. Use before writing component code or UI tests, when reviewing requirements from PO/designer, or analyzing a spec for contradictions. Do not use for code review or test code analysis.
allowed-tools: "Read Write Glob"
agent: agents/auditor.md
context: fork
auto-invoke: false
---

## 🔒 SYSTEM REQUIREMENTS

Before execution the agent MUST:

1. Load `.claude/protocols/gardener.md`
2. All output artifacts (`.md` files, tables, headers, examples) MUST be written in English. Field names and code identifiers remain as-is.

---

# /spec-audit — UI/UX Specification Integrity and Risk Analysis

> **SILENT MODE**: Execute all analytical and generation phases silently. Do not output
> intermediate reasoning or conversational filler. Only the final SKILL COMPLETE block
> (or an explicit ESCALATION if blocked) goes to chat.

## Protocol

1. **Role:** Senior Frontend Engineer & Offensive QA. "Evil UI/UX tester". Critical QA auditor. Zero tolerance for Ambiguity.
2. **Objective:** Find reasons why implementing this specification will lead to bugs, regressions, or development Blockers at the UI layer.
3. **Principle — Shift Left Extreme:** We hunt bugs in *text* while they cost $1, not $1000 in production.
4. **Principle — Trust No One:** Every invocation performs a FRESH, INDEPENDENT audit. Never reuse or reference previous audits. Even if an audit for this specification already exists, create a NEW audit file with a unique timestamp. This ensures consistency, reduces hallucination, and preserves audit history.
5. **Anti-Hallucination Rule:** Never assume a field or state exists unless it is explicitly listed in the spec. If a UI action (form submit, navigation, data display) is mentioned in the text but the required API field or component state is missing from the spec — this is a specification ERROR, not a reason to add data "from memory" or logical inference. Log as Defect 10.
6. **Principle — Frontend Lens:** This audit evaluates specification readiness for **UI component implementation and UI testing**, not backend unit testing. Prioritize defects that affect UI states (Loading/Error/Empty/Success), data binding (Design vs API fields), accessibility (WCAG), and responsive behavior. Per-field validation gaps that are typically handled by framework validators are valid spec-consistency findings but should be deprioritized to Minor (4-5) unless they represent a named UX rule or affect the user-facing error contract.

## Input Data (Step 0 — execute FIRST, before everything else)

Determine the specification by Priority. **Evaluate steps in order. Stop at the first match — do NOT proceed to subsequent steps.**

1. **`$ARGUMENTS`** — if a path is provided here (Claude Code CLI) → read the file with the `Read` tool. **→ STOP. Skip steps 2–4.**
2. **User message** — if it contains a file path (`.md`, `.yaml`, `.json`, `.txt`) → read it with the `Read` tool. (Cursor and other environments where `$ARGUMENTS` is not substituted.) **→ STOP. Skip steps 3–4.**
3. **Auto-search** — only if NO path was found in steps 1 or 2 → run `Glob: specifications/**/*.md`, then `Glob: docs/**/*.md`, read the **first result only**.
4. **Auto-search yielded no results** — output `⚠️ WARNING: specification not found` and continue with an empty base.

**Multiple specifications:** Only if multiple file paths are **explicitly provided** in $ARGUMENTS or user message — run the full analysis for each separately. Each spec generates its own artifact with a unique filename. Do not merge findings across specs. **Auto-search never produces multiple specs — it reads the first result only.**

## Before Starting

Read `.claude/frontend_agent.md`.

## Analysis Algorithm (4 passes)

Perform the analysis in 4 sequential stages — mixing conclusions across stages causes missed defects.

### 1. Static Analysis (Deep Cross-Check)

- **UI-to-API Mapping (List Method):** You MUST physically write out two sorted lists:
  - **List A:** all visual UI elements described in the spec (fields, labels, badges, counts, dates — line by line, alphabetical order).
  - **List B:** all API response fields available per the spec (line by line, alphabetical order).
    Compute the delta: `A \ B` (UI element shown but no API source) and `B \ A` (API field available but not used in UI). Any non-empty `A \ B` delta — **Defect 10** (Data Gap). Skipping list construction is not allowed — an incomplete list invalidates the analysis.
- **Layout Boundary Test:** For each text container in the spec (labels, titles, descriptions, badges): what happens when content is 10x longer than the design assumption? Truncate with ellipsis? Wrap to multiple lines? Overflow hidden? If the spec does not define the overflow behavior — **Defect 7** (Layout risk). Record for each container:
  - `Container: "{name}" → overflow behavior: described / NOT DESCRIBED → PASS / FAIL`
- **State Matrix:** You MUST create a table for every component that fetches or displays async data:

    | Component | Loading | Error | Empty | Partial/Success | Status |
    |---|---|---|---|---|---|
    | `UserCard` | spinner described | error message described | empty state described | data view described | PASS |
    | `OrderList` | not described | not described | not described | described | FAIL → Defect 8 |

    **Presumption of required states:** If a component performs async operations and any of Loading/Error/Empty states are absent — **Defect 8** (Undefined behavior). Do not escalate to Defect 10 unless the entire state model is absent AND cannot be inferred from any part of the spec.
- **Type Checking:** Are the data types appropriate? (e.g. money as float — decimal/int is needed; date as string without format — risk).
- **Verb-Data Lineage (Data Tracing):** Find ALL UI actions (verbs) in the text: form submit, navigation trigger, data display, filter apply, export, delete. You MUST compile a table:

    | UI Action | Required data field | Present in API response / request body? |
    |---|---|---|
    | Display user avatar | `avatarUrl` | FOUND / MISSING |
    | Submit payment form | `cardToken` | FOUND / MISSING |

    If status is MISSING — **Blocker (Data Gap, Priority 10)**. Anti-Hallucination Rule: do not add a field to the table "from memory".

### 2. Mental Sandbox (UI Interaction Fuzzing)

- **Interaction Race Conditions (Dry Run):** Identify all async triggers (form submit, button click, search input). For each:
  - What happens on double-click / double-submit? Is the button disabled during loading?
  - What happens if the user navigates away mid-request?
  - If not described — **Defect 8** (Undefined interaction behavior).
- **Form Validation Timing:** For every form in the spec — when does the error message appear?
  - `onChange` (real-time as the user types)?
  - `onBlur` (when the field loses focus)?
  - `onSubmit` (only after submit attempt)?
  If timing is not specified — **Defect 7** (Ambiguous UX contract). Record for each field:
  - `Field: "{name}" → validation timing: described / NOT DESCRIBED → PASS / FAIL`
- **Network Resilience Fuzzing:** Run 3 mandatory scenarios against the spec:
  1. **Slow network (10s+ response):** Is there a timeout state or skeleton/spinner specified?
  2. **Failed/offline:** Is there a retry mechanism or offline error message described?
  3. **Stale data (user opens tab after 3 days):** Is there a data freshness / cache invalidation strategy?
  If any scenario is unaddressed — log as **Defect 6-8** depending on user impact.
- **User Flow Dry Run:** Run the primary user flow described in the spec step by step:
  - Trace each user action → expected system response → next state.
  - Identify dead ends, missing transitions, or contradictory states.
- **Mental Fuzzing (Most important):** Attack the UI requirements. Devise 3 boundary scenarios that will break the layout or UX:
  - *Empty/null content:* What if an API field is null or an empty string? Is the fallback described?
  - *Long content:* Maximum realistic content length — will layout break?
  - *State conflicts:* What if loading and error states trigger simultaneously? What if the user is logged out mid-flow?

### 3. Architecture and NFR (Non-Functional Requirements)

- **URL State Persistence:** Do filters, active tabs, search queries, and pagination sync to URL params? If the spec describes stateful UI (filters, tabs, search) but says nothing about URL state — **Defect 6** (Missing NFR). Users lose context on page refresh or link share.
- **Accessibility (WCAG):**
  - Are ARIA roles specified for icon-only buttons, custom dropdowns, modals?
  - Is focus trap defined for modals and drawers?
  - Is keyboard navigation (Tab, Enter, Escape) described for interactive elements?
  - If interactive elements lack ARIA or keyboard nav spec — **Defect 8** (WCAG 2.1 AA violation risk).
- **Performance:**
  - Are images lazy-loaded? Is virtualization/pagination specified for long lists (>50 items)?
  - Are skeleton screens or progressive loading patterns defined?
  - Missing pagination/virtualization for large data sets → **Defect 6**.

### 4. Ambiguity Check

- Look for UI weasel words: "make it responsive", "looks nice", "standard error", "smooth animation", "works on mobile", "user-friendly", "intuitive layout", "fast enough". These are signs of tech debt.
- Each weasel phrase must be flagged as **Defect 4-5** with a recommendation to replace with a measurable criterion (e.g., "responsive" → "displays correctly at 375px, 768px, 1440px breakpoints").

---

## Step 5 — Defect Consolidation (MANDATORY — execute AFTER all 4 passes, BEFORE writing any output)

**Purpose:** Guarantee that every labeled defect from the analysis makes it into the Risk Matrix. This step prevents silent defect loss.

1. Scan the full text of all 4 passes for any item labeled `DEFECT N`, `Defect N`, `→ Defect`, `BLOCKER`, or `FAIL →`.
2. Compile a numbered master list. Each **unique issue** = one entry. Do not group or merge distinct issues.
3. Count totals by priority band: 10, 8-9, 6-7, 4-5.
4. Every entry becomes a row in the Risk Matrix — merging rows hides defects and skews the Score. Merging is only allowed when two items are literally the same defect described twice.
5. **Write the Executive Summary LAST** — after the Risk Matrix is finalized. Use the counts from step 3 as inputs to the Score formula. Do not compute the Score from intermediate estimates.

**Verification:** `count(Risk Matrix rows) == count(master list entries)`. If not equal — the report is incomplete. Do not generate the output file until they match.

---

## When to Use

- Before writing component code or UI tests for a new feature
- When reviewing requirements from PO/designer/analyst
- When the specification contains ambiguous or potentially conflicting UI requirements

## Anti-patterns (Do Not Use For)

- **Code review** — use manual PR review instead.
- **Backend API specs without a UI counterpart** — this skill audits the UI layer; use a backend-focused audit for pure API contracts.
- **Existing running code** — audit specs before implementation, not after. Running code has already resolved ambiguities; auditing it produces false positives.
- **Test code analysis** — `/component-tests` or `/e2e-tests` are the appropriate skills for test quality review.

## Output Results

**Default:** save full audit to `audit/fe-spec-audit_{SPEC_NAME}_{YYYYMMDD_HHMMSS}.md`, output SKILL COMPLETE block to chat (timestamp format: `YYYYMMDD_HHMMSS`).

**SPEC_NAME** — derived from the specification filename: lowercase, spaces and slashes replaced with `-`, extension stripped. Example: `user-profile-spec.md` → `user-profile-spec`.

**Multiple runs same day for the same spec** — create a NEW file with unique timestamp. Never overwrite previous audits. This ensures audit history and compliance with "Trust No One" principle.

## Output Contract

**Limit:** Maximum 42 Defects.

### 1. Executive Summary

- **Verdict:** `Ready for development` / `Approved with corrections` / `Blocked`.
- **Specification Quality Score:** (0-100%). Calculated by formula:
  - Start: **100%**
  - **-20%** for each Blocker (Priority 10)
  - **-10%** for each Critical (Priority 8-9)
  - **-5%** for each Major (Priority 6-7)
  - **-2%** for each Minor (Priority 4-5)
  - Score cannot be below **0%**.
  - Formula: `Score = max(0, 100 - 20*Blockers - 10*Critical - 5*Major - 2*Minor)`
- **Top 3 risks:** Brief, main issues.

### 2. Risk Matrix (Defect Table)

Sort by Priority (10 → 1).

**Priority Scale:**

- **10 (Blocker):** Only two kinds:
    1. **Data Gap** — data required to render or submit a declared UI element is completely missing from the API schema (e.g. display "user avatar" but `avatarUrl` field is absent entirely).
    2. **Direct logical Contradiction** — two UI rules are mutually exclusive and cannot be implemented simultaneously without changing the specification.
    Everything else — not a Blocker.
- **8-9 (Critical):** High risk of a bug in production: undefined UI state (loading/error/empty), interaction race condition not described, WCAG 2.1 AA violation risk, critical NFR gaps.
- **6-7 (Major):** Layout risk (text overflow undefined), missing URL state sync, architectural risk (no pagination for long lists), standards violations.
- **4-5 (Minor):** Ambiguity in wording, missing error message examples, UI weasel words, missing auxiliary spec attributes.

**Scope-Priority interaction:** A STATE-scoped defect without critical user impact (e.g., a loading state for a background refresh with no visible user action) is capped at Priority 6 — over-escalating low-impact state gaps distorts the Risk Matrix. States that directly block user interaction retain their natural priority regardless of scope.

| Priority | Scope | Category | Issue | Scenario / Evidence | Recommendation |
|:---:|:---:|---|---|---|---|
| **10** | DATA | Data Gap | No `avatarUrl` for avatar display | Spec shows user avatar in header, but API response schema has no avatar field. | Add `avatarUrl` field to API response or use initials fallback — whichever is intended, specify explicitly. |
| **8** | STATE | Undefined State | OrderList missing Loading/Error/Empty states | Component fetches async data but spec only describes the success state. | Define skeleton loader, error message with retry, and empty-list illustration. |
| **7** | LAYOUT | Layout Risk | ProductTitle overflow undefined | Title container shows product name; no overflow rule for names >80 chars. | Specify: truncate with ellipsis at 2 lines, or wrap up to 3 lines. |
| **8** | A11Y | WCAG Violation | Icon-only Close button lacks ARIA | Modal close button is icon-only with no `aria-label` specified. | Add `aria-label="Close modal"` requirement to spec. |
| **5** | STATE | Ambiguity | "Smooth animation" not measurable | Spec says "add smooth transition". No duration or easing defined. | Replace with measurable: "300ms ease-in-out CSS transition". |

Scope values:

- **DATA** — affects data binding between UI and API (missing fields, type mismatches, data source gaps)
- **STATE** — component state coverage (Loading/Error/Empty/Success states, interaction race conditions, form validation timing)
- **A11Y** — accessibility (ARIA roles, keyboard navigation, focus management, WCAG compliance)
- **LAYOUT** — layout and responsiveness (text overflow, breakpoint behavior, long-list rendering)

### 3. Readiness Checklist (Gap Analysis)

Mark what is present (✅), what is missing (❌).

- [ ] **Data Mapping:** All UI elements have an identified data source (API field or static content).
- [ ] **State Matrix:** Loading/Error/Empty/Success states defined for all async components.
- [ ] **Interactions:** Validation timing (onChange/onBlur/onSubmit) and button disabled states during loading are specified.
- [ ] **Accessibility:** Keyboard navigation, ARIA requirements, and focus management described for interactive elements.
- [ ] **Responsiveness:** Mobile/Tablet/Desktop breakpoint behaviors specified (or explicitly out of scope).

### 4. Blocking Questions

Only questions without answers to which coding cannot begin.

**Style:** Each question — a complete, polite, and precise sentence in English, addressed to the analyst or product owner. Do not use abbreviations or jargon.
*Good question example:* "Please clarify what the application should display when the product list API returns an empty array — should it show a placeholder illustration, a text message, or hide the list section entirely?"

1. [Complete interrogative sentence.] (Impact: ...)

## Definition of Done (for AI agent)

Before generating the output file, run the full **Self-Check** section below (items 1–13). All 13 items must pass. If any item fails — complete the missing step first, do not generate the file.

## Self-Check (Critically important)

Before output, check yourself against 13 specific errors in the specification:

1. **UI-to-API Mapping:** Are Lists A and B constructed? Is the delta computed? Non-empty `A \ B` = Defect 10.
2. **State Matrix:** Are Loading/Error/Empty states defined for all async components? Missing critical state = Defect 8.
3. **Layout Boundary:** Is text overflow behavior defined for all dynamic text containers? Undefined = Defect 7.
4. **Data Gap:** Is every UI element backed by an API field or explicitly defined static source?
5. **Interaction Dry Run:** Are double-submit, navigation-during-loading, and state-conflict scenarios addressed?
6. **Form Validation Timing:** Is onChange/onBlur/onSubmit timing specified for every form field with validation? Not specified = Defect 7.
7. **Network Resilience:** Are slow network (10s), offline, and stale data scenarios covered? Unaddressed = Defect 6-8.
8. **Accessibility:** Are ARIA roles, focus trap, and keyboard navigation described for all interactive elements? Missing = Defect 8.
9. **URL State:** Are filters/tabs/search/pagination synced to URL params? Not described for stateful UI = Defect 6.
10. **Ambiguity:** Are UI weasel words ("responsive", "smooth", "user-friendly") replaced with measurable criteria? Not replaced = Defect 4-5.

11. **Defect Completeness:** Count all items labeled `DEFECT N` / `→ Defect` / `BLOCKER` in analysis sections 1–4. Count rows in Risk Matrix. Are they equal? If not — add missing rows before output.
12. **Score Formula Accuracy:** Do the Priority counts in the Score formula exactly match the Risk Matrix row counts by band? Mismatch = recompute Score.
13. **Scope Tags:** Every Risk Matrix row has a Scope tag (DATA/STATE/A11Y/LAYOUT). STATE-scoped defects without critical user impact do not exceed Priority 6.

**If you found any — output them with Priority 8-10 (Critical/Blocker).**

## Verbosity Protocol

**VERBOSITY: MINIMAL:** Minimum explanatory text. Output only tools and completion blocks.

**Communication modes:**

| Mode | When | Format |
|------|------|--------|
| **DONE** | Task completed | `✅ SKILL COMPLETE: ...` block |
| **WARNING** | Issue, but continuing | `⚠️ WARNING: [Issue]` |
| **STATUS** | Phase change | `🤖 Orchestrator Status` (only on agent/phase change) |

**No chat:**

- No "I will read the file" — just the Read tool
- No "I will now execute" — just the Bash tool
- No "The file contains..." — output goes into the completion block
- No "Successfully created..." — the completion block shows artifacts

**Exception:** On WARNING or Gardener Suggestion — explanation is mandatory.

**Decision format:** BLOCK / REJECT / PASS WITH WARNINGS / APPROVE.

**Audit report:** File only. Risk matrix, tables, and Defect details — FORBIDDEN to output in chat.

### Output Discipline (Action-First)

**Priority Threshold:** Defects with Priority 1–3 → include in artifact as appendix only. Never surface in the chat block or highlighted sections. Only Priority 4+ defects count toward the Score formula and appear in the main Risk Matrix.

**Action-First Report Structure in artifact:**

1. Priority 10 (Blocker) defects FIRST
2. Priority 8-9 (Critical) defects SECOND
3. Priority 6-7 (Major) defects THIRD
4. Priority 4-5 (Minor) defects FOURTH
5. Executive Summary LAST (after all defects, not before)

**Mute Empty Bands Rule:** If an entire priority band has zero defects → omit that band's section entirely from the artifact. Do not output empty tables or "No issues found" placeholders for bands.

**Blocking Questions Rule:** If the Blocking Questions section is empty (no unanswered questions exist) → omit the entire section from the artifact. Do not output "None" or empty numbered list.

### Completion

1. Run Gardener Analysis (per `.claude/protocols/gardener.md`) → append `## 🌱 Gardener Analysis` section to the artifact file.
2. Save the full audit result to `audit/fe-spec-audit_{SPEC_NAME}_{YYYYMMDD_HHMMSS}.md`.
3. Output `SKILL COMPLETE` block to chat only (no Risk Matrix, no Defect details, no summary table):

```text
✅ SKILL COMPLETE: /spec-audit (frontend)
├─ Artifacts: audit/fe-spec-audit_{SPEC_NAME}_{YYYYMMDD_HHMMSS}.md — **Each invocation creates a new timestamped file**
├─ Compilation: N/A
├─ Upstream: {specification file path}
├─ Specification Quality Score: X%
├─ Defects: N total (Priority 10: X, 8-9: Y, 6-7: Z, 4-5: W)
└─ Status: BLOCKED / APPROVED WITH CORRECTIONS / READY FOR DEVELOPMENT
```

Full findings → artifact file.
