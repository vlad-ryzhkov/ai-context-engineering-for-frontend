import { Suspense } from 'react';
import { UserCard } from './UserCard';
import { UserCardSkeleton } from './loading';

interface UserPageProps {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: UserPageProps) {
  const { id } = await params;
  return { title: `User ${id}` };
}

export default async function UserPage({ params }: UserPageProps) {
  const { id } = await params;

  return (
    <main className="mx-auto max-w-2xl p-6">
      <Suspense fallback={<UserCardSkeleton />}>
        <UserCard userId={id} />
      </Suspense>
    </main>
  );
}
