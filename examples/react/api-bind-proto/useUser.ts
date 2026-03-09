import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import type { ListUsersRequest, CreateUserRequest, UpdateUserRequest } from './userTypes';
import { getUser, listUsers, createUser, updateUser } from './userApi';

const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (params?: ListUsersRequest) => [...userKeys.lists(), params] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

export function useUser(userId: string) {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => getUser(userId),
    enabled: Boolean(userId),
  });
}

export function useUsers(params?: ListUsersRequest) {
  return useQuery({
    queryKey: userKeys.list(params),
    queryFn: () => listUsers(params ?? { pageSize: 20, pageToken: '' }),
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserRequest) => createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
}

export function useUpdateUser(userId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: UpdateUserRequest) => updateUser(data),
    onSuccess: (updatedUser) => {
      queryClient.setQueryData(userKeys.detail(userId), updatedUser);
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
}
