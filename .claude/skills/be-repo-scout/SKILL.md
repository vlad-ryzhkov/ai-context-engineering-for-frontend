---
name: be-repo-scout
description: Scans a backend repository (Go, Python, Node.js, Java/Kotlin), excavates API contracts, validation rules, error maps, and entity models, and produces TypeScript interfaces, Zod schemas, and error constant maps for frontend developers. Use when integrating a new backend service. Do not use for frontend repositories — use /fe-repo-scout for those.
allowed-tools: "Read Glob Grep Bash(ls*) Bash(wc*) Bash(jq*) Bash(yq*)"
agent: agents/engineer.md
context: fork
auto-invoke: false
---

# /be-repo-scout — Backend API Contract Excavator for Frontend

<purpose>
Deep scanning of a backend repository → structured report on API surface, TypeScript contracts,
Zod validation schemas, error constant maps, auth setup, entity models, and local dev environment.
Gives frontend developers everything needed to integrate a backend service: generated .d.ts interfaces,
ready-to-paste Zod schemas, typed error maps, and state machine types.
</purpose>

## Scope (SINGLE AUTHORITY)

**be-repo-scout is the ONLY skill responsible for initial backend repository discovery.**

- It reads, catalogs, and extracts API contracts, validation rules, and entity shapes.
- It generates TypeScript interfaces, Zod schemas, error constants, and BFF opportunity analysis.
- It NEVER evaluates code quality, suggests backend improvements, or generates test code.
- It NEVER generates test files, test blueprints, or QA metrics.

**Out of Scope (NEVER do these):**

- Test generation, QA planning, or test coverage analysis
- Architecture pattern detection or diagram generation
- Code quality evaluation or improvement suggestions
- Execution of external scripts or dependency installation

## When to Use

- First integration with a new backend service
- Before `/api-bind` — to understand the full API surface including undocumented endpoints
- When OpenAPI spec is missing or incomplete — this skill excavates the real contract from code
- Periodic audit: "what changed in the API surface or entity shapes?"

## When NOT to Use

- Frontend/mobile repositories (use `/fe-repo-scout`)
- QA automation planning (use `/be-repo-scout` from the QA template)
- Code review

## Analysis Anti-Patterns (NEVER DO)

| Anti-Pattern | Why Skipped |
|-------------|-------------|
| Line count (cloc) | Useless for contract extraction |
| Cyclomatic complexity | QA concern, not FE concern |
| Architecture pattern detection (MVC, DDD) | Folder naming is irrelevant — routes and models matter |
| Test file census | FE doesn't need backend test counts |
| Helm/Kustomize/Terraform deep scan | FE only needs docker-compose |

## Input Data

- Path to repository (or current directory)
- Does not require CLAUDE.md or other AI files — can be the **first step** in a new repo
- Scan mode (optional, default `full`):
  - `full` — complete 7-phase scan
  - `shallow` — skips Phase 3 (Business Logic); outputs §1–§2, §5–§6, §12 only. Use for large monorepos.

## Algorithm

## Shallow Mode Guard

**If `mode: shallow` already specified in prompt** → skip Phase 3, print once:

```text
⚡ SHALLOW MODE: Phase 3 skipped
```

Report includes §1–§2, §5–§6, §12 only.

**If `mode:` is NOT specified in prompt** → after printing TASK BRIEF, ask before Phase 1:

```text
❓ Is this a very large monorepo (hundreds of modules/services)?
   Reply `mode: shallow` to skip Business Logic extraction (saves tokens and time).
   Otherwise the full 7-phase scan starts now.
```

Wait for user response. If user replies `mode: shallow` → activate shallow mode. Any other reply → proceed with `full`.

## Verbosity Protocol

- **Output:** All analysis → artifact (MD), not chat. Chat: max 5-line summary + `📊 Full report: {path}`
- **Checkpoints:** Phase transitions + warnings only. No per-file progress.
- **Tools first:** Grep/Read → table → report. No "Now I will..." preambles.
- **Post-Check:** Inline before SKILL COMPLETE (5-7 line checklist).
- **Phases 1-7:** Silent. **Phase 7:** Summary table + report path (timestamp: `YYYYMMDD_HHMMSS`).

