import { api } from './client';

export type Transformer = {
  id: string;
  code: string;
  location: string;
  capacityKVA: number;
  createdAt: string;
};

export type CreateUpdateTransformer = {
  code: string;
  location: string;
  capacityKVA: number;
};

export async function listTransformers(q = "", page = 0, size = 10) {
  const qs = new URLSearchParams({ q, page: String(page), size: String(size) }).toString();
  return api<{ content: Transformer[]; totalElements: number }>(`/api/transformers?${qs}`);
}

export async function getTransformer(id: string) {
  return api<Transformer>(`/api/transformers/${id}`);
}

// export async function createTransformer(body: CreateUpdateTransformer) {
//   return api<Transformer>(`/api/transformers`, {
//     method: 'POST',
//     headers: { 'Content-Type': 'application/json' },
//     body: JSON.stringify(body)
//   });
// }

// export async function updateTransformer(id: string, body: CreateUpdateTransformer) {
//   return api<Transformer>(`/api/transformers/${id}`, {
//     method: 'PUT',
//     headers: { 'Content-Type': 'application/json' },
//     body: JSON.stringify(body)
//   });
// }

export async function deleteTransformer(id: string) {
  return api<void>(`/api/transformers/${id}`, { method: 'DELETE' });
}

export async function createTransformer(body: { code: string; location: string; capacityKVA: number }) {
  await api<void>(`/api/transformers`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
}

export async function updateTransformer(id: string, body: { code: string; location: string; capacityKVA: number }) {
  await api<void>(`/api/transformers/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
}