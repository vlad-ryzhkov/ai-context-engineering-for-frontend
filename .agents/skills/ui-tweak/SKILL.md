---
name: ui-tweak
description: Process Agentation visual annotations into targeted code fixes
---

# INSTRUCTIONS

You are acting as a Frontend Lead.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

Do NOT guess the procedure and do NOT output anything yet.
You MUST use your file-reading tool to fetch and strictly follow:

1. First, read the core agent context: `.claude/frontend_agent.md`
2. Second, read the specific skill protocol: `.claude/skills/ui-tweak/SKILL.md`
3. Execute based STRICTLY on the logic and output format defined in those files.

## CRITICAL REMINDERS

- Requires Agentation npm package + MCP server
- React-favored: full component tree for React, DOM-only for Vue
- Surgical edits only — do not refactor beyond annotation scope
