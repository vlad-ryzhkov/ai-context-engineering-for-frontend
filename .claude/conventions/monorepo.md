# Monorepo Conventions

## When This Applies

Projects using Turborepo, Nx, or pnpm workspaces with multiple packages/apps.

## Structure Template

```text
root/
├── apps/
│   ├── web/              # Main frontend app
│   ├── admin/            # Admin panel
│   └── docs/             # Documentation site
├── packages/
│   ├── ui/               # Shared component library
│   ├── config/           # Shared configs (tsconfig, biome, tailwind)
│   ├── types/            # Shared TypeScript interfaces
│   └── utils/            # Shared utilities
├── turbo.json            # Turborepo pipeline config
├── pnpm-workspace.yaml   # Workspace definition
└── package.json          # Root scripts
```

## Rules

### Dependency Management

- Shared dependencies (React, Vue, TypeScript) go in root `package.json`
- Package-specific dependencies go in each package's `package.json`
- Use `workspace:*` protocol for internal package references
- Never duplicate a dependency version across packages — use `syncpack` or similar

### Build Pipeline

- `turbo.json` or `nx.json` defines the build graph
- Each package declares its own `build`, `test`, `lint` scripts
- Use `dependsOn` to express build order (e.g., `ui` builds before `web`)

### Import Rules

- Apps can import from packages — never the reverse
- Packages can import from other packages if declared in dependencies
- Circular dependencies between packages are FORBIDDEN
- Each package exports through a single `index.ts` barrel

### Shared UI Package

```text
packages/ui/
├── src/
│   ├── Button/
│   │   ├── Button.tsx        # Component
│   │   ├── Button.test.tsx   # Tests
│   │   └── index.ts          # Public API
│   └── index.ts              # Package barrel
├── package.json
└── tsconfig.json
```

### Config Sharing

```text
packages/config/
├── tsconfig.base.json     # Extended by all apps/packages
├── biome.json             # Shared linter/formatter config
└── tailwind.config.ts     # Shared Tailwind preset
```

Apps extend shared configs:

```json
{
  "extends": "@workspace/config/tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "outDir": "dist"
  }
}
```

### CI/CD

- Use Turborepo's `--filter` for affected-only builds
- Cache build artifacts (Turborepo remote cache or Nx Cloud)
- Run tests only for changed packages: `turbo run test --filter=...[origin/main]`

## CLAUDE.md Adaptation

When using this template in a monorepo, add to root `CLAUDE.md`:

```markdown
## Monorepo

- Tool: Turborepo | Nx | pnpm workspaces
- Apps: [list apps with descriptions]
- Packages: [list shared packages]
- Build: `turbo run build`
- Test: `turbo run test --filter=...[origin/main]`
```
