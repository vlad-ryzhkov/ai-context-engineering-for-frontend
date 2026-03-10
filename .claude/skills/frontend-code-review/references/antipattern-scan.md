# Anti-pattern Scan Tables

> Grep signatures for Phase 3.2 anti-pattern detection.
> Ref paths are relative to `.claude/fe-antipatterns/`.

## Common (always run on diff)

| Pattern | Grep signature | Ref |
|---------|---------------|-----|
| `any` type | `: any\|as any` | CLAUDE.md Safety |
| Inline styles | `style={{` | `common/inline-styles.md` |
| Hardcoded URLs | `https://\|http://localhost` | `common/hardcoded-api-urls.md` |
| console.log | `console\.log` | CLAUDE.md Safety |
| Prop mutation | direct mutation of props object | `common/mixed-concerns.md` |

## React-gated (run only when React detected)

| Pattern | Grep signature | Ref |
|---------|---------------|-----|
| key-as-index | `key={index}\|key={i}` | `react/key-as-index.md` |
| Direct DOM mutation | `document\.querySelector` | `react/direct-dom-mutation.md` |
| useEffect no deps | `useEffect(() =>` without `[]` | `react/useeffect-no-deps.md` |
| useState object mutation | `state.field = value` | `react/usestate-object-mutation.md` |

## Vue-gated (run only when Vue detected)

| Pattern | Grep signature | Ref |
|---------|---------------|-----|
| v-for without :key | `v-for` without `:key` | `vue/v-for-no-key.md` |
| defineProps untyped | `defineProps({` | `vue/missing-defineprops-types.md` |
| Options API | `export default {` + `methods:` | `vue/options-api-in-new-code.md` |
| v-for + v-if same element | `v-for.*v-if\|v-if.*v-for` | `vue/v-for-v-if-same-element.md` |
| Reactive destructuring | `const {.*} = useQuery\|reactive` | `vue/reactive-destructuring-loss.md` |
