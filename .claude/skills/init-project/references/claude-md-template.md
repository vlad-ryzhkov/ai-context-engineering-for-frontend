# CLAUDE.md — Frontend Project Template

> **Purpose:** Project wiki for the AI assistant. One file that answers: what framework, what patterns, what commands, what is forbidden.

---

## Template

````markdown
# [Project Name]

## Purpose

[One-line description of the project.]

## Communication Protocol (STRICT)

- **CLI mode, not chat:** Execute, don't converse.
- **No preamble:** FORBIDDEN: "Great", "Got it", "Sure", "Let me look".
- **Tool-First:** Action first, comments only AFTER if analysis is needed.

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

## Project Structure

```text
src/
[paste actual directory tree here]
```

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

## Available Skills

| Command                          | Description                                      |
|----------------------------------|--------------------------------------------------|
| `/component-gen [react\|vue]`    | Generate FSD structure + component with all states |
| `/api-bind [react\|vue]`         | OpenAPI → types + client + hook                  |
| `/component-tests [react\|vue]`  | Vitest + Testing Library tests + a11y audit      |
| `/e2e-tests`                     | Playwright E2E tests                             |
| `/fe-repo-scout`                 | Explore repository                               |
| `/init-project`                  | Generate this CLAUDE.md                          |
| `/pr`                            | Create PR with conventional commit               |
````

---

## File Location

```text
project-root/
└── CLAUDE.md    # In the project root (commit to repo)
```
