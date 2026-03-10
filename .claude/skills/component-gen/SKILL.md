---
name: component-gen
description: Generate production-ready SPA component (React or Vue). Feature components include all 4 async states. UI components are props-driven. Supports --quick (fast single-file), --path (custom dir), --into (inject markup), --design, --type [ui|feature]. Requires framework parameter [react|vue]. For Next.js, use /component-gen-next.
allowed-tools: "Read Write Edit Glob Grep Bash(npx tsc*) Bash(npx biome*) Bash(npx eslint*) Bash(npm run lint*)"
agent: agents/engineer.md
context: fork
---

## Recommended Flow

`/component-gen [react|vue] ComponentName` → `/api-bind` → `/component-tests`

For UI-heavy work: `/component-gen [react|vue] ComponentName --design`
For simple presentational components: `/component-gen [react|vue] ComponentName --type ui`
For quick simple elements: `/component-gen [react|vue] Badge --quick`
For custom output path: `/component-gen [react|vue] Button --type ui --path src/components/ui`
For injecting markup: `/component-gen [react|vue] --into src/pages/Home.tsx "hero section with CTA"`

Note: `/component-tests` auto-detects `--type` from the generated component's imports.
Pass `--type` explicitly only to override detection.

---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# SPA Component Generator (React / Vue)

<purpose>
Generates a production-ready TypeScript component for React SPA or Vue SPA.

`--type feature` (default): Full async component with all 4 required states: loading, error, empty, success.
`--type ui`: Presentational component. Props-driven only — no async states required.

With `--design` flag: activates Design Thinking (Purpose/Tone/Constraints/Differentiation) and enforces
aesthetic quality — committed font stack, named palette, intentional spatial composition, motion budget.
</purpose>

## When to Use

- `--type feature` (default): Component that fetches or subscribes to async data (useQuery, Pinia store, API call)
- `--type ui`: Pure presentational component — Button, Badge, Avatar, Card, HeroSection, layout primitives
- Add `--design` when visual quality matters: landing pages, hero sections, marketing UI, editorial layouts

## Phase Checkpoints

```text
STOP  if: framework param missing or not react/vue | component name missing
WARN  if: .claude/conventions/*.md stubs are unfilled (contain <!-- Fill in after project setup -->)
WARN  if: no src/shared/ui/ directory found (shared primitives unknown)
WARN  if: user request contradicts conventions (e.g. mentions "Ant Design" but ui-library.md says shadcn)
INFORM: framework=[react|vue], type=[feature|ui], resolved-path=[path]
```

## Input Validation (MANDATORY)

**CRITICAL:** Before any generation, validate framework parameter.

```text
Expected invocation: /component-gen [react|vue] ComponentName [--type ui|feature] [--design] [--quick] [--path <dir>] [--into <file>]
```

If framework is `next`:

```text
ERROR: For Next.js App Router, use /component-gen-next instead.
Usage: /component-gen-next ComponentName [--type ui|feature] [--design]
```

If framework is missing or not `react`/`vue`:

```text
ERROR: Framework parameter required.
Usage: /component-gen [react|vue] ComponentName [--type ui|feature] [--design] [--quick] [--path <dir>] [--into <file>]
Example: /component-gen react UserCard
         /component-gen vue ProductList
         /component-gen react Button --type ui
         /component-gen vue HeroSection --type ui --design
         /component-gen react Badge --quick
         /component-gen vue --into src/pages/Home.vue "pricing section"
```

`--type` defaults to `feature` if omitted.

**Flag compatibility rules:**

| Flag       | Compatible with                                      | Incompatible with                      |
|------------|------------------------------------------------------|----------------------------------------|
| `--quick`  | `--path`                                             | `--type feature`, `--design`, `--into` |
| `--into`   | `--path` (ignored — file already specifies location) | `--type feature`, `--quick`            |
| `--path`   | `--type`, `--design`, `--quick`                      | `--into`                               |
| `--design` | `--type`, `--path`                                   | `--quick`                              |

`--quick` implies `--type ui`. If `--quick` is passed with `--type feature` or `--design`, reject:

```text
ERROR: --quick is incompatible with --type feature and --design.
--quick implies --type ui with minimal quality gates.
```

