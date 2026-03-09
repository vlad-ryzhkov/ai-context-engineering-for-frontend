import { getUser } from './actions';

interface UserCardProps {
  userId: string;
}

export async function UserCard({ userId }: UserCardProps) {
  const user = await getUser(userId);

  if (!user) {
    return (
      <div className="rounded-lg border border-dashed border-gray-300 p-8 text-center">
        <p className="text-gray-500">User not found</p>
      </div>
    );
  }

  return (
    <article className="rounded-lg border bg-white p-6 shadow-sm">
      <div className="flex items-center gap-4">
        <img
          src={user.avatarUrl}
          alt={`${user.name}'s avatar`}
          className="size-16 rounded-full"
        />
        <div>
          <h2 className="text-lg font-semibold">{user.name}</h2>
          <p className="text-sm text-gray-500">{user.email}</p>
        </div>
      </div>
      <p className="mt-4 text-gray-700">{user.bio}</p>
    </article>
  );
}
