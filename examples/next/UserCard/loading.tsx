export function UserCardSkeleton() {
  return (
    <div className="animate-pulse rounded-lg border bg-white p-6 shadow-sm">
      <div className="flex items-center gap-4">
        <div className="size-16 rounded-full bg-gray-200" />
        <div className="space-y-2">
          <div className="h-5 w-32 rounded bg-gray-200" />
          <div className="h-4 w-48 rounded bg-gray-200" />
        </div>
      </div>
      <div className="mt-4 space-y-2">
        <div className="h-4 w-full rounded bg-gray-200" />
        <div className="h-4 w-3/4 rounded bg-gray-200" />
      </div>
    </div>
  );
}

export default function Loading() {
  return <UserCardSkeleton />;
}
