import { api } from './client';

export type ThermalImage = {
  id: string;
  transformerId: string;
  type: 'BASELINE' | 'MAINTENANCE';
  envCondition?: 'SUNNY' | 'CLOUDY' | 'RAINY';
  uploader: string;
  uploadedAt: string;
  publicUrl: string;
  originalFilename: string;
  sizeBytes: number;
  contentType: string;
};

export async function uploadImage(params: {
  transformerId: string;
  type: 'BASELINE' | 'MAINTENANCE';
  envCondition?: 'SUNNY' | 'CLOUDY' | 'RAINY';
  uploader: string;
  file: File;
}) {
  const fd = new FormData();
  fd.set('transformerId', params.transformerId);
  fd.set('type', params.type);
  if (params.type === 'BASELINE' && params.envCondition) fd.set('envCondition', params.envCondition);
  fd.set('uploader', params.uploader);
  fd.set('file', params.file);
  return api<ThermalImage>(`/api/images`, { method: 'POST', body: fd });
}

export async function listImages(params: {
  transformerId?: string;
  type?: 'BASELINE' | 'MAINTENANCE';
  page?: number;
  size?: number;
} = {}) {
  const q = new URLSearchParams();
  if (params.transformerId) q.set('transformerId', params.transformerId);
  if (params.type) q.set('type', params.type);
  if (params.page != null) q.set('page', String(params.page));
  if (params.size != null) q.set('size', String(params.size));
  return api<{ content: ThermalImage[]; totalElements: number }>(`/api/images${q.toString() ? `?${q.toString()}` : ''}`);
}