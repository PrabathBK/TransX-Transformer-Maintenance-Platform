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
      alignItems: 'center',
      gap: '12px',
      padding: '12px 16px',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      borderRadius: '10px',
      boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
      marginBottom: '16px',
    }}>
      {/* Mode Buttons */}
      <div style={{ display: 'flex', gap: '8px', borderRight: '1px solid rgba(255,255,255,0.3)', paddingRight: '12px' }}>
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

      {/* Class Selector (only visible in draw mode) */}
      {mode === 'draw' && (
        <div style={{ display: 'flex', gap: '8px', borderRight: '1px solid rgba(255,255,255,0.3)', paddingRight: '12px' }}>
          <label style={{ color: 'white', fontSize: '14px', fontWeight: '600', alignSelf: 'center' }}>
            Class:
          </label>
          <select
            value={selectedClass}
            onChange={(e) => onClassChange(e.target.value)}
            style={{
              padding: '6px 12px',
              borderRadius: '6px',
              border: '1px solid rgba(255,255,255,0.3)',
              background: 'rgba(255,255,255,0.2)',
              color: 'white',
              fontSize: '14px',
              cursor: 'pointer',
            }}
          >
            {DETECTION_CLASSES.map((cls) => (
              <option key={cls.value} value={cls.value} style={{ background: '#1f2937', color: 'white' }}>
                {cls.label}
              </option>
            ))}
          </select>
        </div>
      )}

      {/* Zoom Controls */}
      <div style={{ display: 'flex', gap: '8px', borderRight: '1px solid rgba(255,255,255,0.3)', paddingRight: '12px' }}>
        <ToolButton onClick={onZoomIn} icon="🔍+" label="Zoom In" />
        <ToolButton onClick={onZoomOut} icon="🔍-" label="Zoom Out" />
        <ToolButton onClick={onResetView} icon="🔄" label="Reset" />
      </div>

      {/* AI Detection Button */}
      {onDetectAnomalies && (
        <button
          onClick={onDetectAnomalies}
          disabled={isDetecting}
          style={{
            padding: '8px 16px',
            borderRadius: '8px',
            border: 'none',
            background: isDetecting 
              ? 'rgba(156, 163, 175, 0.5)' 
              : 'linear-gradient(135deg, #f59e0b 0%, #ef4444 100%)',
            color: 'white',
            fontSize: '14px',
            fontWeight: '600',
            cursor: isDetecting ? 'not-allowed' : 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.2s',
            boxShadow: isDetecting ? 'none' : '0 2px 8px rgba(239, 68, 68, 0.3)',
          }}
        >
          <span>{isDetecting ? '⏳' : '🤖'}</span>
          {isDetecting ? 'Detecting...' : 'Detect Anomalies'}
        </button>
      )}

      {/* Legend */}
      <div style={{ 
        marginLeft: 'auto', 
        display: 'flex', 
        gap: '12px',
        paddingLeft: '12px',
        borderLeft: '1px solid rgba(255,255,255,0.3)'
      }}>
        {DETECTION_CLASSES.map((cls) => (
          <div key={cls.value} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <div style={{
              width: '12px',
              height: '12px',
              background: cls.color,
              borderRadius: '2px',
              border: '1px solid white'
            }} />
            <span style={{ color: 'white', fontSize: '12px', fontWeight: '500' }}>
              {cls.label}
            </span>
          </div>
        ))}
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
        border: active ? '2px solid white' : '1px solid rgba(255,255,255,0.3)',
        background: active ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.1)',
        color: 'white',
        fontSize: '14px',
        fontWeight: active ? '600' : '500',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '6px',
        transition: 'all 0.2s',
      }}
      title={label}
    >
      <span>{icon}</span>
      <span style={{ fontSize: '13px' }}>{label}</span>
    </button>
  );
}
