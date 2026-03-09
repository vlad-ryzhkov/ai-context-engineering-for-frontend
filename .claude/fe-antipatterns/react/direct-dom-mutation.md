# Anti-Pattern: direct-dom-mutation

## Problem

Using `document.querySelector`, `getElementById`, or other direct DOM APIs inside React component body or handlers.

## Why It's Bad

- Bypasses React's virtual DOM reconciliation
- Changes are lost on next render cycle
- Incompatible with Server-Side Rendering
- Unpredictable behavior with React Concurrent Mode

## Detection

```bash
grep -rn "document\.querySelector\|document\.getElementById\|document\.getElementsBy" src/
```

## Bad Example

```tsx
// ❌ Direct DOM mutation
function LoginForm() {
  const handleError = () => {
    document.querySelector('.email-input')?.classList.add('error');
  };
}
```

## Good Example

```tsx
// ✅ React state controls UI
function LoginForm() {
  const [emailError, setEmailError] = useState('');

  return (
    <input
      className={emailError ? 'border-red-500' : 'border-gray-300'}
      aria-invalid={Boolean(emailError)}
      aria-describedby={emailError ? 'email-error' : undefined}
    />
  );
}
```

## Exception

`document.querySelector` is acceptable in:

- Event delegation at document level (outside React tree)
- Focus management after modal open (use `useEffect` + `ref`)

```tsx
// ✅ Focus management via ref
const inputRef = useRef<HTMLInputElement>(null);
useEffect(() => { inputRef.current?.focus(); }, []);
```

## Rule

BANNED: `document.querySelector` or `getElementById` in React component body or event handlers.
REQUIRED: Use `ref` for imperative DOM access (focus, scroll, measurement).
