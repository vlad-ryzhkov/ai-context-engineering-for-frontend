import type {
  User,
  UserListResponse,
  CreateUserRequest,
  UpdateUserRequest,
  UserQueryParams,
} from './userTypes';

const API_BASE = import.meta.env.VITE_API_BASE_URL;

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: response.statusText }));
    throw new Error(error.message || `HTTP ${response.status}`);
  }
  return response.json() as Promise<T>;
}

export async function fetchUsers(params?: UserQueryParams): Promise<UserListResponse> {
  const searchParams = new URLSearchParams();
  if (params?.page) searchParams.set('page', String(params.page));
  if (params?.pageSize) searchParams.set('pageSize', String(params.pageSize));
  if (params?.search) searchParams.set('search', params.search);

  const response = await fetch(`${API_BASE}/api/users?${searchParams.toString()}`);
  return handleResponse<UserListResponse>(response);
}

export async function fetchUser(userId: string): Promise<User> {
  const response = await fetch(`${API_BASE}/api/users/${userId}`);
  return handleResponse<User>(response);
}

export async function createUser(data: CreateUserRequest): Promise<User> {
  const response = await fetch(`${API_BASE}/api/users`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return handleResponse<User>(response);
}

export async function updateUser(userId: string, data: UpdateUserRequest): Promise<User> {
  const response = await fetch(`${API_BASE}/api/users/${userId}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return handleResponse<User>(response);
}

export async function deleteUser(userId: string): Promise<void> {
  const response = await fetch(`${API_BASE}/api/users/${userId}`, {
    method: 'DELETE',
  });
  if (!response.ok) {
    throw new Error(`Failed to delete user: ${response.statusText}`);
  }
}
