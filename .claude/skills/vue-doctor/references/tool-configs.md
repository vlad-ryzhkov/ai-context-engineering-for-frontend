# Tool Configurations — Vue Doctor

> Recommended configs for projects that lack them.
> Used by Phase 2 of `/vue-doctor` when tools are missing.

## Install Command (all 3 tools)

```bash
npm install -D oxlint eslint eslint-plugin-vue vue-eslint-parser @typescript-eslint/parser vue-tsc
```

## Oxlint

Oxlint uses `oxlint.json` (or `oxlintrc.json`) in the project root.

Recommended config for Vue projects:

```json
{
  "rules": {
    "correctness": "error",
    "suspicious": "warn",
    "pedantic": "off"
  },
  "ignore_patterns": [
    "node_modules",
    "dist",
    "coverage",
    "**/*.test.*",
    "**/*.spec.*"
  ]
}
```

Oxlint supports `.vue` files natively — no additional plugin needed.

## ESLint with eslint-plugin-vue

Recommended `.eslintrc.json` for Vue 3 + TypeScript:

```json
{
  "root": true,
  "parser": "vue-eslint-parser",
  "parserOptions": {
    "parser": "@typescript-eslint/parser",
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "extends": [
    "plugin:vue/vue3-recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "vue/no-mutating-props": "error",
    "vue/no-use-v-if-with-v-for": "error",
    "vue/require-v-for-key": "error",
    "vue/define-props-declaration": ["error", "type-based"],
    "vue/component-api-style": ["error", ["script-setup"]],
    "vue/no-side-effects-in-computed-properties": "error",
    "vue/no-watch-after-await": "error",
    "vue/no-ref-object-reactivity-loss": "warn",
    "vue/no-v-html": "warn",
    "vue/require-default-prop": "warn",
    "vue/max-attributes-per-line": "off"
  }
}
```

## vue-tsc

vue-tsc uses the project's existing `tsconfig.json`. No additional config file needed.

Ensure `tsconfig.json` includes:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts", "src/**/*.vue"]
}
```

## Tool Comparison

| Feature | Oxlint | ESLint (vue plugin) | vue-tsc |
|---------|--------|---------------------|---------|
| Speed | Very fast (Rust) | Moderate (JS) | Slow (TS compiler) |
| Vue template analysis | Basic | Deep (vue-specific rules) | Type checking only |
| Auto-fix | Yes | Yes | No |
| JSON output | Limited | Yes (`--format json`) | No |
| Overlap | Partial with ESLint | Partial with Oxlint | None |

## Deduplication Notes

Oxlint and ESLint share ~30% of rules (mostly JS/TS linting). The scoring algorithm
in Phase 6 deduplicates findings at the `file:line:category` level to avoid double-counting.

vue-tsc findings are always unique — type errors do not overlap with lint rules.
