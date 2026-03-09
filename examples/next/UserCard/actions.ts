'use server';

interface User {
  id: string;
  name: string;
  email: string;
  avatarUrl: string;
  bio: string;
}

export async function getUser(userId: string): Promise<User | null> {
  // Replace with your actual data source
  const response = await fetch(`https://api.example.com/users/${userId}`, {
    next: { revalidate: 60 },
  });

  if (!response.ok) {
    if (response.status === 404) return null;
    throw new Error('Failed to fetch user');
  }

  return response.json() as Promise<User>;
}
