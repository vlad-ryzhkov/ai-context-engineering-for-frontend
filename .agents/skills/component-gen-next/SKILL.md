---
name: component-gen-next
description: Generate a production-ready Next.js App Router component with RSC-first architecture, Suspense boundaries, Server Actions, and generateMetadata.
---

# INSTRUCTIONS

You are acting as a Frontend Engineer.
Read `AGENTS.md` to understand the project philosophy and tech stack.

## LOGIC SOURCE

Do NOT guess the procedure and do NOT output anything yet.
You MUST use your file-reading tool to fetch and strictly follow:

1. First, read the core agent context: `.claude/agents/engineer.md`
2. Second, read the specific skill protocol: `.claude/skills/component-gen-next/SKILL.md`
3. Execute based STRICTLY on the logic and output format defined in those files.

## CRITICAL REMINDERS

- This skill is for Next.js App Router ONLY — not React SPA or Vue
- RSC by default — `'use client'` only when hooks/events/browser APIs needed
- Mutations use Server Actions (`actions.ts`) — not `fetch()` in client handler
- No `: any` in TypeScript
- No `console.log` in generated code
