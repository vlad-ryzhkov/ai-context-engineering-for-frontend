# Refactor Transform Patterns

## class-to-hooks (React only)

### Detection

```bash
grep -rn 'extends React\.Component\|extends Component' src/ --include='*.tsx'
```

### Before

```tsx
class UserProfile extends React.Component<Props, State> {
  state = { isEditing: false };

  componentDidMount() {
    this.fetchUser();
  }

  componentDidUpdate(prevProps: Props) {
    if (prevProps.userId !== this.props.userId) {
      this.fetchUser();
    }
  }

  fetchUser = async () => {
    const user = await api.getUser(this.props.userId);
    this.setState({ user });
  };

  render() {
    return <div>{this.state.user?.name}</div>;
  }
}
```

### After

```tsx
function UserProfile({ userId }: Props) {
  const [isEditing, setIsEditing] = useState(false);
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const fetchUser = async () => {
      const data = await api.getUser(userId);
      setUser(data);
    };
    fetchUser();
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

### Transform Rules

| Class Pattern | Hook Equivalent |
|---|---|
| `this.state.X` | `const [X, setX] = useState(...)` |
| `this.setState({ X })` | `setX(value)` |
| `componentDidMount` | `useEffect(() => {...}, [])` |
| `componentDidUpdate` (with comparison) | `useEffect(() => {...}, [deps])` |
| `componentWillUnmount` | `useEffect(() => { return () => {...} }, [])` |
| `this.props.X` | destructured prop `X` |
| class method | `const method = useCallback(...)` or plain function |

### Edge Cases

- **`this.setState` callbacks** (`this.setState({x}, () => ...)`) → use `useEffect` watching the state variable
- **Bound class methods** (`this.handleClick = this.handleClick.bind(this)`) → plain function or `useCallback`
- **`componentDidUpdate` with prev comparison** → `useEffect` with correct deps; WARN if deps are complex objects (referential equality)
- **Multiple `componentDidUpdate` blocks** → separate `useEffect` per concern, not one monolithic effect
- **`this.refs` (legacy string refs)** → `useRef` + ref callback
- **`getDerivedStateFromProps`** → plain const derivation or `useMemo` (see `state-in-render.md`)

---

## options-to-composition (Vue only)

### Detection (options-to-composition)

```bash
grep -rn 'export default {' src/ --include='*.vue' | grep -v 'defineComponent'
grep -rn 'methods:\|computed:\|watch:' src/ --include='*.vue'
```

### Before (options-to-composition)

```vue
<script lang="ts">
export default {
  props: {
    userId: { type: String, required: true }
  },
  data() {
    return { user: null, isLoading: false };
  },
  computed: {
    fullName() { return `${this.user?.first} ${this.user?.last}`; }
  },
  watch: {
    userId(newId) { this.fetchUser(newId); }
  },
  methods: {
    async fetchUser(id: string) {
      this.isLoading = true;
      this.user = await api.getUser(id);
      this.isLoading = false;
    }
  },
  mounted() { this.fetchUser(this.userId); }
};
</script>
```

### After (options-to-composition)

```vue
<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';

const props = defineProps<{ userId: string }>();

const user = ref<User | null>(null);
const isLoading = ref(false);

const fullName = computed(() => `${user.value?.first} ${user.value?.last}`);

async function fetchUser(id: string) {
  isLoading.value = true;
  user.value = await api.getUser(id);
  isLoading.value = false;
}

watch(() => props.userId, (newId) => fetchUser(newId));
onMounted(() => fetchUser(props.userId));
</script>
```

### Transform Rules (options-to-composition)

| Options API | Composition API |
|---|---|
| `props: { X }` | `defineProps<{ X }>()` |
| `data() { return { X } }` | `const X = ref(...)` |
| `computed: { X() {} }` | `const X = computed(() => ...)` |
| `watch: { X(new, old) {} }` | `watch(() => X, (new, old) => ...)` |
| `methods: { X() {} }` | `function X() {}` |
| `mounted()` | `onMounted(() => ...)` |
| `unmounted()` | `onUnmounted(() => ...)` |
| `this.X` | `X.value` (ref) or `X` (reactive/props) |
| `$emit('event')` | `const emit = defineEmits<{...}>()` |

### Edge Cases (options-to-composition)

- **Mixins** → extract each mixin into a composable; track every `this.*` reference to map to correct `ref`/`computed`
- **`this.$refs`** → `useTemplateRef()` (Vue 3.5+) or `ref()` + template `ref="name"`
- **`this.$nextTick`** → `import { nextTick } from 'vue'`
- **Watchers with `deep: true`** → `watch(source, cb, { deep: true })` — preserve options
- **`this.$emit` with validation** → `defineEmits` with TypeScript overloads

---

## cjs-to-esm (framework-agnostic)

### Detection (cjs-to-esm)

```bash
grep -rn 'require(\|module\.exports' src/ --include='*.ts' --include='*.js'
```

### Transform Rules (cjs-to-esm)

| CommonJS | ESM |
|---|---|
| `const X = require('mod')` | `import X from 'mod'` |
| `const { A, B } = require('mod')` | `import { A, B } from 'mod'` |
| `module.exports = X` | `export default X` |
| `module.exports = { A, B }` | `export { A, B }` |
| `exports.X = ...` | `export const X = ...` |

### Edge Cases (cjs-to-esm)

- **Dynamic `require()` inside functions/conditions** → `const mod = await import('mod')` (async!) — flag as BREAKING if call site is sync
- **`require.resolve()`** → `import.meta.resolve()` (Node 20+) or keep as-is with comment
- **`__dirname` / `__filename`** → `import.meta.dirname` / `import.meta.filename` (Node 21+) or `fileURLToPath(import.meta.url)`
- **Circular requires** → ESM handles cycles differently; WARN in dry run if detected

---

## tanstack-v4-to-v5 (React and Vue)

### Detection (tanstack-v4-to-v5)

```bash
grep -rn '@tanstack/react-query\|@tanstack/vue-query' src/ --include='*.ts' --include='*.tsx' --include='*.vue'
```

### Transform Rules (tanstack-v4-to-v5)

| v4 | v5 |
|---|---|
| `useQuery({ queryKey, queryFn })` | Same (no change) |
| `useQuery(key, fn)` (positional) | `useQuery({ queryKey: key, queryFn: fn })` |
| `useMutation(fn)` (positional) | `useMutation({ mutationFn: fn })` |
| `isLoading` (initial load) | `isPending` (renamed) |
| `isInitialLoading` | `isLoading` (renamed — means fetching + no data) |
| `cacheTime` | `gcTime` (renamed) |
| `useQuery` `onSuccess/onError/onSettled` callbacks | Remove — use `.then()` on `mutateAsync` or `useEffect` |
| `import { QueryClient } from '@tanstack/react-query'` | Same (no change) |
| `keepPreviousData: true` | `placeholderData: keepPreviousData` (import `keepPreviousData` from package) |

### Additional v5 Notes

- `status: 'loading'` → `status: 'pending'`
- `getQueryData` / `getQueryState` now require exact key match (no partial matching)
- `queryClient.cancelQueries(key)` → `queryClient.cancelQueries({ queryKey: key })`
