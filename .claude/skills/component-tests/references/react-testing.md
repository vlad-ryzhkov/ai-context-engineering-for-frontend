# React Testing Patterns

## Setup

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
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

```tsx
// UserList.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import UserList from './UserList';

// Mock the fetch function or API module
vi.mock('@/shared/api/users', () => ({
  fetchUsers: vi.fn(),
}));
import { fetchUsers } from '@/shared/api/users';

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

describe('UserList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('shows loading skeleton while fetching', () => {
    vi.mocked(fetchUsers).mockReturnValue(new Promise(() => {})); // never resolves
    render(<UserList title="Team" />, { wrapper: createWrapper() });
    expect(screen.getByRole('status', { name: /loading/i })).toBeInTheDocument();
  });

  it('shows error message when fetch fails', async () => {
    vi.mocked(fetchUsers).mockRejectedValue(new Error('Network error'));
    render(<UserList title="Team" />, { wrapper: createWrapper() });
    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
  });

  it('shows empty state when no users returned', async () => {
    vi.mocked(fetchUsers).mockResolvedValue([]);
    render(<UserList title="Team" />, { wrapper: createWrapper() });
    expect(await screen.findByText(/no users found/i)).toBeInTheDocument();
  });

  it('renders user list when data available', async () => {
    vi.mocked(fetchUsers).mockResolvedValue([
      { id: '1', name: 'Alice', email: 'alice@example.com' },
      { id: '2', name: 'Bob', email: 'bob@example.com' },
    ]);
    render(<UserList title="Team" />, { wrapper: createWrapper() });
    expect(await screen.findByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.getByRole('list')).toBeInTheDocument();
  });

  it('retries fetch when retry button clicked', async () => {
    const user = userEvent.setup();
    vi.mocked(fetchUsers).mockRejectedValueOnce(new Error('fail'));
    vi.mocked(fetchUsers).mockResolvedValue([]);
    render(<UserList title="Team" />, { wrapper: createWrapper() });
    await screen.findByRole('alert');
    await user.click(screen.getByRole('button', { name: /retry/i }));
    await waitFor(() => {
      expect(fetchUsers).toHaveBeenCalledTimes(2);
    });
  });
});
```

## Key Rules

- Always wrap TanStack Query components in `QueryClientProvider` with `retry: false`
- Create `queryClient` fresh inside each `describe` (or `beforeEach`) to avoid test pollution
- Use `findBy*` for async elements (waits for them to appear)
- Use `getBy*` for sync elements that should be present immediately
- Use `userEvent.setup()` for interactions (not `fireEvent`)
- Mock at module level with `vi.mock()`, reset with `vi.clearAllMocks()` in `beforeEach`

## Router Context in Tests

Components using `useNavigate`, `useParams`, `Link`, or `useLocation` require a router wrapper.
Without it, the test throws: `useNavigate() may be used only in the context of a <Router> component`.

```tsx
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

function createWrapper(initialPath = '/') {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <MemoryRouter initialEntries={[initialPath]}>
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      </MemoryRouter>
    );
  };
}

describe('UserDetail', () => {
  it('renders user from route param', async () => {
    vi.mocked(fetchUser).mockResolvedValue({ id: '123', name: 'Alice' });
    render(
      // Wrap in Routes to provide params when component uses useParams
      <Routes>
        <Route path="/users/:userId" element={<UserDetail />} />
      </Routes>,
      { wrapper: createWrapper('/users/123') },
    );
    expect(await screen.findByText('Alice')).toBeInTheDocument();
  });

  it('navigates to list on back click', async () => {
    const user = userEvent.setup();
    render(<UserDetail />, { wrapper: createWrapper('/users/123') });
    await user.click(screen.getByRole('link', { name: /back/i }));
    // Assert navigation by checking rendered content or URL state
  });
});
```

```text
REQUIRED: MemoryRouter wrapper for any component using react-router-dom hooks.
REQUIRED: initialEntries to simulate the starting URL.
REQUIRED: <Routes><Route> wrapper when component reads useParams.
BANNED: BrowserRouter in tests — it requires a real DOM environment; MemoryRouter is the correct choice.
```

## UI Component Test Template (--type ui)

```tsx
// Button.test.tsx — presentational component
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import Button from './Button';

describe('Button', () => {
  it('renders label from props', () => {
    render(<Button label="Save" onClick={vi.fn()} />);
    expect(screen.getByRole('button', { name: /save/i })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    const user = userEvent.setup();
    render(<Button label="Save" onClick={handleClick} />);
    await user.click(screen.getByRole('button', { name: /save/i }));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button label="Save" onClick={vi.fn()} disabled />);
    expect(screen.getByRole('button', { name: /save/i })).toBeDisabled();
  });
});
```

Key rules for UI components:

- No `QueryClientProvider` wrapper needed
- No `findBy*` / `waitFor` — all elements are synchronous
- No mocking of stores or API hooks
