// src/api/client.ts
export const API_BASE =
  (import.meta.env.VITE_API_BASE as string) || 'http://localhost:8080';

console.log('API_BASE =', API_BASE);

// Helper to get auth token
function getAuthToken(): string | null {
  return localStorage.getItem('transx_token');
}

// Helper to build headers with optional auth
function buildHeaders(init?: RequestInit): Headers {
  const headers = new Headers(init?.headers);
  
  // Add auth token if available and not already set
  const token = getAuthToken();
  if (token && !headers.has('Authorization')) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  
  return headers;
}

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const url = `${API_BASE}${path}`;
  
  // Build request with auth headers
  const requestInit: RequestInit = {
    ...init,
    headers: buildHeaders(init),
  };
  
  const res = await fetch(url, requestInit).catch(err => {
    throw new Error(`Network error calling ${url}: ${err?.message || err}`);
  });
  
  // Handle 401 Unauthorized - redirect to login
  if (res.status === 401) {
    localStorage.removeItem('transx_token');
    localStorage.removeItem('transx_user');
    window.location.href = '/login';
    throw new Error('Session expired. Please log in again.');
  }
  
  const text = await res.text();
  const isJson = (res.headers.get('content-type') || '').includes('application/json');
  if (!res.ok) throw new Error(text || `HTTP ${res.status} for ${url}`);
  if (!text) return undefined as unknown as T;
  return isJson ? JSON.parse(text) as T : (text as unknown as T);
}