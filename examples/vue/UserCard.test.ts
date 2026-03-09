import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/vue';
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query';
import UserCard from './UserCard.vue';

const mockUser = {
  id: '1',
  name: 'Alice Johnson',
  email: 'alice@example.com',
  avatarUrl: 'https://example.com/avatar.jpg',
  bio: 'Frontend developer',
};

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });

  return {
    global: {
      plugins: [[VueQueryPlugin, { queryClient }]],
    },
  };
}

describe('UserCard', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('renders loading skeleton initially', () => {
    vi.spyOn(globalThis, 'fetch').mockImplementation(
      () => new Promise(() => {}),
    );

    render(UserCard, {
      props: { userId: '1' },
      ...createWrapper(),
    });

    expect(screen.getByRole('status')).toBeInTheDocument();
  });

  it('renders user data on success', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValueOnce(
      new Response(JSON.stringify(mockUser), { status: 200 }),
    );

    render(UserCard, {
      props: { userId: '1' },
      ...createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText('Alice Johnson')).toBeInTheDocument();
    });

    expect(screen.getByText('alice@example.com')).toBeInTheDocument();
    expect(screen.getByRole('img', { name: /alice johnson/i })).toHaveAttribute(
      'src',
      mockUser.avatarUrl,
    );
  });

  it('renders error state on fetch failure', async () => {
    vi.spyOn(globalThis, 'fetch').mockRejectedValueOnce(new Error('Network error'));

    render(UserCard, {
      props: { userId: '1' },
      ...createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
    });

    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
  });

  it('renders empty state when user not found', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValueOnce(
      new Response(null, { status: 404 }),
    );

    render(UserCard, {
      props: { userId: 'nonexistent' },
      ...createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText(/not found/i)).toBeInTheDocument();
    });
  });
});