## Input Context (Process Isolation)

`context: fork` — you cannot see chat history before your invocation.

**Allowed inputs:** Framework param, component name, `--type` flag, `--design` flag, `--quick` flag, `--path` dir, `--into` file path, optional description, `CLAUDE.md`, existing source files.
**Forbidden:** Assumptions from chat history, inventing API contracts.

## Protocol

### 0. Quick Mode [`--quick` only]

If `--quick` is present, execute abbreviated workflow and SKIP to § Quick Mode Workflow below.

### 0b. Inline Mode [`--into` only]

If `--into <file>` is present, execute inline injection workflow and SKIP to § Inline Mode Workflow below.

### 1. Architecture Resolution

Resolve output path BEFORE generating any files. Load `references/architecture-paths.md` for detection heuristics.

Priority order:

1. `--path <dir>` — explicit override
2. `audit/fe-repo-scout-report_*.md` → §2 Architecture → Pattern
3. `CLAUDE.md` → `## Project Structure` → `architecture:` value
4. Auto-detect: `ls src/` → match against known directory signatures
5. Fallback: FSD (backward compatible)

### 2. Framework Routing

On `react` → load `references/react-patterns.md`
On `vue`   → load `references/vue-patterns.md`
All        → load `references/common-states.md` + `references/quality-gates-spa.md`

If `--design` flag present → also load `.claude/fe-antipatterns/design/no-generic-ai-aesthetics.md`

If component description contains any of **streaming**, **realtime**, **SSE**, **Server-Sent Events**,
**webhook**, **live**, **progress**, **build log**, **AI generation**, **long-running task**,
**import job** → also load `references/streaming-patterns.md`

### 3. Phase 0: Design Thinking [`--design` only]

Load `references/design-thinking.md` — execute the design brief template (palette scan, Purpose/Tone/Constraints/Differentiation).

### 4. Motion & Composition Directives [`--design` only]

Load `references/motion-composition.md` — enforce motion budget and spatial composition rules.

### 5. Banned Patterns

Top violations: `: any` / `as any`, `console.log`, `style={{}}` for layout, `<div onClick>` / `<span onClick>`.
Full list with rationale: `references/banned-patterns.md`

Load `references/banned-patterns.md` during Protocol step before generating any code.

## Component Structure Requirements

### `--type feature` (default — Smart/Async)

Implement all 4 states — gaps cause blank UI on fetch failure or empty response:

```text
1. Loading state  — skeleton, spinner, or shimmer
2. Error state    — user-facing error message (not raw error object)
3. Empty state    — meaningful no-data message (not blank)
4. Success state  — actual data rendered
```

States MUST be mutually exclusive and exhaustive (no UI gap possible).

With `--design`: success state MUST reflect committed aesthetic from Phase 0.

#### Mutation Handling

If the component contains a write action (POST/PUT/DELETE, `useMutation`, like/follow/save/delete/submit):
implement Optimistic UI — instant local update + rollback on error. See `references/common-states.md` §Optimistic UI.

Note: if a `use{Feature}` hook exists from a prior `/api-bind` run, import it instead of generating mutation inline.

#### Integration Patterns (evaluate per component)

If the component warrants a "last-mile" action, generate inline (do not stub):

- Share content → `navigator.share()` with fallback to clipboard copy
- Email trigger → `mailto:` link with pre-filled subject/body
- Calendar invite → `.ics` file or `webcal://` deep link
- Deep link → URL with query params restoring component state

Only add if semantics imply it (EventCard → calendar; ResultCard → share). Do NOT add to every component.

### SEO Protocol [page-level components only]

Activated when component name ends with `Page` / `View` / `Route` / `Screen` OR target FSD layer is `pages/`.

Full protocol: `references/seo-protocol-spa.md` (loaded automatically on page detection).

### `--type ui` (Presentational)

- Render only what props provide — NO async state management
- NO `useQuery`, `useFetch`, Pinia store, or data fetching logic
- Quality gate: "Props-driven render only (no async)" replaces "All 4 states present"
- Barrel export (`index.ts`) still required
- Types file still required

## File Structure

> Output paths depend on detected architecture. See `references/architecture-paths.md`.
> Below are FSD examples (default). For Layer-based/Domain-based, substitute paths per architecture-paths.md.

