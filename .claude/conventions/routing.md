# Routing Convention

<!-- Fill in after project setup -->
<!-- Router: e.g. Vue Router 4 / React Router 6 / Next.js App Router -->
<!-- Pattern: e.g. config-based vs file-based -->
<!-- Auth guard: e.g. route meta + navigation guard -->
<!-- Code splitting: e.g. lazy() / defineAsyncComponent() per page -->

Router: <!-- Vue Router 4 | React Router 6 | Next.js App Router -->
Pattern: config-based — all routes defined in `src/app/router/`
Auth guard: route meta `requiresAuth: true` + global navigation guard in `src/app/router/guards.ts`
Code splitting: lazy-loaded per page — `lazy(() => import('@/pages/...'))` / `defineAsyncComponent`
Notes: |

- Page components live in `src/pages/` (FSD)
- Route params typed via `useTypedParams` wrapper — never use untyped `useParams`
- Redirects after auth handled in guard, not in components
- 404 page: REQUIRED — define a catch-all route (`path: '*'` / `path: '/:pathMatch(.*)*'`) rendering a dedicated NotFound page
- Scroll restoration: REQUIRED — enable `scrollBehavior` (Vue Router) or `<ScrollRestoration />` (React Router) so navigating back restores scroll position
