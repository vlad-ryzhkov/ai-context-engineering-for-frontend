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

> **Minimality Principle** ([research](https://arxiv.org/abs/2602.11988)):
> LLM-generated context files reduce task success rate (−3%) and increase inference cost (+20%).
> This skill generates a **minimal draft** — human review and rewrite is mandatory.
> Include ONLY: tech stack, build/test commands, banned alternatives, specific tooling.
> Do NOT include: codebase overviews, directory listings, architecture descriptions,
> skills tables, or anything already present in existing documentation.

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Init Project — Generate CLAUDE.md

## Verbosity Protocol (SILENT MODE)

- Do NOT output intermediate scan results or file lists to chat.
- Output to chat ONLY: blocker messages, confirmation prompts, and the final SKILL COMPLETE block.

<purpose>
Generate a minimal CLAUDE.md draft based on repository analysis.
Focus: tech stack, commands, and banned alternatives — nothing more.
Human review required before committing.
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
- Actual commands from `package.json` scripts
- Safety protocols section

Do NOT include:

- Project Structure / directory tree (agents discover files on their own)
- Available Skills table (agents discover skills from YAML headers)
- Codebase overview or architecture description
- Content already present in README or docs/

Minimality check: Before saving, delete any section that duplicates information already available in the repository.

### Step 5: Validate

- [ ] No `[placeholder]` or `TODO` left in output (fill or remove)
- [ ] Tech stack matches actual `package.json` (not guessed)
- [ ] Commands exist in `package.json` scripts
- [ ] No codebase overview or directory listing sections
- [ ] No skills listing
- [ ] No duplicated content from README/docs
- [ ] No HTML comments from template

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

## Anti-Patterns

| Anti-Pattern | Why It Breaks | Fix |
|---|---|---|
| Including Project Structure / directory tree | Agents discover files on their own; adds cost | Remove directory listings |
| Including Available Skills table | Agents discover skills from YAML headers | Do not list skills |
| Duplicating README/docs content | +20% reasoning tokens | Only include info NOT in repo docs |
| Hardcoded stack not matching actual project | CLAUDE.md contradicts reality | Scan package.json; verify before writing |
| `[placeholder]` values left unfilled | Template cruft interpreted as literal values | Replace all; remove if unknown |

## Quality Gates

- [ ] Stack detected from actual files
- [ ] Commands match `package.json` scripts
- [ ] No codebase overview or directory listings
- [ ] No skills listing
- [ ] No duplicated content from README/docs
- [ ] CLAUDE.md written to project root
- [ ] `.claude/conventions/` stubs written (6 files)

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /init-project
├─ Artifact: CLAUDE.md
├─ Framework: [detected]
├─ Coverage: [X/7 validation checks passed]
└─ Next: Review CLAUDE.md by hand, then /component-gen [react|vue] to verify setup
```
