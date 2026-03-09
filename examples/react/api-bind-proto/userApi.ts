import { createClient, type Transport } from '@connectrpc/connect';
import { createConnectTransport } from '@connectrpc/connect-web';
import type {
  User,
  GetUserRequest,
  ListUsersRequest,
  ListUsersResponse,
  CreateUserRequest,
  UpdateUserRequest,
} from './userTypes';

// --- Transport (shared across all services) ---

const transport: Transport = createConnectTransport({
  baseUrl: import.meta.env.VITE_GRPC_BASE_URL,
});

// --- Service definition (mirrors proto service block) ---

interface UserService {
  getUser: (request: GetUserRequest) => Promise<User>;
  listUsers: (request: ListUsersRequest) => Promise<ListUsersResponse>;
  createUser: (request: CreateUserRequest) => Promise<User>;
  updateUser: (request: UpdateUserRequest) => Promise<User>;
}

const client = createClient<UserService>(
  { typeName: 'user.v1.UserService' } as Parameters<typeof createClient>[0],
  transport,
);

// --- Typed client functions ---

export async function getUser(userId: string): Promise<User> {
  return client.getUser({ id: userId });
}

export async function listUsers(params: ListUsersRequest): Promise<ListUsersResponse> {
  return client.listUsers(params);
}

export async function createUser(data: CreateUserRequest): Promise<User> {
  return client.createUser(data);
}

export async function updateUser(data: UpdateUserRequest): Promise<User> {
  return client.updateUser(data);
}
