// src/components/InspectionHistoryList.tsx
import React, { useEffect, useState } from 'react';
import { getInspectionHistory, type HistoryEntry } from '../api/history';

interface InspectionHistoryListProps {
  inspectionId: string;
}

const InspectionHistoryList: React.FC<InspectionHistoryListProps> = ({ inspectionId }) => {
  const [history, setHistory] = useState<HistoryEntry[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [collapsed, setCollapsed] = useState(false);

  useEffect(() => {
    loadHistory();
  }, [inspectionId]);

  async function loadHistory() {
    try {
      setLoading(true);
      setError(null);
      const historyData = await getInspectionHistory(inspectionId);
      setHistory(historyData);
    } catch (err: any) {
      setError(err?.message || 'Failed to load inspection history');
    } finally {
      setLoading(false);
    }
  }

  const getActionIcon = (actionType: string) => {
    switch (actionType) {
      case 'CREATED': return '📝';
      case 'STATUS_CHANGED': return '🔄';
      case 'ANNOTATION_ADDED': return '📌';
      case 'ANNOTATION_MODIFIED': return '✏️';
      case 'ANNOTATION_DELETED': return '🗑️';
      case 'INSPECTOR_ASSIGNED': return '👤';
      case 'NOTES_UPDATED': return '📋';
      default: return '📋';
    }
  };

  const getActionColor = (actionType: string) => {
    switch (actionType) {
      case 'CREATED': return '#22c55e';
      case 'STATUS_CHANGED': return '#3b82f6';
      case 'ANNOTATION_ADDED': return '#8b5cf6';
      case 'ANNOTATION_MODIFIED': return '#f59e0b';
      case 'ANNOTATION_DELETED': return '#ef4444';
      case 'INSPECTOR_ASSIGNED': return '#06b6d4';
      case 'NOTES_UPDATED': return '#6b7280';
      default: return '#6b7280';
    }
  };

  const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  if (loading) {
    return (
      <div style={{ 
        padding: '20px', 
        textAlign: 'center',
        background: '#f9fafb',
        borderRadius: '12px',
        border: '1px solid #e5e7eb'
      }}>
        <div style={{ fontSize: '16px', color: '#6b7280' }}>Loading history...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ 
        padding: '20px', 
        textAlign: 'center',
        background: '#fef2f2',
        borderRadius: '12px',
        border: '1px solid #fecaca'
      }}>
        <div style={{ fontSize: '16px', color: '#ef4444' }}>Error: {error}</div>
        <button
          onClick={loadHistory}
          style={{
            marginTop: '8px',
            padding: '6px 12px',
            background: '#ef4444',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            fontSize: '12px',
            cursor: 'pointer'
          }}
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div style={{
      marginTop: '24px',
      background: '#fff',
      borderRadius: '12px',
      border: '1px solid #e5e7eb',
      boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)'
    }}>
      {/* Header */}
      <div 
        onClick={() => setCollapsed(!collapsed)}
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '16px 20px',
          borderBottom: collapsed ? 'none' : '1px solid #e5e7eb',
          cursor: 'pointer',
          background: collapsed ? '#f9fafb' : '#fff',
          borderRadius: collapsed ? '12px' : '12px 12px 0 0'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ fontSize: '20px' }}>📋</span>
          <h3 style={{ 
            margin: 0, 
            fontSize: '18px', 
            fontWeight: '600', 
            color: '#1f2937' 
          }}>
            Inspection History
          </h3>
          <span style={{
            background: '#e5e7eb',
            color: '#374151',
            fontSize: '12px',
            fontWeight: '600',
            padding: '2px 8px',
            borderRadius: '12px'
          }}>
            {history.length} {history.length === 1 ? 'entry' : 'entries'}
          </span>
        </div>
        <div style={{ 
          fontSize: '18px', 
          transform: collapsed ? 'rotate(-90deg)' : 'rotate(0deg)',
          transition: 'transform 0.2s'
        }}>
          ▼
        </div>
      </div>

      {/* History List */}
      {!collapsed && (
        <div style={{ padding: '0' }}>
          {history.length === 0 ? (
            <div style={{ 
              padding: '40px 20px', 
              textAlign: 'center',
              color: '#6b7280'
            }}>
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>📝</div>
              <div>No history entries yet</div>
              <div style={{ fontSize: '14px', marginTop: '4px' }}>
                Actions on this inspection will appear here
              </div>
            </div>
          ) : (
            <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
              {history.map((entry, index) => (
                <div 
                  key={index}
                  style={{
                    padding: '16px 20px',
                    borderBottom: index < history.length - 1 ? '1px solid #f3f4f6' : 'none',
                    display: 'flex',
                    alignItems: 'flex-start',
                    gap: '12px'
                  }}
                >
                  {/* Action Icon */}
                  <div style={{
                    width: '32px',
                    height: '32px',
                    borderRadius: '50%',
                    background: `${getActionColor(entry.actionType)}20`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '14px',
                    flexShrink: 0
                  }}>
                    {getActionIcon(entry.actionType)}
                  </div>

                  {/* Content */}
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ 
                      display: 'flex', 
                      alignItems: 'center', 
                      gap: '8px',
                      marginBottom: '4px'
                    }}>
                      <span style={{
                        fontWeight: '600',
                        fontSize: '14px',
                        color: getActionColor(entry.actionType)
                      }}>
                        {entry.actionType.replace('_', ' ')}
                      </span>
                      {entry.boxNumber && (
                        <span style={{
                          background: '#f3f4f6',
                          color: '#374151',
                          fontSize: '11px',
                          fontWeight: '600',
                          padding: '2px 6px',
                          borderRadius: '4px'
                        }}>
                          Box #{entry.boxNumber}
                        </span>
                      )}
                    </div>

                    <div style={{ 
                      fontSize: '14px', 
                      color: '#374151',
                      marginBottom: '6px',
                      lineHeight: 1.4
                    }}>
                      {entry.actionDescription}
                    </div>

                    <div style={{ 
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      fontSize: '12px',
                      color: '#6b7280'
                    }}>
                      <span>👤 {entry.userName || 'System'}</span>
                      <span> {formatDateTime(entry.createdAt)}</span>
                    </div>

                    {(entry.previousData || entry.newData) && (
                      <div style={{
                        marginTop: '8px',
                        padding: '8px 12px',
                        background: '#f9fafb',
                        borderRadius: '6px',
                        fontSize: '12px',
                        color: '#6b7280'
                      }}>
                        {entry.previousData && <div><strong>Before:</strong> {entry.previousData}</div>}
                        {entry.newData && <div><strong>After:</strong> {entry.newData}</div>}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default InspectionHistoryList;