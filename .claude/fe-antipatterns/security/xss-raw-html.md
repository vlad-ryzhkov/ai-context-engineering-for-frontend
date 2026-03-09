# Anti-Pattern: xss-raw-html

## Problem

Using `dangerouslySetInnerHTML` (React) or `v-html` (Vue) to render unsanitized HTML.
AI generates these when asked to "render rich text" or "display HTML content".

## Why It's Bad

- CRITICAL XSS vulnerability — attacker-controlled HTML executes arbitrary JavaScript
- Stored XSS: malicious script saved to DB renders for every user
- Even "trusted" CMS content can be compromised via admin account takeover

## Severity

CRITICAL

## Detection

```bash
grep -rn "dangerouslySetInnerHTML\|v-html\|\.innerHTML\s*=" src/
```

## Bad Example (React)

```tsx
// ❌ Unsanitized HTML injection
function Comment({ body }: { body: string }) {
  return <div dangerouslySetInnerHTML={{ __html: body }} />;
}
```

## Bad Example (Vue)

```vue
<!-- ❌ Unsanitized HTML injection -->
<template>
  <div v-html="comment.body" />
</template>
```

## Good Example (React)

```tsx
// ✅ Sanitized with DOMPurify
import DOMPurify from 'dompurify';

function Comment({ body }: { body: string }) {
  const sanitized = DOMPurify.sanitize(body);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}
```

## Good Example (Vue)

```vue
<!-- ✅ Sanitized with DOMPurify -->
<script setup lang="ts">
import DOMPurify from 'dompurify';
import { computed } from 'vue';

const props = defineProps<{ body: string }>();
const sanitizedBody = computed(() => DOMPurify.sanitize(props.body));
</script>

<template>
  <div v-html="sanitizedBody" />
</template>
```

## Best Alternative

```tsx
// ✅ Prefer structured rendering over raw HTML
function Comment({ body }: { body: string }) {
  return <p>{body}</p>;  // Text interpolation — auto-escaped
}
```

## Rule

BANNED: `dangerouslySetInnerHTML`, `v-html`, `.innerHTML =` without DOMPurify sanitization.
REQUIRED: If raw HTML rendering is unavoidable, sanitize with DOMPurify before rendering.
PREFERRED: Use text interpolation (`{text}` / `{{ text }}`) whenever possible.
