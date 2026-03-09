---
name: pr
description: >
  Create a pull request with a conventional commit title from staged changes.
  Analyzes diff, applies project skills, auto-fixes lint/type issues, writes title + body,
  pushes branch if needed, creates PR via gh CLI.
  Do not use for amending existing PRs — use gh pr edit.
allowed-tools: "Read Bash(git*) Bash(gh*) Bash(npx*)"
disable-model-invocation: true
context: fork
---

# PR — Pull Request Creator & Self-Reviewer

## Verbosity Protocol

- Do NOT output intermediate diff analysis or grep results to chat.
- Output to chat: draft title + body for user confirmation, blocker messages, and SKILL COMPLETE block.
- User interaction (branch confirmation, PR preview) is allowed — this is an interactive skill.

<purpose>
Creates a pull request using conventional commit format.
Analyzes staged changes → applies project context → auto-fixes quality gates → writes title + body → pushes branch → creates PR via `gh`.
</purpose>

## Conventional Commit Format

```text
type(scope): short description (max 72 chars)

Types: feat | fix | refactor | test | docs | chore | a11y | perf
Scope: component name, feature, or area (optional)

Examples:
feat(user-card): add loading and error states
fix(api-bind): handle empty response array
test(product-list): add coverage for empty state
a11y(login-form): add aria-label to email input
```

## Workflow

1. **Status** — `git status` + `git diff --staged`
2. **Confirm target branch** — ask user (never assume `main` vs `master`)
3. **Analyze diff** — identify: type, scope, what changed
4. **Context Discovery** — check for `.agents/skills/` or `CONTRIBUTING.md`; if present, read relevant files to ensure diff complies with project standards
5. **Quality Gates & Auto-Fix** — run `npx tsc --noEmit` + `npx biome check src/`; if gates fail, attempt auto-fix (`npx biome check --write src/` or direct type error fixes) before proceeding; ask user if complex changes are needed
6. **Draft** — conventional commit title + body with self-review notes
7. **Confirm** — show title + body to user before creating PR
8. **Push** — `git push -u origin HEAD` (if branch not on remote)
9. **Create** — `gh pr create --title "..." --body "..."`

## PR Body Template

```markdown
## Summary

- [What was added/changed]
- [What problem it solves]

## Changes

- `path/to/file` — description

## Self-Review Notes

- [Edge cases handled, design decisions, areas for reviewer focus]

## Test Plan

- [x] Type check: `npx tsc --noEmit`
- [x] Lint: `npx biome check src/`
- [ ] Unit tests: `npx vitest run`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Safety

- Never force push to main/master
- Never push without user confirmation if on a protected branch
- Never commit `.env`, credentials, or secrets (check `git diff --staged`)
- Never use `--no-verify`

## Completion Contract

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE. If you identified missing rules or inefficiencies during this run, output a brief proposal table. Otherwise: `🌱 Gardener: No updates needed.`

```text
✅ SKILL COMPLETE: /pr
├─ Title: [conventional commit title]
├─ Applied Skills: [list of .agents/skills used, or "None"]
├─ PR URL: [url]
└─ Branch: [branch-name]
```
