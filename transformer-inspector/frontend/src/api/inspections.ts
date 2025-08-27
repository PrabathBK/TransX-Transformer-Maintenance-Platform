// src/api/inspections.ts
import { api } from './client';

export type Inspection = {
  id: string;
  inspectionNo: string;
  transformerId: string;
  transformerCode: string;
  branch: string;
  inspectionDate: string;  // LocalDate as string
  inspectionTime: string;  // LocalTime as string
  maintenanceDate?: string | null;
  maintenanceTime?: string | null;
  status: 'IN_PROGRESS' | 'PENDING' | 'COMPLETED';
  inspectedBy: string;
  notes?: string | null;
  createdAt: string;
  updatedAt: string;
};

export type PageResp<T> = {
  content: T[];
  totalElements: number;
  totalPages?: number;
  number?: number;
  size?: number;
};

export type CreateInspectionBody = {
  inspectionNo: string;
  transformerId: string;
  branch: string;
  inspectionDate: string;
  inspectionTime: string;
  maintenanceDate?: string;
  maintenanceTime?: string;
  inspectedBy: string;
  notes?: string;
};

export async function listInspections(q = '', transformerId = '', page = 0, size = 10) {
  const params = new URLSearchParams({ q, page: String(page), size: String(size) });
  if (transformerId) params.set('transformerId', transformerId);
  return api<PageResp<Inspection>>(`/api/inspections?${params.toString()}`);
}

export async function getInspection(id: string) {
  return api<Inspection>(`/api/inspections/${id}`);
}

export async function createInspection(body: CreateInspectionBody) {
  return api<Inspection>(`/api/inspections`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

export async function updateInspection(id: string, body: CreateInspectionBody) {
  return api<Inspection>(`/api/inspections/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

export async function updateInspectionStatus(id: string, status: 'IN_PROGRESS' | 'PENDING' | 'COMPLETED') {
  return api<Inspection>(`/api/inspections/${id}/status?status=${status}`, {
    method: 'PUT',
  });
}

export async function deleteInspection(id: string) {
  return api<void>(`/api/inspections/${id}`, { method: 'DELETE' });
}
