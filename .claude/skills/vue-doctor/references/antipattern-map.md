# Vue Doctor → Anti-Pattern Mapping

> Cross-reference tables for mapping vue-doctor diagnostics to existing
> `.claude/fe-antipatterns/` files. Used by Phase 6 of `/vue-doctor`.

## eslint-plugin-vue → Anti-Patterns

| ESLint Rule | Anti-Pattern File | Match | Notes |
|-------------|-------------------|-------|-------|
| `vue/no-use-v-if-with-v-for` | `vue/v-for-v-if-same-element.md` | Direct | v-if and v-for on the same element |
| `vue/require-v-for-key` | `vue/v-for-no-key.md` | Direct | v-for without :key binding |
| `vue/no-mutating-props` | — | Unmapped | Mutating parent-passed props (CLAUDE.md BANNED) |
| `vue/define-props-declaration` | `vue/missing-defineprops-types.md` | Direct | Props without type declarations |
| `vue/component-api-style` | `vue/options-api-in-new-code.md` | Direct | Options API in new Composition API codebase |
| `vue/no-side-effects-in-computed-properties` | `vue/template-complexity.md` | Partial | Side effects in computed; anti-pattern covers broader template complexity |
| `vue/no-watch-after-await` | `vue/reactive-destructuring-loss.md` | Partial | Watch after await loses reactivity context |
| `vue/no-ref-object-reactivity-loss` | `vue/reactive-destructuring-loss.md` | Direct | Destructuring reactive objects loses reactivity |
| `vue/require-default-prop` | `vue/missing-defineprops-types.md` | Partial | Missing defaults; anti-pattern covers broader type issues |
| `vue/no-v-html` | — | Unmapped | XSS risk via v-html (security concern) |
| `vue/max-attributes-per-line` | `vue/template-complexity.md` | Partial | Template readability |

## Oxlint → Anti-Patterns

| Oxlint Rule | Anti-Pattern File | Match | Notes |
|-------------|-------------------|-------|-------|
| `jsx-a11y/alt-text` | `a11y/missing-alt-text.md` | Direct | `<img>` without alt attribute |
| `jsx-a11y/click-events-have-key-events` | `a11y/div-as-button.md` | Direct | Clickable element without keyboard handler |
| `jsx-a11y/no-noninteractive-element-interactions` | `a11y/div-as-button.md` | Partial | Non-interactive element with click handler |
| `jsx-a11y/aria-props` | `a11y/missing-aria-labels.md` | Partial | Invalid ARIA attributes |
| `no-unused-vars` | `react/dead-code.md` | Partial | Unused variables (anti-pattern is React-focused but principle applies) |
| `import/no-duplicates` | `common/heavy-imports.md` | Partial | Duplicate imports increase bundle |
| `no-console` | — | Unmapped | console.log left in code (CLAUDE.md BANNED) |
| `no-debugger` | — | Unmapped | debugger statement left in code |
| `prefer-const` | — | Unmapped | let used where const would suffice |
| `eqeqeq` | — | Unmapped | Loose equality (== instead of ===) |

## vue-tsc → Anti-Patterns

| TS Error | Anti-Pattern File | Match | Notes |
|----------|-------------------|-------|-------|
| `TS2339: Property does not exist on type` | `vue/missing-defineprops-types.md` | Partial | Often caused by missing prop type declarations |
| `TS7006: Parameter implicitly has an 'any' type` | — | Unmapped | Implicit any — CLAUDE.md BANNED (`any` type in TypeScript) |
| `TS2322: Type is not assignable` | — | Unmapped | Type mismatch (generic TS issue) |
| `TS2345: Argument of type is not assignable` | — | Unmapped | Argument type mismatch |

## Unmapped Rules (Tool-specific)

These rules have no corresponding anti-pattern file.
If frequently triggered, consider creating new anti-pattern files.

### ESLint (Vue-specific)

- `vue/no-mutating-props` — prop mutation (covered by CLAUDE.md BANNED list)
- `vue/no-v-html` — XSS risk via v-html

### Oxlint

- `no-console` — console.log left in code (covered by CLAUDE.md BANNED list)
- `no-debugger` — debugger statement
- `prefer-const` — let where const suffices
- `eqeqeq` — loose equality

### vue-tsc

- `TS7006` — implicit any (covered by CLAUDE.md BANNED list)
- `TS2322` / `TS2345` — type mismatches (generic TS issues)
