#!/bin/bash
# SubagentStop hook: validate skill completion contract
# Checks that Engineer/Auditor sub-agents end with SKILL COMPLETE or SKILL PARTIAL

set -e

INPUT=$(cat)
LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null || true)

if [ -z "$LAST_MSG" ]; then
  exit 0
fi

# Check for SKILL COMPLETE or SKILL PARTIAL
if echo "$LAST_MSG" | grep -qE "SKILL COMPLETE|SKILL PARTIAL"; then
  exit 0
fi

# Check if this was a skill execution (not just a chat response)
if echo "$LAST_MSG" | grep -qE "/(component-gen|api-bind|component-tests|e2e-tests|refactor|setup-configs)"; then
  echo "⚠️ subagent-stop: Sub-agent finished without SKILL COMPLETE/PARTIAL block." >&2
  echo "  Expected: ✅ SKILL COMPLETE or ⚠️ SKILL PARTIAL at the end of skill output." >&2
  # Advisory only — don't block
fi

exit 0
