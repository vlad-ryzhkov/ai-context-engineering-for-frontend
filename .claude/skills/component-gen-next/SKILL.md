---
name: component-gen-next
description: Generate production-ready Next.js App Router component. RSC-first with Suspense, Server Actions, generateMetadata. Supports --quick (fast single-file), --path (custom dir), --into (inject markup), --design, --type [ui|feature]. Do not use for React SPA or Vue — use /component-gen instead.
allowed-tools: "Read Write Edit Glob Grep Bash(npx tsc*) Bash(npx biome*) Bash(npx eslint*) Bash(npm run lint*)"
agent: agents/engineer.md
context: fork
---

## Recommended Flow

`/component-gen-next ComponentName` → `/api-bind react` → `/component-tests react`

For UI-heavy work: `/component-gen-next ComponentName --design`
For simple presentational components: `/component-gen-next ComponentName --type ui`
For quick simple elements: `/component-gen-next Badge --quick`
For custom output path: `/component-gen-next Button --type ui --path src/components/ui`
For injecting markup: `/component-gen-next --into src/app/page.tsx "hero section with CTA"`

Note: `/component-tests` auto-detects `--type` from the generated component's imports.

---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Next.js App Router Component Generator

<purpose>
Generates a production-ready TypeScript component for Next.js App Router (15+).

`--type feature` (default): RSC async component. Loading via `<Suspense>` + skeleton. Errors via `error.tsx` boundary or re-throw. Empty via null-check after `await`. Mutations via Server Actions + `useActionState`.
`--type ui`: Presentational component. RSC by default (no directive), or `'use client'` if interactive. Props-driven only.

With `--design` flag: activates Design Thinking (Purpose/Tone/Constraints/Differentiation) and enforces
aesthetic quality — committed font stack, named palette, intentional spatial composition, motion budget.
</purpose>

## When to Use

- `--type feature` (default): Component that fetches data server-side (RSC `await`) or has mutations (Server Actions)
- `--type ui`: Pure presentational component — Button, Badge, Avatar, Card, HeroSection, layout primitives
- Add `--design` when visual quality matters: landing pages, hero sections, marketing UI, editorial layouts

## Input Validation (MANDATORY)

**CRITICAL:** This skill is for Next.js App Router only.

```text
Expected invocation: /component-gen-next ComponentName [--type ui|feature] [--design] [--quick] [--path <dir>] [--into <file>]
```

If invoked with `react` or `vue` framework param:

```text
ERROR: /component-gen-next is for Next.js App Router only.
For React SPA or Vue, use: /component-gen [react|vue] ComponentName
```

`--type` defaults to `feature` if omitted.

**Flag compatibility rules:** Same as `/component-gen` — see `.claude/skills/component-gen/SKILL.md` § Input Validation.

- `--quick` implies `--type ui`. Incompatible with `--type feature` and `--design`.
- `--into` injects markup into existing file. Incompatible with `--type feature` and `--quick`.
- `--path` overrides architecture-based path resolution.

## Input Context (Process Isolation)

`context: fork` — you cannot see chat history before your invocation.

**Allowed inputs:** Component name, `--type` flag, `--design` flag, `--quick` flag, `--path` dir, `--into` file path, optional description, `CLAUDE.md`, existing source files.
**Forbidden:** Assumptions from chat history, inventing API contracts.

## Protocol

### 0. Quick Mode [`--quick` only]

If `--quick` is present → skip to § Quick Mode Workflow below (same as component-gen --quick but React-only).

### 0b. Inline Mode [`--into` only]

If `--into <file>` is present → skip to § Inline Mode Workflow below (same as component-gen --into but React-only).

### 1. Architecture Resolution

Resolve output path BEFORE generating any files. Load `.claude/skills/component-gen/references/architecture-paths.md`.

Priority order:

1. `--path <dir>` — explicit override
2. `audit/fe-repo-scout-report_*.md` → §2 Architecture → Pattern
3. `CLAUDE.md` → `## Project Structure` → `architecture:` value
4. Auto-detect: `ls src/` → match against known directory signatures
5. Fallback: FSD

Next.js-specific path mapping:

| Architecture | --type feature | --type ui |
|---|---|---|
| FSD | `src/{layer}/{slice}/ui/{Name}/` | `src/shared/ui/{Name}/` |
| App Router | `src/components/{Name}/` | `src/components/ui/{Name}/` |
| Custom (--path) | `{path}/{Name}/` | `{path}/{Name}/` |

### 2. Framework Routing

Always load:

- `references/next-patterns.md`
- `references/react-patterns-client.md` (client island subset)
- `.claude/skills/component-gen/references/common-states.md`
- `references/quality-gates-next.md`

If `--design` flag present → also load `.claude/fe-antipatterns/design/no-generic-ai-aesthetics.md`

If component description contains **streaming**, **realtime**, **SSE**, **Server-Sent Events**,
**webhook**, **live**, **progress**, **build log**, **AI generation**, **long-running task**,
**import job** → also load `.claude/skills/component-gen/references/streaming-patterns.md`

### 3. Phase 0: Design Thinking [`--design` only]

**Before generating styles**, agent MUST scan project for existing design tokens:

1. Glob `tailwind.config.*` → if found, extract `theme.extend.colors` and `theme.extend.fontFamily`
2. Glob `src/**/*.css` + `src/**/*.scss` for `--` CSS custom properties → extract palette tokens
3. Use discovered tokens as base palette. Override only if user explicitly requests a new palette.

Answer all four questions in a short `<!-- design-brief -->` comment block at the top of the primary output file:

```text
Purpose:         What does this UI do / what problem does it solve?
Tone:            What emotion should it evoke? (e.g., "confident + minimal", "playful + energetic")
Constraints:     Brand tokens, palette restrictions, motion budget. (List discovered tokens here)
Differentiation: What named aesthetic direction? (e.g., brutalist, editorial, retro-futuristic, glassmorphism-lite)
                 FORBIDDEN to answer "modern and clean" — that is not a direction.
                 If description contains "modern and clean": MUST pick ONE named direction:
                 Swiss Typography, Apple-esque Glassmorphism, Scandinavian Flat, Brutalist Editorial,
                 Retro-Futuristic, Maximalist Chaos, Organic/Natural, Luxury/Refined,
                 High-Fashion Editorial (serif-heavy), Art Deco / Geometric.
```

If the description is too vague to answer Differentiation → ask ONE clarifying question.

### 4. Motion & Composition Directives [`--design` only]

#### Motion Budget

- ONE primary entrance animation per component — do not animate every element
- Staggered reveals for list/grid items: `animation-delay` increments (50ms per item, max 5)
- FORBIDDEN: looping decorative animations unless core UI metaphor — causes battery drain and layout jank
- Animate only `transform` and `opacity` — `width`/`height`/`margin`/`top`/`left` trigger layout reflow and jank
- Scroll-reveal: `IntersectionObserver` or CSS `animation-timeline: view()` — JS scroll handlers block main thread

#### Spatial Composition

- Vary spatial rhythm: at least 2 different spacing scales
- Prefer asymmetry for editorial layouts: CSS grid with unequal column spans (7+5, 8+4)
- Avoid every section having identical `py-16 px-4` padding — monotonous rhythm kills visual hierarchy

### 5. Banned Patterns

Top violations: `: any` / `as any`, `console.log`, `style={{}}` for layout, `<div onClick>` / `<span onClick>`.
Full list: `.claude/skills/component-gen/references/banned-patterns.md`

### 6. RSC Boundary Decision

**Default:** Server Component (no directive). Add `'use client'` only when needed:

