#!/usr/bin/env bash
# pre-push hook: branch validation + secrets check + compile + markdownlint
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 1. Branch name validation: main/master always allowed; feature branches — Latin + digits + /_.- , 7–45 chars
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
  if ! echo "$CURRENT_BRANCH" | grep -qE '^[a-zA-Z0-9/#_.\-]{3,60}$'; then
    echo -e "${RED}[pre-push] BLOCKED: branch name '$CURRENT_BRANCH' violates CI naming convention (Latin/digits//#/_.-,  3–60 chars).${NC}"
    exit 1
  fi
fi

FORBIDDEN_FILES=(
  "gradle.properties"
  ".env"
  "local.properties"
  "-credentials.toml"
)

# 2. Forbidden files in diff vs remote
REMOTE_BRANCH="origin/$CURRENT_BRANCH"
if git rev-parse --verify "$REMOTE_BRANCH" >/dev/null 2>&1; then
  DIFF_FILES=$(git diff --name-only "$REMOTE_BRANCH"..HEAD)
else
  DIFF_FILES=$(git diff --name-only HEAD)
fi

FOUND_FORBIDDEN=0
for file in $DIFF_FILES; do
  for pattern in "${FORBIDDEN_FILES[@]}"; do
    if echo "$file" | grep -qiE -- "$pattern"; then
      echo -e "${RED}[pre-push] BLOCKED: forbidden file in diff: $file${NC}"
      FOUND_FORBIDDEN=1
    fi
  done
done

if [ "$FOUND_FORBIDDEN" -eq 1 ]; then
  exit 1
fi

# 3. Secret patterns in diff (warn only — no push block to avoid false positives)
SECRET_PATTERNS=(
  "aws_access_key_id"
  "aws_secret_access_key"
  "ghp_[a-zA-Z0-9]+"
  "password\s*=\s*\S{4,}"
  "secret\s*=\s*\S{4,}"
  "api[_-]?key\s*=\s*\S{4,}"
  "AKIA[0-9A-Z]{16}"
)

if git rev-parse --verify "$REMOTE_BRANCH" >/dev/null 2>&1; then
  DIFF_CONTENT=$(git diff "$REMOTE_BRANCH"..HEAD)
else
  DIFF_CONTENT=$(git show HEAD)
fi

for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$DIFF_CONTENT" | grep -qiE "^\+.*$pattern"; then
    echo -e "${YELLOW}[pre-push] WARNING: possible secret pattern detected: $pattern — review before pushing.${NC}"
  fi
done

# 3b. React Doctor health check (React projects only, warning only)
if [ -f "package.json" ] && grep -q '"react"' package.json 2>/dev/null; then
  if command -v npx >/dev/null 2>&1; then
    echo "[pre-push] Running React Doctor..."
    SCORE=$(npx react-doctor@latest . --score 2>/dev/null || echo "")
    if [ -n "$SCORE" ] && [ "$SCORE" -lt 50 ] 2>/dev/null; then
      echo -e "${YELLOW}[pre-push] WARNING: React Doctor score ${SCORE}/100${NC}"
    fi
  fi
fi

# 4. Bundle size guard (WARNING only)
if [ -n "$DIFF_FILES" ]; then
  HEAVY_IMPORT_FOUND=0
  HEAVY_PATTERNS=(
    "import moment"
    "import lodash[^-/e]"
    'import \* as'
  )

  FE_DIFF_CONTENT=""
  if git rev-parse --verify "$REMOTE_BRANCH" >/dev/null 2>&1; then
    FE_DIFF_CONTENT=$(git diff "$REMOTE_BRANCH"..HEAD -- '*.ts' '*.tsx' '*.vue' '*.js' '*.jsx' 2>/dev/null || echo "")
  else
    FE_DIFF_CONTENT=$(git show HEAD -- '*.ts' '*.tsx' '*.vue' '*.js' '*.jsx' 2>/dev/null || echo "")
  fi

  if [ -n "$FE_DIFF_CONTENT" ]; then
    ADDED_LINES=$(echo "$FE_DIFF_CONTENT" | grep '^+[^+]' || true)
    for pattern in "${HEAVY_PATTERNS[@]}"; do
      if echo "$ADDED_LINES" | grep -qE "$pattern"; then
        echo -e "${YELLOW}[pre-push] WARNING: heavy import detected: ${pattern} — consider tree-shakeable alternative.${NC}"
        HEAVY_IMPORT_FOUND=1
      fi
    done
  fi

  # Bundle size check (if dist/ or build/ exists)
  BUNDLE_DIR=""
  if [ -d "dist" ]; then
    BUNDLE_DIR="dist"
  elif [ -d "build" ]; then
    BUNDLE_DIR="build"
  fi

  if [ -n "$BUNDLE_DIR" ]; then
    BUNDLE_SIZE=$(find "$BUNDLE_DIR" -name "*.js" -exec wc -c {} + 2>/dev/null | tail -1 | awk '{print $1}')
    BUDGET_BYTES=921600  # 900KB raw ≈ 300KB gzip
    if [ -n "$BUNDLE_SIZE" ] && [ "$BUNDLE_SIZE" -gt "$BUDGET_BYTES" ] 2>/dev/null; then
      BUNDLE_KB=$((BUNDLE_SIZE / 1024))
      echo -e "${YELLOW}[pre-push] WARNING: JS bundle size ${BUNDLE_KB}KB exceeds 900KB budget. Run /web-vitals for analysis.${NC}"
    fi
  fi
fi

# 5. Markdownlint (check only — never modify files during push)
if command -v npx >/dev/null 2>&1; then
  echo "[pre-push] Running markdownlint..."
  if ! npx markdownlint-cli "**/*.md" --ignore node_modules --ignore audit 2>/dev/null; then
    echo -e "${YELLOW}[pre-push] WARNING: markdownlint found issues. Run 'npx markdownlint-cli --fix **/*.md' to fix.${NC}"
  fi
else
  echo -e "${YELLOW}[pre-push] WARNING: npx not found — markdownlint skipped.${NC}"
fi

echo "[pre-push] All checks passed."
exit 0
