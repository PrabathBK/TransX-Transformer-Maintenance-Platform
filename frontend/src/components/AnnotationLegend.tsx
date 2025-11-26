// src/components/AnnotationLegend.tsx
interface AnnotationLegendProps {
  layout?: 'horizontal' | 'vertical';
  compact?: boolean;
}

const DETECTION_CLASSES = [
  { value: 'Faulty', label: 'Faulty', color: '#ef4444' },
  { value: 'faulty_loose_joint', label: 'Loose Joint', color: '#22c55e' },
  { value: 'faulty_point_overload', label: 'Point Overload', color: '#3b82f6' },
  { value: 'potential_faulty', label: 'Potential Faulty', color: '#eab308' },
];

export default function AnnotationLegend({ 
  layout = 'vertical', 
  compact = false 
}: AnnotationLegendProps) {
  const isVertical = layout === 'vertical';
  
  return (
    <div className="detail-card" style={{
      borderRadius: '8px',
      padding: compact ? '12px' : '16px',
      boxShadow: 'var(--shadow-sm)',
      marginTop: '16px'
    }}>
      <h4 style={{ 
        margin: '0 0 12px 0', 
        fontSize: compact ? '13px' : '14px', 
        fontWeight: '600', 
        color: 'var(--text-primary)',
        display: compact ? 'none' : 'block'
      }}>
        Fault Types
      </h4>
      
      <div style={{
        display: 'flex',
        flexDirection: isVertical ? 'column' : 'row',
        gap: isVertical ? '8px' : '16px',
        alignItems: isVertical ? 'stretch' : 'center',
        flexWrap: isVertical ? 'nowrap' : 'wrap'
      }}>
        {DETECTION_CLASSES.map((cls) => (
          <div 
            key={cls.value} 
            style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '8px',
              padding: compact ? '4px' : '6px 0'
            }}
          >
            <div style={{
              width: compact ? '10px' : '14px',
              height: compact ? '10px' : '14px',
              background: cls.color,
              borderRadius: '2px',
              border: '1px solid rgba(0,0,0,0.1)',
              flexShrink: 0
            }} />
            <span style={{ 
              color: 'var(--text-primary)', 
              fontSize: compact ? '12px' : '13px', 
              fontWeight: '500',
              lineHeight: 1.2
            }}>
              {cls.label}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}