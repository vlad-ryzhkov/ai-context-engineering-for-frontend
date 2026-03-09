# Anti-Pattern: suspense-waterfall

## Problem

Sequential Suspense boundaries causing request waterfalls — child components only start fetching after parent Suspense resolves.

## Why It's Bad

- Each Suspense boundary adds latency (sequential, not parallel)
- Total load time = sum of all sequential fetches
- Users see cascading loading states (skeleton → skeleton → skeleton)
- Defeats the purpose of streaming SSR

## Detection

```bash
grep -rn "Suspense\|await " src/
```

Look for:

- Nested `<Suspense>` where child data fetch depends on parent being resolved
- Multiple `use()` calls in sequence without parallel data fetching
- Server Components with sequential `await` calls

## Bad Example

```tsx
// ❌ Waterfall: UserProfile fetches → then UserPosts fetches → then PostComments fetches
async function UserPage({ userId }: { userId: string }) {
  const user = await getUser(userId);         // 200ms
  const posts = await getUserPosts(userId);    // 300ms (waits for user)
  const comments = await getPostComments(posts[0].id); // 200ms (waits for posts)
  // Total: 700ms sequential

  return (
    <div>
      <UserProfile user={user} />
      <PostList posts={posts} />
      <CommentList comments={comments} />
    </div>
  );
}
```

## Good Example

```tsx
// ✅ Parallel fetching: all requests start simultaneously
async function UserPage({ userId }: { userId: string }) {
  const userPromise = getUser(userId);
  const postsPromise = getUserPosts(userId);

  const [user, posts] = await Promise.all([userPromise, postsPromise]);
  // Total: max(200ms, 300ms) = 300ms

  return (
    <div>
      <UserProfile user={user} />
      <Suspense fallback={<PostsSkeleton />}>
        <PostList posts={posts} />
      </Suspense>
    </div>
  );
}

// ✅ Or use parallel Suspense boundaries with preloaded data
function UserPage({ userId }: { userId: string }) {
  return (
    <div>
      <Suspense fallback={<ProfileSkeleton />}>
        <UserProfile userId={userId} />
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <UserPosts userId={userId} />
      </Suspense>
    </div>
  );
}
```

## Rule

BANNED: Sequential `await` calls in Server Components when requests are independent.
REQUIRED: Use `Promise.all()` for parallel fetching or sibling `<Suspense>` boundaries.

## References

- [React Suspense](https://react.dev/reference/react/Suspense)
- [Next.js Streaming](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
