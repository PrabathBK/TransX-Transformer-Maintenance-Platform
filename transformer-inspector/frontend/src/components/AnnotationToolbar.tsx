// src/components/AnnotationToolbar.tsx
interface AnnotationToolbarProps {
  mode: 'view' | 'edit' | 'draw';
  onModeChange: (mode: 'view' | 'edit' | 'draw') => void;
  selectedClass: string;
  onClassChange: (className: string) => void;
  onZoomIn: () => void;
  onZoomOut: () => void;
  onResetView: () => void;
  onDetectAnomalies?: () => void;
  isDetecting?: boolean;
}

const DETECTION_CLASSES = [
  { value: 'Faulty', label: 'Faulty', color: '#ef4444' },
  { value: 'faulty_loose_joint', label: 'Loose Joint', color: '#22c55e' },
  { value: 'faulty_point_overload', label: 'Point Overload', color: '#3b82f6' },
  { value: 'potential_faulty', label: 'Potential Faulty', color: '#eab308' },
];

export default function AnnotationToolbar({
  mode,
  onModeChange,
  selectedClass,
  onClassChange,
  onZoomIn,
  onZoomOut,
  onResetView,
  onDetectAnomalies,
  isDetecting = false,
}: AnnotationToolbarProps) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      gap: '16px',
      padding: '20px',
      background: '#ffffff',
      borderRadius: '12px',
      boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
      marginBottom: '16px',
      border: '1px solid #e5e7eb'
    }}>
      {/* Top Row: Mode Controls and AI Detection */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ fontSize: '14px', fontWeight: '600', color: '#374151', marginRight: '8px' }}>
            Mode:
          </span>
          <div style={{ display: 'flex', gap: '6px' }}>
            <ToolButton
              active={mode === 'view'}
              onClick={() => onModeChange('view')}
              icon="👁️"
              label="View"
            />
            <ToolButton
              active={mode === 'edit'}
              onClick={() => onModeChange('edit')}
              icon="✏️"
              label="Edit"
            />
            <ToolButton
              active={mode === 'draw'}
              onClick={() => onModeChange('draw')}
              icon="➕"
              label="Draw"
            />
          </div>
        </div>

        {/* AI Detection Button */}
        {onDetectAnomalies && (
          <button
            onClick={onDetectAnomalies}
            disabled={isDetecting}
            style={{
              padding: '10px 20px',
              borderRadius: '8px',
              border: 'none',
              background: isDetecting 
                ? '#9ca3af' 
                : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
              color: 'white',
              fontSize: '14px',
              fontWeight: '600',
              cursor: isDetecting ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              transition: 'all 0.2s',
              boxShadow: isDetecting ? 'none' : '0 2px 8px rgba(59, 130, 246, 0.3)',
            }}
          >
            <span>{isDetecting ? '⏳' : ''}</span>
            {isDetecting ? 'Detecting...' : 'Detect Anomalies'}
          </button>
        )}
      </div>

      {/* Second Row: Class Selector and Zoom Controls */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}>
        {mode === 'draw' && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <span style={{ fontSize: '14px', fontWeight: '600', color: '#374151' }}>
              Fault Type:
            </span>
            <select
              value={selectedClass}
              onChange={(e) => onClassChange(e.target.value)}
              style={{
                padding: '8px 12px',
                borderRadius: '6px',
                border: '1px solid #d1d5db',
                background: 'white',
                color: '#374151',
                fontSize: '14px',
                cursor: 'pointer',
                minWidth: '150px'
              }}
            >
              {DETECTION_CLASSES.map((cls) => (
                <option key={cls.value} value={cls.value}>
                  {cls.label}
                </option>
              ))}
            </select>
          </div>
        )}

        {/* Zoom Controls */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginLeft: mode === 'draw' ? '0' : 'auto' }}>
          <span style={{ fontSize: '14px', fontWeight: '600', color: '#374151' }}>
            Zoom:
          </span>
          <div style={{ display: 'flex', gap: '6px' }}>
            <ToolButton onClick={onZoomIn} icon="+" label="In" />
            <ToolButton onClick={onZoomOut} icon="−" label="Out" />
            <ToolButton onClick={onResetView} icon="⌂" label="Reset" />
          </div>
        </div>
      </div>
    </div>
  );
}

interface ToolButtonProps {
  active?: boolean;
  onClick: () => void;
  icon: string;
  label: string;
}

function ToolButton({ active = false, onClick, icon, label }: ToolButtonProps) {
  return (
    <button
      onClick={onClick}
      style={{
        padding: '8px 12px',
        borderRadius: '6px',
        border: active ? '2px solid #3b82f6' : '1px solid #d1d5db',
        background: active ? '#eff6ff' : 'white',
        color: active ? '#1d4ed8' : '#374151',
        fontSize: '14px',
        fontWeight: active ? '600' : '500',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '6px',
        transition: 'all 0.2s',
        minWidth: '80px',
        justifyContent: 'center'
      }}
      title={label}
    >
      <span style={{ fontSize: '16px' }}>{icon}</span>
      <span style={{ fontSize: '13px' }}>{label}</span>
    </button>
  );
}
