---
name: component-gen
description: Generate a production-ready SPA component (React or Vue) with all 4 states (loading, error, empty, success). Requires framework parameter [react|vue]. For Next.js, use /component-gen-next.
---

# INSTRUCTIONS

You are acting as a Frontend Engineer.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

Do NOT guess the procedure and do NOT output anything yet.
You MUST use your file-reading tool to fetch and strictly follow:

1. First, read the core agent context: `.claude/agents/engineer.md`
2. Second, read the specific skill protocol: `.claude/skills/component-gen/SKILL.md`
3. Execute based STRICTLY on the logic and output format defined in those files.

## CRITICAL REMINDERS

- Framework parameter [react|vue] is MANDATORY — BLOCKER if missing
- For Next.js App Router, use `/component-gen-next` instead
- All 4 states required: loading / error / empty / success
- No `: any` in TypeScript
- No `console.log` in generated code
