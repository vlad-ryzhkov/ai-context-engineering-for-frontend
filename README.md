# AI Context Engineering for Frontend

A ready-to-use AI context template for Vue 3 / React 18 projects.
Drop it into your repo — and your AI assistant gains 25 skills:
component scaffolding, API binding, test generation, code review, and more.

Works with Claude Code, Cursor, VS Code Copilot, and Codex (see `IDE Compatibility`).

Start with this README, then try `/component-gen react` (or `vue`) on a real project.

<details>
<summary><strong>Which path is for me?</strong></summary>

| Starting point                   | First skills                       |
|----------------------------------|------------------------------------|
| **New project** (no code yet)    | `/init-project` → `/setup-configs` |
| **Existing project** (adding AI) | `/fe-repo-scout` → `/init-project` |
| **Daily tasks** (acknowledging)  | `/component-gen react` or `vue`    |
| **Integrating backend API**      | `/be-repo-scout` → `/api-bind`     |

**Learning progression:**

- **Day 1:** Copy `.claude/`, `/init-project`, [fill conventions](#fill-conventions), `/component-gen`
- **Week 1:** `/component-gen` for features + `/component-tests` after each + `/browser-check`
- **Ongoing:** `/fe-repo-scout` periodically + `/frontend-code-review --staged` before PRs

</details>

---

## Quick Start

Three steps to start getting value:

1. **Copy** — Copy the `.claude/` folder from this repo into your frontend project root.
   For non-Claude IDEs (Cursor, Copilot, etc.), see [IDE Compatibility](#ide-compatibility) below.

**Note** — You can use all files locally. For example, add them to the local gitignore:
`echo "claude.md" >> .git/info/exclude`

<a id="fill-conventions"></a>

1. **Initialize** — Open your AI assistant in the project and run:

   ```text
   /init-project
   ```

   This generates `CLAUDE.md` with project-specific AI instructions.

   > **:warning: CRITICAL STEP — fill in `.claude/conventions/`**
   >
   > These files tell AI which UI library, icons, API layer, and router your project uses.
   > Without them, AI falls back to template defaults (shadcn, Iconify, HeyAPI) and
   > **will generate wrong imports, wrong component names, and wrong API patterns.**
   > `/component-gen` checks conventions at runtime and warns on mismatches.

   <details>
   <summary><strong>Convention files — what to fill in</strong></summary>

   | File                  | What it tells AI                      | Example value                                |
   |-----------------------|---------------------------------------|----------------------------------------------|
   | `ui-library.md`       | Component library, import paths       | shadcn/ui → `@/shared/ui/button`             |
   | `icons.md`            | Icon source, package, bundle strategy | Iconify `@iconify/react`, offline only       |
   | `api-layer.md`        | Base URL, auth, client, error format  | HeyAPI, Bearer token, `VITE_API_BASE_URL`    |
   | `routing.md`          | Router, auth guard, code splitting    | Vue Router 4 / React Router 6, lazy loading  |
   | `fonts-and-assets.md` | Fonts, images, SVG, static assets     | Self-hosted fonts, Vite asset pipeline       |
   | `i18n.md`             | i18n library, locales, key format     | react-i18next / vue-i18n, `auth.login.title` |
   | `monorepo.md`         | Workspace structure, build pipeline   | Turborepo + pnpm workspaces                  |

   Each file has HTML comments with hints and sensible defaults pre-filled.
   Replace defaults with your project's actual values. Delete files for concerns that don't apply (e.g. `i18n.md` if no localization).

   </details>

2. **Run your first skill** — Generate a component:

   ```text
   /component-gen react
   ```

   or

   ```text
   /component-gen vue
   ```

> **Behind the scenes:** The orchestrator (`.claude/frontend_agent.md`) routes your
> requests to the correct agent, and [61 anti-pattern quality gates](.claude/fe-antipatterns/_index.md)
> check generated code automatically. No configuration needed.

---

> **Tip:** Start by running individual skills to understand their output.
> Once comfortable, chain them into pipelines (Flows below).
> Each skill is self-contained and can run independently.

## Skills Reference & Flows

| Skill                   | Zone       | Description                                                                                                                                                                       | Flags                                               | Framework     |
|:------------------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|---------------|
| `/init-project`         | Onboarding | Scan repo → generate project-specific CLAUDE.md                                                                                                                                   |                                                     | No            |
| `/setup-configs`        | Onboarding | tsconfig.json + vite.config.ts + biome.json + scripts                                                                                                                             |                                                     | Yes           |
| `/be-repo-scout`        | Discovery  | Scan a **backend** repo → extract API contracts. Output: TypeScript interfaces + Zod schemas + typed error map + local dev setup. Works even without OpenAPI spec.                |                                                     | No            |
| `/fe-repo-scout`        | Discovery  | Audit an **existing frontend** repo. 10-phase scan: stack + architecture + antipattern scan (25 patterns) + memory leaks + perf. Output: CRITICAL/HIGH/MEDIUM findings + fix plan |                                                     | No            |
| `/spec-audit`           | Pre-build  | Audit UI/UX spec for WCAG, state coverage, API field mapping before writing code. Run before `/component-gen` to catch gaps early.                                                |                                                     | No            |
| `/component-gen`        | Build      | SPA component with all 4 states                                                                                                                                                   | `--type`, `--design`, `--quick`, `--path`, `--into` | react \| vue  |
| `/component-gen-next`   | Build      | Next.js App Router component (RSC, Suspense, Server Actions)                                                                                                                      | `--type`, `--design`, `--quick`, `--path`, `--into` | next (React)  |
| `/api-bind`             | Build      | OpenAPI / Protobuf / be-repo-scout report → TS types + typed client + TanStack Query hook                                                                                         |                                                     | react \| vue  |
| `/api-mocks`            | Build      | MSW v2 handlers + typed fixtures from OpenAPI spec, `/api-bind` output, or manual endpoints                                                                                       | `--browser`, `--entity`, `--from-api-bind`          | agnostic      |
| `/refactor`             | Build      | Code transforms: class-to-hooks, options-to-composition, cjs-to-esm, tanstack-v4-to-v5, custom AI refactoring                                                                     | `--scope`, `--dry-run`                              | react \| vue  |
| `/component-tests`      | QA         | Unit tests (Vitest or Jest) + Testing Library + a11y audit. Auto-detects runner from project config.                                                                              | `--type` (auto-detected), `--diff`                  | react \| vue  |
| `/e2e-tests`            | QA         | Playwright E2E tests — Page Object Model, auth storage, network mocking, data factories.                                                                                          | `--auth`, `--mock`, `--visual`                      | No            |
| `/browser-check`        | QA         | Ad-hoc visual check via [agent-browser](https://github.com/vercel-labs/agent-browser) CLI. Snapshots interactive elements (93% fewer tokens than raw DOM). No file artifacts.     |                                                     | No            |
| `/web-vitals`           | QA         | Audit Core Web Vitals (LCP/CLS/INP) + JS/CSS/image budgets against Google thresholds. Output: prioritized fix plan. Does not fix — only audits.                                   |                                                     | No            |
| `/frontend-code-review` | QA         | Review PR diff for security, architecture, anti-patterns                                                                                                                          | `--staged`                                          | No            |
| `/react-doctor`         | QA         | React Doctor health check — 0-100 score, dead code, heavy imports, 60+ Oxlint rules (React-only)                                                                                  | `--threshold N`                                     | React only    |
| `/vue-doctor`           | QA         | Vue 3 health check — 0-100 score via Oxlint + eslint-plugin-vue + vue-tsc pipeline (Vue-only)                                                                                     | `--threshold N`                                     | Vue only      |
| `/ui-tweak`             | QA         | Visual feedback loop via [Agentation](https://github.com/nichochar/agentation). Human annotates UI in browser → AI locates source → applies fix → type check + lint → resolves.   | `watch`, `session <id>`                             | React-favored |
| `/pr`                   | Ship       | PR with conventional commit title from staged changes                                                                                                                             |                                                     | No            |

<details>
<summary><strong>Template maintenance skills (not for daily development)</strong></summary>

These skills are for maintaining and extending the template itself, not for daily frontend work.

| Skill              | Description                                                 |
|:-------------------|:------------------------------------------------------------|
| `/fix-markdown`    | Fix markdownlint errors in .md files                        |
| `/init-agent`      | Generate frontend_agent.md for AI onboarding                |
| `/init-skill`      | Create or improve a skill interactively                     |
| `/skill-audit`     | Audit SKILL.md / frontend_agent.md for bloat                |
| `/update-ai-setup` | Sync docs/ai-setup.md Registry after adding/removing skills |
| `/agents-checker`  | Verify .claude/agents/ structural integrity                 |
| `/curate-lessons`  | Deduplicate + graduate .ai-lessons/ into context files      |

</details>

### Flow 0: Project Onboarding (one-time)

```text
New frontend project:
  /init-project → /setup-configs [react|vue]
  → generates CLAUDE.md + tsconfig + vite.config + biome.json
  → fill .claude/conventions/ (ui-library, icons, api-layer, routing, etc.)
    ⚠ Without this step AI uses template defaults and generates wrong imports/patterns.
    See Quick Start § "CRITICAL STEP — fill in .claude/conventions/" for details.

  # Example:
  # /init-project          → detects: React 18.3 + Vite 5 + Zustand + TanStack Query
  # /setup-configs react   → writes: tsconfig.json, vite.config.ts, biome.json, package.json scripts

Integrating a backend service:
  Step 0 (recommended): open the backend repo and run /init-project
    → generates CLAUDE.md in the backend repo with project-specific context
    → gives /be-repo-scout better understanding of the codebase structure

  /be-repo-scout
  → outputs: TypeScript interfaces, Zod schemas, error const map, local dev setup
  → works with: OpenAPI/Swagger, Protobuf/gRPC, GraphQL, undocumented code (greps handlers)

  If OpenAPI spec or Protobuf found:
    → /api-bind [react|vue] reads spec (or §2+§7 from report) → typed client + TanStack Query hook

  If no spec at all:
    → /api-bind [react|vue] can still use be-repo-scout report (§7 TS types) as input
    → generates typed client + hook from excavated interfaces

  # Example:
  # /be-repo-scout ../payments-service
  #   → audit/be-repo-scout-report_payments-service.md (§7: ChargeRequest, ChargeResponse, PaymentError)
  # /api-bind react ./openapi.json POST /api/payments/charge
  #   → src/features/payments/api/paymentsTypes.ts + paymentsApi.ts + useChargePayment.ts

Auditing an existing frontend codebase (standalone):
  /fe-repo-scout
  → output: CRITICAL/HIGH/MEDIUM findings + prioritized fix plan

  # Example:
  # /fe-repo-scout → found: 3 CRITICAL, 7 HIGH, 12 MEDIUM findings
  #   CRITICAL: raw fetch in 4 components (missing error/loading states)

Auditing frontend + known backend (cross-layer analysis):
  /be-repo-scout → /fe-repo-scout
  → fe-repo-scout reads be-repo-scout output: detects missing error handlers, type mismatches,
    unhandled [UNDOCUMENTED] validation rules
  → output: CRITICAL/HIGH/MEDIUM findings + prioritized fix plan
```

### Flow 1: Feature Delivery (main loop — per feature)

```text
figma:implement-design  ─┐
                         ├──► /component-gen [react|vue] ComponentName     ← 4 async states
/spec-audit (optional) ──┘    /component-gen [react|vue] Name --design    ← + design thinking
                              /component-gen [react|vue] Icon --quick     ← simple element
                              /component-gen [react|vue] --into Page.tsx  ← inject markup
→ /browser-check                                                ← AI visual check (optional)
→ /api-bind [react|vue]                                         ← OpenAPI, Protobuf, or be-repo-scout report
→ /component-tests [react|vue]                                  ← Vitest tests + a11y audit
→ /refactor [react|vue] <transform>                             ← codemod / migration (optional)
→ /e2e-tests                                                    ← critical paths (optional)
→ /pr
```

> `/component-gen` variant details: [docs/ai-setup.md § Skill Details](docs/ai-setup.md#component-gen--variant-behavior)

### Flow 2: API Binding

```text
/be-repo-scout                                      ← excavate API contracts from backend code

Input mode 1 — OpenAPI spec:
→ /api-bind react ./openapi.json GET /api/users
  # Output: src/features/users/api/usersTypes.ts + usersApi.ts + useUsers.ts
  # GET → useQuery hook (auto-cached, background refetch)

→ /api-bind vue ./openapi.json POST /api/orders
  # Output: src/features/orders/api/ordersTypes.ts + ordersApi.ts + useCreateOrder.ts
  # POST → useMutation hook (optimistic update, error rollback)

Input mode 2 — Protobuf:
→ /api-bind react ./proto/user.proto UserService.GetUser
  # Output: src/features/users/api/usersTypes.ts + usersApi.ts + useGetUser.ts

Input mode 3 — no spec (be-repo-scout fallback):
→ /api-bind react
  # Reads be-repo-scout report §7 TS interfaces → generates typed client + hook
```

### Flow 3: Frontend Testing

```text
/spec-audit spec.md                          ← (pre-dev) deep QA audit of UI/UX spec: states, a11y, data gaps
→ /component-tests react UserCard              ← feature component: tests all 4 async states + a11y audit
  /component-tests vue ProductList --type ui   ← UI component: tests prop variants + interactions
→ /e2e-tests "user adds item to cart and checks out" --auth --mock
  # → tests/e2e/cart-checkout.spec.ts + CartPage.ts (Page Object)
→ /browser-check http://localhost:5173/cart    ← quick visual sanity check (no files written)
→ /react-doctor | /vue-doctor                  ← framework health check (0-100 score + diagnostics)
→ /frontend-code-review                        ← PR diff review: security, architecture, anti-patterns
→ /web-vitals                                  ← Core Web Vitals + bundle budget audit
→ /ui-tweak                                    ← visual annotation → targeted code fix

# Gaps (no skill yet): coverage report analysis
```

> Per-tool details (testing pyramid, runner detection, POM, thresholds): [docs/ai-setup.md § Skill Details](docs/ai-setup.md#skill-details)

### Flow 4: Adopting in an Existing Project

```text
/init-project                              ← scan repo → generate project-specific CLAUDE.md
→ /fe-repo-scout                           ← map architecture, conventions, antipatterns found
→ fill .claude/conventions/ stubs          ← add team conventions: icons, UI library, API layer, routing
→ /component-gen [react|vue] NextFeature   ← generate next feature with correct project context

# Example — adding AI to an existing Vue 3 dashboard:
# /init-project        → detects: Vue 3.4 + Pinia + Vite 5 + Element Plus + Vue Router 4
# /fe-repo-scout       → found: 2 CRITICAL (raw fetch, missing error states), 5 HIGH, 9 MEDIUM
# fill conventions:
#   ui-library.md → Element Plus, import from "element-plus"
#   icons.md      → @element-plus/icons-vue
#   api-layer.md  → axios + /src/services/http.ts wrapper, Bearer token
#   routing.md    → Vue Router 4, lazy routes via defineAsyncComponent
# /component-gen vue AnalyticsDashboard
#   → src/features/analytics/ui/AnalyticsDashboard.vue (uses Element Plus + Pinia, not template defaults)
```

### Flow 5: Iterating on a Skill

```text
/skill-audit .claude/skills/{skill-name}/SKILL.md   ← baseline: detect bloat, duplication, harmful patterns
→ run the skill on a real task                       ← observe output quality in practice
→ edit SKILL.md based on findings                    ← tighten instructions, add missing states, fix Loop Guard
→ /skill-audit .claude/skills/{skill-name}/SKILL.md ← re-audit: confirm score improved, no regressions
```

```text
# Example — tightening /component-gen after noticing it skips empty states:
# 1. /skill-audit .claude/skills/component-gen/SKILL.md → score: 72/100, finding: "empty state not enforced"
# 2. /component-gen react OrderList → output missing empty state (confirms the gap)
# 3. Edit SKILL.md: add "MUST include EmptyState component when data array can be []" to Phase 3
# 4. /component-gen react OrderList → now generates <EmptyState> with illustration + CTA
# 5. /skill-audit .claude/skills/component-gen/SKILL.md → score: 88/100, no regressions
```

### Flow 6: Creating a New Skill

```text
/init-skill   ← interactive 7-phase wizard: purpose → structure → YAML header → SKILL.md body → validate

# Alternative: Anthropic community skill-creator (framework-agnostic, works in any IDE)
# https://github.com/anthropics/skills/tree/main/skills/skill-creator
# Recommended when starting from scratch or building non-frontend skills.
# After generation, run /skill-audit to apply project-specific Tier 1 baseline checks.
```

```text
# Example — creating a /storybook-gen skill:
# /init-skill
#   Phase 1 — Purpose: "Generate Storybook stories (.stories.tsx) for existing components"
#   Phase 2 — Structure: context: fork, auto-invoke: false, references: react-patterns.md
#   Phase 3 — YAML header: name: storybook-gen, description: ..., framework: react|vue
#   Phase 4 — SKILL.md body: Phase 1 scan component props → Phase 2 generate stories → Phase 3 validate
#   Phase 5 — Validate: ✅ no bloat, no hallucinated imports, YAML parses clean
# → .claude/skills/storybook-gen/SKILL.md created
# /skill-audit .claude/skills/storybook-gen/SKILL.md → score: 85/100, ready for use
```

### Flow 7: Visual Feedback Loop (Agentation)

```text
Human annotates UI element in browser (via Agentation component)
  → /ui-tweak
    → fetch annotations → locate source file → apply fix → type check + lint → resolve
    → watch mode: repeat until user interrupt or 30min timeout
```

```text
# Example — designer flags button padding issue:
# Designer clicks "Submit" button in browser → annotates: "padding too small, hard to tap on mobile"
# /ui-tweak
#   → fetches annotation → locates src/shared/ui/Button.tsx:42
#   → changes: className="px-3 py-1.5" → className="px-4 py-2.5 min-h-[44px]"
#   → tsc --noEmit ✓, biome check ✓ → resolves annotation
# /ui-tweak watch
#   → live loop: fixes annotations as designer flags them (30min timeout)
```

### Flow 8: Code Migration

```text
/refactor react class-to-hooks --scope "src/features/**"    ← class → hooks
/refactor vue options-to-composition                         ← Options API → Composition API
/refactor react tanstack-v4-to-v5 --dry-run                 ← preview TanStack v5 migration
/refactor react custom "replace axios with ky"               ← AI-driven custom transform
```

> **Vue 2 → Vue 3 migration:** There is no dedicated migration skill. The template assumes Vue 3 baseline.
> `options-to-composition` handles the API style change (Options → Composition), but Vue 2-specific
> breaking changes (slot syntax, lifecycle renames, v-model changes, filters removal, `$listeners`/`$attrs` merge)
> require a custom transform:
>
> ```text
> /refactor vue custom "migrate Vue 2 component to Vue 3: update slot syntax, lifecycle hooks, v-model, remove filters"
> ```
>
> Recommended approach: run `/fe-repo-scout` first to identify all Vue 2 patterns, then migrate file-by-file with `/refactor vue custom`.

---

## Framework Parameter

Every code-generating skill requires a framework argument:

```text
/component-gen react   →  generates .tsx with React hooks
/component-gen vue     →  generates .vue SFC with Composition API
```

The skill loads the appropriate `references/react-patterns.md` or `references/vue-patterns.md`
and generates idiomatic code for that framework.

`/component-gen-next` is React-only (Next.js App Router). A Nuxt.js equivalent (`/nuxt-component-gen`) is a known gap — Vue developers building Nuxt apps should use `/component-gen vue` for the component logic and adapt the file structure manually.

---

## Skill Flags Reference

Each skill accepts specific flags documented in the Skills Reference table above.

> Full flag reference with combinations and decision guides: [docs/ai-setup.md § Skill Flags Reference](docs/ai-setup.md#skill-flags-reference)

---

## How to Adapt

This library is a starting point. To make it yours:

1. **Copy `.claude/`** into your project.
2. **Run `/init-project`** to generate a project-specific `CLAUDE.md`.
3. **Edit the generated `CLAUDE.md`** — replace defaults with your actual stack.
4. **Run skills and review.** Expect some gaps on first try.
5. **Tweak SKILL.md files.** Skills are plain Markdown. Add team conventions, remove noise.

---

## IDE Compatibility

<details>
<summary><strong>Compatibility matrix — click to expand</strong></summary>

| Capability          | Claude Code | Cursor                  | VS Code Copilot             | Codex               |
|---------------------|-------------|-------------------------|-----------------------------|---------------------|
| `CLAUDE.md`         | **Native**  | **Native**              | → `copilot-instructions.md` | → `AGENTS.md`       |
| `frontend_agent.md` | **Native**  | → `.cursor/rules/*.mdc` | → `copilot-instructions.md` | → `AGENTS.md`       |
| `skills/*.md`       | **Native**  | → `.cursor/rules/*.mdc` | Open file in editor         | → `.agents/skills/` |
| Anti-patterns       | Yes         | Yes                     | Yes                         | Yes                 |

**Codex onboarding:** Copy `AGENTS.md` and `.agents/skills/` into your project root. Codex will discover skills from `.agents/skills/` automatically.

</details>

---

## Architecture

- **25 skills** in `.claude/skills/` (18 developer + 7 maintenance) — from scaffolding to component generation to testing
- **61 anti-pattern quality gates** in `.claude/fe-antipatterns/` — checked during code review
- **12 path-scoped rules** in `.claude/rules/` — loaded only when touching matching file patterns (TypeScript, React, Vue, testing, FSD, a11y, git safety, markdown, async states, monorepo)
- **2 specialized agents** (Engineer + Auditor) in `.claude/agents/`
- **Progressive Disclosure** — `CLAUDE.md` → `frontend_agent.md` → `SKILL.md` load only on demand
- **Gardener Protocol** — AI suggests improvements to the knowledge base at the end of each run
- **Adaptive Context (ACE)** — reflection protocol + lessons store + `/curate-lessons` skill for cross-session learning ([details](docs/ai-setup.md#adaptive-context-evolution-ace))
- **Dual-Framework** — every skill accepts `react` or `vue` as a parameter

> Full inventory of all files and patterns: [docs/ai-setup.md](docs/ai-setup.md)

---

<details>
<summary><strong>Token Economy & Selective Loading</strong></summary>

Context is loaded progressively — not all at once:

| Layer                             | When loaded                      | ~Tokens  |
|-----------------------------------|----------------------------------|----------|
| `CLAUDE.md`                       | Always                           | ~400     |
| `.claude/rules/*.md`              | Path-scoped (on matching edits)  | ~50–150  |
| `frontend_agent.md`               | On demand (skills / agents read) | ~460     |
| Skill `SKILL.md`                  | When invoked                     | 100–500  |
| Anti-pattern `.md`                | On violation (lazy)              | ~50 each |
| `references/*.md`                 | When skill loads them            | 100–300  |

**Typical run:** ~1,600 tokens. **Worst case:** ~7,000 (never happens in practice).

**Lite mode:**

- Remove unused MCP servers from `.mcp.json`
- Disable hooks in `.claude/settings.json` → `hooks.PostToolUse` (each is independent)
- `fe-lint.sh` only runs when Biome is installed — safe to remove if you lint separately

</details>

---

## Default Tech Stack (for generated code)

| Concern        | Default                                          |
|----------------|--------------------------------------------------|
| Language       | TypeScript (strict)                              |
| Styling        | Tailwind CSS                                     |
| State (global) | Zustand (React) / Pinia (Vue)                    |
| Server state   | TanStack Query                                   |
| Build          | Vite                                             |
| Testing (unit) | Vitest + Testing Library                         |
| Testing (E2E)  | Playwright                                       |
| API client     | HeyAPI / openapi-ts                              |
| Linter         | Biome                                            |
| Health check   | Oxlint (React) / Oxlint + ESLint + vue-tsc (Vue) |

> Override any of these in your project's `CLAUDE.md`.

---

## MCP Setup

The `.mcp.json` file ships with greppable placeholder values. Search for `<REPLACE:` and fill in:

| Placeholder                       | Server   | What to set                                                                                                              |
|-----------------------------------|----------|--------------------------------------------------------------------------------------------------------------------------|
| `<REPLACE:GITHUB_TOKEN>`          | `github` | Personal access token from [github.com/settings/tokens](https://github.com/settings/tokens) — scopes: `repo`, `read:org` |
| `<REPLACE:FIGMA_MCP_SERVER_PATH>` | `figma`  | Absolute path to your Figma MCP server entry point                                                                       |
| `<REPLACE:FIGMA_TOKEN>`           | `figma`  | Personal access token from Figma → Account Settings → Personal access tokens                                             |

**agentation** — no credentials needed. Requires `npm install agentation -D` in project + `<Agentation />` component + MCP server (`npx agentation-mcp server`).

The `openapi` server points to `http://localhost:8080/v3/api-docs` by default.
Change the `--url` arg in `.mcp.json` to match your API docs endpoint.

---

## Verification Checklist

After setup, verify the template works:

- [ ] `/component-gen react` → `.tsx` file with 4 states (loading / error / empty / success)
- [ ] `/component-gen vue` → `.vue` SFC with Composition API, 4 states
- [ ] `/component-tests react` → Vitest tests passing `vitest run`
- [ ] `/component-tests vue` → Vitest tests passing `vitest run`
- [ ] Anti-pattern `missing-loading-state` triggers during review
- [ ] Gardener Protocol adds suggestions at end of each skill run
- [ ] `/browser-check http://localhost:5173` → snapshot with interactive element list
- [ ] `.cursor/rules/` contains wrappers for skills
- [ ] `.github/copilot-instructions.md` references `.claude/`
- [ ] `.claude/rules/*.md` files load when touching matching file patterns
- [ ] `wc -l CLAUDE.md` → under 110 lines
- [ ] `grep -r "auto-invoke: false" .claude/skills/*/SKILL.md` → 17 manual-only skills

---

<details>
<summary><strong>FAQ (Common Questions)</strong></summary>

**Q: Do I need both React AND Vue?**
A: No. Pick one, pass it consistently.

**Q: What are the "4 states"?**
A: Loading, Error, Empty, Success — every async component must handle all four.

**Q: AI generated wrong imports. Fix?**
A: Fill in `.claude/conventions/` stubs (especially `ui-library.md`, `icons.md`). This is the #1 cause of incorrect code generation — see [CRITICAL STEP](#fill-conventions) in Quick Start.

**Q: What does "FSD" mean?**
A: Feature-Sliced Design — architecture with strict layer imports. See CLAUDE.md § Project Structure.

**Q: Pre-commit hook blocked my commit?**
A: Read the error — it shows the specific rule. Fix the issue or set `FE_PRECOMMIT_STRICT=0` for warnings-only.

**Q: I see "Rust" in Advanced tools. Do I need Rust?**
A: No. Those tools install via npm (`npx react-doctor@latest .`). Rust is their build language, not your dependency.

**Q: Can I use this in a monorepo?**
A: Yes. Copy `.claude/` to root. Use `--path` / `--scope` flags to target packages.

</details>

---

## References

- [vercel-labs](https://github.com/vercel-labs)
- [ibelick/ui-skills](https://github.com/ibelick/ui-skills/tree/main/skills)
- [addyosmani/web-quality-skills](https://github.com/addyosmani/web-quality-skills/tree/main/skills)
- [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates/tree/main/.claude/agents)

---

## Advanced tools

- [react.doctor](https://react.doctor) — Static analyzer for React, 60+ rules, 0-100 score; installed via npm (`npx react-doctor@latest .`), no Rust toolchain needed; powers `/react-doctor`
- [agentation](https://github.com/nichochar/agentation) — React 18+ visual annotation package (PolyForm Shield license); human annotates UI → AI receives structured context (selector, component tree, styles, a11y) → code fix; powers `/ui-tweak`
- [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) — CLI for AI browser control, 93% fewer tokens vs raw DOM; installed via npm, no Rust toolchain needed; powers `/browser-check`
- [vercel-labs skills](https://github.com/vercel-labs/skills)
- [mcp-for-next.js](https://github.com/vercel-labs/mcp-for-next.js)
- [openreview](https://github.com/vercel-labs/openreview)
- [next-skills](https://github.com/vercel-labs/next-skills)

---

## Resources

- [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [Claude Code Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Cursor Rules Docs](https://cursor.com/docs/context/rules)
- [VS Code Copilot Custom Instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Codex Agent Skills](https://developers.openai.com/codex/skills/)

- [Reference repo: AI Context Engineering for QA](https://github.com/vlad-ryzhkov/ai-context-engineering-for-qa)
