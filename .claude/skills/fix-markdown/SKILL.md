---
name: fix-markdown
description: >
  Fix all markdownlint errors in .md files across the repository.
  Use when markdown linting fails in CI or before committing documentation changes.
  Do not use for content changes — only formatting fixes.
allowed-tools: "Read Edit Bash(npx*)"
auto-invoke: false
---

# Fix Markdown Lint Skill

Fix all markdownlint errors in .md files across the repository.

## Rules

- Only fix formatting issues
- Do not change content meaning
- Do not add tables or restructure sections
- Do not rewrite or rephrase text

## Steps

1. Auto-fix what's possible:

   ```bash
   npx markdownlint-cli --fix "**/*.md" --ignore node_modules --ignore ".gradle" --ignore build --ignore audit
   ```

2. Re-run to find remaining issues:

   ```bash
   npx markdownlint-cli "**/*.md" --ignore node_modules --ignore ".gradle" --ignore build --ignore audit
   ```

3. Fix remaining errors manually using Edit tool (line length, heading levels, inline HTML)
4. Verify: re-run step 2, expect zero errors

## Verbosity Protocol (SILENT MODE)

- Do NOT output intermediate markdownlint output to chat.
- Output to chat ONLY: blocker messages and the final SKILL COMPLETE block.

## Quality Gate

- [ ] `npx markdownlint-cli "**/*.md"` returns zero errors
- [ ] No content meaning changed
- [ ] No tables added or sections restructured

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /fix-markdown
├─ Files fixed: [N]
├─ Errors resolved: [N]
└─ Remaining: [0 | N with description]
```