### `--type feature` — React output (FSD)

```text
src/{layer}/{feature}/
├── ui/{ComponentName}/
│   ├── {ComponentName}.tsx          # Component (exported as default)
│   ├── {ComponentName}.types.ts     # Props interface + data types
│   └── index.ts                     # Barrel export
├── model/                           # State (Zustand store or hooks)
└── api/                             # API calls + TanStack Query hooks
```

### `--type feature` — Vue output (FSD)

```text
src/{layer}/{feature}/
├── ui/{ComponentName}/
│   ├── {ComponentName}.vue          # SFC with <script setup lang="ts">
│   ├── {ComponentName}.types.ts     # Props interface + data types (if complex)
│   └── index.ts                     # Barrel export
├── model/                           # State (Pinia store)
└── api/                             # API calls + TanStack Query hooks
```

### `--type ui` — React output (FSD)

```text
src/shared/ui/{ComponentName}/
├── {ComponentName}.tsx              # Component (exported as default)
├── {ComponentName}.types.ts         # Props interface
└── index.ts                         # Barrel export
```

### `--type ui` — Vue output (FSD)

```text
src/shared/ui/{ComponentName}/
├── {ComponentName}.vue              # SFC with <script setup lang="ts">
├── {ComponentName}.types.ts         # Props interface (if complex)
└── index.ts                         # Barrel export
```

### `--quick` — Single file output (any framework)

```text
{resolved-path}/{ComponentName}.tsx   # React: inline props interface + component
{resolved-path}/{ComponentName}.vue   # Vue: inline props in defineProps + SFC
```

No `types.ts`, no `index.ts`. Props interface inlined in the component file.

### `--into` — No new files

Modifies the target file in-place. No types.ts, no index.ts, no new directories.

## Workflow (Standard Mode)

> If `--quick` → skip to § Quick Mode Workflow.
> If `--into` → skip to § Inline Mode Workflow.

1. **Validate** — check framework param (`react`/`vue` only). Reject `next` with redirect. BLOCKER if missing. Check flag compatibility. Apply Phase Checkpoints above.
1a. **Pre-Load Context** — before resolving architecture, read project conventions:

    ```bash
    cat .claude/conventions/api-layer.md 2>/dev/null || true
    cat .claude/conventions/ui-library.md 2>/dev/null || true
    cat .claude/conventions/icons.md 2>/dev/null || true
    cat .claude/conventions/routing.md 2>/dev/null || true
    ```

    Use discovered conventions (base URL pattern, component library, icon system, router) when generating code.

    **Convention mismatch check:** Compare user's request (component description, mentioned libraries, import paths) against loaded conventions. If a contradiction is detected, output a warning before generating:

    ```text
    ⚠️ CONVENTION MISMATCH:
    ├─ Request mentions: {what user asked for}
    ├─ Convention says:  {what .claude/conventions/ specifies}
    └─ Action: Generating per convention. To override, update .claude/conventions/{file}.md
    ```

    Generate code per conventions unless user explicitly confirms the override.
2. **Resolve architecture** — follow `references/architecture-paths.md` priority (--path > scout report > CLAUDE.md > auto-detect > FSD fallback).
3. **[`--design`] Design Thinking** — scan palette tokens, answer Purpose/Tone/Constraints/Differentiation.
4. **[`--design` + complex primitives]** UI-kit scaffolding — React: check `components.json` (shadcn/ui); Vue: check `components.json` (shadcn-vue). If no shadcn → generate inline.
5. **Scaffold structure** — branch on `--type` + architecture:
   - `--type ui`: resolved UI path from architecture-paths.md.
   - `--type feature`: resolved feature path. FSD: create `ui/`, `model/`, `api/`. Non-FSD: co-locate in component directory.
