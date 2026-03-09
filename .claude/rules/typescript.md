---
globs: "*.ts, *.tsx, *.vue"
---

# TypeScript Strict Rules

- FORBIDDEN: `any`, `as any` — use `unknown` + type guard or explicit interface
- FORBIDDEN: `// @ts-ignore`, `// @ts-expect-error` without explanation
- FORBIDDEN: Non-null assertion `!` unless provably safe
- All function params and returns must be explicitly typed
- Prefer `interface` over `type` for object shapes (extendable)
- Use `satisfies` for type-safe object literals
- Enums: prefer `as const` objects over `enum`
- Generic constraints: always constrain type params — `<T extends Record<string, unknown>>` not bare `<T>`; unconstrained generics accept `any` silently
