# Micro-Frontend CSS Leak

## Problem

CSS styles from one micro-frontend bleeding into another due to global selectors, unscopied class names, or shared Tailwind configurations without isolation.

## Why It's Bad

- Visual regressions appear when deploying one MFE but not the other
- Debugging CSS issues requires inspecting multiple codebases
- Tailwind utility conflicts when MFEs use different config versions
- CSS specificity wars between teams

## Detection

Grep signatures:

- Global CSS selectors without scoping: `body {`, `* {`, `html {`
- Unscoped `@tailwind base` in micro-frontend (should be shell-only)
- Shared class names without prefix/namespace

## Bad Example

```css
/* ❌ mfe-checkout/styles.css — global styles leak to other MFEs */
.btn {
  background: blue;
  padding: 8px 16px;
}

h2 {
  font-size: 24px;
  margin-bottom: 16px;
}

/* ❌ Tailwind base imported in every MFE — resets conflict */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Good Example

```css
/* ✅ Scoped with CSS Modules or shadow DOM */

/* mfe-checkout/Button.module.css */
.btn {
  background: blue;
  padding: 8px 16px;
}
```

```tsx
// ✅ CSS Modules — class names are hashed, no leaks
import styles from './Button.module.css';

export function CheckoutButton() {
  return <button className={styles.btn}>Pay Now</button>;
}
```

```ts
// ✅ Tailwind with prefix per MFE
// mfe-checkout/tailwind.config.ts
export default {
  prefix: 'co-', // all classes: co-bg-blue-500, co-p-4
  important: '#mfe-checkout', // scope to container
  corePlugins: {
    preflight: false, // disable base reset — shell handles it
  },
};
```

## Isolation Strategies

| Strategy | Pros | Cons |
|----------|------|------|
| CSS Modules | Zero config, hashed names | No sharing between MFEs |
| Shadow DOM | True isolation | Harder to style, no Tailwind |
| Tailwind prefix | Familiar DX | Manual discipline required |
| CSS-in-JS (runtime) | Component-scoped | Bundle size, SSR complexity |

## References

- [CSS Containment](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment)
- [Tailwind Prefix](https://tailwindcss.com/docs/configuration#prefix)
