---
name: setup-configs
description: Generate project-level config boilerplate for a new Vite + TypeScript project. Outputs tsconfig.json (strict, FSD path aliases), vite.config.ts (framework plugin + aliases), biome.json (formatter + linter), and package.json scripts. Use when starting a new React or Vue project or standardizing configs. Do not use for non-Vite build systems (Webpack, CRA) or non-TypeScript projects.
allowed-tools: "Read Write Edit Glob Bash(npx tsc*) Bash(npx biome*)"
agent: agents/engineer.md
context: fork
auto-invoke: false
---

## Recommended Flow

`/setup-configs` → `/component-gen`

---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Setup Configs — Project Config Generator

> **SILENT MODE**: Execute all analytical and generation phases silently. Do not output
> intermediate reasoning or conversational filler. Only the final SKILL COMPLETE block
> (or an explicit ESCALATION if blocked) goes to chat.

<purpose>
Generates production-ready project configuration files for a new Vite + TypeScript project.
Framework-agnostic base (tsconfig, biome) + framework-specific files (vite.config.ts).
Covers: tsconfig.json, vite.config.ts, biome.json, package.json scripts section.
</purpose>

## When to Use

- Starting a new React or Vue project from scratch
- Standardizing configs on an existing project that lacks strict TypeScript or Biome
- Onboarding a project to FSD path aliases

## Input Validation (MANDATORY)

**CRITICAL:** Before any generation, validate framework parameter.

Expected invocation: `/setup-configs [react|vue] [ProjectName]`

If framework is missing or not `react`/`vue`, output and stop:

```text
❌ BLOCKER: Framework parameter required.
Usage: /setup-configs [react|vue] ProjectName
Example: /setup-configs react MyApp
         /setup-configs vue MyApp
```

## Input Context (Process Isolation)

`context: fork` — you cannot see chat history before your invocation.

**Allowed inputs:** Framework param, project name, optional target directory, `CLAUDE.md`.
**Forbidden:** Assumptions from chat history, inventing dependency versions.

## Protocol

### 1. Framework Routing

On `react` → load `references/react-configs.md`
On `vue`   → load `references/vue-configs.md`
Both       → load `references/common-configs.md`

### 2. Output Files

| File | Framework | Notes |
|------|-----------|-------|
| `tsconfig.json` | both | strict mode, FSD path aliases |
| `vite.config.ts` | both | framework plugin + path aliases |
| `src/app/test-setup.ts` | both | Vitest setup — imports `@testing-library/jest-dom` |
| `env.d.ts` | Vue only | Vite client types for `.vue` SFC imports |
| `biome.json` | both | formatter + linter, project conventions |
| `package.json` (scripts only) | both | dev, build, typecheck, lint, test |

### 3. BANNED

Stack constraints are LOCKED in `CLAUDE.md` → Tech Stack table. Additional config-level constraints:

- `"strict": false` in tsconfig
- `any` type in generated vite.config.ts
- ESLint or Prettier config files (Biome only)
- Webpack config (Vite only)
- `"noEmit": false`
- `__dirname` or `require()` in vite.config.ts (ESM only — use `import.meta.url`)
- Fabricated semver version numbers (use `"latest"` placeholder)

## tsconfig.json Requirements

- `"strict": true` (mandatory)
- `"noImplicitAny": true`
- `"moduleResolution": "bundler"`
- `"target": "ES2022"`
- Path aliases for all FSD layers: `@app/*`, `@pages/*`, `@widgets/*`, `@features/*`, `@entities/*`, `@shared/*` → `src/{layer}/*`

## vite.config.ts Requirements

- React: `@vitejs/plugin-react` / Vue: `@vitejs/plugin-vue`
- `resolve.alias` matching all FSD layers from tsconfig
- **CRITICAL:** Use ESM-compatible path resolution: `import { fileURLToPath, URL } from 'node:url'` and `fileURLToPath(new URL('./src/{layer}', import.meta.url))`. DO NOT use `__dirname` — it does not exist in ESM (`"module": "ESNext"` + `"moduleResolution": "bundler"`)
- `test` config block for Vitest (`environment: 'jsdom'`)

## biome.json Requirements

