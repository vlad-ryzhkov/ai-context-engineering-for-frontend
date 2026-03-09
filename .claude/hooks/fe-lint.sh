#!/bin/bash
# Post-edit hook: auto-format TypeScript/Vue files via Biome
# Runs only on .ts, .tsx, .vue files; skips silently if Biome not configured

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Filter: only .ts, .tsx, .vue files
if [[ ! "$FILE_PATH" =~ \.(ts|tsx|vue)$ ]]; then
  exit 0
fi

# Resolve project root via git
PROJECT_ROOT=$(git -C "$(dirname "$FILE_PATH")" rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi

# Skip if Biome not configured in this project
if [ ! -f "$PROJECT_ROOT/biome.json" ] && [ ! -f "$PROJECT_ROOT/biome.jsonc" ]; then
  exit 0
fi

# Run Biome on the specific file only (not whole src/)
RESULT=$(cd "$PROJECT_ROOT" && npx --no-install biome check --write "$FILE_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "fe-lint: Biome issues in $(basename "$FILE_PATH")" >&2
  echo "$RESULT" >&2
  exit 2
fi

exit 0
