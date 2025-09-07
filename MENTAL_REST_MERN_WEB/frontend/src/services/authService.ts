import api from './api';
import { User, LoginCredentials, RegisterCredentials, ApiResponse } from '../types';

interface LoginResponse {
  message: string;
  token: string;
  user: User;
}

interface RegisterResponse {
  message: string;
  token: string;
  user: User;
}

export const authService = {
  // Login user
  async login(credentials: LoginCredentials): Promise<LoginResponse> {
    const response = await api.post<LoginResponse>('/auth/login', credentials);
    return response.data;
  },

  // Register user
  async register(credentials: RegisterCredentials): Promise<RegisterResponse> {
    const response = await api.post<RegisterResponse>('/auth/register', credentials);
    return response.data;
  },

  // Get current user
  async getCurrentUser(): Promise<User> {
    const response = await api.get<{ user: User; stats: any }>('/auth/me');
    return response.data.user;
  },

  // Update user profile
  async updateProfile(userData: Partial<User>): Promise<User> {
    const response = await api.put<{ message: string; user: User }>('/auth/profile', userData);
    return response.data.user;
  },

  // Change password
  async changePassword(currentPassword: string, newPassword: string): Promise<void> {
    await api.post('/auth/change-password', {
      currentPassword,
      newPassword,
    });
  },

  // Deactivate account
  async deactivateAccount(password: string): Promise<void> {
    await api.post('/auth/deactivate', { password });
  },

  // Verify token
  async verifyToken(): Promise<{ valid: boolean; user: Partial<User> }> {
    const response = await api.get('/auth/verify-token');
    return response.data;
  },

  // Google OAuth login
  async googleLogin(): Promise<void> {
    window.location.href = `${process.env.REACT_APP_API_URL || 'http://localhost:5000/api'}/auth/google`;
  },
};
