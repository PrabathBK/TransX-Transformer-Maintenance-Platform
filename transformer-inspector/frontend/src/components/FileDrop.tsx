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
        padding: 20,
        border: '2px dashed #999',
        borderRadius: 8,
        textAlign: 'center',
        background: hover ? '#f6f6f6' : 'transparent'
      }}
    >
      <p style={{ margin: 0 }}>Drag & drop image here, or pick a file</p>
      <input
        type="file"
        accept="image/*"
        onChange={e => { const f = e.target.files?.[0]; if (f) onFile(f); }}
        style={{ marginTop: 8 }}
      />
    </div>
  );
}