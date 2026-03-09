# Anti-Pattern: dead-code

## Problem

Unused exports, components, types, or hooks that remain in the codebase after refactoring.

## Why It's Bad

- Increases bundle size — unused exports may still be bundled depending on build config
- Creates confusion — developers see dead code and assume it's used elsewhere
- Slows down IDE and type-checker — more files to index and analyze
- Makes refactoring riskier — unclear if removing code will break something

## Detection

Dead code detection requires AST-level analysis. Grep is insufficient — an export may appear
"used" in import statements that are themselves dead.

```bash
# React Doctor detects dead exports natively
npx react-doctor@latest . --verbose 2>&1 | grep "dead-export"

# Approximate grep (false positives expected)
# Find exports, then check if they are imported anywhere
grep -rn "export " src/ --include="*.ts" --include="*.tsx" | head -20
```

## Common Dead Code Sources

| Source | Example |
|--------|---------|
| Renamed component | Old `UserCard.tsx` still exported after rename to `ProfileCard.tsx` |
| Removed feature | Feature flag removed but helper functions remain |
| Refactored hook | Custom hook replaced by TanStack Query but old hook file persists |
| Unused types | Interface defined for an endpoint that was deprecated |
| Barrel re-exports | `index.ts` re-exports a module no longer imported by consumers |

## Rule

REQUIRED: Run dead code analysis before major releases (React Doctor or `ts-prune`).
REQUIRED: Remove unused exports during refactoring — don't leave them "just in case."
BANNED: Commenting out dead code instead of deleting (use git history for recovery).
