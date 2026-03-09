# Vue Config Templates

Vue-specific configuration for `/setup-configs vue`.

Load alongside `common-configs.md`.

---

## tsconfig.json (Vue — extends common base)

Add to the common base `compilerOptions`:

```json
{
  "compilerOptions": {
    "verbatimModuleSyntax": true
  }
}
```

Full merged tsconfig.json:

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
    "verbatimModuleSyntax": true,
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
  "include": ["src", "env.d.ts"],
  "exclude": ["node_modules", "dist"]
}
```

---

## env.d.ts (Vue — required for SFC type support)

```typescript
/// <reference types="vite/client" />
```

Place at project root alongside `vite.config.ts`.

---

## vite.config.ts (Vue)

```typescript
/// <reference types="vitest" />
import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
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
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/app/test-setup.ts"],
    exclude: ["**/node_modules/**", "**/e2e/**"],
  },
});
```

---

## src/app/test-setup.ts (Vue)

```typescript
import "@testing-library/jest-dom";
```

---

## Required devDependencies (Vue)

These belong in `devDependencies`. Output as a reference block — do NOT auto-install:

```json
{
  "devDependencies": {
    "vite": "latest",
    "@vitejs/plugin-vue": "latest",
    "typescript": "latest",
    "vue-tsc": "latest",
    "@types/node": "latest",
    "@biomejs/biome": "latest",
    "vitest": "latest",
    "@testing-library/vue": "latest",
    "@testing-library/jest-dom": "latest",
    "@testing-library/user-event": "latest",
    "jsdom": "latest",
    "@playwright/test": "latest"
  }
}
```

Required dependencies:

```json
{
  "dependencies": {
    "vue": "latest",
    "vue-router": "latest",
    "pinia": "latest",
    "@tanstack/vue-query": "latest"
  }
}
```

---

## Vue-specific build command

Vue projects use `vue-tsc` for type checking, not plain `tsc`:

```json
{
  "scripts": {
    "build": "vue-tsc && vite build",
    "typecheck": "vue-tsc --noEmit"
  }
}
```

Override the `build` and `typecheck` scripts from `common-configs.md` with these Vue-specific versions.

---

## Vue-specific BANNED in configs

| Anti-pattern | Why banned |
|---|---|
| `"jsx": "react-jsx"` | Wrong JSX transform for Vue |
| Options API component stubs | Use Composition API + `<script setup lang="ts">` |
| Vuex in deps | Banned — use Pinia |
| `tsc --noEmit` for type check | Use `vue-tsc --noEmit` for SFC support |
| Missing `env.d.ts` | `.vue` imports will have no types |