6. **Page Detection (AUTO):** if name ends with Page/View/Route/Screen OR layer is `pages/` → load `references/seo-protocol-spa.md`. Detect rendering context: `nuxt.config.*` → Nuxt; else → SPA.
7. **Discover** — read `CLAUDE.md`, glob `src/**/*.tsx` or `src/**/*.vue` for style reference, scan `src/shared/ui/` for reusable primitives, check for upstream scout reports (`audit/fe-repo-scout-report_*.md`, `audit/be-repo-scout-report_*.md`).
8. **Load references** — framework-specific patterns + common-states. If `--design`: also load design anti-patterns.
9. **Generate types** — `{ComponentName}.types.ts` first. `strictNullChecks` + `noUncheckedIndexedAccess` safe. JSDoc on exported Props interface.
10. **Generate component** — branch on `--type`:
    - `--type feature`: all 4 states. If mutation detected → Optimistic UI. If `--design` → committed aesthetic.
    - `--type ui`: props-driven render only. If `--design` → committed aesthetic.
11. **Generate barrel** — `index.ts` with named export.
12. **Type check** — `npx tsc --noEmit 2>&1 | grep -E "{ComponentName}|{output-path}" | head -30`
13. **Lint** — detect linter (biome/eslint) and run.
14. **Post-Check** — BANNED pattern grep + data-testid coverage. Auto-fix soft violations.
15. **Gardener** — `.claude/protocols/gardener.md`
16. **SKILL COMPLETE**

## Quick Mode Workflow (`--quick`)

Abbreviated workflow for simple presentational elements. Implies `--type ui`.

1. **Validate** — check framework param. Check `--quick` compatibility (no `--type feature`, no `--design`).
2. **Resolve architecture** — same priority as standard mode.
3. **Load banned-patterns.md ONLY** — skip common-states, quality-gates, streaming, seo references.
4. **Generate single file** — props interface inlined, no types.ts, no index.ts.
5. **SKILL COMPLETE (compact)**

**Quick quality gates (5 only):**

- [ ] No `: any` / `as any`
- [ ] No `console.log`
- [ ] No `<div onClick>` / `<span onClick>`
- [ ] Props typed (inline interface)
- [ ] Semantic HTML (`<button>`, `<a>`, not `<div>` for interactive)

**Skip:** tsc, lint, post-check, gardener, full completion report.

```text
✅ SKILL COMPLETE: /component-gen --quick
├─ Framework: [react | vue]
├─ Artifact: {single file path}
└─ Gates: 5/5 PASS
```

## Inline Mode Workflow (`--into`)

Injects markup into an existing component file. No new files created.

```text
/component-gen [react|vue] --into src/pages/Home/ui/HomePage.tsx "hero section with CTA"
```

1. **Validate** — check framework param. Check `--into` compatibility (no `--type feature`, no `--quick`).
2. **Read target file** — MANDATORY. Understand existing structure, imports, Tailwind patterns.
3. **Load banned-patterns.md** — apply banned patterns to injected markup.
4. **Locate injection point** — find JSX `return` (React) or `<template>` (Vue) → identify where to insert.
5. **Generate markup** — match existing Tailwind patterns, reuse project's design tokens.
6. **Edit file** — use Edit tool to insert markup at the correct location.
7. **Lint** — run linter on the modified file only.
8. **SKILL COMPLETE (compact)**

**Inline quality gates:**

- [ ] No `: any` / `as any`
- [ ] No `console.log`
- [ ] No `<div onClick>`
- [ ] Semantic HTML
- [ ] Existing file structure preserved (no accidental deletions)

```text
✅ SKILL COMPLETE: /component-gen --into
├─ Framework: [react | vue]
├─ Modified: {file path}
├─ Injected: {description of added section}
└─ Lint: [PASS | FAIL]
```

## Post-Check (Mandatory)

```bash
# Grep BANNED patterns in generated files
grep -rn ": any\b\|as any\b\|console\.log\|document\.querySelector\|style={{\|div.*onClick\|span.*onClick" {output-path}/
# Render performance
grep -rn "addEventListener.*['\"]scroll['\"]" {output-path}/
```

If `--design` flag was used, also run:

```bash
grep -rn "font-family.*Inter\|font-family.*Arial\|font-family.*Roboto\|font-family.*system-ui" {output-path}/
```

**data-testid coverage:**

- **`--type feature`:** `data-testid` on each async state container: `loading-skeleton`, `error-state`, `empty-state`, `content`
- **`--type ui`:** no async state containers — skip state container check
- Every interactive element (`<button>`, `<input>`, `<a>`, `<form>`, `<select>`, `<textarea>`) needs `data-testid`
- Convention: `{component-name}-{element-role}` in kebab-case

