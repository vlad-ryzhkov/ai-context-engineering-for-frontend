# Anti-Pattern: memory-leak-subscriptions

## Problem

Setting up event listeners, timers, WebSocket connections, or observers without cleaning them up on unmount.
AI routinely generates `addEventListener` / `setInterval` without return cleanup.

## Why It's Bad

- Memory leak — listeners accumulate on every mount/navigation
- Stale closures fire callbacks on unmounted components → React warnings, Vue errors
- Performance degrades progressively — app slows down over time
- WebSocket/EventSource connections stay open, consuming server resources

## Severity

HIGH

## Detection

```bash
# Event listeners without cleanup
grep -rn "addEventListener\|setInterval\|setTimeout\|new WebSocket\|new EventSource\|ResizeObserver\|IntersectionObserver\|MutationObserver" src/ | grep -v "removeEventListener\|clearInterval\|clearTimeout\|\.close()\|\.disconnect()\|\.unobserve("
```

## Bad Example (React)

```tsx
// ❌ No cleanup — listener leaks on every mount
function WindowSize() {
  const [width, setWidth] = useState(window.innerWidth);

  useEffect(() => {
    window.addEventListener('resize', () => setWidth(window.innerWidth));
  }, []);

  return <span>{width}px</span>;
}
```

## Bad Example (Vue)

```vue
<!-- ❌ No cleanup — interval leaks on unmount -->
<script setup lang="ts">
import { ref, onMounted } from 'vue';

const elapsed = ref(0);

onMounted(() => {
  setInterval(() => {
    elapsed.value++;
  }, 1000);
});
</script>
```

## Good Example (React)

```tsx
// ✅ Cleanup in useEffect return
function WindowSize() {
  const [width, setWidth] = useState(window.innerWidth);

  useEffect(() => {
    const handleResize = () => setWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return <span>{width}px</span>;
}
```

## Good Example (Vue)

```vue
<!-- ✅ Cleanup in onUnmounted -->
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';

const elapsed = ref(0);
let intervalId: ReturnType<typeof setInterval>;

onMounted(() => {
  intervalId = setInterval(() => {
    elapsed.value++;
  }, 1000);
});

onUnmounted(() => {
  clearInterval(intervalId);
});
</script>
```

## Cleanup Reference

| Subscription | Setup | Cleanup |
|-------------|-------|---------|
| DOM event | `addEventListener` | `removeEventListener` |
| Timer | `setInterval` / `setTimeout` | `clearInterval` / `clearTimeout` |
| WebSocket | `new WebSocket()` | `.close()` |
| ResizeObserver | `.observe()` | `.disconnect()` |
| IntersectionObserver | `.observe()` | `.disconnect()` |
| MutationObserver | `.observe()` | `.disconnect()` |
| EventSource | `new EventSource()` | `.close()` |
| AbortController | `fetch(url, { signal })` | `controller.abort()` |

## Rule

BANNED: `addEventListener`, `setInterval`, `setTimeout`, observers, or connections without corresponding cleanup on unmount.
REQUIRED: Every subscription MUST have a matching teardown in `useEffect` return (React) or `onUnmounted` (Vue).
