#!/bin/bash
# UserPromptSubmit hook: validate framework parameter for code-generating skills

set -e

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // empty' 2>/dev/null || true)

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Skills that require framework parameter
FRAMEWORK_SKILLS="component-gen|api-bind|component-tests|setup-configs|refactor"

# Check if prompt invokes a framework-required skill
SKILL_MATCH=$(echo "$PROMPT" | grep -oE "/(${FRAMEWORK_SKILLS})" | head -1 || true)

if [ -n "$SKILL_MATCH" ]; then
  # component-gen-next is React-only, skip framework check
  if echo "$PROMPT" | grep -q "/component-gen-next"; then
    exit 0
  fi

  # Check for framework param
  if ! echo "$PROMPT" | grep -qiE "\breact\b|\bvue\b"; then
    echo "⚠️ Missing framework parameter. Usage: ${SKILL_MATCH} [react|vue] ..." >&2
    echo "  Skills that generate code require 'react' or 'vue' as a parameter." >&2
    # Advisory warning — don't block
  fi
fi

exit 0
