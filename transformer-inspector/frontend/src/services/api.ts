// src/api/api.ts
import { Transformer, ThermalImage, Inspection } from '@/types/transformer';

class ApiService {
  private baseUrl = 'http://localhost:8080/api'; // Change to your backend URL

  // ============================
  // Transformer APIs
  // ============================
  async getTransformers(): Promise<Transformer[]> {
    const res = await fetch(`${this.baseUrl}/transformers`);
    if (!res.ok) throw new Error('Failed to fetch transformers');
    return res.json();
  }

  async getTransformer(id: string): Promise<Transformer> {
    const res = await fetch(`${this.baseUrl}/transformers/${id}`);
    if (!res.ok) throw new Error('Transformer not found');
    return res.json();
  }

  async createTransformer(
    data: Omit<Transformer, 'id' | 'createdAt' | 'updatedAt'>
  ): Promise<Transformer> {
    const res = await fetch(`${this.baseUrl}/transformers`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!res.ok) {
      const err = await res.json();
      throw new Error(err.message || 'Failed to create transformer');
    }
    return res.json();
  }

  async updateTransformer(
    id: string,
    data: Partial<Transformer>
  ): Promise<Transformer> {
    const res = await fetch(`${this.baseUrl}/transformers/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error('Failed to update transformer');
    return res.json();
  }

  async deleteTransformer(id: string): Promise<void> {
    const res = await fetch(`${this.baseUrl}/transformers/${id}`, {
      method: 'DELETE',
    });
    if (!res.ok) throw new Error('Failed to delete transformer');
  }

  // ============================
  // Thermal Image APIs
  // ============================
  async uploadThermalImage(
    transformerId: string,
    file: File,
    type: 'Baseline' | 'Maintenance',
    environmentalCondition?: 'Sunny' | 'Cloudy' | 'Rainy'
  ): Promise<ThermalImage> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('type', type);
    if (environmentalCondition) {
      formData.append('environmentalCondition', environmentalCondition);
    }

    const res = await fetch(
      `${this.baseUrl}/thermal-images/upload/${transformerId}`,
      {
        method: 'POST',
        body: formData,
      }
    );
    if (!res.ok) throw new Error('Failed to upload thermal image');
    return res.json();
  }

  async getThermalImages(transformerId: string): Promise<ThermalImage[]> {
    const res = await fetch(`${this.baseUrl}/thermal-images/${transformerId}`);
    if (!res.ok) throw new Error('Failed to fetch thermal images');
    return res.json();
  }

  // ============================
  // Inspection APIs
  // ============================
  async getInspections(): Promise<Inspection[]> {
    const res = await fetch(`${this.baseUrl}/inspections`);
    if (!res.ok) throw new Error('Failed to fetch inspections');
    return res.json();
  }

  async createInspection(
    data: Omit<Inspection, 'id' | 'inspectionNo'>
  ): Promise<Inspection> {
    const res = await fetch(`${this.baseUrl}/inspections`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error('Failed to create inspection');
    return res.json();
  }
}

export const apiService = new ApiService();

