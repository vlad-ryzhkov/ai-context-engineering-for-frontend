---
globs: "*.test.ts, *.test.tsx, *.spec.ts, *.spec.tsx"
---

# Testing Conventions

- Selectors: use `getByRole`, `getByLabelText`, `getByText` — NEVER `querySelector` or `getByTestId` as first choice
- Structure: Arrange-Act-Assert (AAA) pattern
- Async: always `await` user events and assertions
- Mocking: mock at module boundary (API calls, stores), never mock implementation details
- Coverage: test all 4 async states (loading, error, empty, success) for feature components
- A11y: every test file for a component should include at least one `axe` or manual ARIA assertion
- Naming: `describe('ComponentName')` → `it('renders [state] when [condition]')`
