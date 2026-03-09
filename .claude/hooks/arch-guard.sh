#!/bin/bash
# PostToolUse hook: FSD import violations, `: any`, `console.log` detection
# WARNING only (exit 0) — informational, non-blocking.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run on Write/Edit of .ts/.tsx/.vue files
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if [[ ! "$FILE_PATH" =~ \.(ts|tsx|vue)$ ]]; then
  exit 0
fi

WARNINGS=""

# Check 1: FSD import violations (only for files in src/)
if [[ "$FILE_PATH" =~ src/(entities|shared)/ ]]; then
  # entities/ must not import from features/, widgets/, pages/
  if [[ "$FILE_PATH" =~ src/entities/ ]]; then
    if grep -qE "from ['\"].*/(features|widgets|pages)/" "$FILE_PATH" 2>/dev/null; then
      WARNINGS="${WARNINGS}[arch-guard] FSD violation: entities/ imports from upper layer (features/widgets/pages)\n"
    fi
  fi
  # shared/ must not import from any layer above
  if [[ "$FILE_PATH" =~ src/shared/ ]]; then
    if grep -qE "from ['\"].*/(features|widgets|pages|entities)/" "$FILE_PATH" 2>/dev/null; then
      WARNINGS="${WARNINGS}[arch-guard] FSD violation: shared/ imports from upper layer\n"
    fi
  fi
fi

if [[ "$FILE_PATH" =~ src/features/ ]]; then
  if grep -qE "from ['\"].*/(widgets|pages)/" "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}[arch-guard] FSD violation: features/ imports from upper layer (widgets/pages)\n"
  fi
fi

if [[ "$FILE_PATH" =~ src/widgets/ ]]; then
  if grep -qE "from ['\"].*/(pages)/" "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}[arch-guard] FSD violation: widgets/ imports from pages/\n"
  fi
fi

# Check 2: TypeScript `any` type
if grep -qE ': any\b|as any\b' "$FILE_PATH" 2>/dev/null; then
  WARNINGS="${WARNINGS}[arch-guard] WARNING: \`: any\` or \`as any\` detected in $(basename "$FILE_PATH")\n"
fi

# Check 3: console.log
if grep -qE 'console\.log\(' "$FILE_PATH" 2>/dev/null; then
  WARNINGS="${WARNINGS}[arch-guard] WARNING: console.log() detected in $(basename "$FILE_PATH")\n"
fi

if [ -n "$WARNINGS" ]; then
  echo -e "$WARNINGS" >&2
fi

exit 0
