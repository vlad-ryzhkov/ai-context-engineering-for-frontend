/** Generated from user.proto — UserService */

export const UserStatus = {
  UNSPECIFIED: 0,
  ACTIVE: 1,
  INACTIVE: 2,
  BANNED: 3,
} as const;

export type UserStatus = (typeof UserStatus)[keyof typeof UserStatus];

export interface UserAddress {
  street: string;
  city: string;
  country: string;
  zipCode: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
  status: UserStatus;
  address: UserAddress | undefined;
  createdAt: string; // google.protobuf.Timestamp → ISO 8601
  updatedAt: string; // google.protobuf.Timestamp → ISO 8601
}

export interface GetUserRequest {
  id: string;
}

export interface ListUsersRequest {
  pageSize: number;
  pageToken: string;
}

export interface ListUsersResponse {
  users: User[];
  nextPageToken: string;
}

export interface CreateUserRequest {
  name: string;
  email: string;
  status: UserStatus;
  address?: UserAddress;
}

export interface UpdateUserRequest {
  id: string;
  name?: string;
  email?: string;
  status?: UserStatus;
  address?: UserAddress;
  updateMask: string[]; // google.protobuf.FieldMask
}
