# CLAUDE.md — Minimal Frontend Project Template

> **Minimality Principle** ([research](https://arxiv.org/abs/2602.11988)):
> Hand-written context outperforms AI-generated (+4% vs −3%). Do NOT add codebase overviews,
> directory listings, or skills tables — agents discover these on their own.

---

## Template

````markdown
# [Project Name]

## Purpose

[One-line description of the project.]

## Tech Stack

| Concern        | Technology                    | BANNED                         |
|----------------|-------------------------------|--------------------------------|
| Language       | TypeScript strict             | `any`, `as any`                |
| Framework      | [React 18 / Vue 3]            | —                              |
| Styling        | [Tailwind CSS / CSS Modules]  | inline `style={}` for layout   |
| State (global) | [Zustand / Pinia]             | —                              |
| Server state   | [TanStack Query / SWR]        | raw fetch in component body    |
| Build          | [Vite]                        | —                              |
| Testing (unit) | [Vitest + Testing Library]    | Jest (unless specified)        |
| Testing (E2E)  | [Playwright]                  | —                              |
| API Client     | [HeyAPI / openapi-ts / fetch] | untyped axios                  |
| Linter         | [Biome / ESLint]              | —                              |

## Commands

| Action      | Command                  |
|-------------|--------------------------|
| Dev server  | `[npm run dev]`          |
| Build       | `[npm run build]`        |
| Type check  | `[npm run typecheck]`    |
| Lint        | `[npx biome check .]`    |
| Test unit   | `[npx vitest run]`       |
| Test E2E    | `[npx playwright test]`  |

## Safety

FORBIDDEN in ALL generated code:
- `any` type in TypeScript
- Prop mutation (mutating props passed from parent)
- Business logic in presentational/view components
- Direct DOM manipulation in component code
- `console.log` left in committed code

MANDATORY for ALL async components:
- Loading state
- Error state (user-facing message)
- Empty/no-data state
- Success/data state

## Safety Protocols

FORBIDDEN: `git reset --hard`, `git clean -fd`, branch deletion, `rm -rf`
MANDATORY: Read file before editing. Stage specific files, never `git add -A`.
OVERRIDE: Requires the word **DESTROY**.

````

---

## File Location

```text
project-root/
└── CLAUDE.md    # In the project root (commit to repo)
```
