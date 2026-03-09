# SEO Protocol — SPA (React / Vue)

Load this file only when page detection is triggered (component name ends with Page/View/Route/Screen OR layer is `pages/`).

## Metadata by State

| State | Metadata |
|-------|----------|
| Success | `title = "${entity.name} \| App"`, `description = entity.summary[:160]`, `og:title`, `og:description`, `og:image` (only if `imageUrl` in props) |
| Error | `title = "Error \| App"`, `<meta name="robots" content="noindex" />` |
| Empty | `title = "Not Found \| App"`, `<meta name="robots" content="noindex" />` |
| Loading | No dynamic meta — inherit route defaults |

## Rendering Context → Implementation

| Context | Implementation |
|---------|---------------|
| React — SPA / Vite | `document.title` assignment (only in page component) |
| Vue — Nuxt | `useSeoMeta()` composable |
| Vue — SPA / Vite | `useHead()` from `@vueuse/head` if installed; else `document.title` |

## JSON-LD (Conditional)

Generate JSON-LD **ONLY** when:

1. Component semantics match a schema.org type (`Product`, `Article`, `Event`, `Recipe`, `Person`)
2. ALL required JSON-LD fields exist in props/API response — **never invent data**

Map only fields present in the component's props or API response. Any invented value = BLOCKER.
