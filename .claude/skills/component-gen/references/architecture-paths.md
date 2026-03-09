# Architecture Path Resolution

## Detection Priority

Path resolution follows strict priority order:

```text
1. --path <dir>        ← explicit override, highest priority
2. Scout report        ← audit/fe-repo-scout-report_*.md → §2 Architecture → Pattern
3. CLAUDE.md           ← ## Project Structure → detect architecture keyword
4. Auto-detect         ← ls src/ → match against known directory signatures
5. Fallback: FSD       ← backward compatible default
```

## Architecture Detection Heuristics

### FSD (Feature-Sliced Design)

Signature directories (3+ present = FSD):

```text
src/app/
src/pages/
src/widgets/
src/features/
src/entities/
src/shared/
```

Import rule: layers import ONLY from strictly lower layers. Cross-layer imports FORBIDDEN.

### Layer-based

Signature directories:

```text
src/components/
src/hooks/
src/utils/ OR src/lib/
src/services/ OR src/api/
src/types/
```

No `src/features/`, `src/entities/`, `src/widgets/` present.

### Domain-based

Signature directories:

```text
src/{domain}/components/
src/{domain}/hooks/
src/{domain}/services/
src/shared/ OR src/common/
```

Multiple domain directories with internal `components/` subfolders.

### App Router (Next.js)

Signature directories:

```text
app/              OR src/app/
app/(routes)/     OR app/(groups)/
src/components/
```

`next.config.*` present. Colocation inside `app/` route segments.

## Path Templates

### --type feature

| Architecture | Output path |
|---|---|
| FSD | `src/{layer}/{slice}/ui/{Name}/` |
| Layer-based | `src/components/{Name}/` |
| Domain-based | `src/{domain}/components/{Name}/` |
| App Router | `src/components/{Name}/` |
| Custom (--path) | `{path}/{Name}/` |

### --type ui

| Architecture | Output path |
|---|---|
| FSD | `src/shared/ui/{Name}/` |
| Layer-based | `src/components/ui/{Name}/` |
| Domain-based | `src/components/ui/{Name}/` |
| App Router | `src/components/ui/{Name}/` |
| Custom (--path) | `{path}/{Name}/` |

## FSD Layer Rules (FSD architecture only)

FSD `{layer}` resolution for `--type feature`:

| Component semantics | Target layer |
|---|---|
| Route-level page | `pages` |
| Composite block (header, sidebar, feed) | `widgets` |
| User action (auth, checkout, filter) | `features` |
| Business object (user, product, order) | `entities` |

Non-FSD architectures do NOT create separate `model/`, `api/` subdirectories — co-locate all files in the component directory.

## Scout Report Integration

If `audit/fe-repo-scout-report_*.md` exists, read §2 Architecture:

```text
Pattern: [FSD | Layer-based | Domain-based | Flat | Custom]
```

Use the detected pattern for path resolution. If Pattern is `Custom` or not recognized, fall through to auto-detect (priority 4).
