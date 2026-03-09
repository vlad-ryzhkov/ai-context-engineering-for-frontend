# Report Template — Vue Doctor Health Check

> Template for `/vue-doctor` output.
> Save to: `audit/vue-doctor-report_{YYYYMMDD_HHMMSS}.md`

---

````markdown
# Vue Doctor Health Report

| Field | Value |
|-------|-------|
| Date | {YYYY-MM-DD HH:MM} |
| Mode | {full \| diff \| fix} |
| Path | {scanned path} |
| Score | **{N}/100** (Grade {A-F}) |
| Threshold | {N \| N/A} |
| Verdict | {PASS \| FAIL \| N/A} |

## Tool Status

| Tool | Version | Status | Findings |
|------|---------|--------|----------|
| Oxlint | {version \| N/A} | {ran \| skipped} | {N} |
| ESLint (vue plugin) | {version \| N/A} | {ran \| skipped} | {N} |
| vue-tsc | {version \| N/A} | {ran \| skipped} | {N} |

## Score Computation

```text
Starting score: 100
Errors (unique):  {N} × -3 = -{N}
Warnings (unique): {N} × -1 = -{N}
Deduped findings: {N} removed (same file:line across tools)
Final score: {N}/100 (Grade {A-F})
```

## Score Breakdown

| Category | Issues | Severity |
|----------|--------|----------|
| Vue Reactivity | {N} | {error \| warning} |
| Template Issues | {N} | {error \| warning} |
| Type Safety | {N} | {error \| warning} |
| Dead Code | {N} | {error \| warning} |
| Bundle Size | {N} | {error \| warning} |
| Security | {N} | {error \| warning} |
| Accessibility | {N} | {error \| warning} |

## Findings

### HIGH

> Omit section if no HIGH findings.

#### {N}. {Rule Name}: {Title}

- **File:** `{path}:{line}`
- **Tool:** `{oxlint \| eslint-vue \| vue-tsc}`
- **Rule:** `{rule-id}`
- **Anti-pattern:** `{category/name.md}` or `—` (unmapped)
- **Message:** {diagnostic message}
- **Fix:** {recommendation}

### MEDIUM

> Omit section if no MEDIUM findings.

#### {N}. {Rule Name}: {Title} (Medium)

- **File:** `{path}:{line}`
- **Tool:** `{oxlint \| eslint-vue \| vue-tsc}`
- **Rule:** `{rule-id}`
- **Anti-pattern:** `{category/name.md}` or `—` (unmapped)
- **Message:** {diagnostic message}
- **Fix:** {recommendation}

### LOW

> Omit section if no LOW findings.

#### {N}. {Rule Name}: {Title} (Low)

- **File:** `{path}:{line}`
- **Tool:** `{oxlint \| eslint-vue \| vue-tsc}`
- **Rule:** `{rule-id}`
- **Message:** {diagnostic message}

## Anti-Pattern Coverage

| Rule | Tool | Anti-Pattern | Match |
|------|------|-------------|-------|
| {rule} | {tool} | `{path}` \| — | {Direct \| Partial \| New} |

## Gardener Analysis

> Appended by Gardener Protocol after scan completion.

````
