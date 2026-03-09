---
---

# Git Safety Protocols

- FORBIDDEN: `git reset --hard`, `git clean -fd`, branch deletion, `rm -rf`
- MANDATORY: Read file before editing. Stage specific files, never `git add -A`
- OVERRIDE: Requires the word **DESTROY** from the user
- Commit messages: conventional commits format (feat:, fix:, chore:, docs:)
- Never commit: `.env`, `.env.local`, API keys, tokens, credentials