- `useState`, `useEffect`, `useRef`, or React state/lifecycle hooks
- Browser APIs (`window`, `document`, `navigator`, `localStorage`)
- Event handlers (`onClick`, `onChange`, `onSubmit`)
- Next.js client hooks: `useRouter`, `usePathname`, `useSearchParams`

**Isolation rule:** Push `'use client'` as deep as possible — small interactive islands, RSC outer shell.

## Component Structure Requirements

### `--type feature` (default — RSC Async)

4 states handled differently than SPA:

| State | Next.js Implementation |
|-------|----------------------|
| Loading | `<Suspense fallback={<Skeleton />}>` at call site + `{ComponentName}.loading.tsx` |
| Error | `error.tsx` boundary catches thrown errors from RSC |
| Empty | Null-check after `await` → inline empty UI or `notFound()` |
| Success | Direct `await` in async RSC body — no TanStack Query |

With `--design`: success state MUST reflect committed aesthetic from Phase 0.

#### Mutation Handling — Server Actions

If the component contains a write action (POST/PUT/DELETE, form submit, like/follow/save/delete):

- Generate `actions.ts` with `'use server'` directive
- Client island uses `useActionState` for pending/error feedback
- Pass action to `<form action={serverAction}>` — NEVER `onSubmit` + `fetch()`
- Note: if a `use{Feature}` hook exists from `/api-bind`, import it for client-side data needs only

### SEO Protocol [page-level components only]

Activated when component name ends with `Page` / `View` / `Route` / `Screen` OR target FSD layer is `pages/`.

| Method | Usage |
|--------|-------|
| `generateMetadata()` | Export async function for title/description/og tags |
| `notFound()` | Call from `next/navigation` when entity not found |
| `redirect()` | Server-side redirect from RSC |

JSON-LD: generate ONLY when component semantics match a schema.org type AND all required fields exist in props/API response.

### `--type ui` (Presentational)

- RSC by default (no directive) — add `'use client'` only if interactive
- Props-driven render only — NO data fetching
- Quality gate: "Props-driven render only" replaces "All 4 states present"

## File Structure

> Output paths depend on detected architecture. See `.claude/skills/component-gen/references/architecture-paths.md`.
> Below are FSD examples (default). For App Router layout, substitute paths per architecture resolution.

### `--type feature` — Next.js App Router (FSD)

```text
src/{layer}/{feature}/
├── ui/{ComponentName}/
│   ├── {ComponentName}.tsx          # RSC (async) or Client Component ('use client')
│   ├── {ComponentName}.types.ts     # Props interface + data types
│   ├── {ComponentName}.loading.tsx  # Skeleton for <Suspense fallback>
│   └── index.ts                     # Barrel export
├── model/                           # Client state only (if 'use client' island needed)
└── actions.ts                       # Server Actions ('use server') — replaces api/
```

### `--type ui` — Next.js App Router (FSD)

```text
src/shared/ui/{ComponentName}/
├── {ComponentName}.tsx              # RSC by default or 'use client' if interactive
├── {ComponentName}.types.ts         # Props interface
└── index.ts                         # Barrel export
```

### `--quick` — Single file output

```text
{resolved-path}/{ComponentName}.tsx   # RSC by default, inline props interface
```

No `types.ts`, no `index.ts`, no `.loading.tsx`.

### `--into` — No new files

Modifies the target file in-place. No types.ts, no index.ts, no new directories.

## Workflow (Standard Mode)

> If `--quick` → skip to § Quick Mode Workflow.
> If `--into` → skip to § Inline Mode Workflow.

1. **Validate** — check invocation (no `react`/`vue` framework param). Check flag compatibility. BLOCKER if wrong.
2. **Resolve architecture** — follow `references/architecture-paths.md` priority (--path > scout report > CLAUDE.md > auto-detect > FSD fallback).
3. **[`--design`] Design Thinking** — scan palette tokens, answer Purpose/Tone/Constraints/Differentiation.
4. **[`--design` + complex primitives]** UI-kit scaffolding — check for `components.json` (shadcn/ui) → `npx shadcn add`.
5. **Scaffold structure** — branch on `--type` + architecture:
   - `--type ui`: resolved UI path from architecture-paths.md.
   - `--type feature`: resolved feature path. FSD: create `ui/`, `model/` (if client island), `actions.ts` (if mutation). Non-FSD: co-locate.
