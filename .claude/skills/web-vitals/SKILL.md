---
name: web-vitals
description: >
  Audit Core Web Vitals and performance budget for a frontend project.
  Measures LCP (<2.5s), CLS (<0.1), INP (<200ms) against Google thresholds.
  Declares and checks JS/CSS/image budgets. Outputs prioritized fix plan.
  Use for performance audits before launch or after significant bundle changes.
  Do not use as a replacement for /fe-repo-scout — run after repo scout for focused perf analysis.
allowed-tools: "Read Glob Grep Bash(npx*) Bash(cat*) Bash(ls*) Bash(wc*) Write"
context: fork
auto-invoke: false
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# Web Vitals — Core Web Vitals & Performance Budget Audit

> **SILENT MODE**: Execute all scan phases silently. Do not output intermediate grep results or file
> lists to chat. Only the final report path and SKILL COMPLETE block go to chat.

<purpose>
Audits a frontend project for Core Web Vitals compliance and performance budget adherence.
Produces a prioritized fix plan with file-level recommendations.
</purpose>

## Performance Budget (Google Standards)

| Metric | Target | Threshold | Standard |
|--------|--------|-----------|----------|
| LCP (Largest Contentful Paint) | <2.5s | <4.0s | Core Web Vitals |
| CLS (Cumulative Layout Shift) | <0.1 | <0.25 | Core Web Vitals |
| INP (Interaction to Next Paint) | <200ms | <500ms | Core Web Vitals |
| Total JS bundle | <300KB (gzip) | <500KB | Web Almanac |
| Total CSS | <50KB (gzip) | <100KB | Web Almanac |
| LCP image size | <150KB | <250KB | Lighthouse 10 |
| Total page weight | <1.5MB | <3MB | Web Almanac |

## Phase Checkpoints

```text
STOP  if: no package.json found | not a frontend project
WARN  if: no Lighthouse CI config found (lighthouserc.* or lighthouse.config.*)
WARN  if: no web-vitals package in dependencies
INFORM: framework=[detected], bundler=[vite|webpack|other], budget-status=[within|over]
```

## Algorithm (7 Phases)

### Phase 1 — Stack & Bundle Detection

```bash
cat package.json | grep -E '"vite|"webpack|"rollup|"esbuild|"web-vitals|"lighthouse'
ls dist/ build/ .next/ out/ 2>/dev/null | head -20
```

Detect:

- Build output directory
- Bundler (Vite / Webpack / other)
- `web-vitals` package present?
- Lighthouse CI configured?

**WARN if no build output directory exists** (`dist/`, `build/`, `.next/`, `out/`).
Add `WARN: Build directory not found — bundle size analysis will be skipped or estimated.`
to the report. Do NOT report `PASS` for bundle budgets when there is no build output.

### Phase 2 — Bundle Size Analysis

**Gzip rule:** `wc -c` returns raw (uncompressed) bytes. Budget thresholds in the table
are gzip-compressed sizes. Apply a **3× multiplier** when comparing raw bytes to gzip
budgets (e.g., JS budget <300KB gzip ≈ <900KB raw, CSS <50KB gzip ≈ <150KB raw).
If build directory is missing (Phase 1 WARN), skip file-size checks and mark budget
cells as `N/A — no build output`.

```bash
# Check if build dir exists before measuring
ls dist/ build/ .next/ out/ 2>/dev/null || echo "WARN_NO_BUILD"

# Check build output sizes (raw bytes — apply 3x gzip multiplier for budget comparison)
find dist build .next/static -name "*.js" -o -name "*.css" 2>/dev/null | xargs wc -c 2>/dev/null | sort -rn | head -20

# Check for unoptimized large imports
grep -rn "import.*from.*lodash\b" src/ 2>/dev/null | head -10
grep -rn "import \* as " src/ --include="*.ts" --include="*.tsx" --include="*.vue" 2>/dev/null | head -10
grep -rn "import.*from.*moment\b" src/ 2>/dev/null | head -5
```

Flag:

- JS chunks >300KB raw (~100KB gzip) → HIGH
- CSS files >90KB raw (~30KB gzip) → MEDIUM
- Total JS >900KB raw (~300KB gzip) → CRITICAL
- `lodash` (use lodash-es or tree-shakeable import) → MEDIUM
- `import * as X` (prevents tree shaking) → MEDIUM
- `moment` (use date-fns or dayjs) → HIGH (moment = ~232KB)

### Phase 3 — LCP Anti-Patterns

**Framework-aware image detection:** Search for standard `<img>` AND framework-specific
image components: `<Image>` (Next.js/Nuxt), `<NuxtImg>`, `<StaticImage>` (Gatsby).

```bash
# LCP image as CSS background (not discoverable by browser preloader)
grep -rn "background-image\|backgroundImage" src/ --include="*.tsx" --include="*.vue" --include="*.css" 2>/dev/null | head -15

# Missing preload for LCP image
grep -rn "rel=\"preload\"\|rel='preload'" public/ 2>/dev/null | head -10

# Missing loading/priority on images (standard + framework components)
grep -rn '<img\|<Image\|<NuxtImg\|<StaticImage' src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep -v "loading=\|priority\|fetchPriority" | head -15

# Render-blocking resources
grep -rn '<link.*stylesheet\|<script.*src=' public/index.html index.html 2>/dev/null | grep -v "async\|defer\|type=\"module\"" | head -10
```

Flag:

- LCP candidate in `background-image` → CRITICAL (browser can't preload it)
- No `<link rel="preload">` for hero image → HIGH
- `<img>` / `<Image>` / `<NuxtImg>` without `loading` or `priority` attribute → MEDIUM
- Render-blocking `<link>` or `<script>` in `<head>` → HIGH

### Phase 4 — CLS Anti-Patterns

```bash
# Images without explicit dimensions (cause layout shift) — standard + framework components
grep -rn '<img\|<Image\|<NuxtImg' src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep -v 'width=\|height=\|aspect-ratio\|fill' | head -15

# Dynamic content insertion above fold (skeleton vs no skeleton)
grep -rn "isLoading\|isPending\|loading" src/ --include="*.tsx" --include="*.vue" -l 2>/dev/null | xargs grep -L "skeleton\|Skeleton\|shimmer\|Shimmer" 2>/dev/null | head -10

# Font causing FOUT/FOIT (no font-display)
grep -rn "font-display" src/ public/ 2>/dev/null | head -5
grep -rn "@font-face\|font-face" src/ public/ 2>/dev/null | grep -v "font-display" | head -5
```

Flag:

- `<img>` without `width`/`height` or `aspect-ratio` → HIGH (layout shift on load)
- Async component missing skeleton → MEDIUM (content shift on load)
- `@font-face` without `font-display: swap` or `optional` → MEDIUM (FOUT)

### Phase 5 — INP Anti-Patterns

**Noise reduction:** Simple `.filter`/`.reduce` on small arrays is not an INP problem.
Focus on genuinely heavy synchronous work: nested loops, `JSON.parse` of large payloads,
`useLayoutEffect` blocking paint, and missing debounce on high-frequency inputs.

```bash
# Synchronous blocking: JSON.parse/stringify in render path (HIGH — blocks main thread)
grep -rn "JSON\.parse\|JSON\.stringify" src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep -v "useMemo\|computed\|useCallback\|worker\|Worker" | head -10

# useLayoutEffect (synchronous, blocks paint — verify necessity)
grep -rn "useLayoutEffect" src/ --include="*.tsx" 2>/dev/null | head -10

# Heavy sorting/mapping in render without memoization (only flag .sort — mutates + often O(n log n))
grep -rn "\.sort(" src/ --include="*.tsx" --include="*.vue" 2>/dev/null | grep -v "useMemo\|computed\|useCallback" | head -10

# Scroll/touchmove listeners without passive flag (vanilla JS only — React 17+ onScroll is passive by default)
grep -rn "addEventListener.*scroll\|addEventListener.*touchmove" src/ 2>/dev/null | grep -v "passive" | head -10

# React re-renders on every keystroke without debounce
grep -rn "onChange.*setState\|onChange.*setSearch\|onChange.*setValue" src/ --include="*.tsx" 2>/dev/null | head -10

# Vue v-model on search/filter without debounce
grep -rn "v-model.*search\|v-model.*filter\|v-model.*query" src/ --include="*.vue" 2>/dev/null | head -10
```

Flag:

- `JSON.parse`/`JSON.stringify` in render path without memoization → HIGH
- `useLayoutEffect` usage → MEDIUM (verify: necessary for DOM measurement, or replaceable with `useEffect`?)
- `.sort()` in render without `useMemo`/`computed` → MEDIUM
- `scroll`/`touchmove` `addEventListener` without `{ passive: true }` → HIGH (vanilla JS only; note React 17+ synthetic `onScroll` is passive by default)
- Input `onChange`/`v-model` without debounce for search → MEDIUM

### Phase 6 — Lighthouse Config Check

```bash
ls lighthouserc.js lighthouserc.json lighthouserc.yaml .lighthouserc lighthouse.config.js 2>/dev/null
cat lighthouserc.* 2>/dev/null | head -40
```

If no Lighthouse config found:

- Recommend adding Lighthouse CI with budget assertions
- Generate config template (see Completion Contract)

### Phase 7 — web-vitals Package Integration

```bash
grep -rn "web-vitals\|getCLS\|getLCP\|getINP\|getFID\|getTTFB" src/ 2>/dev/null | head -10
```

If `web-vitals` package exists but no instrumentation found → MEDIUM (metrics not tracked in production).

---

## Output: Performance Report

Save to `audit/web-vitals-report_{YYYYMMDD_HHMMSS}.md`

### Report Template

```markdown
# Web Vitals Report — {date}

## Budget Status

| Metric | Target | Status | Notes |
|--------|--------|--------|-------|
| LCP | <2.5s | [PASS/WARN/FAIL] | [evidence] |
| CLS | <0.1 | [PASS/WARN/FAIL] | [evidence] |
| INP | <200ms | [PASS/WARN/FAIL] | [evidence] |
| JS Bundle | <300KB | [PASS/WARN/FAIL] | [actual size] |
| CSS | <50KB | [PASS/WARN/FAIL] | [actual size] |

## Critical Findings

[snippet → why → fix triple per finding — same format as Auditor]

## Prioritized Fix Plan

| Priority | Finding | File | Estimated Impact |
|----------|---------|------|-----------------|
| P0 | [finding] | [file] | LCP −Xs |
| P1 | ... | ... | ... |

## Lighthouse CI Config (if missing)

[Generated lighthouserc.json with budget assertions]
```

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Quality Gate

- [ ] All 7 phases completed (or explicitly skipped with reason)
- [ ] Budget table populated with actual or estimated values
- [ ] Every HIGH finding has a concrete file reference + fix
- [ ] Report written to `audit/web-vitals-report_{timestamp}.md`
- [ ] No intermediate grep output in chat (SILENT MODE)

## Completion Contract

```text
✅ SKILL COMPLETE: /web-vitals
├─ Report: audit/web-vitals-report_{YYYYMMDD_HHMMSS}.md
├─ Framework: [detected]
├─ Budget: [PASS | WARN: N over budget | FAIL: N critical]
├─ Findings: [N critical / N high / N medium]
└─ Top fix: [single most impactful recommendation]
```
