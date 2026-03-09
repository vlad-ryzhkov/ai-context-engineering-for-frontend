# Quality Gates: page-level components

Load this file only when page detection is triggered (Step 3b).

- [ ] Page auto-detected (name ends with Page/View/Route/Screen OR layer is pages/)
- [ ] Rendering context detected (Next.js App Router / Pages Router, Nuxt, SPA)
- [ ] SEO metadata present for success state (title + description + og:title minimum)
- [ ] Error and empty states include `<meta name="robots" content="noindex" />`
- [ ] No invented data in JSON-LD or OG tags (map props/API only)
- [ ] Dynamic strings sanitized before use in aria-labels / alt / meta
