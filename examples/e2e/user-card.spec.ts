import { test, expect } from '@playwright/test';

test.describe('UserCard', () => {
  test('displays user information after loading', async ({ page }) => {
    await page.goto('/users/1');

    // Loading state should appear first
    const skeleton = page.getByRole('status');
    await expect(skeleton).toBeVisible();

    // Wait for content to load
    const userName = page.getByRole('heading', { name: /alice johnson/i });
    await expect(userName).toBeVisible({ timeout: 10_000 });

    // Verify user details
    await expect(page.getByText('alice@example.com')).toBeVisible();
    await expect(page.getByRole('img', { name: /alice johnson/i })).toBeVisible();
  });

  test('shows error state on network failure', async ({ page }) => {
    // Simulate network error
    await page.route('**/api/users/**', (route) => route.abort());
    await page.goto('/users/1');

    const alert = page.getByRole('alert');
    await expect(alert).toBeVisible({ timeout: 10_000 });
    await expect(alert).toContainText(/failed|error/i);
  });

  test('shows empty state for non-existent user', async ({ page }) => {
    await page.route('**/api/users/**', (route) =>
      route.fulfill({ status: 404, body: '' }),
    );
    await page.goto('/users/nonexistent');

    await expect(page.getByText(/not found/i)).toBeVisible({ timeout: 10_000 });
  });

  test('user card is accessible', async ({ page }) => {
    await page.goto('/users/1');

    // Wait for content
    await expect(page.getByRole('heading', { name: /alice johnson/i })).toBeVisible({
      timeout: 10_000,
    });

    // Avatar has alt text
    const avatar = page.getByRole('img', { name: /alice johnson/i });
    await expect(avatar).toHaveAttribute('alt', /alice johnson/i);

    // Article landmark present
    await expect(page.getByRole('article')).toBeVisible();
  });
});
