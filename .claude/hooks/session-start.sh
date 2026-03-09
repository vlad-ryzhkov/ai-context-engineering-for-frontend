#!/bin/bash
# SessionStart hook: restore pre-compact state and check pending lessons

set -e

STATE_FILE=".claude/.pre-compact-state.md"
PENDING_LESSONS=".ai-lessons/pending.md"

MESSAGES=""

if [ -f "$STATE_FILE" ]; then
  MESSAGES="${MESSAGES}📋 Restored pre-compact state from $(head -2 "$STATE_FILE" | tail -1). Review .claude/.pre-compact-state.md for context.\n"
fi

if [ -f "$PENDING_LESSONS" ] && [ -s "$PENDING_LESSONS" ]; then
  COUNT=$(grep -c "^-\|^##" "$PENDING_LESSONS" 2>/dev/null || echo "0")
  if [ "$COUNT" -gt 0 ]; then
    MESSAGES="${MESSAGES}📝 ${COUNT} pending lessons in .ai-lessons/pending.md — consider /curate-lessons.\n"
  fi
fi

if [ -n "$MESSAGES" ]; then
  echo -e "$MESSAGES" >&2
fi

exit 0
