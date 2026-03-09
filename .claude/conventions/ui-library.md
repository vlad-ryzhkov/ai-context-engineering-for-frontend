# UI Library Convention

<!-- Fill in after project setup -->
<!-- Source: e.g. shadcn/ui (https://ui.shadcn.com) -->
<!-- Package: e.g. installed via `npx shadcn@latest add <component>` -->
<!-- Usage: import from `@/shared/ui/<component>` after shadcn generation -->
<!-- Notes: never import directly from shadcn — always re-export from shared/ui -->

Source: shadcn/ui
Package: installed per-component via `npx shadcn@latest add <component>`
Usage: `import { Button } from '@/shared/ui/button'`
Notes: |

- Components live in `src/shared/ui/` after generation
- Never import from `components/ui/` path directly — re-export via `shared/ui/index.ts`
- Extend via `cn()` utility (clsx + tailwind-merge), never override base component files
