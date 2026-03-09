# Common Config Templates

Shared configuration templates used by both React and Vue variants of `/setup-configs`.

---

## tsconfig.json (base — framework extends this)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@app/*": ["src/app/*"],
      "@pages/*": ["src/pages/*"],
      "@widgets/*": ["src/widgets/*"],
      "@features/*": ["src/features/*"],
      "@entities/*": ["src/entities/*"],
      "@shared/*": ["src/shared/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

---

## biome.json

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100,
    "lineEnding": "lf"
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "suspicious": {
        "noExplicitAny": "error",
        "noConsoleLog": "warn"
      },
      "correctness": {
        "noUnusedVariables": "warn"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "trailingCommas": "all",
      "semicolons": "always"
    }
  },
  "files": {
    "ignore": ["dist", "node_modules", ".vite", "coverage", "*.generated.ts"]
  }
}
```

---

## package.json scripts section

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "typecheck": "tsc --noEmit",
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test"
  }
}
```

---

## vite.config.ts — path alias resolver (shared)

The `resolve.alias` block is identical for both frameworks. Use ESM-compatible `fileURLToPath` — **DO NOT use `__dirname`** (it does not exist in ESM):

```typescript
import { fileURLToPath, URL } from "node:url";

// Inside defineConfig:
resolve: {
  alias: {
    "@app": fileURLToPath(new URL("./src/app", import.meta.url)),
    "@pages": fileURLToPath(new URL("./src/pages", import.meta.url)),
    "@widgets": fileURLToPath(new URL("./src/widgets", import.meta.url)),
    "@features": fileURLToPath(new URL("./src/features", import.meta.url)),
    "@entities": fileURLToPath(new URL("./src/entities", import.meta.url)),
    "@shared": fileURLToPath(new URL("./src/shared", import.meta.url)),
  },
},
```

---

## Vitest config block (shared — embedded in vite.config.ts)

```typescript
// Add to defineConfig (requires /// <reference types="vitest" /> at top)
test: {
  globals: true,
  environment: "jsdom",
  setupFiles: ["./src/app/test-setup.ts"],
  exclude: ["**/node_modules/**", "**/e2e/**"],
},
```

---

## Anti-patterns to avoid

| Anti-pattern | Why banned |
|---|---|
| `"strict": false` | Defeats TypeScript safety |
| ESLint + Prettier alongside Biome | Mixed linter configs, conflicts |
| `allowJs: true` without `checkJs: true` | Silent JS bugs |
| No path aliases | Brittle relative imports `../../../` |
| `moduleResolution: "node"` | Incorrect for Vite/ESM |
| `__dirname` in vite.config.ts | Does not exist in ESM — use `fileURLToPath` + `import.meta.url` |
| Version numbers in templates | Templates go stale — user pins versions |
