# Anti-Pattern: testing-implementation-details

## Problem

Tests that verify internal component state, hook calls, CSS classes, or DOM structure instead of user-visible behavior.
AI tests "how it works" instead of "what the user sees".

## Why It's Bad

- Tests break on every refactor even when behavior is unchanged → false negatives
- Gives false confidence — internal state can be "correct" while UI is broken
- Couples tests to implementation → tests become maintenance burden, not safety net
- Discourages refactoring because developers fear breaking tests

## Severity

MEDIUM

## Detection

```bash
# Testing internal state / implementation details
grep -rn "wrapper\.vm\.\|component\.state\|\.instance()\.\|querySelector\(\|getByTestId\|toHaveClass\|toHaveStyle\|toHaveAttribute.*class" src/ | grep "\.test\.\|\.spec\."
```

## Bad Example (React)

```tsx
// ❌ Testing internal state and CSS classes
it('toggles dropdown', () => {
  const { container } = render(<Dropdown items={items} />);

  // Testing CSS class — implementation detail
  expect(container.querySelector('.dropdown-menu')).toHaveClass('hidden');

  fireEvent.click(container.querySelector('.dropdown-toggle')!);

  // Testing internal DOM structure — implementation detail
  expect(container.querySelector('.dropdown-menu')).not.toHaveClass('hidden');
  expect(container.querySelectorAll('.dropdown-item')).toHaveLength(3);
});
```

## Bad Example (Vue)

```vue
// ❌ Testing internal component state
it('updates counter state', async () => {
  const wrapper = mount(Counter);

  // Testing internal vm state — implementation detail
  expect(wrapper.vm.count).toBe(0);

  await wrapper.find('button').trigger('click');

  expect(wrapper.vm.count).toBe(1);
});
```

## Good Example (React)

```tsx
// ✅ Testing user-visible behavior
it('shows dropdown items when toggle is clicked', async () => {
  render(<Dropdown items={['Apple', 'Banana', 'Cherry']} />);

  // Items not visible initially
  expect(screen.queryByRole('option')).not.toBeInTheDocument();

  // User clicks toggle
  await userEvent.click(screen.getByRole('button', { name: /select/i }));

  // Items visible to user
  expect(screen.getAllByRole('option')).toHaveLength(3);
  expect(screen.getByRole('option', { name: 'Apple' })).toBeInTheDocument();
});
```

## Good Example (Vue)

```typescript
// ✅ Testing what user sees, not internal state
it('displays updated count when button is clicked', async () => {
  render(Counter);

  expect(screen.getByText('Count: 0')).toBeInTheDocument();

  await userEvent.click(screen.getByRole('button', { name: /increment/i }));

  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

## Test Priority Pyramid

| Priority | What to Test | How |
|----------|-------------|-----|
| 1 (highest) | User interactions | `userEvent.click`, `userEvent.type` |
| 2 | Visible output | `getByRole`, `getByText`, `toHaveTextContent` |
| 3 | Accessibility | `getByRole`, `toHaveAccessibleName`, axe |
| 4 | Side effects | Mock API calls, navigation, toast messages |
| 5 (lowest) | DOM structure | Only when structure IS the behavior (tables, lists) |

## Rule

BANNED: `wrapper.vm.*`, `component.state`, `querySelector` as primary selector, testing CSS classes for behavior.
REQUIRED: Test from user perspective — `getByRole`, `getByText`, `getByLabelText`, `userEvent`.
REQUIRED: Tests should survive refactors that preserve user-visible behavior.
