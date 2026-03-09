# Vue Testing Patterns

## Setup

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
  },
});
```

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom';
```

## Test File Template

```typescript
// UserList.test.ts
import { render, screen, waitFor } from '@testing-library/vue';
import userEvent from '@testing-library/user-event';
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import UserList from './UserList.vue';

vi.mock('@/shared/api/users', () => ({
  fetchUsers: vi.fn(),
}));
import { fetchUsers } from '@/shared/api/users';

function createPlugins() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return { plugins: [[VueQueryPlugin, { queryClient }]] };
}

describe('UserList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('shows loading skeleton while fetching', () => {
    vi.mocked(fetchUsers).mockReturnValue(new Promise(() => {}));
    render(UserList, { props: { title: 'Team' }, ...createPlugins() });
    expect(screen.getByRole('status', { name: /loading/i })).toBeInTheDocument();
  });

  it('shows error message when fetch fails', async () => {
    vi.mocked(fetchUsers).mockRejectedValue(new Error('Network error'));
    render(UserList, { props: { title: 'Team' }, ...createPlugins() });
    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
  });

  it('shows empty state when no users returned', async () => {
    vi.mocked(fetchUsers).mockResolvedValue([]);
    render(UserList, { props: { title: 'Team' }, ...createPlugins() });
    expect(await screen.findByText(/no users found/i)).toBeInTheDocument();
  });

  it('renders user list when data available', async () => {
    vi.mocked(fetchUsers).mockResolvedValue([
      { id: '1', name: 'Alice', email: 'alice@example.com' },
      { id: '2', name: 'Bob', email: 'bob@example.com' },
    ]);
    render(UserList, { props: { title: 'Team' }, ...createPlugins() });
    expect(await screen.findByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.getByRole('list')).toBeInTheDocument();
  });

  it('retries fetch when retry button clicked', async () => {
    const user = userEvent.setup();
    vi.mocked(fetchUsers).mockRejectedValueOnce(new Error('fail'));
    vi.mocked(fetchUsers).mockResolvedValue([]);
    render(UserList, { props: { title: 'Team' }, ...createPlugins() });
    await screen.findByRole('alert');
    await user.click(screen.getByRole('button', { name: /retry/i }));
    await waitFor(() => {
      expect(fetchUsers).toHaveBeenCalledTimes(2);
    });
  });
});
```

## Pinia in Tests

Components that use Pinia stores require `createTestingPinia` from `@pinia/testing`.

```typescript
import { render, screen } from '@testing-library/vue';
import { createTestingPinia } from '@pinia/testing';
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query';
import { vi } from 'vitest';
import UserProfile from './UserProfile.vue';
import { useUserStore } from '@/shared/stores/user';

function createPlugins(piniaState?: Record<string, unknown>) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return {
    plugins: [
      [VueQueryPlugin, { queryClient }],
      createTestingPinia({
        createSpy: vi.fn,
        initialState: piniaState,
      }),
    ],
  };
}

describe('UserProfile', () => {
  it('renders user name from store', () => {
    render(UserProfile, {
      ...createPlugins({ user: { currentUser: { id: '1', name: 'Alice' } } }),
    });
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });

  it('calls setUser action on save', async () => {
    const user = userEvent.setup();
    render(UserProfile, { ...createPlugins() });
    // Access the store after render to assert on actions
    const store = useUserStore();
    await user.click(screen.getByRole('button', { name: /save/i }));
    expect(store.setUser).toHaveBeenCalledTimes(1);
  });
});
```

```text
REQUIRED: createTestingPinia({ createSpy: vi.fn }) — wraps store actions with vitest spies.
REQUIRED: Pass initialState to seed the store with test data — never mutate store directly.
BANNED: Importing and calling store methods directly in tests to set up state — use initialState.
NOTE: createTestingPinia stubs ALL actions by default; assert they were called, not their side effects.
```

## Key Rules

- Use `@testing-library/vue` (not `@vue/test-utils` directly)
- Pass plugins via `render(Component, { plugins: [...] })`
- Create `QueryClient` fresh per test or `beforeEach` to avoid cache pollution
- Use `findBy*` for async elements; `getBy*` for immediately-present elements
- Use `userEvent.setup()` for interactions
- Mock at module level, reset in `beforeEach`
- Do NOT directly access `wrapper.vm` — test behavior via DOM
