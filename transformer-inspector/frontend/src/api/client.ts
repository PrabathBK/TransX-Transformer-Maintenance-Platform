export const API_BASE =
  (import.meta.env.VITE_API_BASE as string) || 'http://localhost:8080';

console.log('API_BASE =', API_BASE);

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const url = `${API_BASE}${path}`;
  const res = await fetch(url, init).catch(err => {
    throw new Error(`Network error calling ${url}: ${err?.message || err}`);
  });
  const text = await res.text();
  const isJson = (res.headers.get('content-type') || '').includes('application/json');
  if (!res.ok) throw new Error(text || `HTTP ${res.status} for ${url}`);
  if (!text) return undefined as unknown as T;
  return isJson ? JSON.parse(text) as T : (text as unknown as T);
}