### Before Starting

Read `.claude/frontend_agent.md` (if present in the working project). Output:

```text
📋 TASK BRIEF
├─ Target: {repo-name} — backend API contract extraction
├─ Scope: API surface + TypeScript contracts + Zod schemas + error maps
├─ Constraint: Read-only, backend patterns only (Go / Python / Node.js / Java/Kotlin)
└─ Action: Invoking /be-repo-scout...
```

### Phase 1: File System Scan

**Goal:** Determine language, build system, directory structure.

1. **Detect language** — check build files using the detection table in `references/lang-patterns.md`:

   ```text
   Glob: go.mod, package.json, pom.xml, build.gradle.kts, build.gradle, requirements.txt, pyproject.toml, setup.py, Cargo.toml
   ```

   - Record detected language(s). If multiple → monorepo, note all.
   - If none → ⚠️ WARNING: No known build file found. Generic scan only.
   - Set **language reference file**: Go → `references/lang-go.md`, Python → `references/lang-python.md`, Node.js/TS → `references/lang-nodejs.md`, Java/Kotlin → `references/lang-jvm.md`.

2. Read primary build file for metadata:
   Per `references/lang-patterns.md` → Build Files for detected language, extract: module/package name, runtime version, key dependencies.

3. Determine structure:
   Use `references/lang-patterns.md` for detected language to identify entry-point directories and module layout.
   **Exclude from all scans:** `node_modules/`, `vendor/`, `__pycache__/`, `.venv/`, `venv/`,
   `dist/`, `build/`, `target/`, `.gradle/`, `.mvn/`, `bin/`, `obj/`, `.git/`,
   `fixtures/`, `seeds/`, `mock_data/`, `testdata/`

4. Count size:
   Record: number of source files, number of test files (for reference only — not analyzed).

5. **VCS Hotspot Analysis** (run only if `.git` directory exists):

   ```bash
   git log --pretty=format: --name-only --since="1 year ago" \
     | grep -v vendor/ | grep -v node_modules/ \
     | sort | uniq -c | sort -rg | head -10
   ```

   - Record: file path + change frequency.
   - Map hotspot files → handlers → endpoints from Phase 2 (match by file path).
   - Tag mapped endpoints as `[HOTSPOT: N changes]` in §2 API Surface Catalog.
   - If `.git` absent → skip silently.

### Phase 2: API Surface Discovery

**Goal:** Find and catalog ALL API endpoints.

#### 2.1 OpenAPI / Swagger

Search for files:

```text
Glob: **/swagger.json, **/swagger.yaml, **/swagger.yml, **/openapi.json, **/openapi.yaml, **/openapi.yml, **/*.swagger.json
```

For each found file:

- If file exceeds 500 lines → summarize by tags/domains. Use `cat {file} | jq '[.paths | keys[]]'` (JSON) or `yq '[.paths | keys[]]' {file}` (YAML) to extract the route list.
- Otherwise read the file fully.
- Extract endpoints: Method, Path, Description
- Note presence/absence of response schemas, error codes

#### 2.2 Protocol Buffers (gRPC)

Search for files:

```text
Glob: **/*.proto
```

For each .proto file:

- Extract services and rpc methods
- Record Request/Response types
- Note streaming type (unary / server-stream / client-stream / bidirectional)
- Extract `validate` tags on message fields (`required`, `min`, `max`, `pattern`)

#### 2.3 Route Registration (from code)

Read `references/lang-patterns.md` → section for detected language → use that language's **Grep String for Route Search**.

For each found:

- File + line
- HTTP method + path
- Handler function

⚠️ **Do not duplicate:** If endpoint already found in swagger/proto — do not add from code.

#### 2.4 HTTP Client Files

```text
Glob: **/*.http, **/api.http
```

If found — note as an additional source of examples.

