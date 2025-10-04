// src/components/NotesSection.tsx
import { useState } from 'react';
import { updateInspectionNotes } from '../api/inspections';

interface NotesSectionProps {
  inspectionId: string;
  initialNotes: string;
  onNotesUpdate: () => void;
}

export default function NotesSection({ inspectionId, initialNotes, onNotesUpdate }: NotesSectionProps) {
  const [notes, setNotes] = useState(initialNotes);
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [saveSuccess, setSaveSuccess] = useState(false);

  const handleSave = async () => {
    if (notes.trim() === initialNotes.trim()) {
      setIsEditing(false);
      return;
    }

    try {
      setIsSaving(true);
      setSaveError(null);
      
      await updateInspectionNotes(inspectionId, notes.trim());
      
      setSaveSuccess(true);
      setIsEditing(false);
      setTimeout(() => setSaveSuccess(false), 2000);
      onNotesUpdate();
    } catch (e: any) {
      setSaveError(e?.message || 'Failed to save notes');
    } finally {
      setIsSaving(false);
    }
  };

  const handleCancel = () => {
    setNotes(initialNotes);
    setIsEditing(false);
    setSaveError(null);
  };

  return (
    <div style={{
      background: 'white',
      borderRadius: '12px',
      boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
      padding: '20px',
      marginTop: '16px',
      border: '1px solid #e5e7eb'
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
        <h3 style={{ margin: 0, fontSize: '16px', fontWeight: '600', color: '#374151' }}>
          Notes
        </h3>
        {!isEditing && (
          <button
            onClick={() => setIsEditing(true)}
            style={{
              padding: '6px 12px',
              borderRadius: '6px',
              border: '1px solid #d1d5db',
              background: 'white',
              color: '#374151',
              fontSize: '13px',
              fontWeight: '500',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '4px',
              transition: 'all 0.2s'
            }}
          >
            ✏️ Edit
          </button>
        )}
      </div>

      {isEditing ? (
        <div>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Add inspection notes..."
            style={{
              width: '100%',
              minHeight: '100px',
              padding: '12px',
              border: '1px solid #d1d5db',
              borderRadius: '6px',
              fontSize: '14px',
              lineHeight: '1.5',
              resize: 'vertical',
              fontFamily: 'inherit'
            }}
          />
          
          {saveError && (
            <div style={{ 
              marginTop: '8px', 
              color: '#dc2626', 
              fontSize: '13px',
              display: 'flex',
              alignItems: 'center',
              gap: '4px'
            }}>
              ❌ {saveError}
            </div>
          )}
          
          <div style={{ 
            display: 'flex', 
            gap: '8px', 
            marginTop: '12px',
            justifyContent: 'flex-end'
          }}>
            <button
              onClick={handleCancel}
              disabled={isSaving}
              style={{
                padding: '8px 16px',
                borderRadius: '6px',
                border: '1px solid #d1d5db',
                background: 'white',
                color: '#374151',
                fontSize: '14px',
                fontWeight: '500',
                cursor: isSaving ? 'not-allowed' : 'pointer'
              }}
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={isSaving}
              style={{
                padding: '8px 16px',
                borderRadius: '6px',
                border: 'none',
                background: isSaving ? '#9ca3af' : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                color: 'white',
                fontSize: '14px',
                fontWeight: '600',
                cursor: isSaving ? 'not-allowed' : 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '6px'
              }}
            >
              {isSaving ? '💾 Saving...' : '💾 Save'}
            </button>
          </div>
        </div>
      ) : (
        <div>
          {saveSuccess && (
            <div style={{ 
              marginBottom: '12px', 
              color: '#059669', 
              fontSize: '13px',
              display: 'flex',
              alignItems: 'center',
              gap: '4px'
            }}>
              ✅ Notes saved successfully!
            </div>
          )}
          
          <div style={{ 
            fontSize: '14px', 
            color: notes ? '#374151' : '#9ca3af', 
            lineHeight: '1.6',
            whiteSpace: 'pre-wrap',
            minHeight: '40px',
            padding: '8px 0'
          }}>
            {notes || 'No notes added yet. Click "Edit" to add inspection notes.'}
          </div>
        </div>
      )}
    </div>
  );
}