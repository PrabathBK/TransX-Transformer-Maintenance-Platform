// src/pages/MaintenanceRecordPage.tsx
import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import MaintenanceRecordForm from '../components/MaintenanceRecordForm';
import {
  getMaintenanceRecord,
  getMaintenanceRecordByInspection,
  createMaintenanceRecord,
  updateMaintenanceRecord,
  type MaintenanceRecord,
  type UpdateMaintenanceRecordRequest
} from '../api/maintenanceRecords';
import { getInspection, type Inspection } from '../api/inspections';

export default function MaintenanceRecordPage() {
  const { inspectionId, recordId } = useParams();
  const nav = useNavigate();

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [record, setRecord] = useState<MaintenanceRecord | null>(null);
  const [inspection, setInspection] = useState<Inspection | null>(null);
  const [saving, setSaving] = useState(false);

  // Load maintenance record
  useEffect(() => {
    loadRecord();
  }, [inspectionId, recordId]);

  async function loadRecord() {
    try {
      setLoading(true);
      setError(null);

      if (recordId) {
        // Load existing record by ID
        const recordData = await getMaintenanceRecord(recordId);
        setRecord(recordData);
        
        // Load associated inspection
        const inspectionData = await getInspection(recordData.inspectionId);
        setInspection(inspectionData);
      } else if (inspectionId) {
        // Try to load existing record for this inspection
        try {
          const recordData = await getMaintenanceRecordByInspection(inspectionId);
          setRecord(recordData);
          
          // Redirect to record URL
          nav(`/maintenance-records/${recordData.id}`, { replace: true });
        } catch (e: any) {
          // No record exists, create one
          // Check for 404 status or "not found" message
          if (e?.message?.includes('404') || e?.message?.toLowerCase().includes('not found')) {
            console.log('No existing maintenance record found, creating new one...');
            await handleCreateRecord(inspectionId);
          } else {
            throw e;
          }
        }
      }
    } catch (e: any) {
      setError(e?.message || 'Failed to load maintenance record');
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateRecord(inspId: string) {
    try {
      setLoading(true);
      console.log('Creating new maintenance record for inspection:', inspId);
      
      // Load inspection first
      const inspectionData = await getInspection(inspId);
      setInspection(inspectionData);
      console.log('Inspection loaded:', inspectionData.inspectionNumber);

      // Create maintenance record
      const newRecord = await createMaintenanceRecord({
        inspectionId: inspId,
        createdBy: 'engineer' // TODO: Get from auth context
      });
      
      console.log('Maintenance record created successfully:', newRecord.recordNumber);
      setRecord(newRecord);
      
      // Redirect to record URL
      nav(`/maintenance-records/${newRecord.id}`, { replace: true });
    } catch (e: any) {
      console.error('Failed to create maintenance record:', e);
      setError(e?.message || 'Failed to create maintenance record');
    } finally {
      setLoading(false);
    }
  }

  async function handleSave(updates: UpdateMaintenanceRecordRequest) {
    if (!record) return;

    try {
      setSaving(true);
      setError(null);

      const updated = await updateMaintenanceRecord(record.id, updates);
      setRecord(updated);
      
      alert('Maintenance record saved successfully!');
    } catch (e: any) {
      setError(e?.message || 'Failed to save maintenance record');
      alert('Failed to save: ' + (e?.message || 'Unknown error'));
    } finally {
      setSaving(false);
    }
  }

  async function handleDownloadPDF() {
    if (!record) return;

    try {
      // For now, we'll use the browser's print functionality
      // Later, this can be enhanced with a backend PDF generation endpoint
      window.print();
    } catch (e: any) {
      alert('Failed to generate PDF: ' + (e?.message || 'Unknown error'));
    }
  }

  if (loading) {
    return (
      <div style={{ padding: '40px', textAlign: 'center' }}>
        <h2>Loading...</h2>
      </div>
    );
  }

  if (error && !record) {
    return (
      <div style={{ padding: '40px' }}>
        <div style={{ 
          background: '#f8d7da', 
          color: '#721c24', 
          padding: '15px', 
          borderRadius: '8px',
          marginBottom: '20px'
        }}>
          <strong>Error:</strong> {error}
        </div>
        <button
          onClick={() => nav(-1)}
          style={{
            padding: '10px 20px',
            background: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer'
          }}
        >
          Go Back
        </button>
      </div>
    );
  }

  if (!record) {
    return (
      <div style={{ padding: '40px', textAlign: 'center' }}>
        <h2>No maintenance record found</h2>
      </div>
    );
  }

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '20px' }}>
      {/* Header */}
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '20px'
      }}>
        <div>
          <button
            onClick={() => nav(`/inspections/${record.inspectionId}`)}
            style={{
              padding: '8px 16px',
              background: '#6c757d',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              marginRight: '10px'
            }}
          >
            ← Back to Inspection
          </button>
          <h1 style={{ display: 'inline', marginLeft: '10px' }}>
            Maintenance Record
          </h1>
        </div>
        
        {inspection && (
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '14px', color: '#666' }}>
              Inspection: {inspection.inspectionNumber}
            </div>
            <div style={{ fontSize: '14px', color: '#666' }}>
              Transformer: {inspection.transformerCode}
            </div>
          </div>
        )}
      </div>

      {/* Error Message */}
      {error && (
        <div style={{ 
          background: '#fff3cd', 
          color: '#856404', 
          padding: '12px', 
          borderRadius: '6px',
          marginBottom: '20px',
          border: '1px solid #ffeaa7'
        }}>
          <strong>Warning:</strong> {error}
        </div>
      )}

      {/* Saving Indicator */}
      {saving && (
        <div style={{ 
          background: '#d1ecf1', 
          color: '#0c5460', 
          padding: '12px', 
          borderRadius: '6px',
          marginBottom: '20px',
          border: '1px solid #bee5eb'
        }}>
          Saving changes...
        </div>
      )}

      {/* Form */}
      <div style={{ 
        background: 'white', 
        borderRadius: '8px', 
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        overflow: 'hidden'
      }}>
        <MaintenanceRecordForm
          record={record}
          onSave={handleSave}
          onDownloadPDF={handleDownloadPDF}
          inspectionImageUrl={inspection?.inspectionImageUrl || record.thermalImageUrl}
        />
      </div>

      {/* Anomalies Section */}
      {record.anomalies && record.anomalies.length > 0 && (
        <div style={{ 
          marginTop: '30px',
          background: 'white', 
          borderRadius: '8px', 
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          padding: '20px'
        }}>
          <h3 style={{ marginTop: 0 }}>Detected Anomalies ({record.anomalyCount})</h3>
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ background: '#f8f9fa', borderBottom: '2px solid #dee2e6' }}>
                  <th style={{ padding: '12px', textAlign: 'left' }}>Box #</th>
                  <th style={{ padding: '12px', textAlign: 'left' }}>Class</th>
                  <th style={{ padding: '12px', textAlign: 'left' }}>Confidence</th>
                  <th style={{ padding: '12px', textAlign: 'left' }}>Source</th>
                  <th style={{ padding: '12px', textAlign: 'left' }}>Location (BBox)</th>
                </tr>
              </thead>
              <tbody>
                {record.anomalies.map((anomaly, idx) => (
                  <tr key={anomaly.id} style={{ borderBottom: '1px solid #dee2e6' }}>
                    <td style={{ padding: '12px' }}>{anomaly.boxNumber || idx + 1}</td>
                    <td style={{ padding: '12px' }}>
                      <span style={{
                        padding: '4px 8px',
                        borderRadius: '4px',
                        background: anomaly.className.includes('faulty') ? '#f8d7da' : '#fff3cd',
                        color: anomaly.className.includes('faulty') ? '#721c24' : '#856404',
                        fontSize: '12px',
                        fontWeight: 'bold'
                      }}>
                        {anomaly.className}
                      </span>
                    </td>
                    <td style={{ padding: '12px' }}>
                      {anomaly.confidence ? `${(anomaly.confidence * 100).toFixed(1)}%` : 'N/A'}
                    </td>
                    <td style={{ padding: '12px' }}>
                      <span style={{
                        padding: '4px 8px',
                        borderRadius: '4px',
                        background: anomaly.source === 'ai' ? '#d1ecf1' : '#d4edda',
                        color: anomaly.source === 'ai' ? '#0c5460' : '#155724',
                        fontSize: '12px'
                      }}>
                        {anomaly.source}
                      </span>
                    </td>
                    <td style={{ padding: '12px', fontSize: '12px', color: '#666' }}>
                      ({anomaly.bboxX1}, {anomaly.bboxY1}) - ({anomaly.bboxX2}, {anomaly.bboxY2})
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
