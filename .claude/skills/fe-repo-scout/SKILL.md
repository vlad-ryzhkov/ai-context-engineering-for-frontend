---
name: fe-repo-scout
description: >
  Deep analysis of an existing frontend repository. Maps tech stack,
  architecture patterns, component conventions, API integration, test coverage,
  and scans for antipatterns, memory leaks, and performance issues.
  Output: structured recon report with prioritized fix plan.
  Do not use for backend repositories — use /be-repo-scout instead.
allowed-tools: "Read Glob Grep Bash(ls*) Bash(wc*) Bash(grep*) Write"
context: fork
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Repo Scout — Frontend Repository Reconnaissance

<purpose>
Performs a structured exploration of an existing frontend repository.
Outputs a recon report that serves as the upstream artifact for all generation skills.
</purpose>

## Verbosity Protocol (SILENT MODE)

- Do NOT output per-phase progress to chat.
- Do NOT print intermediate grep results or file lists to chat.
- Output to chat ONLY: blocker messages and the final report path on completion.

## Input

```text
Usage: /fe-repo-scout [path?]
Example: /fe-repo-scout
         /fe-repo-scout ../my-frontend-app
```

Default: current directory.

## Algorithm (10 Phases)

### Phase 1 — Stack Detection

```bash
cat package.json | grep -E '"react|"vue|"next|"nuxt|"vite|"webpack|"typescript|"tailwind|"zustand|"pinia|"@tanstack'
```

Detect:

- Framework (React / Vue / Next / Nuxt / other)
- TypeScript? (strict mode?)
- Styling approach (Tailwind / CSS Modules / styled-components / other)
- Build tool (Vite / Webpack / other)

### Phase 2 — Architecture Pattern

```bash
ls src/
```

Identify:

- FSD (app/pages/widgets/features/entities/shared)
- Layer-based (components/hooks/pages/utils)
- Domain-based (by feature folders)
- Flat (no structure)

### Phase 3 — Component Conventions

```bash
# Find component files
ls src/**/*.tsx src/**/*.vue 2>/dev/null | head -20

# Check naming convention
# Check if components have tests
# Check if all 4 states are present in existing async components
```

### Phase 4 — API Integration

```bash
grep -rn "useQuery\|useSWR\|axios\|fetch(" src/ --include="*.ts" --include="*.tsx" --include="*.vue" | head -20
```

Identify:

- Data fetching approach
- API client (typed? raw fetch? axios?)
- Mock strategy (MSW? vi.mock? hardcoded?)

**Upstream contract check (CONDITIONAL):** Glob `audit/be-repo-scout-report_*.md`. If found — read the latest file and cross-reference against actual backend contracts:

- **Missing error handling:** Compare `§4 Error Mapping` codes against FE error handlers. Flag error codes that exist in the backend but are never handled in FE as `[MISSING_ERROR_HANDLER]`.
- **Type mismatches:** If `§14 Contract Mismatch Report` contains `[TYPE_MISMATCH]` entries — check if FE types match. Flag discrepancies.
- **Undocumented rules:** If `§3 Validation Rules` has `[UNDOCUMENTED]` entries — check if FE Zod/yup schemas cover them. Flag missing rules as `[UNDOCUMENTED_RULE_NOT_HANDLED]`.
- **Hidden endpoints:** If `§11 Behavioral Nuances` has `[HIDDEN_PARAM]` entries — note whether FE is passing them.

Record cross-reference findings in report §4 API Integration under "Backend Contract Gaps" sub-section. If no `be-repo-scout` report found → skip silently.

### Phase 5 — Test Coverage

```bash
# Find test files
ls src/**/*.test.* src/**/*.spec.* e2e/**/*.spec.* 2>/dev/null | wc -l

# Check test frameworks
grep -r "vitest\|jest\|playwright\|cypress" package.json
```

### Phase 6 — AI Setup Audit

```bash
ls CLAUDE.md .cursorrules .github/copilot-instructions.md AGENTS.md 2>/dev/null
```

Note: is there existing AI context? Is it up to date?

### Phase 6b — Project Convention Files

```bash
ls .claude/conventions/*.md 2>/dev/null
```

If found — read each file and include findings in §7 Project Conventions of the report.
Extract: icon library, UI component library, routing approach, API base URL pattern.

If not found — note "No convention files — recommend running `/init-project` to scaffold them" in §7.

---

> **Deep Analysis Phases** — run after Phases 1–6. Framework-specific checks are gated on the framework detected in Phase 1.

---

### Phase 7 — Architecture Integrity

**FSD layer violation detection** (run if FSD pattern detected in Phase 2):

```bash
# Upper-layer imports in lower layers (shared / entities)
grep -rn "from.*\/features\|from.*\/pages\|from.*\/widgets" src/shared/ src/entities/ 2>/dev/null | head -20

# API calls inside shared UI (Smart/Dumb coupling)
grep -rn "useQuery\|useSWR\|fetch\|axios" src/shared/ui/ src/components/ 2>/dev/null | head -10
```

Record: number of violations per layer. Each violation is a CRITICAL finding.

### Phase 8 — Antipattern Scan (Framework-Aware)

> **Lazy Load Protocol:** Read `.claude/fe-antipatterns/_index.md` for grep signatures. Read individual pattern files ONLY when a violation is found.

