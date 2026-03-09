# Repo Scout Report: {repo-name}

## §1 Tech Stack

- Framework: [React 18 / Vue 3 / Next 14 / ...]
- TypeScript: [strict | loose | no]
- Styling: [Tailwind / CSS Modules / ...]
- State (global): [Zustand / Pinia / Redux / none]
- Server State: [TanStack Query / SWR / raw / none]
- Build: [Vite / Webpack / ...]
- Testing: [Vitest / Jest / none] + [Playwright / Cypress / none]

## §2 Architecture

- Pattern: [FSD / layers / domain / flat]
- Layer compliance: [% of files in correct layer]

## §3 Component Health

- Total components: N
- With tests: N (%)
- With all 4 states: N (%)
- BANNED patterns found: [list]

## §4 API Integration

- Approach: [TanStack Query / SWR / raw fetch / axios]
- Typed client: [yes / no]
- Mock strategy: [MSW / vi.mock / none]

### Backend Contract Gaps

> CONDITIONAL: Include only if `audit/be-repo-scout-report_*.md` found. Skip section entirely if absent.
> Source: cross-reference of Phase 4 FE code scan vs `be-repo-scout` §3/§4/§7/§11/§14.

| # | Gap Type | Backend Contract | FE Code | File:Line | Severity |
|---|----------|-----------------|---------|-----------|----------|
| 1 | [MISSING_ERROR_HANDLER] | {ERROR_CODE} in §4 Error Map | never caught in FE | {file:line or "not found"} | HIGH |
| 2 | [UNDOCUMENTED_RULE_NOT_HANDLED] | {field min/max rule} in §3 [UNDOCUMENTED] | no Zod/.min()/.max() in FE schema | {file:line} | MEDIUM |
| 3 | [TYPE_MISMATCH] | {field}: int64 in §14 | declared as string in FE types | {file:line} | HIGH |

## §5 Critical Findings

### CRITICAL

- [file:line] — [description] (ref: [antipattern file])

### HIGH

- [file:line] — [description] (ref: [antipattern file])

### MEDIUM

- [file:line] — [description] (ref: [antipattern file])

> Omit severity level if no findings in that tier.

## §6 Prioritized Fix Plan

**Fix immediately (before next deploy):**

1. [Specific action] — [file:line]

**Fix this sprint:**

1. [Specific action] — [file:line]

**Backlog:**

1. [Specific action] — [file:line]

## §7 Project Conventions

> Source: `.claude/conventions/*.md` (Phase 6b). If absent: "No convention files — recommend running `/init-project` to scaffold them."

- Icon library: [Iconify / Heroicons / none / not documented]
- UI component library: [shadcn / Headless UI / custom / none]
- Routing: [Next.js App Router / Vue Router / React Router / not documented]
- API base URL pattern: [env var / hardcoded / not documented]
- Fonts/assets: [Google Fonts / CDN / local / not documented]

## §8 Test Coverage

- Unit tests: N files
- E2E tests: N files
- Estimated coverage: [high / medium / low]

## §9 AI Setup

- CLAUDE.md: [present / absent]
- Cursor rules: [present / absent]
- Copilot instructions: [present / absent]

## §10 Recommendations

Top 3 gaps + suggested next skills
