# Anti-Pattern: images-without-dimensions

## Problem

`<img>` elements without explicit `width` and `height` attributes.
AI generates `<img src={url} alt="..." />` without dimensions.

## Why It's Bad

- Causes Cumulative Layout Shift (CLS) — page content jumps when image loads
- CLS is a Core Web Vital — poor score hurts SEO ranking
- Users accidentally click wrong elements as layout shifts
- Especially bad on slow connections where images load progressively

## Severity

MEDIUM

## Detection

```bash
grep -rn "<img\|<Image" src/ | grep -v "width\|height\|fill\|aspect-ratio"
```

## Bad Example

```tsx
// ❌ No dimensions — browser can't reserve space until image loads
<img src={user.avatarUrl} alt={user.name} />

// ❌ CSS-only sizing — no intrinsic aspect ratio hint
<img src={product.image} alt={product.name} className="w-full" />
```

## Good Example

```tsx
// ✅ Explicit dimensions — browser reserves space before load
<img
  src={user.avatarUrl}
  alt={user.name}
  width={48}
  height={48}
  className="rounded-full"
/>

// ✅ Aspect ratio via CSS when exact dimensions vary
<img
  src={product.image}
  alt={product.name}
  className="w-full aspect-video object-cover"
/>

// ✅ Next.js Image with required dimensions
<Image
  src={product.image}
  alt={product.name}
  width={600}
  height={400}
/>

// ✅ Next.js fill mode for responsive images
<div className="relative aspect-video">
  <Image src={product.image} alt={product.name} fill className="object-cover" />
</div>
```

## Additional Rules

- Hero/above-the-fold images: add `fetchPriority="high"` or `priority={true}` (Next.js)
- Below-the-fold images: add `loading="lazy"` for deferred loading
- NEVER use `loading="lazy"` on hero/banner images — delays LCP

## Rule

BANNED: `<img>` without `width`/`height` attributes or CSS `aspect-ratio`.
REQUIRED: All images must have explicit dimensions OR `aspect-ratio` CSS property.
REQUIRED: Above-the-fold images must have `fetchPriority="high"`.
REQUIRED: Below-the-fold images should have `loading="lazy"`.
