#!/bin/bash
# PreCompact hook: save context state before auto-compaction
# async: false — must complete before compaction

set -e

STATE_FILE=".claude/.pre-compact-state.md"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Collect current state
{
  echo "# Pre-Compact State"
  echo "Saved: ${TIMESTAMP}"
  echo ""

  # Current skill (from last assistant message if available)
  INPUT=$(cat)
  LAST_MSG=$(echo "$INPUT" | jq -r '.transcript[-1].message // empty' 2>/dev/null || true)
  if [ -n "$LAST_MSG" ]; then
    SKILL=$(echo "$LAST_MSG" | grep -oE '/(component-gen|component-gen-next|api-bind|component-tests|e2e-tests|fe-repo-scout|be-repo-scout|pr|browser-check|web-vitals|frontend-code-review|react-doctor|vue-doctor|refactor|ui-tweak|setup-configs|init-project|init-agent|init-skill|fix-markdown|update-ai-setup|skill-audit|spec-audit|agents-checker|curate-lessons)' | head -1 || true)
    if [ -n "$SKILL" ]; then
      echo "## Active Skill: ${SKILL}"
      echo ""
    fi
  fi

  # Modified files
  echo "## Modified Files"
  git diff --name-only 2>/dev/null || echo "(not a git repo)"
  echo ""
  git diff --staged --name-only 2>/dev/null || true
  echo ""

  # Last SKILL COMPLETE/PARTIAL block
  echo "## Last Completion Status"
  echo "(check transcript for SKILL COMPLETE/PARTIAL blocks)"

} > "$STATE_FILE" 2>/dev/null || true

exit 0
