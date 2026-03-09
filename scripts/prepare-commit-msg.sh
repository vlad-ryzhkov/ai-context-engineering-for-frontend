#!/usr/bin/env bash
# prepare-commit-msg hook: auto-suggest Conventional Commit prefix from staged diff
# No AI dependencies — pure shell heuristics.
set -euo pipefail

COMMIT_MSG_FILE="${1:-}"
COMMIT_SOURCE="${2:-}"

# Skip merge, amend, squash commits
if [ -n "$COMMIT_SOURCE" ]; then
  exit 0
fi

if [ -z "$COMMIT_MSG_FILE" ]; then
  exit 0
fi

# Skip if user already wrote a message (non-empty, non-comment first line)
FIRST_LINE=$(head -1 "$COMMIT_MSG_FILE" | sed 's/^[[:space:]]*//')
if [ -n "$FIRST_LINE" ] && [[ ! "$FIRST_LINE" =~ ^# ]]; then
  exit 0
fi

# Gather staged file stats
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

STAGED_STAT=$(git diff --cached --stat 2>/dev/null || echo "")

# Determine commit type from file patterns
TYPE="chore"

has_pattern() {
  echo "$STAGED_FILES" | grep -qE "$1" 2>/dev/null
}

# Test files → test
if has_pattern '\.(test|spec)\.(ts|tsx|js|jsx|vue)$'; then
  TYPE="test"
# Doc/markdown files only
elif echo "$STAGED_FILES" | grep -qE '\.(md|mdx)$' && ! echo "$STAGED_FILES" | grep -qvE '\.(md|mdx)$'; then
  TYPE="docs"
# Config files only
elif echo "$STAGED_FILES" | grep -qE '(config|rc|\.json|\.yaml|\.yml|\.toml)' && ! echo "$STAGED_FILES" | grep -qvE '(config|rc|\.json|\.yaml|\.yml|\.toml)'; then
  TYPE="chore"
# New component files (creation)
elif git diff --cached --diff-filter=A --name-only | grep -qE '\.(tsx|vue)$'; then
  TYPE="feat"
# Deletions dominate
elif [ "$(git diff --cached --diff-filter=D --name-only | wc -l)" -gt "$(git diff --cached --diff-filter=M --name-only | wc -l)" ]; then
  TYPE="refactor"
# Modifications only
elif has_pattern '\.(ts|tsx|vue|js|jsx)$'; then
  # Check if diff looks like a fix (small change) or feature (large addition)
  ADDITIONS=$(git diff --cached --numstat | awk '{s+=$1} END {print s+0}')
  DELETIONS=$(git diff --cached --numstat | awk '{s+=$2} END {print s+0}')
  if [ "$ADDITIONS" -lt 10 ] && [ "$DELETIONS" -lt 10 ]; then
    TYPE="fix"
  else
    TYPE="feat"
  fi
fi

# Extract FSD scope from path
SCOPE=""
extract_scope() {
  local file="$1"
  # FSD: src/features/auth/... → auth
  if echo "$file" | grep -qE '^src/(features|entities|widgets|pages)/'; then
    echo "$file" | sed -E 's|^src/(features\|entities\|widgets\|pages)/([^/]+).*|\2|'
    return
  fi
  # FSD: src/shared/ui/... → shared-ui
  if echo "$file" | grep -qE '^src/shared/'; then
    local sub
    sub=$(echo "$file" | sed -E 's|^src/shared/([^/]+).*|\1|')
    echo "shared-${sub}"
    return
  fi
  # Layer-based: src/components/... → components
  if echo "$file" | grep -qE '^src/([^/]+)/'; then
    echo "$file" | sed -E 's|^src/([^/]+).*|\1|'
    return
  fi
  echo ""
}

# Get scope from the most common directory among staged files
for file in $STAGED_FILES; do
  candidate=$(extract_scope "$file")
  if [ -n "$candidate" ]; then
    SCOPE="$candidate"
    break
  fi
done

# Build prefix
if [ -n "$SCOPE" ]; then
  PREFIX="${TYPE}(${SCOPE}): "
else
  PREFIX="${TYPE}: "
fi

# Write prefix to commit message file (preserve existing comments)
EXISTING=$(cat "$COMMIT_MSG_FILE")
echo "${PREFIX}" > "$COMMIT_MSG_FILE"
echo "$EXISTING" >> "$COMMIT_MSG_FILE"

exit 0
