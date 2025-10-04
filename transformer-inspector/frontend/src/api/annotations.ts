// // src/api/annotations.ts
// import { api } from './client';

// export type BoundingBox = {
//   x1: number;
//   y1: number;
//   x2: number;
//   y2: number;
// };

// export type Annotation = {
//   id: string;
//   inspectionId: string;
//   bbox: BoundingBox;
//   className: string;
//   confidence: number;
//   source: 'ai' | 'human';
//   status: 'PENDING' | 'APPROVED' | 'REJECTED';
//   actionType?: 'created' | 'edited' | 'approved' | 'rejected';
//   version?: number;
//   createdBy?: string;
//   createdAt: string;
//   modifiedBy?: string;
//   modifiedAt?: string;
//   updatedAt: string;
// };

// export type SaveAnnotationRequest = {
//   id?: string; // For updates - creates new version when provided
//   inspectionId: string;
//   bbox: BoundingBox;
//   classId?: number;
//   className: string;
//   confidence?: number;
//   source?: 'ai' | 'human';
//   userId?: string;
// };

// export type FeedbackExport = {
//   inspectionId: string;
//   inspectionNumber: string;
//   aiAnnotations: Annotation[];
//   humanAnnotations: Annotation[];
//   approvedAnnotations: Annotation[];
//   rejectedAnnotations: Annotation[];
// };

// export async function getAnnotationsByInspection(inspectionId: string) {
//   return api<Annotation[]>(`/api/annotations?inspectionId=${inspectionId}`);
// }

// export async function saveAnnotation(body: SaveAnnotationRequest) {
//   return api<Annotation>(`/api/annotations`, {
//     method: 'POST',
//     headers: { 'Content-Type': 'application/json' },
//     body: JSON.stringify(body),
//   });
// }

// export async function approveAnnotation(id: string, userId: string) {
//   return api<Annotation>(`/api/annotations/${id}/approve?userId=${encodeURIComponent(userId)}`, {
//     method: 'POST',
//   });
// }

// export async function rejectAnnotation(id: string, userId: string, reason: string = 'User rejected') {
//   return api<Annotation>(`/api/annotations/${id}/reject`, {
//     method: 'POST',
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     body: JSON.stringify({
//       userId: userId,
//       reason: reason
//     })
//   });
// }

// export async function deleteAnnotation(id: string, userId: string) {
//   return api<void>(`/api/annotations/${id}?userId=${encodeURIComponent(userId)}`, {
//     method: 'DELETE',
//   });
// }

// export async function getAnnotationHistory(id: string) {
//   return api<Annotation[]>(`/api/annotations/${id}/history`);
// }

// export async function exportFeedback(inspectionId: string) {
//   return api<FeedbackExport>(`/api/inspections/${inspectionId}/feedback-export`);
// }

// export async function exportFeedbackCSV(inspectionId: string) {
//   const url = `/api/inspections/${inspectionId}/feedback-export/csv`;
//   // For CSV download, we'll trigger a direct download
//   window.open(`${import.meta.env.VITE_API_BASE || 'http://localhost:8080'}${url}`, '_blank');
// }


// src/api/annotations.ts
import { api } from './client';

export type BoundingBox = {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
};

export type Annotation = {
  id: string;
  inspectionId: string;
  bbox: BoundingBox;

  // class info
  classId?: number;              // <-- make optional; AI/manual may omit
  className: string;

  confidence: number;
  source: 'ai' | 'human';

  // workflow
  status?: 'PENDING' | 'APPROVED' | 'REJECTED';
  actionType?: 'created' | 'edited' | 'deleted' | 'approved' | 'rejected';
  version?: number;

  // audit
  createdBy?: string;
  createdAt: string;
  modifiedBy?: string;
  modifiedAt?: string;
  updatedAt?: string;

  // ---- NEW FIELDS ----
  annotationNumber?: number;
  sizePx?: number;
  severityScore?: number | null;
  flagged?: boolean;

  // optional extras your backend might return
  // comments?: string;
};

export type SaveAnnotationRequest = {
  id?: string; // for update/versioning
  inspectionId: string;
  bbox: BoundingBox;
  classId?: number;
  className: string;
  confidence?: number;
  source?: 'ai' | 'human';
  userId?: string;

  // ---- NEW FIELDS ----
  annotationNumber?: number;
  sizePx?: number;
  severityScore?: number | null;
  flagged?: boolean;
};

export type FeedbackExport = {
  inspectionId: string;
  inspectionNumber: string;
  aiAnnotations: Annotation[];
  humanAnnotations: Annotation[];
  approvedAnnotations: Annotation[];
  rejectedAnnotations: Annotation[];
};

export async function getAnnotationsByInspection(inspectionId: string) {
  return api<Annotation[]>(`/api/annotations?inspectionId=${inspectionId}`);
}

export async function saveAnnotation(body: SaveAnnotationRequest) {
  return api<Annotation>(`/api/annotations`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

export async function approveAnnotation(id: string, userId: string) {
  return api<Annotation>(`/api/annotations/${id}/approve?userId=${encodeURIComponent(userId)}`, {
    method: 'POST',
  });
}

export async function rejectAnnotation(id: string, userId: string, reason = 'User rejected') {
  return api<Annotation>(`/api/annotations/${id}/reject`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userId, reason }),
  });
}

export async function deleteAnnotation(id: string, userId: string) {
  return api<void>(`/api/annotations/${id}?userId=${encodeURIComponent(userId)}`, {
    method: 'DELETE',
  });
}

export async function getAnnotationHistory(id: string) {
  return api<Annotation[]>(`/api/annotations/${id}/history`);
}

export async function exportFeedback(inspectionId: string) {
  return api<FeedbackExport>(`/api/inspections/${inspectionId}/feedback-export`);
}

export async function exportFeedbackCSV(inspectionId: string) {
  const url = `/api/inspections/${inspectionId}/feedback-export/csv`;
  window.open(`${import.meta.env.VITE_API_BASE || 'http://localhost:8080'}${url}`, '_blank');
}

<<<<<<< Updated upstream
=======
export async function getAnnotationHistoryForInspection(inspectionId: string) {
  const res = await fetch(`/api/annotations/${inspectionId}/history`);
  if (!res.ok) throw new Error("Failed to load annotation history");
  return res.json();
}

>>>>>>> Stashed changes
