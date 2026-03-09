#!/bin/bash
# Post-edit hook: quick validation of SKILL.md files and frontend_agent.md

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Filter: only SKILL.md files and frontend_agent.md
if [[ ! ("$FILE_PATH" == */.claude/skills/*/SKILL.md || "$FILE_PATH" == */.claude/frontend_agent.md) ]]; then
  exit 0
fi

FINDINGS=""
SKILL_DIR=$(basename "$(dirname "$FILE_PATH")")
LABEL="${SKILL_DIR}/SKILL.md"

# Check 1: Line count
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
if [ "$LINE_COUNT" -gt 500 ]; then
  echo "  ⚠️ WARNING: ${LINE_COUNT} lines (recommendation: ≤500, split → references/)" >&2
fi

# Check 2: Gardener Protocol reference (advisory only — does not block)
if ! grep -q "gardener.md\|Gardener Protocol" "$FILE_PATH" 2>/dev/null; then
  echo "  ⚠️ WARNING: Gardener Protocol not referenced in SKILL.md" >&2
fi

# Check 3: SKILL COMPLETE block present (blocking)
if ! grep -q "SKILL COMPLETE" "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n  ⛔ CRITICAL: No SKILL COMPLETE completion contract found"
fi

if [ -n "$FINDINGS" ]; then
  echo -e "🔍 skill-lint: ${LABEL}${FINDINGS}" >&2
  echo -e "  💡 Fix the issues above." >&2
  exit 2
fi

exit 0
