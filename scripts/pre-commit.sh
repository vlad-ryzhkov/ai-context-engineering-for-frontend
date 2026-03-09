#!/usr/bin/env bash
# pre-commit hook: blocks forbidden files and secret patterns in staged changes
set -euo pipefail

RED='\033[0;31m'
NC='\033[0m'

FORBIDDEN_FILES=(
  "gradle\.properties"
  "local\.properties"
  "\.env($|[^a-z])"
  "(^|/)credentials(\.[^/]+)?$"
  "\.pem$"
  "\.p12$"
  "\.key$"
  "\.keystore$"
  "\.jks$"
)

SECRET_PATTERNS=(
  "aws_access_key_id"
  "aws_secret_access_key"
  "ghp_[a-zA-Z0-9]+"
  "password\s*=\s*\S{4,}"
  "secret\s*=\s*\S{4,}"
  "api[_-]?key\s*=\s*\S{4,}"
  "AKIA[0-9A-Z]{16}"
)

STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# Check forbidden files
FOUND_FORBIDDEN=0
for file in $STAGED_FILES; do
  for pattern in "${FORBIDDEN_FILES[@]}"; do
    if echo "$file" | grep -qiE "$pattern"; then
      echo -e "${RED}[pre-commit] BLOCKED: forbidden file staged: $file${NC}"
      FOUND_FORBIDDEN=1
    fi
  done
done

# Check secret patterns in staged diff (exclude scripts/ — they contain pattern definitions)
FOUND_SECRET=0
STAGED_DIFF=$(git diff --cached -- . ':(exclude)scripts/' ':(exclude).claude/' ':(exclude)docs/' ':(exclude)examples/' ':(exclude).ai-lessons/' ':(exclude).agents/' ':(exclude).cursor/')
for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$STAGED_DIFF" | grep -qiE "^\+.*$pattern"; then
    echo -e "${RED}[pre-commit] BLOCKED: secret pattern detected: $pattern${NC}"
    FOUND_SECRET=1
  fi
done

if [ "$FOUND_FORBIDDEN" -eq 1 ] || [ "$FOUND_SECRET" -eq 1 ]; then
  echo -e "${RED}[pre-commit] Commit aborted. Remove sensitive data and try again.${NC}"
  exit 1
fi

# Phase 3: Anti-pattern quick scan (WARNING only, non-blocking by default)
YELLOW='\033[1;33m'
GREEN='\033[0;32m'

ANTIPATTERN_PATTERNS=(
  ": any"
  "as any"
  "console\.log"
  "style={{"
  "key={index}\|key={i}"
  "document\.querySelector"
  "import moment"
  'import lodash[^-/]'
)

ANTIPATTERN_REFS=(
  "common/inline-styles.md"
  "common/inline-styles.md"
  "CLAUDE.md#Safety"
  "common/inline-styles.md"
  "react/key-as-index.md"
  "react/direct-dom-mutation.md"
  "common/heavy-imports.md"
  "common/heavy-imports.md"
)

STAGED_FE_DIFF=$(git diff --cached -- '*.ts' '*.tsx' '*.vue' 2>/dev/null || echo "")
if [ -n "$STAGED_FE_DIFF" ]; then
  ADDED_LINES=$(echo "$STAGED_FE_DIFF" | grep '^+[^+]' || true)
  FOUND_ANTIPATTERN=0

  for idx in "${!ANTIPATTERN_PATTERNS[@]}"; do
    pattern="${ANTIPATTERN_PATTERNS[$idx]}"
    ref="${ANTIPATTERN_REFS[$idx]}"
    if echo "$ADDED_LINES" | grep -qE "$pattern"; then
      echo -e "${YELLOW}[pre-commit] WARNING: anti-pattern detected: ${pattern}  (ref: .claude/fe-antipatterns/${ref})${NC}"
      FOUND_ANTIPATTERN=1
    fi
  done

  if [ "$FOUND_ANTIPATTERN" -eq 1 ]; then
    if [ "${FE_PRECOMMIT_STRICT:-0}" = "1" ]; then
      echo -e "${RED}[pre-commit] BLOCKED: FE_PRECOMMIT_STRICT=1 — fix anti-patterns before committing.${NC}"
      exit 1
    else
      echo -e "${YELLOW}[pre-commit] Anti-pattern warnings above are non-blocking. Set FE_PRECOMMIT_STRICT=1 to enforce.${NC}"
    fi
  else
    echo -e "${GREEN}[pre-commit] Anti-pattern scan: clean.${NC}"
  fi
fi

exit 0
