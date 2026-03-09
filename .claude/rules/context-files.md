---
globs: "CLAUDE.md, .claude/**/*.md, .ai-lessons/*.md"
---

# Delta Update Protocol

- Context files evolve incrementally. Full rewrites lose nuance (context collapse)
- FORBIDDEN: Rewriting an entire context file to add or modify a single rule
- MANDATORY: Use `Edit` (surgical replace) — never `Write` (full overwrite) on existing context files
- MANDATORY: Append new rules to the correct section. Do not reorganize existing rules
- Governed files: `CLAUDE.md`, `.claude/frontend_agent.md`, `.claude/agents/*.md`, `.claude/protocols/*.md`, `.claude/fe-antipatterns/**/*.md`, `.claude/conventions/*.md`, `.claude/skills/*/SKILL.md`, `.ai-lessons/*.md`
