# Frontend Context Engineering

AI-driven frontend template for Vue 3 / React 18. Every code-generating skill requires `react` or `vue` as input.

## Communication

- **CLI mode:** Execute, don't converse. Tool first, comments only after output.
- **FORBIDDEN:** preamble ("Great", "Got it"), announcements ("I'll now read..."), verbose explanations.

## Tech Stack

| Concern        | React                           | Vue                           | BANNED                           |
|----------------|---------------------------------|-------------------------------|----------------------------------|
| Language       | TypeScript strict               | TypeScript strict             | `any`, `as any`                  |
| Styling        | Tailwind CSS                    | Tailwind CSS                  | inline `style={}` for layout     |
| State (local)  | useState / useReducer           | ref / reactive                | class components                 |
| State (global) | Zustand                         | Pinia                         | Redux Toolkit (unless specified) |
| Server state   | TanStack Query (React)          | TanStack Query (Vue)          | raw fetch in component body      |
| Build          | Vite                            | Vite                          | CRA, Webpack (unless specified)  |
| Testing unit   | Vitest + @testing-library/react | Vitest + @testing-library/vue | Jest (unless specified)          |
| Testing E2E    | Playwright                      | Playwright                    | Cypress (unless specified)       |
| API Client     | HeyAPI / openapi-ts             | HeyAPI / openapi-ts           | raw axios without types          |
| Linter         | Biome                           | Biome                         | mixed ESLint + Prettier configs  |

## Commands

| Action     | Command                                            |
|------------|----------------------------------------------------|
| Dev server | `npm run dev`                                      |
| Build      | `npm run build`                                    |
| Type check | `npm run typecheck` (fallback: `npx tsc --noEmit`) |
| Lint       | `npx biome check .`                                |
| Test unit  | `npx vitest run`                                   |
| Test E2E   | `npx playwright test`                              |

## Principles

1. **Zero Hallucination** — only facts from tools, never fabricate file paths or APIs.
2. **Production Ready** — generated code must be valid TypeScript, no `TODO` stubs left in output.

## Token Economy & Loop Guard

- PAUSE on tasks > 20,000 tokens.
- **Loop Guard:** FORBIDDEN to repeat the same action more than 3 times without progress.
- After 3 unsuccessful attempts → Output "LOOP_GUARD_TRIGGERED: [Reason]" and PAUSE.

## Architecture

→ see `.claude/rules/fsd.md` and `.claude/rules/architecture-alternatives.md`.

## Skills

→ see `.claude/frontend_agent.md` § Skills Matrix for full list and routing.
