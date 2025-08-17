// src/api/images.ts
import { api } from './client';

// ---- Types ---------------------------------------------------------------

export type ImageType = 'BASELINE' | 'MAINTENANCE';
export type EnvCondition = 'SUNNY' | 'CLOUDY' | 'RAINY';

export type ThermalImage = {
  id: string;
  transformerId: string;
  type: ImageType;
  envCondition?: EnvCondition;
  uploader: string;
  uploadedAt: string;         // ISO string from backend
  publicUrl: string;
  originalFilename: string;
  sizeBytes: number;
  contentType: string;
};

export type PageResp<T> = {
  content: T[];
  totalElements: number;
  totalPages?: number;
  number?: number;
  size?: number;
};

// ---- Helpers -------------------------------------------------------------

function qs(params: Record<string, string | number | undefined>): string {
  const p = new URLSearchParams();
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') p.set(k, String(v));
  });
  const s = p.toString();
  return s ? `?${s}` : '';
}

// ---- API ----------------------------------------------------------------

/**
 * Upload a thermal image for a specific transformer.
 * NOTE: Do NOT set Content-Type when sending FormData. The browser will set the boundary.
 */
export async function uploadImage(params: {
  transformerId: string;
  type: ImageType;
  envCondition?: EnvCondition;     // required when type === 'BASELINE'
  uploader: string;
  file: File;
}) {
  const fd = new FormData();
  fd.set('transformerId', params.transformerId);
  fd.set('type', params.type);
  if (params.type === 'BASELINE' && params.envCondition) {
    fd.set('envCondition', params.envCondition);
  }
  fd.set('uploader', params.uploader);
  fd.set('file', params.file);

  // No headers here – fetch will add multipart/form-data with boundary automatically
  return api<ThermalImage>(`/api/images`, { method: 'POST', body: fd });
}

/**
 * List images with optional filters and pagination.
 * If transformerId is provided, results are scoped to that transformer.
 */
export async function listImages(params: {
  transformerId?: string;
  type?: ImageType;
  page?: number;
  size?: number;
} = {}) {
  const query = qs({
    transformerId: params.transformerId,
    type: params.type,
    page: params.page ?? 0,
    size: params.size ?? 20,
  });
  return api<PageResp<ThermalImage>>(`/api/images${query}`);
}

/**
 * Convenience: get the most recent BASELINE and/or MAINTENANCE images
 * for a transformer in a single call (client-side pick from a single page).
 * Falls back to empty if none.
 */
export async function getLatestForTransformer(transformerId: string) {
  const page = await listImages({ transformerId, page: 0, size: 200 });
  const sorted = [...(page.content ?? [])].sort(
    (a, b) => +new Date(b.uploadedAt) - +new Date(a.uploadedAt)
  );

  const latestBaseline = sorted.find(i => i.type === 'BASELINE') ?? null;
  const latestMaintenance = sorted.find(i => i.type === 'MAINTENANCE') ?? null;

  // If only one exists, return it twice to satisfy the Phase-1 UI requirement
  const pair: [ThermalImage | null, ThermalImage | null] =
    latestBaseline && latestMaintenance
      ? [latestBaseline, latestMaintenance]
      : (latestBaseline || latestMaintenance)
      ? [latestBaseline || latestMaintenance, latestBaseline || latestMaintenance]
      : [null, null];

  return { latestBaseline, latestMaintenance, pair, all: sorted };
}