6. **Page Detection (AUTO):** if name ends with Page/View/Route/Screen OR layer is `pages/` → activate SEO Protocol.
7. **Discover** — read `CLAUDE.md`, glob `src/**/*.tsx` for style reference, scan `src/shared/ui/` for reusable primitives.
8. **Load references** — Next.js patterns + client island patterns + common-states.
9. **Generate types** — `{ComponentName}.types.ts` first. `strictNullChecks` + `noUncheckedIndexedAccess` safe.
10. **Generate component** — RSC async for feature, props-driven for UI. Generate `.loading.tsx` skeleton. Generate `actions.ts` if mutation detected.
11. **Generate barrel** — `index.ts` with named export.
12. **Type check** — `npx tsc --noEmit 2>&1 | grep -E "{ComponentName}|{output-path}" | head -30`
13. **Lint** — detect linter (biome/eslint) and run.
14. **Post-Check** — run BANNED pattern grep + data-testid coverage check.
15. **Gardener** — `.claude/protocols/gardener.md`
16. **SKILL COMPLETE**

## Quick Mode Workflow (`--quick`)

Same as `/component-gen --quick` but Next.js-specific: RSC by default (no `'use client'` unless interactive).

1. **Validate** — check invocation. Check `--quick` compatibility.
2. **Resolve architecture** — same priority as standard mode.
3. **Load banned-patterns.md ONLY** — skip common-states, quality-gates, streaming references.
4. **Generate single file** — RSC by default, props interface inlined, no types.ts, no index.ts, no .loading.tsx.
5. **SKILL COMPLETE (compact)**

```text
✅ SKILL COMPLETE: /component-gen-next --quick
├─ Framework: next
├─ RSC Boundary: [Server Component | Client Component]
├─ Artifact: {single file path}
└─ Gates: 5/5 PASS
```

## Inline Mode Workflow (`--into`)

Same as `/component-gen --into` but Next.js-specific.

1. **Validate** — check invocation. Check `--into` compatibility.
2. **Read target file** — MANDATORY. Understand existing structure, RSC/client boundary, imports.
3. **Load banned-patterns.md** — apply banned patterns to injected markup.
4. **Locate injection point** — find JSX `return` → identify where to insert.
5. **Generate markup** — match existing Tailwind patterns, respect RSC boundary.
6. **Edit file** — use Edit tool to insert markup at the correct location.
7. **Lint** — run linter on the modified file only.
8. **SKILL COMPLETE (compact)**

```text
✅ SKILL COMPLETE: /component-gen-next --into
├─ Framework: next
├─ Modified: {file path}
├─ Injected: {description of added section}
└─ Lint: [PASS | FAIL]
```

## Post-Check (Mandatory)

```bash
# BANNED patterns
grep -rn ": any\b\|as any\b\|console\.log\|document\.querySelector\|style={{\|div.*onClick\|span.*onClick" {output-path}/
# Next.js-specific
grep -rn "from 'next/router'" {output-path}/
grep -rn "export const revalidate" {output-path}/
# Render performance
grep -rn "addEventListener.*['\"]scroll['\"]" {output-path}/
```

If `--design` flag was used, also run:

```bash
grep -rn "font-family.*Inter\|font-family.*Arial\|font-family.*Roboto\|font-family.*system-ui" {output-path}/
```

**data-testid coverage:**

- `--type feature`: `data-testid` on empty state container and success state root (`loading-skeleton` lives in `.loading.tsx`, error in `error.tsx`)
- Every interactive element (`<button>`, `<input>`, `<a>`, `<form>`) needs `data-testid`
- Convention: `{component-name}-{element-role}` in kebab-case

