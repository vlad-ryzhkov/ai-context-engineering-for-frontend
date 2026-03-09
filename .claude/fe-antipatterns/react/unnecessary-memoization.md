# Anti-Pattern: unnecessary-memoization

## Problem

Manual `useMemo`, `useCallback`, or `React.memo` in projects where React Compiler handles memoization automatically.

## Why It's Bad

- React Compiler auto-memoizes all components and hooks — manual memos are redundant
- Adds visual noise and maintenance burden with zero performance benefit
- Manual `useCallback` with wrong deps can **prevent** compiler optimizations
- `React.memo` wrappers obscure component intent and add indirection

## Applicability

**CONDITIONAL:** This anti-pattern applies ONLY when React Compiler is active in the project.

Detection — check for ANY of:

- `babel-plugin-react-compiler` in `package.json` devDependencies
- `react-compiler-runtime` in `package.json` dependencies
- `reactCompiler` in `vite.config.ts` or `babel.config.js`
- `"use no memo"` directive in source files (opt-out = compiler is on)

If none found → this anti-pattern does NOT apply. Manual memoization remains valid.

## Detection

```bash
# Find manual memos (only flag if React Compiler is confirmed active)
grep -rn 'useMemo\|useCallback\|React\.memo' src/ --include='*.tsx' --include='*.ts'

# Verify React Compiler is active
grep -rn 'react-compiler\|reactCompiler' package.json vite.config.* babel.config.* 2>/dev/null
```

## Bad Example (React Compiler active)

```tsx
// ❌ Redundant — React Compiler handles this automatically
const MemoizedCard = React.memo(function Card({ title }: { title: string }) {
  return <div className="card">{title}</div>;
});

function Parent({ items }: { items: Item[] }) {
  // ❌ Redundant useCallback — compiler auto-memoizes
  const handleClick = useCallback((id: string) => {
    console.info('clicked', id);
  }, []);

  // ❌ Redundant useMemo — compiler auto-memoizes
  const sorted = useMemo(
    () => [...items].sort((a, b) => a.name.localeCompare(b.name)),
    [items]
  );

  return <ul>{sorted.map(i => <MemoizedCard key={i.id} title={i.name} />)}</ul>;
}
```

## Good Example (React Compiler active)

```tsx
// ✅ No manual memoization — compiler handles it
function Card({ title }: { title: string }) {
  return <div className="card">{title}</div>;
}

function Parent({ items }: { items: Item[] }) {
  const handleClick = (id: string) => {
    console.info('clicked', id);
  };

  const sorted = [...items].sort((a, b) => a.name.localeCompare(b.name));

  return <ul>{sorted.map(i => <Card key={i.id} title={i.name} />)}</ul>;
}
```

## Rule

CONDITIONAL: When React Compiler is active in the project:

- BANNED: `React.memo()` wrappers — remove them.
- BANNED: `useCallback` for referential stability — remove wrapper, keep plain function.
- BANNED: `useMemo` for derived values — remove wrapper, keep plain computation.
- EXCEPTION: `useMemo` for truly expensive computations (>1ms measured) may be kept with `"use no memo"` directive and a comment explaining why.

When React Compiler is NOT active:

- This anti-pattern does NOT apply. Follow `missing-usecallback.md` and `state-in-render.md` instead.
