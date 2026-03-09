export interface LoginFormValues {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    name: string;
  };
}

export interface LoginError {
  code: 'INVALID_CREDENTIALS' | 'ACCOUNT_LOCKED' | 'NETWORK_ERROR';
  message: string;
}
