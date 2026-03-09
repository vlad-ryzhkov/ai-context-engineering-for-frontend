---
name: react-doctor
description: >
  Run React Doctor health check on a React project. Outputs 0-100 score + diagnostics
  mapped to anti-patterns. React-only — auto-skips Vue projects.
allowed-tools: "Read Glob Grep Bash(npx --yes react-doctor*) Bash(cat*) Bash(jq*) Bash(git*)"
context: fork
auto-invoke: false
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# /react-doctor — React Doctor Health Check

<purpose>
Runs React Doctor (Rust-based Oxlint analyzer, 60+ rules) on a React project.
Outputs a 0-100 health score with diagnostics mapped to existing anti-patterns.
React-only — automatically skips Vue projects.
</purpose>

## Verbosity Protocol (SILENT MODE)

- Do NOT output per-phase progress to chat.
- Output to chat ONLY: blocker messages and the final SKILL COMPLETE block.

## When to Use

- Health check before release or major PR
- Dead code audit (unused exports, components, types)
- Bundle size analysis (heavy imports)
- Quick quality score for a React codebase

## When NOT to Use

- Vue projects → SKIP with note
- Full architecture review → use `/fe-repo-scout`
- PR-scoped code review → use `/frontend-code-review`
- Performance audit with Web Vitals → use `/web-vitals`

## Input

```text
Usage: /react-doctor [mode] [options]

Modes:
  full              Full scan (default)
  diff [base]       Diff-only scan against base branch (default: origin/main)
  fix               Auto-fix safe issues

Options:
  --threshold N     Fail if score < N (default: no threshold)
  --path <dir>      Scan specific directory (default: .)
```

## Protocol (BANNED)

- BANNED: running React Doctor on Vue-only projects
- BANNED: fabricating diagnostics not in tool output
- BANNED: outputting intermediate scan results to chat
- BANNED: modifying source files in `full` or `diff` mode (read-only)

## Phase 1 — Framework Guard (MANDATORY)

```bash
# Check package.json for React dependency (includes peerDependencies for monorepos/UI libs)
cat package.json | jq -r '(.dependencies.react // .devDependencies.react // .peerDependencies.react) // empty'
```

If React not found → output `⚠️ SKIP: React not detected in package.json. React Doctor is React-only.` and STOP.

If Vue detected AND React not detected → same SKIP.

If both React and Vue detected → proceed (React Doctor will analyze React files only).

## Phase 2 — Install Check

```bash
npx --yes react-doctor@1 --version
```

IMPORTANT: Always use `--yes` flag to prevent interactive prompts hanging in CI/automation.
Pin major version (`@1`) — `@latest` is BANNED in automated skills (causes non-reproducible runs).

If unavailable → output `⚠️ React Doctor not available via npx. Install: npm install -g react-doctor` and STOP.

## Phase 3 — Scan

### 3.1 Full Mode (default)

```bash
npx --yes react-doctor@1 . --verbose 2>&1
```

### 3.2 Diff Mode

```bash
# Ensure remote ref is up-to-date (shallow fetch to save time; tolerates offline/CI)
git fetch origin {base} --depth=1 || true
npx --yes react-doctor@1 . --diff origin/{base} --verbose 2>&1
```

Where `{base}` is the argument or `main` by default.

### 3.3 Fix Mode

```bash
npx --yes react-doctor@1 . --fix 2>&1
```

WARN user before running: fix mode modifies source files.

## Phase 4 — Score Extraction

Prefer `--format json` if the tool supports it (parse with `jq`). Fallback to text parsing:

```bash
# Option A: JSON output (preferred — deterministic parsing)
npx --yes react-doctor@1 . --score --format json 2>&1 | jq -r '.score // empty'

# Option B: Text output fallback
npx --yes react-doctor@1 . --score 2>&1
```

**Score Extraction Rule (MANDATORY):**
Search stdout for the exact pattern matching this regex: `Health Score:\s*(\d{1,3})`.
Extract ONLY the number following "Health Score:".
BANNED: treating any other number in the output (file count, rule count, line number) as the health score.

### Threshold Gate

If `--threshold N` was provided and score < N:

- Set verdict to `FAIL`
- Include in report: `Score {X}/100 is below threshold {N}`

### Score Interpretation

| Range | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent — minimal issues |
| 70-89 | B | Good — minor improvements needed |
| 50-69 | C | Fair — significant issues present |
| 30-49 | D | Poor — major refactoring needed |
| 0-29 | F | Critical — fundamental problems |

## Phase 5 — Anti-Pattern Mapping

Cross-reference diagnostics with existing anti-patterns.

> **Reference:** `references/antipattern-map.md`

For each React Doctor finding:

1. Look up the rule name in the mapping table
2. If mapped → cite the anti-pattern reference
3. If unmapped → report as standalone finding

### Severity Mapping

| React Doctor Level | Report Severity |
|--------------------|----------------|
| error | HIGH |
| warning | MEDIUM |
| info | LOW |

## Phase 6 — Report Generation

Generate report using template: `references/report-template.md`

Save to: `audit/react-doctor-report_{YYYYMMDD_HHMMSS}.md`

## Quality Gate

Before marking SKILL COMPLETE, verify ALL of the following:

- [ ] Framework guard passed (React detected in package.json)
- [ ] React Doctor executed successfully
- [ ] Score extracted and graded
- [ ] Diagnostics mapped to anti-patterns where applicable
- [ ] Report written to `audit/`
- [ ] No intermediate output printed to chat (SILENT MODE enforced)

## Gardener Protocol

Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

**Markdown skills** (append to artifact): `react-doctor`

## Completion Contract

```text
SKILL COMPLETE: /react-doctor
 - Report: audit/react-doctor-report_{YYYYMMDD_HHMMSS}.md
 - Mode: [full | diff | fix]
 - Score: {N}/100 (Grade {A-F})
 - Findings: [N high / N medium / N low]
 - Threshold: [PASS | FAIL | N/A]
 - Anti-patterns matched: [N/{total findings}]
```

```text
SKILL PARTIAL: /react-doctor
 - Mode: [full | diff | fix]
 - Artifacts: [list]
 - Coverage: [phases completed / total]
 - Blockers: [description]
```
