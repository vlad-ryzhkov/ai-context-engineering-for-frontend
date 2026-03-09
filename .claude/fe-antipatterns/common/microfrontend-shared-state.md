# Micro-Frontend Shared State Leak

## Problem

Sharing runtime state (global stores, singletons, context providers) directly between micro-frontends, creating tight coupling that defeats the purpose of independent deployment.

## Why It's Bad

- Micro-frontends lose independent deployability — a state shape change in one breaks others
- Shared Zustand/Pinia stores create hidden coupling between teams
- Global singletons (event buses, shared caches) become coordination bottlenecks
- Version mismatches in shared state libraries cause runtime errors

## Detection

Grep signatures:

- `window.__SHARED_STATE__` or `window.__MFE_`
- Importing from another micro-frontend's internal modules
- Shared store instances across module federation boundaries

## Bad Example

```tsx
// ❌ Micro-frontend A exports its store for B to consume
// mfe-a/src/stores/userStore.ts
export const useUserStore = create<UserState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));

// mfe-b/src/features/Profile.tsx — imports from mfe-a directly
import { useUserStore } from 'mfe-a/stores/userStore'; // tight coupling!

export function Profile() {
  const user = useUserStore((state) => state.user);
  return <div>{user?.name}</div>;
}
```

## Good Example

```tsx
// ✅ Contract-based communication via custom events
// shared-contracts/events.ts (versioned, published as package)
export interface UserChangedEvent {
  type: 'user:changed';
  payload: { id: string; name: string; email: string };
}

// mfe-a: dispatches event
window.dispatchEvent(
  new CustomEvent('user:changed', {
    detail: { id: '1', name: 'Alice', email: 'alice@example.com' },
  }),
);

// mfe-b: listens to event, owns its own state
function useSharedUser() {
  const [user, setUser] = useState<UserChangedEvent['payload'] | null>(null);

  useEffect(() => {
    const handler = (e: CustomEvent<UserChangedEvent['payload']>) => {
      setUser(e.detail);
    };
    window.addEventListener('user:changed', handler as EventListener);
    return () => window.removeEventListener('user:changed', handler as EventListener);
  }, []);

  return user;
}
```

## References

- [Micro Frontends (martinfowler.com)](https://martinfowler.com/articles/micro-frontends.html)
- [Module Federation](https://module-federation.io/)
