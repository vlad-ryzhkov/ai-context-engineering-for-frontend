---
name: init-project
description: >
  Generate a project-specific CLAUDE.md by scanning the actual project tech stack.
  Run once when setting up AI context for a new frontend project.
  Do not use if CLAUDE.md already exists and is up to date.
allowed-tools: "Read Glob Grep Write Bash(ls*) Bash(cat*)"
disable-model-invocation: true
context: fork
auto-invoke: false
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Init Project — Generate CLAUDE.md

## Verbosity Protocol (SILENT MODE)

- Do NOT output intermediate scan results or file lists to chat.
- Output to chat ONLY: blocker messages, confirmation prompts, and the final SKILL COMPLETE block.

<purpose>
Scans the current project to detect the actual tech stack, then generates a project-specific
`CLAUDE.md` that overrides the defaults from this template.
Run once per project, then commit CLAUDE.md to the repo.
</purpose>

## Algorithm

### Step 1: Detect Stack

```bash
cat package.json 2>/dev/null
cat tsconfig.json 2>/dev/null
ls src/ 2>/dev/null
ls 2>/dev/null
```

Extract:

- Framework (React / Vue / Next / Nuxt — check for `"react"` or `"vue"` in deps)
- TypeScript? Strict mode? (check `tsconfig.json "strict": true`)
- Styling (Tailwind / CSS Modules / styled-components / emotion)
- Global state (Zustand / Pinia / Redux / Jotai)
- Server state (TanStack Query / SWR / Apollo)
- Build tool (Vite / Webpack / Turbopack)
- Testing (Vitest / Jest + Playwright / Cypress)
- Linter (Biome / ESLint / Prettier)
- API Client (HeyAPI / openapi-ts / axios / raw fetch)

### Step 2: Detect Architecture

```bash
ls src/ 2>/dev/null
```

Identify pattern:

- FSD: `app/ pages/ widgets/ features/ entities/ shared/`
- Layer-based: `components/ hooks/ pages/ utils/`
- Domain-based: feature name folders at root of `src/`
- Flat: all files in `src/`

### Step 3: Extract Commands

```bash
cat package.json | grep -A 20 '"scripts"'
```

Map to: dev, build, test, typecheck, lint.

### Step 4: Generate CLAUDE.md

Read `references/claude-md-template.md`.
Fill in detected values. Mark unknown values as TODO for user to fill.

Include:

- Detected tech stack table (React or Vue column, with BANNED column)
- Detected architecture + `src/` structure diagram
- Actual commands from `package.json` scripts
- Safety protocols section
- Available skills list

### Step 5: Validate

- [ ] No `[placeholder]` or `TODO` left in output (fill or remove)
- [ ] Tech stack matches actual `package.json` (not guessed)
- [ ] Commands exist in `package.json` scripts
- [ ] Structure reflects actual `src/` directory

### Step 6: Write

If `CLAUDE.md` already exists:

```text
⚠️ CLAUDE.md already exists. Show diff and ask for confirmation before overwriting.
```

Otherwise: write to project root.

### Step 7: Scaffold Convention Stubs

Write the following stub files to `.claude/conventions/` (skip any that already exist):

- `_index.md` — table of convention files
- `icons.md` — icon library choice and usage pattern
- `ui-library.md` — component library (shadcn / Headless UI / custom)
- `api-layer.md` — env vars, base URLs, auth headers
- `routing.md` — router setup and file conventions
- `fonts-and-assets.md` — font source, CDN, asset pipeline

Each stub format:

```md
# [Topic] Convention

<!-- Fill in after project setup -->
<!-- Source: -->
<!-- Package: -->
<!-- Usage: -->
<!-- Notes: -->
```

Read `references/fe-codegen-templates.md` for convention stub templates if available.

## Quality Gates

- [ ] Stack detected from actual files
- [ ] Commands match `package.json` scripts
- [ ] Architecture diagram matches actual `src/`
- [ ] CLAUDE.md written to project root
- [ ] `.claude/conventions/` stubs written (6 files)

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /init-project
├─ Artifact: CLAUDE.md
├─ Framework: [detected]
├─ Architecture: [detected]
└─ Next: /component-gen [react|vue] to verify setup
```
