# React Config Templates

React-specific configuration for `/setup-configs react`.

Load alongside `common-configs.md`.

---

## tsconfig.json (React — extends common base)

Add to the common base `compilerOptions`:

```json
{
  "compilerOptions": {
    "jsx": "react-jsx"
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
    "jsx": "react-jsx",
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

## vite.config.ts (React)

```typescript
/// <reference types="vitest" />
import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
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

## src/app/test-setup.ts (React)

```typescript
import "@testing-library/jest-dom";
```

---

## Required devDependencies (React)

These belong in `devDependencies`. Output as a reference block — do NOT auto-install:

```json
{
  "devDependencies": {
    "vite": "latest",
    "@vitejs/plugin-react": "latest",
    "typescript": "latest",
    "@types/node": "latest",
    "@biomejs/biome": "latest",
    "vitest": "latest",
    "@testing-library/react": "latest",
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
    "react": "latest",
    "react-dom": "latest",
    "@tanstack/react-query": "latest"
  }
}
```

---

## React-specific BANNED in configs

| Anti-pattern | Why banned |
|---|---|
| `"jsx": "react"` (classic) | Requires manual `import React` — forbidden in React 18 |
| CRA (`react-scripts`) | Banned — use Vite |
| `@vitejs/plugin-react-swc` as default | Optional, not default in this template |
| Redux Toolkit in deps | Banned unless explicitly requested by user |
