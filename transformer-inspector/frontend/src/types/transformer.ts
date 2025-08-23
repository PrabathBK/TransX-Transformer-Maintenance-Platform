export interface Transformer {
  id: string;
  transformerNo: string;
  poleNo: string;
  region: string;
  type: 'Bulk' | 'Distribution';
  locationDetails: string;
  isStarred?: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ThermalImage {
  id: string;
  transformerId: string;
  imageUrl: string;
  type: 'Baseline' | 'Maintenance';
  environmentalCondition?: 'Sunny' | 'Cloudy' | 'Rainy';
  uploadDate: string;
  uploader: string;
  metadata?: {
    fileSize: number;
    dimensions: { width: number; height: number };
    format: string;
  };
}

export interface Inspection {
  id: string;
  inspectionNo: string;
  transformerId: string;
  inspectedDate: string;
  maintenanceDate?: string;
  status: 'In Progress' | 'Pending' | 'Completed';
  inspectedBy: string;
  thermalImages: ThermalImage[];
  notes?: string;
}

export interface TransformerStats {
  total: number;
  byRegion: Record<string, number>;
  byType: Record<string, number>;
  byStatus: Record<string, number>;
}