```bash
grep -n "<button\|<input\|<a href\|<form\|<select\|<textarea" {output-path}/ | grep -v "data-testid"
```

## Quality Gates

- [ ] Framework param validated (`react`/`vue` only — `next` rejected with redirect)
- [ ] `--type` param resolved (default: `feature`)
- [ ] **[`--type feature`]** All 4 states present and mutually exclusive
- [ ] **[`--type ui`]** Props-driven render only (no async)
- [ ] No `: any` or `as any` (auto-fixed or BLOCKER)
- [ ] No `console.log` (auto-fixed)
- [ ] No hardcoded URLs
- [ ] No direct DOM access
- [ ] `tsc --noEmit` PASS (isolated) — **Trust Assertion:** if you already ran `npx tsc --noEmit` this session with zero errors, state "typecheck passed" to skip re-run
- [ ] Linter PASS (biome/eslint — auto-detected)
- [ ] **[`--type feature`]** FSD slice directories created (ui/, model/, api/)
- [ ] **[`--type ui`]** Output in `src/shared/ui/{ComponentName}/` (no model/api)
- [ ] Barrel export (`index.ts`) created
- [ ] [`--design`] → see `references/quality-gates-design.md`
- [ ] `src/shared/ui/` scanned — no re-implemented primitives
- [ ] Types use `value?: T` for optional props
- [ ] Dynamic array access uses `arr[i]?.prop` guard
- [ ] Props interface has JSDoc block
- [ ] **[`--type feature`]** All state containers have `data-testid`
- [ ] All interactive elements have `data-testid`
- [ ] **[`--type feature`, mutation]** Optimistic UI implemented
- [ ] Interactive elements use semantic tags (`<button>`, `<a>`)
- [ ] Form errors: `aria-invalid` + `aria-describedby`
- [ ] Icon-only buttons have `aria-label`
- [ ] **[`--type feature`]** Integration: last-mile action evaluated
- [ ] [page-level] → see `references/quality-gates-page.md` + `references/seo-protocol-spa.md`

## References

- Architecture paths: `references/architecture-paths.md`
- Framework patterns: `references/react-patterns.md` or `references/vue-patterns.md`
- State structure: `references/common-states.md`
- Quality rules: `references/quality-gates-spa.md`
- Banned patterns: `references/banned-patterns.md`
- Anti-patterns: `.claude/fe-antipatterns/_index.md`
- Design anti-patterns [`--design`]: `.claude/fe-antipatterns/design/no-generic-ai-aesthetics.md`
- Streaming patterns [trigger keywords]: `references/streaming-patterns.md`
- Quality gates `--design`: `references/quality-gates-design.md`
- Quality gates page-level: `references/quality-gates-page.md`
- SEO protocol [page-level]: `references/seo-protocol-spa.md`

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /component-gen
├─ Type: [UI (Presentational) | Feature (Smart/Async)]
├─ Framework: [react | vue]
├─ Artifacts: [list of created files]
├─ Type Check: [PASS (isolated) | FAIL: {error}]
├─ Lint: [PASS (biome) | PASS (eslint) | PASS (npm run lint) | FAIL: {error}]
├─ States: [4/4 (Async) | N/A (Presentational)]
├─ A11y: [PASS | FAIL: {violation}]
├─ Auto-Corrected: [console.log ×N | any ×N | none]
├─ Integration: [navigator.share | mailto | calendar | deep-link | N/A]
├─ SEO: [N/A | Nuxt | SPA (document.title) | SPA (@vueuse/head)]
├─ Type Hint: [/component-tests can auto-detect type via import scan]
└─ Aesthetic: [Project defaults | {Named direction} (--design)]
```

```text
⚠️ SKILL PARTIAL: /component-gen
├─ Type: [UI (Presentational) | Feature (Smart/Async)]
├─ Framework: [react | vue]
├─ Artifacts: [list (✅/❌)]
├─ Type Check: [PARTIAL]
├─ Coverage: [X/Y states | N/A (Presentational)]
└─ Blockers: [description]
```
