# Anti-Pattern: server-state-in-client-store

## Problem

Server-fetched data (API responses) stored in Zustand/Pinia instead of TanStack Query.

## Why It's Bad

- Manual cache invalidation — error-prone, leads to stale data
- No automatic background refetching
- No built-in loading/error states — must implement manually
- Duplicated logic: fetch + store + loading + error flags = 50+ lines for one endpoint
- TanStack Query solves ALL of this in 5 lines

## Detection

```bash
# Look for fetch calls inside Zustand actions or Pinia actions
grep -rn "fetch\|axios" src/store/ src/stores/ 2>/dev/null
grep -rn "fetch\|axios" src/features/**/model/ 2>/dev/null
```

## Bad Example (Zustand)

```typescript
// ❌ Server state in Zustand
interface UserStore {
  users: User[];
  loading: boolean;
  error: string | null;
  fetchUsers: () => Promise<void>;
}

const useUserStore = create<UserStore>((set) => ({
  users: [],
  loading: false,
  error: null,
  fetchUsers: async () => {
    set({ loading: true });
    try {
      const data = await fetch('/api/users').then(r => r.json());
      set({ users: data, loading: false });
    } catch (e) {
      set({ error: 'Failed', loading: false });
    }
  },
}));
```

## Good Example (TanStack Query)

```typescript
// ✅ Server state in TanStack Query — 5 lines
export function useUsers() {
  return useQuery<User[]>({
    queryKey: ['users'],
    queryFn: () => fetch('/api/users').then(r => r.json()),
  });
}
```

## Rule

BANNED: API fetch logic inside Zustand/Pinia store actions.
REQUIRED: Server state (any data from the API) → TanStack Query (useQuery/useMutation).
Zustand/Pinia is for CLIENT-ONLY state: UI state, user preferences, session data not from API.
