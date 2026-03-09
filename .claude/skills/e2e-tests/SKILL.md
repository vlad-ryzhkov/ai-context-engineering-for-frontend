---
name: e2e-tests
description: Generate Playwright E2E tests for a user flow. Framework-agnostic (tests run in the browser, not against framework internals). Focus on critical user journeys. Do not use for component-level unit tests — use /component-tests instead.
allowed-tools: "Read Write Edit Glob Grep Bash(npx playwright*) Bash(cat*)"
disable-model-invocation: true
agent: agents/engineer.md
context: fork
---

## SYSTEM REQUIREMENTS

Before execution the agent MUST load: `.claude/protocols/gardener.md`

---

# E2E Tests Generator — Playwright

Generates Playwright E2E tests for critical user flows. Tests run in a real browser (Chromium by default). Focus: user-visible behavior, not implementation details. Produces stable, maintainable, accessible tests.

## Input

```text
Usage: /e2e-tests [flow-description] [base-url?] [--auth] [--mock] [--visual]
Example: /e2e-tests "User logs in and views dashboard" http://localhost:5173 --auth
```

Default base URL: `http://localhost:5173` (Vite dev server).

| Flag       | Effect                                                          |
|------------|-----------------------------------------------------------------|
| `--auth`   | Generate `e2e/auth/setup.ts` + storageState session reuse       |
| `--mock`   | Generate `page.route()` stubs for unstable backend APIs         |
| `--visual` | Add `toHaveScreenshot()` for critical UI components (opt-in)    |

## Protocol

### BANNED

- Hardcoded waits: `page.waitForTimeout(2000)` — FORBIDDEN (use `waitForURL`, `waitForSelector`, `expect(locator).toBeVisible()`)
- Hardcoded credentials: `'user@example.com'` / `'password123'` — FORBIDDEN; use `process.env.TEST_USER` / `process.env.TEST_PASS` or a data factory
- `page.locator('.css-class')` — BANNED except as absolute Last Resort with comment `// LAST RESORT: no role/label/testid available`
- Testing internal state (localStorage, Vuex/Pinia internals) — test what user SEES
- Duplicate selectors defined inline in each test — use Page Object Model

## Selector Hierarchy

The agent MUST follow this priority order strictly:

```text
1. getByRole        — semantic, most stable
2. getByLabel       — form fields
3. getByPlaceholder — inputs without visible label
4. getByTestId      — data-testid attribute
5. getByText        — visible text (avoid for dynamic content)
6. locator(css)     — LAST RESORT only; requires comment
```

## Test Structure

```text
e2e/
├── {flow-name}.spec.ts
├── auth/
│   └── setup.ts              # storageState generation (--auth flag)
├── fixtures/
│   └── data.ts               # data factories (unique strings / faker)
├── components/
│   └── {Name}.component.ts   # shared component objects (nav, table, modal)
└── pages/
    └── {Name}.page.ts        # page objects (extend BasePage)
```

## BasePage Template

Every Page Object MUST extend `BasePage`:

```typescript
// e2e/pages/BasePage.ts
import type { Page } from '@playwright/test';
import { expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

export abstract class BasePage {
  constructor(protected page: Page) {}

  async waitForReady() {
    await this.page.waitForLoadState('networkidle');
  }

  async checkA11y() {
    const results = await new AxeBuilder({ page: this.page }).analyze();
    expect(results.violations).toEqual([]);
  }
}
```

`checkA11y()` is called **explicitly** in tests — not auto-injected. Keeps simple tests simple.

## Page Object Model Template

```typescript
// e2e/pages/LoginPage.ts
import type { Page } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async goto() {
    await this.page.goto('/login');
    await this.waitForReady();
  }

  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Sign in' }).click();
  }
}
```

## Data Factories

```typescript
// e2e/fixtures/data.ts
export const testUser = () => ({
  email: `test-${Date.now()}@example.com`,
  password: process.env.TEST_PASS ?? 'Secure123!',
});
```

Replace ALL hardcoded credential strings with `testUser()` calls.

## Test Template

```typescript
// e2e/user-login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { testUser } from './fixtures/data';

test.describe('User login flow', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page);
    const user = testUser();
    await loginPage.goto();
    await loginPage.login(user.email, user.password);
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
  });

  test('invalid credentials shows error message', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('bad@invalid.test', 'wrongpass');
    await expect(
      page.getByRole('alert', { name: /invalid/i })
    ).toBeVisible();
  });
});
```

## Auth Storage State (`--auth` flag)

When `--auth` is passed, generate global setup to avoid re-authenticating per test:

```typescript
// e2e/auth/setup.ts
import { chromium } from '@playwright/test';

async function globalSetup() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('/login');
  await page.getByLabel('Email').fill(process.env.TEST_USER!);
  await page.getByLabel('Password').fill(process.env.TEST_PASS!);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: 'e2e/auth/auth.json' });
  await browser.close();
}
export default globalSetup;
```

Add to `playwright.config.ts`:

```typescript
use: {
  storageState: 'e2e/auth/auth.json',
},
globalSetup: './e2e/auth/setup.ts',
```

`auth.json` MUST be in `.gitignore`.

## Network Mocking (`--mock` flag)

When `--mock` is passed and the flow depends on external API calls:

```typescript
// Intercept unstable API — add inside test or Page Object method
await page.route('**/api/orders', route =>
  route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify({ orders: [{ id: '1', status: 'delivered' }] }),
  })
);
```

Add mocks **only** for APIs identified as unstable or external in the described flow.

## Workflow

1. **Discover** — read `playwright.config.ts`; check if `e2e/auth/auth.json` exists
2. **Plan** — identify 3-5 critical paths; decide if `--auth` / `--mock` are needed based on flow
3. **Generate** — test file + Page Objects + fixtures + BasePage
4. **Run** — `npx playwright test {file} --reporter=list 2>&1 | tail -30`
5. **Fix** — on failure: read trace screenshot via `cat` → update selector (max 3 iterations). After 3 failed fix attempts → output `🛑 LOOP_GUARD_TRIGGERED: [selector/assertion]` and PAUSE for user input
6. **A11y** — if page has forms or interactive elements: add `checkA11y()` assertions
7. **Gardener** → SKILL COMPLETE

## Quality Gates

- [ ] No hardcoded `waitForTimeout`
- [ ] No hardcoded credentials (use env vars or data factory)
- [ ] Selectors follow hierarchy (role → label → placeholder → testid → text → css last resort)
- [ ] Page Objects extend `BasePage`
- [ ] `testUser()` factory used for all credential strings
- [ ] `auth.json` added to `.gitignore` (if `--auth`)
- [ ] A11y check added for pages with forms or interactive widgets
- [ ] Tests pass `npx playwright test` (against running dev server)

**Gardener Protocol**: Call `.claude/protocols/gardener.md` before SKILL COMPLETE.

## Completion Contract

```text
✅ SKILL COMPLETE: /e2e-tests
├─ Artifacts: [e2e/{flow}.spec.ts + Page Objects + fixtures?]
├─ Flow: [description]
├─ Tests: [N total]
├─ A11y: [violations: 0 | skipped]
└─ Run: [PASS | FAIL | SKIPPED (dev server not running)]
```
