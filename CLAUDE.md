# Frontend Context Engineering

AI-driven frontend template for Vue 3 / React 18. Every code-generating skill requires `react` or `vue` as input.

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
