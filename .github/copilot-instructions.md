# AI Context Engineering for Frontend — Copilot Instructions

## INSTRUCTIONS FOR GITHUB COPILOT

ALWAYS prioritize the context defined in `CLAUDE.md` and `.claude/frontend_agent.md`.

## Context

- **Project:** AI Context Engineering Template for Vue 3 / React 18
- **Role:** Frontend Lead
- **Frameworks:** React 18 (TSX) and Vue 3 (SFC with `<script setup lang="ts">`)
- **Documentation:** in English

> **Tech Stack, Core Principles, Safety Protocols:** see `CLAUDE.md` at root (SSOT)

## Anti-Patterns (BANNED)

| Problem | What to do instead |
|---------|--------------------|
| `: any` in TypeScript | Explicit interface or `unknown` |
| Missing loading state | All 4 states: loading / error / empty / success |
| `div onClick` no role | `<button type="button">` |
| Hardcoded API URLs | `import.meta.env.VITE_API_BASE_URL` |
| `v-for` without `:key` | `:key="item.id"` always |
| `useEffect` no deps | Explicit dependency array `[]` or `[dep]` |
| Options API in Vue 3 | `<script setup lang="ts">` with Composition API |

## Skills (How to Use)

GitHub Copilot reads context from open files. To execute a skill:

1. Open the SKILL.md file in the editor
2. Open the target source file
3. Type your request in chat

| Task | Open in editor |
|------|----------------|
| Generate SPA component (React/Vue) | `.claude/skills/component-gen/SKILL.md` |
| Generate Next.js component | `.claude/skills/component-gen-next/SKILL.md` |
| Write tests + a11y audit | `.claude/skills/component-tests/SKILL.md` |
| Bind API | `.claude/skills/api-bind/SKILL.md` |
| Generate API mocks (MSW) | `.claude/skills/api-mocks/SKILL.md` |
| E2E tests | `.claude/skills/e2e-tests/SKILL.md` |
| Explore repo | `.claude/skills/fe-repo-scout/SKILL.md` |
| Browser check (verify running UI) | `.claude/skills/browser-check/SKILL.md` |
| Explore backend repo | `.claude/skills/be-repo-scout/SKILL.md` |
| Process visual annotations | `.claude/skills/ui-tweak/SKILL.md` |
| Refactor / migrate code | `.claude/skills/refactor/SKILL.md` |
| Generate project CLAUDE.md | `.claude/skills/init-project/SKILL.md` |
| Create PR | `.claude/skills/pr/SKILL.md` |

## Project Structure

```text
CLAUDE.md                        # Full project context (SSOT)
.claude/frontend_agent.md        # Orchestrator: mindset, routing, protocols
.claude/agents/                  # Engineer + Auditor agent definitions
.claude/skills/                  # Detailed instructions per skill
.claude/fe-antipatterns/         # Anti-pattern reference files
.claude/protocols/gardener.md    # Continuous improvement protocol
examples/                        # React + Vue code examples
```

> Full project context: `CLAUDE.md`
> Skill catalog: `.claude/frontend_agent.md`
