// src/context/AuthContext.tsx
import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import type { ReactNode } from 'react';

export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: 'admin' | 'inspector' | 'viewer';
  provider: 'email' | 'google';
  createdAt: string;
  lastLogin?: string;
  preferences?: UserPreferences;
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  notifications: boolean;
  emailNotifications: boolean;
  language: string;
  timezone: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  loginWithGoogle: (credential: string) => Promise<void>;
  signup: (name: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  updateUser: (updates: Partial<User>) => Promise<void>;
  updatePreferences: (preferences: Partial<UserPreferences>) => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

const API_BASE = (import.meta.env.VITE_API_BASE as string) || 'http://localhost:8080';

// Helper to get stored token
const getStoredToken = (): string | null => {
  return localStorage.getItem('transx_token');
};

// Helper to get stored user
const getStoredUser = (): User | null => {
  const stored = localStorage.getItem('transx_user');
  return stored ? JSON.parse(stored) : null;
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(getStoredUser);
  const [isLoading, setIsLoading] = useState(true);

  // Validate token on mount
  useEffect(() => {
    const validateSession = async () => {
      const token = getStoredToken();
      if (!token) {
        setIsLoading(false);
        return;
      }

      try {
        const res = await fetch(`${API_BASE}/api/auth/me`, {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (res.ok) {
          const userData = await res.json();
          setUser(userData);
          localStorage.setItem('transx_user', JSON.stringify(userData));
        } else {
          // Token invalid, clear storage
          localStorage.removeItem('transx_token');
          localStorage.removeItem('transx_user');
          setUser(null);
        }
      } catch (error) {
        console.error('Session validation error:', error);
        // Keep existing user data on network error
      } finally {
        setIsLoading(false);
      }
    };

    validateSession();
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const res = await fetch(`${API_BASE}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      const error = await res.text();
      throw new Error(error || 'Login failed');
    }

    const { token, user: userData } = await res.json();
    localStorage.setItem('transx_token', token);
    localStorage.setItem('transx_user', JSON.stringify(userData));
    setUser(userData);
  }, []);

  const loginWithGoogle = useCallback(async (credential: string) => {
    const res = await fetch(`${API_BASE}/api/auth/google`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ credential }),
    });

    if (!res.ok) {
      const error = await res.text();
      throw new Error(error || 'Google login failed');
    }

    const { token, user: userData } = await res.json();
    localStorage.setItem('transx_token', token);
    localStorage.setItem('transx_user', JSON.stringify(userData));
    setUser(userData);
  }, []);

  const signup = useCallback(async (name: string, email: string, password: string) => {
    const res = await fetch(`${API_BASE}/api/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, email, password }),
    });

    if (!res.ok) {
      const error = await res.text();
      throw new Error(error || 'Signup failed');
    }

    const { token, user: userData } = await res.json();
    localStorage.setItem('transx_token', token);
    localStorage.setItem('transx_user', JSON.stringify(userData));
    setUser(userData);
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('transx_token');
    localStorage.removeItem('transx_user');
    setUser(null);
    window.location.href = '/login';
  }, []);

  const updateUser = useCallback(async (updates: Partial<User>) => {
    const token = getStoredToken();
    if (!token || !user) throw new Error('Not authenticated');

    const res = await fetch(`${API_BASE}/api/auth/profile`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(updates),
    });

    if (!res.ok) {
      const error = await res.text();
      throw new Error(error || 'Failed to update profile');
    }

    const updatedUser = await res.json();
    localStorage.setItem('transx_user', JSON.stringify(updatedUser));
    setUser(updatedUser);
  }, [user]);

  const updatePreferences = useCallback(async (preferences: Partial<UserPreferences>) => {
    const token = getStoredToken();
    if (!token || !user) throw new Error('Not authenticated');

    const res = await fetch(`${API_BASE}/api/auth/preferences`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(preferences),
    });

    if (!res.ok) {
      const error = await res.text();
      throw new Error(error || 'Failed to update preferences');
    }

    const updatedUser = await res.json();
    localStorage.setItem('transx_user', JSON.stringify(updatedUser));
    setUser(updatedUser);
  }, [user]);

  const refreshUser = useCallback(async () => {
    const token = getStoredToken();
    if (!token) return;

    const res = await fetch(`${API_BASE}/api/auth/me`, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });

    if (res.ok) {
      const userData = await res.json();
      localStorage.setItem('transx_user', JSON.stringify(userData));
      setUser(userData);
    }
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: !!user,
        login,
        loginWithGoogle,
        signup,
        logout,
        updateUser,
        updatePreferences,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// Helper hook to get auth header for API calls
export function useAuthHeader(): Record<string, string> {
  const token = getStoredToken();
  return token ? { 'Authorization': `Bearer ${token}` } : {};
}

// Helper function to get current user ID for tracking
export function getCurrentUserId(): string | null {
  const user = getStoredUser();
  return user?.id || null;
}

// Helper function to get current user name for display
export function getCurrentUserName(): string {
  const user = getStoredUser();
  return user?.name || 'Unknown User';
}