#### 2.5 GraphQL

```text
Glob: **/*.graphql, **/schema.graphqls
Grep: type Query|type Mutation|ApolloServer|graphqlHTTP|GraphQLSchema|@GraphQLApi
```

If found: extract queries and mutations with types.

#### 2.6 WebSockets & SSE

Grep: `WebSocket|ws\.NewConn|websocket\.Upgrade|websocket\.Accept|gorilla/websocket`
      `EventSource|text/event-stream|SseEmitter|http\.Flusher|socket\.io`

If found:

- Record each endpoint: path, protocol (WS/WSS/SSE), handler function
- Extract event types emitted (structs passed to WriteMessage / json.NewEncoder(w).Encode)
- Note auth mechanism (WS handshake header vs query param)
- Mark as [WS] in §2 API Surface Catalog

#### 2.7 Business Domain Grouping

After cataloging all endpoints, group them into 3–8 high-level business domains
(e.g., "User Management", "Billing", "Order Processing", "Catalog", "Auth").

- If < 5 endpoints total → skip this step
- Domains become the organizing structure for the report

### Phase 3: Business Logic Analysis

**Goal:** Extract API contracts and business rules from handler code.

**Token-saving strategy:** Skip DTO mapping / field copying blocks. Focus on conditional branches, error returns, validation calls, auth checks.

**Reference:** `references/lang-patterns.md` → Handler Patterns, Error Patterns, Validation Patterns, Auth/Middleware Patterns for detected language.

**Read `references/phase3-analysis.md`** — execute sub-steps §3.0–§3.8 in order (skip §3.9–§3.11 which are QA-only). All output targets, conditional guards, and grep patterns are defined there.

### Phase 4: Local Dev Setup Extraction

**Goal:** Extract everything a frontend developer needs to run the backend locally.

1. **Token / Auth config:** Search for token setup in config files, env vars, CI scripts. Record:
   - Token format (JWT, API key, gRPC metadata)
   - Header names and formats (e.g., `Authorization: Bearer {jwt}`)
   - Token generation commands or examples
   - Which endpoints require which token type

2. **docker-compose extraction:**
   - Find `docker-compose.yml` / `docker-compose.yaml`
   - Record: services, ports, required env vars, volume mounts
   - Identify which services the backend depends on (DB, Redis, etc.)

3. **Env vars for FE:**
   - Scan `.env.example`, `README.md`, config files for base URL, WS URL
   - Map to FE env var conventions: `VITE_API_URL`, `VITE_WS_URL`, `VITE_API_KEY`

4. **Mock server options:**
   - Check if MSW (msw) or json-server is already in the project
   - List which endpoints have fixtures/seeds suitable for mocking

5. Output: generates `audit/fe-local-setup.md` using `references/fe-local-setup-template.md` if token config + setup commands found.

### Phase F1: TypeScript Contract Generation

**Goal:** Generate TypeScript interfaces for every request/response shape discovered in Phase 3.6.

For each entity / response shape found:

1. Emit a TypeScript `interface` with:
   - All fields with correct TypeScript types (string, number, boolean, null, Array<T>)
   - JSDoc `@example` annotation with a realistic example value
   - Optional fields marked with `?`
2. Map backend types to TypeScript:
   - `int32`/`int64` → `number`
   - `string UUID` → `string` (add JSDoc `@format uuid`)
   - `timestamp`/`datetime` → `string` (add JSDoc `@format iso8601`)
   - Enum → TypeScript `type` union string literal
3. Flag `[TYPE_MISMATCH]` where proto/ORM type differs from handler type (e.g., proto `int32` but code parses as `int64`)
4. Use code gen templates from `references/fe-codegen-templates.md`

### Phase F2: Zod Schema Generation

**Goal:** From Phase 3.2 validation rules, emit ready-to-paste Zod schemas.

For each endpoint with validation rules:

