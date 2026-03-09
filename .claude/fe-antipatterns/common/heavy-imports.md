# Anti-Pattern: heavy-imports

## Problem

Non-tree-shakeable library imports that bundle the entire package instead of the used function.

## Why It's Bad

- `import moment from 'moment'` adds ~300 KB to the bundle (unminified)
- `import _ from 'lodash'` adds ~70 KB instead of ~2 KB for a single function
- Increases initial load time, hurts LCP and TTI
- Tree-shaking cannot remove unused code from CJS/namespace imports

## Detection

```bash
grep -rn "import moment\|from 'moment'\|from \"moment\"" src/
grep -rn "import lodash\|from 'lodash'" src/ | grep -v "lodash/"
grep -rn "import \* as " src/ | grep -v "node_modules"
```

## Bad Example

```tsx
// ❌ Imports entire library
import moment from 'moment';
import _ from 'lodash';

const formatted = moment(date).format('YYYY-MM-DD');
const unique = _.uniqBy(items, 'id');
```

## Good Example

```tsx
// ✅ Tree-shakeable alternatives
import { format } from 'date-fns';
import uniqBy from 'lodash/uniqBy';

const formatted = format(date, 'yyyy-MM-dd');
const unique = uniqBy(items, 'id');
```

## Common Offenders

| Library | Size (minified) | Alternative |
|---------|----------------|-------------|
| `moment` | ~72 KB | `date-fns` (~2 KB per function) or `dayjs` (~7 KB) |
| `lodash` (root) | ~25 KB | `lodash/{fn}` deep import or `lodash-es` |
| `rxjs` (root) | ~50 KB | `rxjs/operators` deep imports |

## Rule

BANNED: `import moment from 'moment'` — use `date-fns` or `dayjs`.
BANNED: `import _ from 'lodash'` or `import { x } from 'lodash'` — use `lodash/{fn}` deep imports.
REQUIRED: Verify tree-shakeability of new dependencies before adding.
