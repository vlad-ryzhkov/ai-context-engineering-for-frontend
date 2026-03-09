# Anti-Pattern: snapshot-overuse

## Problem

AI defaults to `toMatchSnapshot()` or `toMatchInlineSnapshot()` as the primary assertion strategy.
Snapshot tests pass on first run and then become noise — updated blindly when anything changes.

## Why It's Bad

- Snapshots test the implementation, not the behavior — any markup change breaks them
- Developers blindly run `--updateSnapshot` without reviewing diff → bugs pass through
- Large snapshots are impossible to code-review — reviewers skip them
- Zero signal for regressions — the test "passes" as long as someone updates the snapshot
- Doesn't verify user-facing behavior, accessibility, or interactions

## Severity

MEDIUM

## Detection

```bash
grep -rn "toMatchSnapshot\|toMatchInlineSnapshot" src/
```

## Bad Example

```tsx
// ❌ Snapshot as primary assertion — tests nothing meaningful
it('renders UserCard', () => {
  const { container } = render(<UserCard user={mockUser} />);
  expect(container).toMatchSnapshot();
});

// ❌ Inline snapshot of entire component output
it('renders correctly', () => {
  const { container } = render(<SearchResults results={mockResults} />);
  expect(container.innerHTML).toMatchInlineSnapshot(`"<div>...800 chars..."`);
});
```

## Good Example

```tsx
// ✅ Behavior-based assertions
it('renders user name and role', () => {
  render(<UserCard user={mockUser} />);
  expect(screen.getByRole('heading')).toHaveTextContent('Jane Doe');
  expect(screen.getByText('Admin')).toBeInTheDocument();
});

it('calls onEdit when edit button is clicked', async () => {
  const onEdit = vi.fn();
  render(<UserCard user={mockUser} onEdit={onEdit} />);
  await userEvent.click(screen.getByRole('button', { name: /edit/i }));
  expect(onEdit).toHaveBeenCalledWith(mockUser.id);
});
```

## When Snapshots Are Acceptable

- Serialized data structures (API response shapes, config objects) — NOT DOM
- Visual regression tools (Chromatic, Percy) — pixel-level, not markup-level
- Small, stable utility output (date formatter, URL builder)

```tsx
// ✅ Acceptable — testing data transformation, not DOM
it('formats API response correctly', () => {
  const result = transformUserResponse(rawResponse);
  expect(result).toMatchInlineSnapshot(`
    {
      "id": "123",
      "fullName": "Jane Doe",
    }
  `);
});
```

## Rule

BANNED: `toMatchSnapshot()` on rendered component output (DOM/HTML).
REQUIRED: Use behavior-based assertions — `getByRole`, `getByText`, `toHaveTextContent`, user event assertions.
ALLOWED: Snapshots for serialized data structures or stable utility output only.