**Common (always run):**

```bash
# Inline styles
grep -rn "style={{" src/ --include="*.tsx" --include="*.jsx" --include="*.vue" 2>/dev/null | head -20

# Hardcoded URLs (ref: common/hardcoded-api-urls.md)
grep -rn "https://\|http://localhost" src/ --include="*.ts" --include="*.tsx" --include="*.vue" 2>/dev/null | head -20

# XSS risk (ref: common)
grep -rn "dangerouslySetInnerHTML\|v-html" src/ 2>/dev/null | head -10

# Missing loading/error states near data-fetching (ref: common/missing-loading-state.md)
grep -rn "useQuery\|useSWR" src/ --include="*.tsx" --include="*.vue" -l 2>/dev/null | xargs grep -L "isLoading\|isPending\|isError\|error" 2>/dev/null | head -10
```

**React-gated (run only when framework=React):**

```bash
# key-as-index (ref: react/key-as-index.md)
grep -rn "key={index}\|key={i}\b" src/ --include="*.tsx" --include="*.jsx" 2>/dev/null | head -20

# Direct DOM mutation (ref: react/direct-dom-mutation.md)
grep -rn "document\.querySelector" src/ --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# useEffect without deps array (ref: react/useeffect-no-deps.md)
grep -rn "useEffect(() =>" src/ --include="*.tsx" --include="*.jsx" 2>/dev/null | head -10

# defineProps without TypeScript (sanity check - should not appear in React)
```

**Vue-gated (run only when framework=Vue):**

```bash
# v-for without :key (ref: vue/v-for-no-key.md)
grep -rn "v-for" src/ --include="*.vue" 2>/dev/null | grep -v ":key" | head -20

# defineProps without TypeScript generics (ref: vue/missing-defineprops-types.md)
grep -rn "defineProps({" src/ --include="*.vue" 2>/dev/null | head -10

# Options API in new code (ref: vue/options-api-in-new-code.md)
grep -rn "export default {" src/ --include="*.vue" 2>/dev/null | xargs grep -l "methods:" 2>/dev/null | head -10
```

**State management (always run):**

```bash
# Server state in UI components (ref: state/server-state-in-client-store.md)
grep -rn "useSelector\|useStore" src/components/ src/shared/ui/ 2>/dev/null | head -10

# Large store files (ref: state/god-store.md)
find src/ -name "*.ts" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | xargs wc -l 2>/dev/null | sort -rn | head -10
```

**A11y (always run):**

```bash
# div/span as button without role (ref: a11y/div-as-button.md)
grep -rn "onClick\|@click" src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep "div\|span" | grep -v 'role=' | head -20

# img without alt (ref: a11y/missing-aria-labels.md)
grep -rn "<img" src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep -v "alt=" | head -10
```

### Phase 9 — Bug Hunt (Memory Leaks & Race Conditions)

```bash
# setInterval/addEventListener without cleanup (potential memory leak)
grep -rn "setInterval\|addEventListener" src/ --include="*.tsx" --include="*.ts" --include="*.vue" -A 10 2>/dev/null | grep -v "clearInterval\|removeEventListener" | head -20

# useEffect with async but no AbortController / isMounted guard (React)
grep -rn "useEffect" src/ --include="*.tsx" -A 5 2>/dev/null | grep "async\|fetch\|axios" | head -10
```

Record: each hit without a corresponding cleanup/guard is a HIGH finding.

### Phase 10 — Performance Scan

```bash
# Heavy array operations in render without memoization
grep -rn "\.filter(\|\.reduce(\|\.sort(" src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep -v "useMemo\|computed" | head -15

# Large JSON imports into bundle
grep -rn "import.*from.*\.json" src/ 2>/dev/null | grep -v "type " | head -10

# Top 5 largest component files (sample for deep read if needed)
find src/ \( -name "*.tsx" -o -name "*.vue" \) 2>/dev/null | xargs wc -l 2>/dev/null | sort -rn | head -6
```

Record: unmemoized heavy computations are MEDIUM findings. Large JSON imports are HIGH.

---

## Output: Recon Report

Save to `audit/fe-repo-scout-report_{YYYYMMDD_HHMMSS}.md`

Follow the template at `.claude/skills/fe-repo-scout/references/report-template.md`.

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Quality Gate

Before marking SKILL COMPLETE, verify ALL of the following:

- [ ] Report file written to `audit/fe-repo-scout-report_{YYYYMMDD_HHMMSS}.md`
- [ ] §1 Tech Stack populated (framework detected, not guessed)
- [ ] §2 Architecture pattern identified
- [ ] §5 Critical Findings present (or explicitly states "No findings")
- [ ] §6 Prioritized Fix Plan has at least one actionable item with file reference
- [ ] Framework-specific checks (Phase 8) match the detected framework — not applied to wrong stack
- [ ] No intermediate grep output printed to chat (SILENT MODE enforced)

## Completion Contract

```text
✅ SKILL COMPLETE: /fe-repo-scout
├─ Report: audit/fe-repo-scout-report_{YYYYMMDD_HHMMSS}.md
├─ Framework: [detected]
├─ Architecture: [detected pattern]
├─ Critical Findings: [N critical / N high / N medium]
└─ Top gaps: [list]
```
