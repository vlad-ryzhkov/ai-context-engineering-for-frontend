# Review Report Template — Frontend Code Review

> Template for `/frontend-code-review` local mode output.
> Save to: `audit/frontend-code-review_{YYYYMMDD_HHMMSS}.md`

---

```markdown
# Frontend Code Review Report

| Field | Value |
|-------|-------|
| Date | {YYYY-MM-DD HH:MM} |
| Branch | {branch-name} |
| Base | {base-branch} |
| Framework | {React \| Vue \| both} |
| Files reviewed | {N} |
| Lines changed | +{added} / -{removed} |

## React Doctor Score

> Omit section if React not detected or React Doctor unavailable.

| Metric | Value |
|--------|-------|
| Score | {N}/100 (Grade {A-F}) |
| Findings | {N high / N medium} |

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | {N} |
| HIGH | {N} |
| MEDIUM | {N} |
| **Total** | **{N}** |

**Verdict:** {PASS \| PASS WITH WARNINGS \| BLOCK}

- PASS: 0 CRITICAL, 0 HIGH
- PASS WITH WARNINGS: 0 CRITICAL, any HIGH or MEDIUM
- BLOCK: any CRITICAL finding

## Findings

### CRITICAL

> Omit section if no CRITICAL findings.

#### {SEC\|ARCH\|AP\|PERF\|A11Y\|STATE}-{N}: {Title}

- **File:** `{path}:{line}`
- **Category:** {Security \| Architecture \| Anti-pattern \| Performance \| Accessibility \| State Management}
- **Pattern:** {what was detected}
- **Recommendation:** {specific fix}

### HIGH

> Omit section if no HIGH findings.

#### {SEC\|ARCH\|AP\|PERF\|A11Y\|STATE}-{N}: {Title}

- **File:** `{path}:{line}`
- **Category:** {category}
- **Pattern:** {what was detected}
- **Recommendation:** {specific fix}

### MEDIUM

> Omit section if no MEDIUM findings.

#### {SEC\|ARCH\|AP\|PERF\|A11Y\|STATE}-{N}: {Title}

- **File:** `{path}:{line}`
- **Category:** {category}
- **Pattern:** {what was detected}
- **Recommendation:** {specific fix}

## Config & Dependency Changes

> Omit section if no config/dependency files in diff.

| File | Change | Risk |
|------|--------|------|
| {path} | {description} | {LOW \| MEDIUM \| HIGH} |

## Category Legend

| Code | Category |
|------|----------|
| SEC | Security — XSS, secrets, insecure storage, eval |
| ARCH | Architecture — FSD violations, layer coupling |
| AP | Anti-pattern — framework-specific bad practices |
| PERF | Performance — heavy imports, missing memoization, CLS |
| A11Y | Accessibility — ARIA, keyboard nav, alt text |
| STATE | State Management — missing async states, god stores |

## Gardener Analysis

> Appended by Gardener Protocol after review completion.
```
