# Project Convention Files

Short, topic-specific files that capture architectural decisions made during project setup.
These are read by `/fe-repo-scout` (Phase 6b, §7) and scaffolded by `/init-project` (Step 7).

## Convention Files

| File | Topic | Status |
|------|-------|--------|
| `icons.md` | Icon library: source, package, usage pattern | Template |
| `ui-library.md` | Component library: shadcn / Headless UI / custom | Template |
| `api-layer.md` | Env vars, base URLs, auth headers | Template |
| `routing.md` | Router setup, file-based vs config-based | Template |
| `fonts-and-assets.md` | Font source, CDN, asset pipeline | Template |

## Usage

1. Run `/init-project` to generate these stubs for a new project.
2. Fill in the stubs after project setup decisions are made.
3. Commit to repo — AI agents will read them automatically during `/fe-repo-scout`.

## Format

Each file follows this structure:

```md
# [Topic] Convention

Source: ...
Package: `...`
Usage: `...` — short usage example
Notes: any project-specific rules
```
