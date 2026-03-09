# Graduated Lessons

<!-- Lessons promoted by /curate-lessons. Format: date | rule | target file -->

## Form Components

- **Always validate on client AND server.** Zod schema on the form + API returns typed error codes. Client-only validation is bypassable.
- **Use `noValidate` on `<form>`.** Browser default validation conflicts with custom error UI. Set `noValidate` and handle all validation through React Hook Form / VeeValidate.
- **Map server errors to user-friendly messages.** Never show raw API error objects. Maintain an error code → message map.

## Error Boundaries

- **Wrap every lazy-loaded route in an Error Boundary.** One crashing component should not blank the entire page.
- **Error boundaries are the ONLY valid use of class components in React.** `getDerivedStateFromError` is not available as a hook.
- **Always provide a reset/retry action.** Users need a way to recover without refreshing the page.

## State Management

- **Server state → TanStack Query, client state → Zustand/Pinia.** Mixing them causes manual cache invalidation, stale data, and duplicated loading/error flags.
- **Use selectors in Zustand, not derived state fields.** Storing `totalPrice` alongside `items` creates sync bugs. Compute via selector instead.
- **Never persist access tokens to localStorage.** Persist only non-sensitive user info. Use refresh token flow via HTTP-only cookies for auth.
- **Pinia stores must not import other Pinia stores.** Use composables to orchestrate cross-store logic. Direct imports cause circular dependencies.
