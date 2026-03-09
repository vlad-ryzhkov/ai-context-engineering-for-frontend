---
name: vue-doctor
description: "Run Vue 3 health check via Oxlint + eslint-plugin-vue + vue-tsc pipeline, outputs 0-100 score + anti-pattern diagnostics. Use for pre-release quality gate or Vue template/reactivity audit. Not for React projects, full architecture review, or PR-scoped code review."
allowed-tools: "Read Glob Grep Bash(npx oxlint*) Bash(npx eslint*) Bash(npx vue-tsc*) Bash(cat*) Bash(jq*) Bash(git*) Bash(wc*) Write"
context: fork
auto-invoke: false
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# /vue-doctor — Vue 3 Health Check

<purpose>
Runs a 3-tool pipeline (Oxlint + eslint-plugin-vue + vue-tsc) on a Vue 3 project.
Computes a composite 0-100 health score with diagnostics mapped to existing anti-patterns.
Vue-only — automatically skips React-only projects.
</purpose>

## Verbosity Protocol (SILENT MODE)

- Do NOT output per-phase progress to chat.
- Output to chat ONLY: blocker messages and the final SKILL COMPLETE block.

## When to Use

- Health check before release or major PR
- Vue template and reactivity issue audit
- Type safety analysis (vue-tsc)
- Dead code audit (unused exports, components)
- Quick quality score for a Vue 3 codebase

## When NOT to Use

- React-only projects → SKIP with note
- Full architecture review → use `/fe-repo-scout`
- PR-scoped code review → use `/frontend-code-review`
- Performance audit with Web Vitals → use `/web-vitals`

## Input

```text
Usage: /vue-doctor [mode] [options]

Modes:
  full              Full scan (default)
  diff [base]       Diff-only scan against base branch (default: origin/main)
  fix               Auto-fix safe issues (oxlint --fix + eslint --fix; vue-tsc has no fix)

Options:
  --threshold N     Fail if score < N (default: no threshold)
  --path <dir>      Scan specific directory (default: src/)
```

## Protocol (BANNED)

- BANNED: running vue-doctor on React-only projects
- BANNED: fabricating diagnostics not in tool output
- BANNED: outputting intermediate scan results to chat
- BANNED: modifying source files in `full` or `diff` mode (read-only)
- BANNED: counting the same file:line finding twice across tools (deduplication mandatory)

## Phase 1 — Framework Guard (MANDATORY)

```bash
# Check package.json for Vue dependency
cat package.json | jq -r '(.dependencies.vue // .devDependencies.vue // .peerDependencies.vue) // empty'
```

If Vue not found → output `SKIP: Vue not detected in package.json. Vue Doctor is Vue-only.` and STOP.

If React detected AND Vue not detected → same SKIP.

If both Vue and React detected → proceed (vue-doctor will analyze Vue files only).

## Phase 2 — Tool Availability

Check each tool independently. Missing tool → WARN + SKIP that tool. If ALL 3 missing → STOP.

```bash
# Check Oxlint
npx oxlint --version 2>&1

# Check ESLint with vue plugin
npx eslint --version 2>&1

# Check vue-tsc
npx vue-tsc --version 2>&1
```

Track available tools in a status table:

| Tool | Status | Version |
|------|--------|---------|
| Oxlint | available / SKIPPED | {version} |
| ESLint (vue plugin) | available / SKIPPED | {version} |
| vue-tsc | available / SKIPPED | {version} |

If a tool is missing: `WARN: {tool} not found — skipping. Install: {install command}`

If ALL 3 missing → output `STOP: No analysis tools available. Install at least one: see references/tool-configs.md` and STOP.

## Phase 3 — Scan: Oxlint

> Skip if Oxlint unavailable (Phase 2).

### 3.1 Full Mode (default)

```bash
npx oxlint -D all --include "**/*.vue" --include "**/*.ts" . 2>&1
```

### 3.2 Diff Mode

```bash
git fetch origin {base} --depth=1 || true
git diff --name-only origin/{base}...HEAD -- '*.vue' '*.ts' > /tmp/vue-doctor-diff-files.txt
npx oxlint -D all $(cat /tmp/vue-doctor-diff-files.txt | tr '\n' ' ') 2>&1
```

### 3.3 Fix Mode

```bash
npx oxlint -D all --fix --include "**/*.vue" --include "**/*.ts" . 2>&1
```

WARN user before running: fix mode modifies source files.

## Phase 4 — Scan: ESLint Vue

