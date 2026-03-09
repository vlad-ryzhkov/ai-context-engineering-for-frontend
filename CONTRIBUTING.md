# Contributing

## Prerequisites

- Node.js 20+
- Bash 4+
- Install git hooks:

```bash
bash scripts/setup-hooks.sh
```

## Creating or Modifying a Skill

1. Run `/init-skill` to scaffold a new skill with the standard template.
2. Run `/skill-audit` for a deep audit of the skill.
3. Every `SKILL.md` must include YAML frontmatter with `framework:` parameter (`react`, `vue`, or `both`).
4. Keep `SKILL.md` under **500 lines**. Move overflow to `references/`.
5. Create a matching Codex wrapper in `.agents/skills/<name>/SKILL.md`.

## Adding an Anti-Pattern

1. Create a file in `.claude/fe-antipatterns/{category}/{problem-name}.md`.
2. Add an entry to `.claude/fe-antipatterns/_index.md`.
3. Follow the existing format: **Problem → Why it matters → Fix → References**.

## Adding a Convention

1. Edit or create the file in `.claude/conventions/`.
2. If a new file is created, add an entry to `.claude/conventions/_index.md`.
3. Use the Delta Update Protocol — surgical edits, never full rewrites.

## Quality Gates

The `template-validate.yml` CI workflow runs on every push and PR:

| Check | What it validates |
| ----- | ----------------- |
| Frontmatter | Every `SKILL.md` has valid YAML frontmatter |
| Skill count | Skill count in `CLAUDE.md` matches `.claude/skills/` |
| Codex wrappers | Every skill has a matching `.agents/skills/` wrapper |
| Anti-pattern index | Every file in `fe-antipatterns/` is listed in `_index.md` |
| Markdownlint | All `.md` files pass `markdownlint-cli` (MD040, MD056) |

## Git Hooks

Install with `bash scripts/setup-hooks.sh`. Three hooks are configured:

| Hook | What it checks |
| ---- | -------------- |
| `pre-commit` | Forbidden files (`.env`, `.pem`, `.key`), secret patterns (`aws_access_key_id`, `ghp_*`, passwords), anti-pattern quick scan (`any`, `console.log`, `style={{`, index keys) |
| `pre-push` | Branch naming (7–45 chars, Latin+digits), forbidden files in diff, secret patterns, React Doctor score, heavy imports (`moment`, `lodash`), bundle size budget (900 KB), markdownlint |
| `prepare-commit-msg` | Auto-suggests conventional commit prefix (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`) from staged diff heuristics |

## PR Checklist

Before opening a PR that touches `.claude/` or `src/`:

- [ ] Git hooks installed: `bash scripts/setup-hooks.sh`
- [ ] Markdownlint passes: `npx markdownlint-cli "**/*.md" --ignore node_modules --ignore audit`
- [ ] `SKILL.md` has valid YAML frontmatter with `framework:` parameter
- [ ] Codex wrapper exists in `.agents/skills/<name>/SKILL.md`
- [ ] Anti-pattern index up to date: every file listed in `_index.md`
- [ ] `SKILL.md` ≤ 500 lines; overflow moved to `references/`
- [ ] No secrets committed (`.env`, API keys, tokens, credentials)

## Conventions

- **Commit messages:** conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`).
- **Delta Update Protocol:** context files (CLAUDE.md, agents, protocols, conventions, anti-patterns) are edited surgically with `Edit` — never rewritten with `Write`. See `.claude/rules/context-files.md`.
- **MD040:** every fenced code block must have a language tag.
- **MD056:** pipe `\|` inside table cells must be escaped.
