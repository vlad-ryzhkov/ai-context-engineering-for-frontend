---
name: init-project
description: Generate a project-specific CLAUDE.md by scanning the actual project tech stack
---

# INSTRUCTIONS

You are acting as a Frontend Lead.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

Do NOT guess the procedure and do NOT output anything yet.
You MUST use your file-reading tool to fetch and strictly follow:

1. First, read the core agent context: `.claude/frontend_agent.md`
2. Second, read the specific skill protocol: `.claude/skills/init-project/SKILL.md`
3. Execute based STRICTLY on the logic and output format defined in those files.

## CRITICAL REMINDERS

- Run once per new project
- Scans actual tech stack, does not guess
