# agent-browser CLI Cheat Sheet

Reference for the `/browser-check` skill. All commands run via `npx --yes agent-browser`.

## Session Management

| Command | Description |
|---------|-------------|
| `npx --yes agent-browser open <url>` | Open URL in browser, start session |
| `npx --yes agent-browser --version` | Check agent-browser is installed |

## Snapshot

| Command | Description |
|---------|-------------|
| `npx --yes agent-browser snapshot -i` | Interactive snapshot — lists `@eN` refs for all interactive elements |
| `npx --yes agent-browser snapshot` | Full snapshot (more tokens — avoid unless needed) |

## Interaction (uses `@eN` refs from snapshot)

| Command | Description |
|---------|-------------|
| `npx --yes agent-browser click @eN` | Click element N |
| `npx --yes agent-browser fill @eN "text"` | Fill input element N with text |
| `npx --yes agent-browser select @eN "option"` | Select option in dropdown |
| `npx --yes agent-browser hover @eN` | Hover over element N |

## Assertions

| Command | Description |
|---------|-------------|
| `npx --yes agent-browser get text @eN` | Get text content of element N |
| `npx --yes agent-browser is visible @eN` | Check if element N is visible (exit 0 = visible) |
| `npx --yes agent-browser screenshot` | ⚠️ LAST RESORT: raw base64 PNG — can exhaust context. Prefer `is visible` / `get text` |

## Navigation

| Command | Description |
|---------|-------------|
| `npx --yes agent-browser navigate <url>` | Navigate to a new URL within the session |
| `npx --yes agent-browser back` | Go back in history |

## Tips

- Always use `--yes` flag with `npx` to prevent interactive install prompts in non-TTY environments
- Always run `snapshot -i` after each interaction to get updated `@eN` refs
- `@eN` refs are session-scoped and reset after navigation
- Always wrap `fill` text in single quotes (`'...'`) — double quotes allow bash expansion of `$`, `!`, `` ` ``
- If snapshot shows loading/spinner elements, wait (`sleep 2`) and re-snapshot before interacting
- Use `is visible` for pass/fail assertions — exit code 0 = PASS, non-zero = FAIL
- `screenshot` output can be read as image for visual verification
