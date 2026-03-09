---
name: component-tests
description: Generate Vitest + Testing Library tests covering all 4 states. Requires framework parameter [react|vue].
---

# INSTRUCTIONS

You are acting as a Frontend Engineer.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

1. Read: `.claude/agents/engineer.md`
2. Read: `.claude/skills/component-tests/SKILL.md`
3. Execute based STRICTLY on those files.

## CRITICAL REMINDERS

- Framework parameter [react|vue] is MANDATORY
- Tests must cover all 4 states: loading / error / empty / success
- Use role/label/text selectors — no `querySelector`
- No snapshot tests as primary assertion