> Skip if ESLint unavailable (Phase 2).

### 4.1 Full Mode (default)

```bash
npx eslint --ext .vue,.ts --format json src/ 2>&1
```

### 4.2 Diff Mode

```bash
npx eslint --ext .vue,.ts --format json $(cat /tmp/vue-doctor-diff-files.txt | tr '\n' ' ') 2>&1
```

### 4.3 Fix Mode

```bash
npx eslint --ext .vue,.ts --fix src/ 2>&1
```

Parse JSON output to extract rule IDs, file paths, line numbers, and severity.

## Phase 5 — Scan: vue-tsc

> Skip if vue-tsc unavailable (Phase 2).

```bash
npx vue-tsc --noEmit 2>&1
```

vue-tsc has no diff mode (always scans full project) and no fix mode.
Parse output for TS error codes (TS2339, TS7006, etc.), file paths, and line numbers.

## Phase 6 — Score Computation + Anti-Pattern Mapping

### 6.1 Deduplication

Before scoring, deduplicate findings where the same `file:line` is reported by multiple tools (Oxlint and ESLint overlap significantly):

1. Build a set of unique `{file}:{line}:{rule-category}` keys
2. If Oxlint and ESLint report the same file:line for the same category → keep one, discard duplicate
3. vue-tsc findings are always unique (type errors don't overlap with lint rules)

### 6.2 Scoring Algorithm

```text
score = 100
for each unique error:   score -= 3
for each unique warning: score -= 1
score = max(score, 0)
```

### 6.3 Grade Scale

| Range | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent — minimal issues |
| 70-89 | B | Good — minor improvements needed |
| 50-69 | C | Fair — significant issues present |
| 30-49 | D | Poor — major refactoring needed |
| 0-29 | F | Critical — fundamental problems |

### 6.4 Threshold Gate

If `--threshold N` was provided and score < N:

- Set verdict to `FAIL`
- Include in report: `Score {X}/100 is below threshold {N}`

### 6.5 Anti-Pattern Mapping

Cross-reference diagnostics with existing anti-patterns.

> **Reference:** `references/antipattern-map.md`

For each finding:

1. Look up the rule name in the mapping tables (one per tool)
2. If mapped → cite the anti-pattern reference
3. If unmapped → report as standalone finding

### Severity Mapping

| Tool Level | Report Severity |
|------------|----------------|
| error | HIGH |
| warning | MEDIUM |
| info / hint | LOW |

### Score Breakdown Categories

| Category | What counts |
|----------|-------------|
| Vue Reactivity | Prop mutation, reactive destructuring, computed side effects |
| Template Issues | v-for/v-if conflicts, missing keys, template complexity |
| Type Safety | vue-tsc errors, missing defineProps types, implicit any |
| Dead Code | Unused exports, components, types |
| Bundle Size | Heavy imports, non-tree-shakeable packages |
| Security | v-html usage, unsafe-target-blank |
| Accessibility | Missing alt text, div-as-button, missing aria labels |

## Phase 7 — Report Generation

Generate report using template: `references/report-template.md`

Save to: `audit/vue-doctor-report_{YYYYMMDD_HHMMSS}.md`

## Quality Gate

Before marking SKILL COMPLETE, verify ALL of the following:

- [ ] Framework guard passed (Vue detected in package.json)
- [ ] At least 1 of 3 tools executed successfully
- [ ] Findings deduplicated across tools
- [ ] Score computed and graded
- [ ] Diagnostics mapped to anti-patterns where applicable
- [ ] Report written to `audit/`
- [ ] No intermediate output printed to chat (SILENT MODE enforced)

## Gardener Protocol

Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

**Markdown skills** (append to artifact): `vue-doctor`

## Completion Contract

```text
SKILL COMPLETE: /vue-doctor
 - Report: audit/vue-doctor-report_{YYYYMMDD_HHMMSS}.md
 - Mode: [full | diff | fix]
 - Score: {N}/100 (Grade {A-F})
 - Tools: [oxlint: ran/skipped] [eslint-vue: ran/skipped] [vue-tsc: ran/skipped]
 - Findings: [N high / N medium / N low] (after dedup)
 - Threshold: [PASS | FAIL | N/A]
 - Anti-patterns matched: [N/{total findings}]
```

```text
SKILL PARTIAL: /vue-doctor
 - Mode: [full | diff | fix]
 - Artifacts: [list]
 - Coverage: [phases completed / total]
 - Blockers: [description]
```
