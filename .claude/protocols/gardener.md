# Gardener Protocol — Continuous Improvement

Runs **MANDATORY** at the end of every skill, BEFORE the `SKILL COMPLETE` block.

## Algorithm

1. Read `.claude/skills/{current-skill}/SKILL.md`
2. Analyze the current run:
   - **Did the run end in `🚨 BLOCKER` or `⚠️ SKILL PARTIAL`? If yes — what specific rule would have prevented the AI from failing or looping?**
   - What problems/deviations were found in the artifact?
   - Which algorithm step was ambiguous or required interpretation?
   - Is there an error pattern not covered by explicit SKILL.md rules?
   - Did the AI produce architecture violations (wrong FSD layer imports, business logic in view components)?
   - Did the AI use hardcoded values instead of design tokens (colors, spacing)?
3. For each observation: is the rule **missing** from SKILL.md or `fe-antipatterns/`? → include in the table

## Output Format (mandatory always)

```text
🌱 GARDENER ANALYSIS
| # | Observation | Proposed rule | Section | Target file |
|---|-------------|---------------|---------|-------------|
| 1 | {what happened} | {specific prohibition/rule} | {Protocol/BANNED/Quality Gates/...} | skills/{name}/SKILL.md OR fe-antipatterns/{category}.md |
```

**Target file selection:**

- Rule is skill-specific (checklist step, output format, framework param) → `skills/{name}/SKILL.md`
- Rule is a global code pattern (TypeScript, architecture, styling, a11y) → `fe-antipatterns/{category}.md`
- Rule is cross-cutting (applies to multiple skills, not captured by existing fe-antipatterns) → `.ai-lessons/pending.md`

If no proposals:

```text
🌱 GARDENER: no proposals for this run
```

## Where to Output

| Skill artifact type                   | Action                                    |
|---------------------------------------|-------------------------------------------|
| Markdown report (`.md`)               | Append section `## 🌱 Gardener Analysis` to end of artifact |
| Code (`.tsx`, `.vue`, `.ts`, `.spec.ts`) | Output to chat (do not add to code)    |
| Config/init file (`CLAUDE.md`)        | Output to chat                            |
| No file (chat-only skill)             | Output to chat                            |

**Markdown skills** (append to artifact): `fe-repo-scout`

## Generation Rules

- Formulate as a prohibition or specific requirement, not as a wish
- Only if the rule is **missing** from SKILL.md — do not duplicate existing rules
- If >5 observations — group by topic (max 5 rows in the table)
- Do not apply independently — suggestion only, the user decides

## Examples: Good vs. Bad Observations

| Quality | Observation | Proposed rule | Why |
|---------|-------------|---------------|-----|
| ✅ Good | Component generated without `empty` state | BANNED: omitting `empty` state when data array can be empty | Specific, actionable, maps to 4-states rule |
| ✅ Good | `: any` appeared in generated hook | BANNED: `: any` — use explicit interface or `unknown` | Missing from BANNED at time of run |
| ✅ Good | Component used `text-[#333]` instead of theme token | BANNED: arbitrary hex colors in Tailwind classes — use `text-foreground` / design tokens | Prevents theme breakage in dark mode |
| ✅ Good | Async widget had no error boundary | REQUIREMENT: wrap all `features/` and `widgets/` async components in `<ErrorBoundary>` | Enforces architecture stability |
| ✅ Good | `SKILL PARTIAL` — TS error looped 4 times with same fix | REQUIREMENT: after 3 failed TS fix attempts — output `🛑 LOOP_GUARD_TRIGGERED` and pause | Prevents wasted tokens on stuck compilation |
| ❌ Bad | "Consider improving the component" | — (too vague) | Not a prohibition or requirement — a wish |
| ❌ Bad | "Code should be readable" | — (not actionable) | Already implied by Biome; adds no new constraint |

**Noise filter:** Before adding a row, ask — "Would this rule, written exactly as proposed, prevent the same mistake on the next run?" If no → drop it.