## Quality Gates

- [ ] No `react`/`vue` framework param accepted (Next.js only)
- [ ] `--type` param resolved (default: `feature`)
- [ ] **[`--type feature`]** RSC async with `await` — no TanStack Query for data fetching
- [ ] **[`--type feature`]** `.loading.tsx` skeleton created for Suspense fallback
- [ ] **[`--type feature`]** Error handling: thrown to `error.tsx` boundary (not swallowed)
- [ ] **[`--type feature`]** Empty state: null-check after await
- [ ] **[`--type ui`]** Props-driven render only (no async)
- [ ] **[`--type ui`]** RSC by default; `'use client'` only if interactive
- [ ] Defaulted to Server Component unless client strictly needed
- [ ] `'use client'` at very top of file (if used)
- [ ] Uses `next/link` and `next/image` (not `<a>` or `<img>`)
- [ ] No `useRouter` from `next/router` (must use `next/navigation`)
- [ ] Mutations use Server Actions in `actions.ts` (not `fetch()` in client handler)
- [ ] No `export const revalidate = N` (use `'use cache'` directive)
- [ ] No `: any` or `as any` (auto-fixed or BLOCKER)
- [ ] No `console.log` (auto-fixed)
- [ ] No hardcoded URLs
- [ ] `tsc --noEmit` PASS (isolated)
- [ ] Linter PASS
- [ ] Barrel export (`index.ts`) created
- [ ] `src/shared/ui/` scanned — no re-implemented primitives
- [ ] All interactive elements have `data-testid`
- [ ] [`--design` only] → see `.claude/skills/component-gen/references/quality-gates-design.md`
- [ ] [page-level] → see `.claude/skills/component-gen/references/quality-gates-page.md`

## References

- Next.js patterns: `references/next-patterns.md`
- Client island patterns: `references/react-patterns-client.md`
- State structure: `.claude/skills/component-gen/references/common-states.md`
- Quality rules: `references/quality-gates-next.md`
- Banned patterns: `.claude/skills/component-gen/references/banned-patterns.md`
- Design anti-patterns [`--design`]: `.claude/fe-antipatterns/design/no-generic-ai-aesthetics.md`
- Streaming patterns [trigger keywords]: `.claude/skills/component-gen/references/streaming-patterns.md`
- Quality gates `--design`: `.claude/skills/component-gen/references/quality-gates-design.md`
- Quality gates page-level: `.claude/skills/component-gen/references/quality-gates-page.md`

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /component-gen-next
├─ Type: [UI (Presentational) | Feature (RSC Async)]
├─ Framework: next
├─ RSC Boundary: [Server Component | Client Component | Mixed (RSC + client island)]
├─ Artifacts: [list of created files]
├─ Type Check: [PASS (isolated) | FAIL: {error}]
├─ Lint: [PASS (biome) | PASS (eslint) | PASS (npm run lint) | FAIL: {error}]
├─ States: [4/4 (Suspense + error.tsx + empty + success) | N/A (Presentational)]
├─ A11y: [PASS | FAIL: {violation}]
├─ Auto-Corrected: [console.log ×N | any ×N | none]
├─ Server Actions: [Yes (actions.ts) | No | N/A]
├─ SEO: [generateMetadata | N/A]
├─ Type Hint: [/component-tests can auto-detect type via import scan]
└─ Aesthetic: [Project defaults | {Named direction} (--design)]
```

```text
⚠️ SKILL PARTIAL: /component-gen-next
├─ Type: [UI (Presentational) | Feature (RSC Async)]
├─ Framework: next
├─ Artifacts: [list (✅/❌)]
├─ Type Check: [PARTIAL]
├─ Coverage: [X/Y states | N/A (Presentational)]
└─ Blockers: [description]
```
