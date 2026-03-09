---
globs: "src/**"
---

# Feature-Sliced Design Rules

- Layer hierarchy (top to bottom): app → pages → widgets → features → entities → shared
- Import rule: modules can ONLY import from layers strictly BELOW them
- Cross-imports within same layer are FORBIDDEN (e.g., features/a importing features/b)
- Public API: each slice exposes only through index.ts barrel file
- Shared layer: UI kit, API client, utilities, hooks — no business logic
- Entities: business objects only — no UI rendering logic
- Features: user-facing actions — may compose entities
