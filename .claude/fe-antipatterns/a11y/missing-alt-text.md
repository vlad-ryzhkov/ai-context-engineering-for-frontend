# Anti-Pattern: missing-alt-text

## Problem

`<img>` element without an `alt` attribute. Screen readers cannot describe the image to users.

## Why It's Bad

- WCAG 2.2 Level A violation (1.1.1 Non-text Content)
- Screen readers announce the image filename or URL instead of meaningful description
- SEO penalty — search engines use alt text for image indexing
- Fails automated accessibility audits (axe, Lighthouse)

## Detection

```bash
# React
grep -rn "<img" src/ --include="*.tsx" --include="*.jsx" | grep -v "alt="

# Vue
grep -rn "<img" src/ --include="*.vue" | grep -v "alt="
```

## Bad Example (React)

```tsx
// ❌ No alt attribute
<img src="/avatar.jpg" className="rounded-full w-10 h-10" />
```

## Good Example (React)

```tsx
// ✅ Descriptive alt text
<img src="/avatar.jpg" alt="User profile photo" className="rounded-full w-10 h-10" />

// ✅ Decorative image — empty alt (not omitted)
<img src="/divider.svg" alt="" className="w-full" />
```

## Bad Example (Vue)

```vue
<!-- ❌ No alt attribute -->
<img :src="product.image" class="w-full object-cover" />
```

## Good Example (Vue)

```vue
<!-- ✅ Dynamic alt text -->
<img :src="product.image" :alt="product.name" class="w-full object-cover" />

<!-- ✅ Decorative image -->
<img src="/pattern.svg" alt="" role="presentation" />
```

## Decorative vs Informative

| Image Type | `alt` Value | Example |
|------------|------------|---------|
| Informative | Descriptive text | `alt="Sales chart showing 20% growth"` |
| Decorative | Empty string `""` | `alt=""` (plus optional `role="presentation"`) |
| Functional (link/button) | Action description | `alt="Download PDF report"` |

## Rule

BANNED: `<img>` without `alt` attribute.
REQUIRED: Informative images must have descriptive `alt` text.
REQUIRED: Decorative images must have `alt=""` (empty string, not omitted).
REQUIRED: Functional images (inside links/buttons) must describe the action.