- `formatter.enabled: true`, `indentWidth: 2`, `lineWidth: 100`
- `linter.enabled: true`, `recommended: true`
- `organizeImports.enabled: true`
- `files.ignore: ["dist", "node_modules", ".vite"]`

## package.json Scripts Requirements

| Script | React | Vue |
|--------|-------|-----|
| `dev` | `vite` | `vite` |
| `build` | `tsc && vite build` | `vue-tsc && vite build` |
| `typecheck` | `tsc --noEmit` | `vue-tsc --noEmit` |
| `lint` | `biome check .` | `biome check .` |
| `lint:fix` | `biome check --write .` | `biome check --write .` |
| `test` | `vitest run` | `vitest run` |
| `test:watch` | `vitest` | `vitest` |
| `test:e2e` | `playwright test` | `playwright test` |

## Workflow

1. **Validate** — framework param (BLOCKER if missing).
2. **Load references** — `common-configs.md` + framework-specific configs.
3. **Check target dir** — if project directory exists, read existing configs to avoid overwriting custom settings.
4. **Generate tsconfig.json** — strict + FSD aliases (Vue: include `env.d.ts` in `"include"` array).
5. **Generate vite.config.ts** — with correct framework plugin + aliases.
6. **Generate `src/app/test-setup.ts`** — `import "@testing-library/jest-dom"` (both frameworks).
7. **Generate `env.d.ts`** (Vue only) — `/// <reference types="vite/client" />` at project root.
8. **Generate biome.json** — formatter + linter rules.
9. **Generate package.json scripts** — scripts section only (do NOT overwrite full package.json if it exists). Vue: use `vue-tsc` for `build` and `typecheck`.
10. **Dependency check** — If `node_modules` does not exist, SKIP steps 11-12 and set Type Check / Lint to `N/A (no node_modules)`.
11. **Type check** — (only if deps exist) React: `npx tsc --noEmit 2>&1 | head -30` / Vue: `npx vue-tsc --noEmit 2>&1 | head -30`.
12. **Lint** — (only if deps exist) `npx biome check . 2>&1 | head -20` on generated biome.json.
13. **Gardener** — `.claude/protocols/gardener.md`
14. **SKILL COMPLETE**

## Safety Rules

- If `package.json` already exists → ONLY update the `scripts` key via structural edit. Never overwrite `dependencies`, `devDependencies`, or `name`.
- If `package.json` DOES NOT exist → generate a minimal template with `"name"`, `"type": "module"`, `"private": true`, and the required `scripts`.
- If `tsconfig.json` already exists → warn user, output as `tsconfig.generated.json` for manual review.
- If `biome.json` already exists → warn user, output diff only.
- For Vue projects: Biome may have limited `.vue` SFC support. Scope `biome check` to `.ts/.tsx/.js` files if Biome errors on `.vue` syntax.

## Quality Gates

- [ ] Framework param validated
- [ ] tsconfig.json has `"strict": true`
- [ ] tsconfig.json has all 6 FSD path aliases
- [ ] vite.config.ts uses correct framework plugin
- [ ] vite.config.ts `resolve.alias` matches tsconfig paths
- [ ] biome.json has formatter + linter enabled
- [ ] package.json scripts has all 8 required scripts
- [ ] `tsc --noEmit` (React) / `vue-tsc --noEmit` (Vue) PASS on generated tsconfig
- [ ] `biome check` PASS on generated config
- [ ] `src/app/test-setup.ts` generated
- [ ] `env.d.ts` generated (Vue only)

## References

- React config templates: `references/react-configs.md`
- Vue config templates: `references/vue-configs.md`
- Shared config base: `references/common-configs.md`
- Anti-patterns: `.claude/fe-antipatterns/_index.md`

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /setup-configs
├─ Framework: [react | vue]
├─ Project: [project-name]
├─ Artifacts: [tsconfig.json | vite.config.ts | src/app/test-setup.ts | env.d.ts (Vue) | biome.json | package.json scripts]
├─ Type Check: [PASS | FAIL | N/A]  (tsc for React, vue-tsc for Vue)
├─ Lint: [PASS | FAIL | N/A]
└─ Next: /component-gen [react|vue] [ComponentName]
```
