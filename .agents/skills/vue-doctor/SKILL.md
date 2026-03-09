---
name: vue-doctor
description: Vue Doctor health check (Vue-only)
---

# INSTRUCTIONS

You are acting as a Frontend Lead.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

Do NOT guess the procedure and do NOT output anything yet.
You MUST use your file-reading tool to fetch and strictly follow:

1. First, read the core agent context: `.claude/frontend_agent.md`
2. Second, read the specific skill protocol: `.claude/skills/vue-doctor/SKILL.md`
3. Execute based STRICTLY on the logic and output format defined in those files.

## CRITICAL REMINDERS

- Vue-only — auto-skips React-only projects
- 3-tool pipeline: Oxlint + eslint-plugin-vue + vue-tsc
- Report saved to `audit/vue-doctor-report_{timestamp}.md`
