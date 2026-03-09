# Anti-Pattern: context-overuse

## Problem

Using React Context for frequently-changing state, causing all consumers to re-render on every change.

## Why It's Bad

- Every component that calls `useContext(MyContext)` re-renders when context value changes
- High-frequency state (form input, mouse position, scroll) = constant re-renders of entire tree
- `React.memo` does NOT help — context changes bypass it

## Detection

Look for `useContext` used with frequently-updating values:

```bash
grep -rn "useContext\|createContext" src/ | head -20
```

## Bad Example

```tsx
// ❌ Putting frequently-changing state in Context
const AppContext = createContext({ theme: 'dark', searchQuery: '' });

// Every keystroke in search = ALL consumers re-render
function SearchBar() {
  const { searchQuery, setSearchQuery } = useContext(AppContext);
  return <input value={searchQuery} onChange={e => setSearchQuery(e.target.value)} />;
}
```

## Good Example

```tsx
// ✅ Context for STABLE values (theme, user, locale)
const ThemeContext = createContext<'light' | 'dark'>('dark');

// ✅ Frequently-changing state → Zustand (selective subscription)
const useStore = create((set) => ({
  searchQuery: '',
  setSearchQuery: (q: string) => set({ searchQuery: q }),
}));

function SearchBar() {
  const { searchQuery, setSearchQuery } = useStore();
  return <input value={searchQuery} onChange={e => setSearchQuery(e.target.value)} />;
}
```

## Rule

BANNED: Context for state that changes more than once per user interaction.
REQUIRED: Context for stable values (theme, locale, current user, feature flags).
REQUIRED: Zustand/Pinia for frequently-updating client state.
