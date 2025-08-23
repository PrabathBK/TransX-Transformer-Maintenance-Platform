import React, { useCallback, useState } from 'react';

type Props = { onFile: (file: File) => void; };

export default function FileDrop({ onFile }: Props) {
  const [hover, setHover] = useState(false);

  const onDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setHover(false);
    const file = e.dataTransfer.files?.[0];
    if (file) onFile(file);
  }, [onFile]);

  return (
    <div
      onDragOver={e => { e.preventDefault(); setHover(true); }}
      onDragLeave={() => setHover(false)}
      onDrop={onDrop}
      style={{
        padding: 48,
        border: `2px dashed ${hover ? '#7c3aed' : '#e879f9'}`,
        borderRadius: 12,
        textAlign: 'center',
        background: hover ? 'rgba(124, 58, 237, 0.05)' : 'rgba(248, 250, 252, 0.5)',
        transition: 'all 0.3s ease',
        cursor: 'pointer',
        position: 'relative'
      }}
    >
      {/* Cloud Upload Icon */}
      <div style={{ 
        fontSize: 64, 
        marginBottom: 16,
        color: hover ? '#7c3aed' : '#a855f7'
      }}>
        ☁
      </div>
      
      {/* Main Text */}
      <p style={{ 
        margin: '0 0 8px 0', 
        fontSize: 16, 
        fontWeight: 600,
        color: hover ? '#7c3aed' : '#475569'
      }}>
        Drag & drop to upload
      </p>
      
      {/* Secondary Text */}
      <p style={{ 
        margin: '0 0 20px 0', 
        fontSize: 14, 
        color: '#e879f9',
        fontWeight: 500
      }}>
        or browse
      </p>
      
      {/* Hidden File Input */}
      <input
        type="file"
        accept="image/*"
        onChange={e => { const f = e.target.files?.[0]; if (f) onFile(f); }}
        style={{ 
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          opacity: 0,
          cursor: 'pointer'
        }}
      />
    </div>
  );
}