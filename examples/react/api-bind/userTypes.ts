/** Generated from OpenAPI spec — /api/users */

export interface User {
  id: string;
  name: string;
  email: string;
  avatarUrl: string;
  bio: string;
  createdAt: string;
}

export interface UserListResponse {
  data: User[];
  total: number;
  page: number;
  pageSize: number;
}

export interface CreateUserRequest {
  name: string;
  email: string;
  bio?: string;
}

export interface UpdateUserRequest {
  name?: string;
  email?: string;
  bio?: string;
}

export interface UserQueryParams {
  page?: number;
  pageSize?: number;
  search?: string;
}
