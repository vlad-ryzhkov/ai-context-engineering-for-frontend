# Report Template — React Doctor Health Check

> Template for `/react-doctor` output.
> Save to: `audit/react-doctor-report_{YYYYMMDD_HHMMSS}.md`

---

```markdown
# React Doctor Health Report

| Field | Value |
|-------|-------|
| Date | {YYYY-MM-DD HH:MM} |
| Mode | {full \| diff \| fix} |
| Path | {scanned path} |
| Score | **{N}/100** (Grade {A-F}) |
| Threshold | {N \| N/A} |
| Verdict | {PASS \| FAIL \| N/A} |

## Score Breakdown

| Category | Issues | Severity |
|----------|--------|----------|
| State & Effects | {N} | {error \| warning} |
| Dead Code | {N} | {error \| warning} |
| Bundle Size | {N} | {error \| warning} |
| Performance | {N} | {error \| warning} |
| Security | {N} | {error \| warning} |
| Accessibility | {N} | {error \| warning} |

## Findings

### HIGH

> Omit section if no HIGH findings.

#### {N}. {Rule Name}: {Title}

- **File:** `{path}:{line}`
- **Rule:** `{react-doctor-rule-name}`
- **Anti-pattern:** `{category/name.md}` or `—` (unmapped)
- **Message:** {diagnostic message}
- **Fix:** {recommendation}

### MEDIUM

> Omit section if no MEDIUM findings.

#### {N}. {Rule Name}: {Title}

- **File:** `{path}:{line}`
- **Rule:** `{react-doctor-rule-name}`
- **Anti-pattern:** `{category/name.md}` or `—` (unmapped)
- **Message:** {diagnostic message}
- **Fix:** {recommendation}

### LOW

> Omit section if no LOW findings.

#### {N}. {Rule Name}: {Title}

- **File:** `{path}:{line}`
- **Rule:** `{react-doctor-rule-name}`
- **Message:** {diagnostic message}

## Anti-Pattern Coverage

| React Doctor Rule | Anti-Pattern | Match |
|-------------------|-------------|-------|
| {rule} | `{path}` \| — | {Direct \| Partial \| New} |

## Gardener Analysis

> Appended by Gardener Protocol after scan completion.
```
