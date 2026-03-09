---
globs: "packages/**, apps/**"
---

# Monorepo Rules

- Apps can import from packages — never the reverse
- Circular dependencies between packages are FORBIDDEN
- Use `workspace:*` protocol for internal package references
- Each package exports through a single `index.ts` barrel
- Shared dependencies go in root `package.json`
- Run affected-only builds: `turbo run build --filter=...[origin/main]`
- See `.claude/conventions/monorepo.md` for full conventions
