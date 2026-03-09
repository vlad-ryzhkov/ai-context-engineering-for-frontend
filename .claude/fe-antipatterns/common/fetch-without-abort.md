# Anti-Pattern: fetch-without-abort

## Problem

Fetching data in `useEffect` or `onMounted` without an `AbortController` for cleanup.
AI generates fetch calls that continue after component unmount, causing memory leaks and state updates on unmounted components.

## Why It's Bad

- Memory leak — response handler holds reference to unmounted component scope
- React: "Can't perform state update on unmounted component" warning
- Race condition — rapid navigation fires multiple requests, last response might not be latest
- Wasted bandwidth — abandoned requests complete but results are discarded

## Severity

MEDIUM

## Detection

```bash
# fetch/axios in useEffect without AbortController
grep -rn "useEffect.*fetch\|useEffect.*axios\|onMounted.*fetch\|onMounted.*axios" src/ | grep -v "AbortController\|signal\|abort"
```

## Bad Example (React)

```tsx
// ❌ No abort — leaks on unmount, race condition on rapid re-renders
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then((res) => res.json())
      .then((data) => setUser(data));
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

## Good Example (React)

```tsx
// ✅ AbortController cancels on unmount and userId change
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then((res) => res.json())
      .then((data) => setUser(data))
      .catch((error) => {
        if (error.name !== 'AbortError') {
          console.error('Fetch failed:', error);
        }
      });

    return () => controller.abort();
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

## Good Example (Vue)

```vue
<!-- ✅ AbortController with onUnmounted cleanup -->
<script setup lang="ts">
import { ref, watch, onUnmounted } from 'vue';

const props = defineProps<{ userId: string }>();
const user = ref<User | null>(null);
let controller: AbortController;

watch(() => props.userId, async (userId) => {
  controller?.abort();
  controller = new AbortController();

  try {
    const res = await fetch(`/api/users/${userId}`, { signal: controller.signal });
    user.value = await res.json();
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') return;
    throw error;
  }
}, { immediate: true });

onUnmounted(() => controller?.abort());
</script>
```

## Best Practice

Prefer TanStack Query over manual fetch — it handles abort, caching, and race conditions automatically:

```tsx
// ✅ TanStack Query — automatic abort + cache + dedup
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: ({ signal }) => fetch(`/api/users/${userId}`, { signal }).then(r => r.json()),
});
```

## Rule

BANNED: `fetch`/`axios` in `useEffect`/`onMounted` without `AbortController` cleanup.
REQUIRED: Every manual fetch must use `AbortController` with cleanup on unmount/dependency change.
PREFERRED: Use TanStack Query instead of manual fetch for data fetching.
