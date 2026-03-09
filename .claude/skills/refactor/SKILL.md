---
name: refactor
description: >
  AI-powered code transformations for React and Vue projects. Supports predefined transforms
  (class-to-hooks, options-to-composition, cjs-to-esm, tanstack-v4-to-v5) and custom
  AI-driven refactoring. Requires framework parameter [react|vue].
  Each transform follows Discovery → Dry Run → Transform → Verify → Report.
allowed-tools: "Read Write Edit Glob Grep Bash(npx tsc*) Bash(npx biome*) Bash(npx vitest*)"
agent: agents/engineer.md
context: fork
auto-invoke: false
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Refactor — Code Transformation Skill

AI-powered code transformations with verification. Each transform is applied file-by-file
with type-check and lint verification after each batch.

## When to Use

- Migrating class components to hooks (React)
- Migrating Options API to Composition API (Vue)
- Converting CommonJS to ESM
- Upgrading TanStack Query v4 → v5
- Custom refactoring across a scope of files

## Input Validation (MANDATORY)

```text
❌ BLOCKER if framework not provided.

Accepted invocation formats:
  /refactor [react|vue] <transform> [--scope <glob>] [--dry-run]

Available transforms:
  class-to-hooks          Class components → functional + hooks (React only)
  options-to-composition  Options API → Composition API (Vue only)
  cjs-to-esm              require() → import
  tanstack-v4-to-v5       TanStack Query v4 → v5 API changes
  custom "<description>"  AI-powered custom transformation

Flags:
  --scope <glob>   Limit to matching files (default: src/**/*.{tsx,vue,ts})
  --dry-run        Show planned changes without applying them
```

### STOP Checkpoints

| Phase   | Condition                                  | Action                                                              |
| ------- | ------------------------------------------ | ------------------------------------------------------------------- |
| Input   | Framework missing                          | ❌ BLOCKER — halt                                                   |
| Input   | Transform name invalid                     | ❌ BLOCKER — halt                                                   |
| Input   | `class-to-hooks` on Vue project            | ❌ BLOCKER — React only                                             |
| Input   | `options-to-composition` on React project  | ❌ BLOCKER — Vue only                                               |
| Dry Run | >20 files matched                          | ⚠️ WARN — confirm with user before proceeding                      |
| Verify  | tsc fails after transform                  | ⚠️ WARN — attempt 1 fix, then PARTIAL                              |
| Verify  | Existing tests fail post-transform         | ⚠️ WARN — list affected test files in report, do NOT auto-fix tests |

## Protocol

### BANNED

- Transforming test files (*.test.*, *.spec.*) — they follow source, not the other way
- Changing public API signatures without flagging as BREAKING
- Removing comments/JSDoc during transform — preserve all documentation
- Transforming files outside `--scope` glob

### Selector Priority for Custom Transforms

```text
1. AST-level patterns (import statements, export shapes)
2. Type signatures (interface/type changes)
3. Hook/composable usage patterns
4. String-level grep (last resort)
```

## Known Limitations

**Text-based transforms are not AST-level codemods.** The Edit tool operates on string replacement,
not Abstract Syntax Trees. For paradigm-shift transforms (class-to-hooks, options-to-composition),
the agent must reason about scope, closures, and state flow — not just pattern-match text.

**What `tsc --noEmit` cannot catch after transform:**

- Stale closures from incorrect `useEffect` dependency arrays (class-to-hooks)
- Infinite re-render loops from missing/wrong deps
- Behavioral changes in execution order (sync class methods → async hooks)
- Reactivity loss from incorrect `this.*` → `ref.value` mapping (options-to-composition)
- Dynamic `require()` converted to static `import` losing conditional loading semantics (cjs-to-esm)

**Mitigation:** After transform, existing tests serve as behavioral regression baseline.
If tests break → flag in Completion Contract as `Test Impact: X test files need update`.

## Workflow

### Step 1 — Validate

Check framework param. BLOCKER if missing.
Validate transform name against known list or accept `custom "..."`.
Resolve `--scope` glob (default: `src/**/*.{tsx,vue,ts}`).

### Step 2 — Discovery

1. Glob files matching `--scope`.
2. For predefined transforms: grep for transform-specific patterns (see `references/transforms.md`).
3. For custom transforms: scan all files in scope, identify matching patterns.
4. Output discovery summary:

```text
📋 Discovery: /refactor {transform}
├─ Scope: {glob}
├─ Files scanned: {N}
├─ Files matching: {M}
└─ Estimated changes: {description}
```

### Step 3 — Dry Run

For each matching file, output planned changes as a bullet list:

- File path
- What will change (before → after summary)
- Risk level: `safe` | `review` | `breaking`

If `--dry-run` flag → output the plan and STOP. Do not apply changes.

If >20 files → WARN and request user confirmation before proceeding.

### Step 4 — Transform

For each file (sequential, not parallel):

**4a.** Read the file.
**4b.** Apply transformation using `Edit` tool (surgical replacements, not full rewrite).
**4c.** Load `references/transforms.md` for before/after patterns of predefined transforms.

### Step 5 — Verify

After all files transformed:

```bash
npx tsc --noEmit 2>&1 | head -30
npx biome check . 2>&1 | head -20
```

**On tsc failure:**

- Analyze errors — attempt 1 fix iteration.
- On 2nd failure → mark as PARTIAL with error summary.

**On biome failure:**

- Auto-fix: `npx biome check --write .`
- If still failing → include in report.

**Test impact scan:**

```bash
npx vitest run --reporter=verbose 2>&1 | tail -20
```

If tests fail: do NOT transform test files. Report affected tests in Completion Contract under
`Test Impact:` field. Tests written for the old API (e.g., Enzyme for class components) require
separate manual update or a follow-up `/component-tests` run.

### Step 6 — Gardener → SKILL COMPLETE

## Quality Gates

- [ ] Framework param validated
- [ ] Transform name validated (predefined or custom)
- [ ] Discovery completed — file list confirmed
- [ ] Dry run shown to user (or `--dry-run` mode → STOP)
- [ ] All transforms applied via Edit (not Write)
- [ ] `npx tsc --noEmit` — PASS or PARTIAL with errors listed
- [ ] `npx biome check .` — PASS or auto-fixed
- [ ] Test files NOT modified
- [ ] Public API changes flagged as BREAKING (if any)

## References

- Transform patterns: `references/transforms.md`
- Anti-patterns: `.claude/fe-antipatterns/_index.md`

## Completion Contract

```text
✅ SKILL COMPLETE: /refactor
├─ Framework: [react | vue]
├─ Transform: [name]
├─ Scope: [glob]
├─ Files transformed: [X/Y matched]
├─ Type Check: [PASS | FAIL]
├─ Lint: [PASS | FAIL | auto-fixed]
├─ Test Impact: [none | X test files need update]
└─ Breaking Changes: [none | list]
```

```text
⚠️ SKILL PARTIAL: /refactor
├─ Framework: [react | vue]
├─ Transform: [name]
├─ Files transformed: [X/Y matched]
├─ Type Check: [PARTIAL — errors listed]
├─ Lint: [status]
├─ Test Impact: [none | X test files need update]
└─ Blockers: [description]
```