1. Emit a `z.object({...})` covering:
   - Required fields: `z.string()`, `z.number()`, etc.
   - Optional fields: `.optional()` or `.nullable()`
   - Length constraints: `.min(N).max(M)`
   - Regex patterns: `.regex(/pattern/)`
   - Enum values: `z.enum([...])`
   - Cross-field rules: `.refine(...)` with descriptive message
2. Tag `[UNDOCUMENTED]` rules not present in OpenAPI/proto — these are invisible to spec-only generation
3. Use Zod schema templates from `references/fe-codegen-templates.md`

### Phase F3: Error Constants Map

**Goal:** From Phase 3.3, emit a TypeScript `const` error map.

1. Emit:

   ```typescript
   export const API_ERRORS = {
     ERROR_CODE: { httpStatus: 400, message: "Human-readable message" },
   } as const satisfies Record<string, { httpStatus: number; message: string }>;
   ```

2. Classify each error for UI treatment:
   - `field` — show under specific form field
   - `toast` — show as notification
   - `screen` — replace current view (401, 403, 404, 500)
3. Flag missing codes: backend throws it in code, but has no named constant → `[MISSING_CONSTANT]`

### Phase F4: BFF Opportunity Analysis

**Goal:** Detect pages that need N+1 endpoint calls and flag as BFF candidates.

1. Detect "N+1 endpoint" patterns from domain grouping:
   - If a realistic page/feature would require 3+ unrelated entities fetched independently → flag as `[BFF_CANDIDATE]`
2. For each candidate: list entities required and suggest an aggregation endpoint name
3. Detect chatty patterns: single-item fetches inside list iterations

### Phase F5: Undocumented API Discovery

**Goal:** Surface hidden API behavior for frontend developers.

1. Query params in handler code but NOT in OpenAPI/proto → tag `[HIDDEN_PARAM]`
2. Admin/internal endpoints accessible from the public API → tag `[HIDDEN_ENDPOINT]`
3. Feature flags / A/B testing parameters → tag `[FEATURE_FLAG]`
4. Undocumented response fields (present in code but absent from swagger schema) → tag `[HIDDEN_FIELD]`

### Phase 7: Report Generation

Compile the report and save to `audit/be-repo-scout-report_{timestamp}.md` (timestamp format: `YYYYMMDD_HHMMSS`). Full report template — in `references/report-template.md`.

**Required sections (always present):**

1. Repository Profile (module, language version, service type, dependencies)
2. API Surface Catalog (REST + gRPC + GraphQL endpoints with Summary)
3. Validation Rules (endpoint × field × rule × error code) + Zod schema snippets
4. Error Mapping + TypeScript error constants map
5. Auth & Access Control (header names, token format, auth matrix)
6. Specification Inventory (coverage formula + exact relative file paths to all spec files)
7. TypeScript Contracts (generated interfaces per entity)
8. Zod Schemas (generated zod objects per endpoint input)
9. Local Dev Setup (docker-compose, env vars, token setup)

**Conditional sections (include only if data found):**
9. State Transition Matrix (from Phase 3.5) + TypeScript state union types
10. Entity & Data Model (from Phase 3.6) — response shapes, ID types, pagination
11. Behavioral Nuances + Hidden Params (from Phase 3.7) + `[HIDDEN_PARAM]` tags
13. BFF Opportunities (from Phase F4) + `[BFF_CANDIDATE]` analysis
14. Contract Mismatch Report (from Phases F1–F5) + `[TYPE_MISMATCH]` table

**Local Dev Onboarding (conditional):** If Phase 4 extracted token config + setup commands →
also save `audit/fe-local-setup.md` using `references/fe-local-setup-template.md`.
Print path in SKILL COMPLETE block.

## Quality Gates

