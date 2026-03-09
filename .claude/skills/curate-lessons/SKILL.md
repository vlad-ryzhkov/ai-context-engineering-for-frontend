---
name: curate-lessons
description: >
  Review .ai-lessons/pending.md, deduplicate against existing context files using
  hybrid grep+semantic comparison, graduate unique lessons into target files.
  Requires user approval before applying changes.
allowed-tools: "Read Edit Glob Grep"
auto-invoke: false
---

# /curate-lessons — Lesson Curation Skill

> **Gardener Protocol:** `.claude/protocols/gardener.md` — runs BEFORE `SKILL COMPLETE`.

## Verbosity Protocol (SILENT MODE)

- Do NOT output per-phase progress to chat during Phase 1–2.
- Output to chat ONLY: Phase 3 Curation Report, blocker/WARN messages, and the final SKILL COMPLETE block.

## Purpose

Review `.ai-lessons/pending.md`, deduplicate against existing rules, graduate unique lessons into target context files.

## Input

No parameters required. Reads `.ai-lessons/pending.md` automatically.

## Phase Checkpoints

```text
STOP  if: .ai-lessons/pending.md does not exist or contains 0 entries
WARN  if: < 3 entries → "Only N lesson(s) pending. Curate anyway? [y/N]" — wait for user
INFORM: N entries parsed, proceeding to dedup
```

## Pre-Conditions

- `.ai-lessons/pending.md` must exist and contain ≥ 1 lesson
- If 0 entries → output "No lessons to curate" → STOP
- If < 3 entries → WARN: "Only N lesson(s) pending. Curate anyway? [y/N]" — wait for user response

## Algorithm

### Phase 1 — Read & Parse

1. Read `.ai-lessons/pending.md`
2. Parse each `- RULE:` entry into a list
3. If 0 entries → output "No lessons to curate" → STOP
4. If < 3 entries → WARN: "Only N lesson(s) pending. Curate anyway? [y/N]" → wait for user response. If "n" or no response → STOP

### Phase 2 — Dedup Check

For each pending lesson, run a **two-pass hybrid** dedup:

#### Pass 1 — Grep Narrowing (cheap, parallel)

1. Extract 2–3 most distinctive terms from the lesson text (nouns, technical terms — not generic words like "should", "always", "component")
2. Grep each term independently across candidate files (use `files_with_matches` mode):
   - `CLAUDE.md`
   - `.claude/fe-antipatterns/**/*.md`
   - `.claude/skills/*/SKILL.md`
3. Collect file paths that match ≥ 2 terms → these are **candidate files**
4. If 0 candidate files → lesson is likely unique, skip Pass 2

#### Pass 2 — Semantic Comparison (precise)

1. Read only the candidate files from Pass 1 (not all 50+ context files)
2. For each candidate, compare the lesson's intent against existing rules in that file
3. Verdict per lesson:
   - `DUPLICATE` — same intent already expressed → cite the specific file and section
   - `OVERLAP` — partially covered but lesson adds specificity → recommend merge target
   - `UNIQUE` — no semantic match found

#### Classification (for UNIQUE and OVERLAP lessons)

Classify the graduation target:

- Global rule (applies to all generated code) → `.claude/rules/git-safety.md`
- Skill-specific rule → target `skills/{name}/SKILL.md`
- Code pattern anti-pattern → new or existing `fe-antipatterns/{category}.md`

#### META Classification

If a lesson is **self-referential** (about curation, context file management, gardener behavior, or AI lesson-learning itself) → classify as `META`. META lessons target `curate-lessons/SKILL.md` or `.claude/protocols/gardener.md` — do NOT graduate them into `CLAUDE.md` or anti-pattern files.

### Phase 3 — Curation Report

Output for user confirmation:

```text
📋 CURATION REPORT
| # | Lesson | Verdict | Target | Action |
|---|--------|---------|--------|--------|
| 1 | [text] | GRADUATE | `.claude/rules/git-safety.md` | Append |
| 2 | [text] | DUPLICATE | fe-antipatterns/react/... | Skip |
| 3 | [text] | OVERLAP | skills/api-bind/SKILL.md | Merge |
| 4 | [text] | META | skills/curate-lessons/SKILL.md | Append |
```

**STOP checkpoint:** Wait for user approval before applying changes.

### Phase 4 — Apply (after user approval)

1. Apply Delta Updates (`Edit`, not `Write`) to target files
2. Move graduated rules from `pending.md` to `graduated.md` with date:

   ```text
   - [YYYY-MM-DD] RULE: [text]. Target: [file path]
   ```

3. Remove graduated entries from `pending.md` using `Edit` (Delta Update Protocol):
   - For each graduated entry, set `old_string` to the **complete** entry text — from `- RULE:` through (but not including) the next `- RULE:` line or end of file
   - If the entry spans multiple lines (indented continuation, fenced code blocks), capture the full block including all indented lines
   - Set `new_string` to empty string `""`
   - NEVER use `Write` to regenerate `pending.md` — this violates Delta Update Protocol

### Phase 5 — Update Freq (optional)

1. Check if `.claude/fe-antipatterns/_index.md` exists (Glob for the file). If not found → skip this phase entirely
2. If a graduated rule maps to an existing anti-pattern in `_index.md`:
   - Increment its `Freq` column (`low` → `med` → `high`) based on recurrence

## BANNED

- FORBIDDEN: `Write` on any governed file (Delta Update Protocol)
- FORBIDDEN: graduating a lesson without user approval
- FORBIDDEN: deleting `pending.md` or `graduated.md`
- FORBIDDEN: modifying lessons during dedup — only classify them
- FORBIDDEN: invoking `Edit` or `Write` tools in the same response that outputs the Phase 3 Curation Report — Phase 3 (report) and Phase 4 (apply) MUST be separate turns with user approval between them
- FORBIDDEN: using `Write` on `pending.md` — removals MUST use `Edit` with `old_string`/`new_string` (Delta Update Protocol, `pending.md` header: `<!-- NEVER rewrite -->`)

## Quality Gates

| Gate | Criteria |
|------|----------|
| Start | `pending.md` exists with ≥ 1 entry (WARN if < 3, STOP if 0) |
| Dedup | Two-pass hybrid: Grep narrowing → semantic comparison on candidates |
| Verdicts | Each lesson classified: GRADUATE \| DUPLICATE \| OVERLAP \| META |
| Report | Curation table shown to user (Phase 3 output only — no Edit/Write in same response) |
| Separation | Phase 3→4 boundary enforced: user approval received before any file edits |
| Apply | Delta Updates only (`Edit`, never `Write`) on all governed files |
| Freq | `_index.md` existence verified before Freq update (Phase 5) |

## Completion

```text
✅ SKILL COMPLETE: /curate-lessons
├─ Framework: N/A
├─ Artifacts: [list of modified files]
├─ Type Check: N/A
├─ Lint: N/A
└─ Coverage: [X graduated / Y pending reviewed]
```
