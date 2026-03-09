# Fonts and Assets Convention

<!-- Fill in after project setup -->
<!-- Fonts: e.g. Google Fonts via next/font, self-hosted, or CDN -->
<!-- Images: e.g. Vite asset pipeline, next/image, or CDN -->
<!-- SVGs: e.g. SVGR plugin, Iconify (see icons.md), or inline -->
<!-- Static: e.g. public/ directory for unprocessed assets -->

Fonts: self-hosted via `src/app/styles/fonts.css` — no Google Fonts CDN in production
Images: processed by Vite asset pipeline — import into components, never reference `/public` paths in JS
SVGs: use Iconify (see `icons.md`) — raw SVG imports forbidden except for logo/brand assets
Static: `public/` directory for unprocessed assets (favicons, robots.txt, og-images)
Notes: |

- Font files go in `public/fonts/` with `font-display: swap`
- Image optimization: use `vite-imagetools` for responsive images in Vite projects
- For Next.js: use `next/image` with explicit `width` and `height` — never unoptimized