- [ ] Build file for detected language found and parsed
- [ ] All proto files read and RPCs cataloged
- [ ] All swagger/openapi files read and endpoints cataloged
- [ ] Endpoint counts are correct (formula shown)
- [ ] Handler analysis performed for all discovered endpoints
- [ ] Error constants cataloged with TypeScript error map generated
- [ ] Auth header names and token formats documented
- [ ] No placeholders `{xxx}` in the final report (except "none")
- [ ] §7: At least one TypeScript interface generated per major entity
- [ ] §8: At least one Zod schema generated per POST/PUT/PATCH endpoint
- [ ] §4: TypeScript error const map generated with UI treatment classification
- [ ] §11: If state enums found → TypeScript union types generated
- [ ] §3: Code-level validations without proto/swagger counterpart flagged as `[UNDOCUMENTED]`
- [ ] §13: If N+1 patterns found → `[BFF_CANDIDATE]` entries present
- [ ] §14: `[TYPE_MISMATCH]` table present if cross-layer type inconsistencies found
- [ ] §12: docker-compose services and ports extracted
- [ ] §12: FE env vars (VITE_API_URL, VITE_WS_URL) mapped
- [ ] §2: WebSocket/SSE endpoints marked [WS], excluded from REST count
- [ ] §2: Business Domain Map present if total endpoints > 5
- [ ] shallow mode: Phase 3 skipped when mode=shallow specified
- [ ] fe-local-setup.md generated if Phase 4 has token config + setup commands
- [ ] §1: VCS hotspot analysis run (if .git present)

## Self-Check

Before saving the report, verify:

- [ ] **Completeness:** All required sections filled? Conditional §9–§14 present if data found?
- [ ] **Accuracy:** Endpoint counts match between §2 and §6?
- [ ] **No Hallucinations:** Each interface field actually found in a file (source specified)?
- [ ] **Validation Rules:** Zod schemas cover all validation constraints found in code?
- [ ] **Error Map:** Covers all error constants found in code with UI treatment assigned?
- [ ] **Auth:** Header name and format extracted for each auth mechanism?
- [ ] **Type Contracts:** Every `[TYPE_MISMATCH]` has a specific field, proto type, and code type?
- [ ] **BFF:** Each `[BFF_CANDIDATE]` has entity list and suggested endpoint name?
- [ ] **Domain Map:** endpoint count per domain sums to §2 API totals?

## Completion

After saving `audit/be-repo-scout-report_{timestamp}.md`:

**Gardener Protocol**: Call `.claude/protocols/gardener.md`. If you identified missing rules
or inefficiencies during this run, output a brief proposal table. Otherwise: `🌱 Gardener: No updates needed.`

Then print `SKILL COMPLETE` block.

```text
✅ SKILL COMPLETE: /be-repo-scout
├─ Artifacts: audit/be-repo-scout-report_{timestamp}.md — Each invocation creates a new timestamped file
├─ Local Dev: audit/fe-local-setup.md — {generated / skipped (insufficient env data)}
├─ Self-Review: N/A (scanning)
├─ Endpoints: {N REST} + {M gRPC} + {K GraphQL} = {total}
├─ TS Contracts: {N interfaces} + {M state unions} + {K enum types}
├─ Zod Schemas: {N schemas} with {M [UNDOCUMENTED] rules}
├─ Error Map: {N error codes} — {field: N} + {toast: N} + {screen: N}
├─ BFF Candidates: {N [BFF_CANDIDATE] patterns}
└─ Mismatches: {N [TYPE_MISMATCH]} + {M [HIDDEN_PARAM]} + {K [HIDDEN_ENDPOINT]}
```

---

## Related Files

- Language patterns (index): `references/lang-patterns.md`
- Language patterns (per-lang): `references/lang-go.md`, `references/lang-python.md`, `references/lang-nodejs.md`, `references/lang-jvm.md`
- Phase 3 sub-steps: `references/phase3-analysis.md` (§3.0–§3.8 + FE extraction rules)
- Report template: `references/report-template.md` (§1–§8 required, §9–§14 conditional)
- Local dev template: `references/fe-local-setup-template.md` (generates `audit/fe-local-setup.md`)
- Code gen templates: `references/fe-codegen-templates.md` (TS interfaces, Zod, error map)
- Downstream: `/api-bind` (reads §2+§7 for type generation), `/component-gen` (reads §9–§10 for state-aware UI)
