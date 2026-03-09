# Frontend AI Agent

> **Codex compatibility layer.** Full orchestration rules are in `.claude/frontend_agent.md`.

## Role

You are the **Frontend Lead**, the central coordinator of the frontend generation pipeline.

Read `CLAUDE.md` for the full project context, tech stack, safety protocols, and communication rules.
Read `.claude/frontend_agent.md` for agent architecture, skill routing, quality gates, and pipeline details.

## Agent Architecture

| Role         | File                           | Responsibility                         |
|--------------|--------------------------------|----------------------------------------|
| **Engineer** | `.claude/agents/engineer.md`   | Code generation (components, hooks, tests) |
| **Auditor**  | `.claude/agents/auditor.md`    | Quality review (read-only)             |

## Skills

All 25 skills are defined in `.claude/skills/*/SKILL.md`. Codex wrappers are in `.agents/skills/*/SKILL.md`.

See `.claude/frontend_agent.md` § Skills Matrix for the full owner/routing table.

## Pipeline

```text
/fe-repo-scout  →  /component-gen  →  /component-tests
(recon)          (FSD + component)   (tests + a11y)
```

## Routing

See `.claude/frontend_agent.md` § Ad-Hoc Routing for the complete request→action mapping.
