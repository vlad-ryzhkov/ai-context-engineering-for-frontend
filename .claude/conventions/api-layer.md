# API Layer Convention

<!-- Fill in after project setup -->
<!-- Base URL: e.g. VITE_API_BASE_URL env var -->
<!-- Auth: e.g. Bearer token in Authorization header -->
<!-- Client: e.g. HeyAPI generated client from OpenAPI spec -->
<!-- Error format: e.g. { code: string, message: string } -->

Base URL: `import.meta.env.VITE_API_BASE_URL` — never hardcode URLs in source
Auth: Bearer token via `Authorization` header — set in API client interceptor
Client: HeyAPI (`@hey-api/client-fetch`) generated from OpenAPI spec at `src/shared/api/`
Error format: `{ code: string, message: string, details?: unknown }`
Notes: |

- All API calls go through the generated typed client — never use raw `fetch` in components
- Env vars must be prefixed with `VITE_` for Vite projects
- Local dev uses `.env.local` (gitignored) — never commit `.env` with real values

## gRPC / Connect Transport (for proto-based APIs)

Base URL: `import.meta.env.VITE_GRPC_BASE_URL`
Transport: `@connectrpc/connect-web` (Connect protocol)
Fallback: gRPC-Web transport for legacy backends (`--transport=grpc-web`)
Types: Parsed from `.proto` message blocks (not openapi-ts)
Enums: `as const` object pattern (not TypeScript `enum`)
