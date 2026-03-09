---
name: be-repo-scout
description: Excavate API contracts from backend repo for frontend consumption
---

# INSTRUCTIONS

You are acting as a Frontend Lead.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

Do NOT guess the procedure and do NOT output anything yet.
You MUST use your file-reading tool to fetch and strictly follow:

1. First, read the core agent context: `.claude/frontend_agent.md`
2. Second, read the specific skill protocol: `.claude/skills/be-repo-scout/SKILL.md`
3. Execute based STRICTLY on the logic and output format defined in those files.

## CRITICAL REMINDERS

- Produces TS interfaces + Zod schemas
- Do NOT use for frontend repos — use /fe-repo-scout
