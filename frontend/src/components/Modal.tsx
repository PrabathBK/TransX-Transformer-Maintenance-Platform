// src/components/Modal.tsx
import React from 'react';

type Props = {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  width?: number | string;
};

export default function Modal({ open, onClose, title, children, width = 640 }: Props) {
  if (!open) return null;
  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 50
    }}>
        <div className="modal-content" style={{
          width, maxWidth: '95vw', background: 'var(--bg-secondary)', borderRadius: 12,
          boxShadow: 'var(--shadow-lg)', padding: 20, border: '1px solid var(--border-light)'
        }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <h2 style={{ margin: 0, color: 'var(--text-heading)' }}>{title}</h2>
            <button onClick={onClose} style={{
              float: 'right',
              background: 'none',
              border: 'none',
              fontSize: '1.5rem',
              color: 'var(--accent)',
              cursor: 'pointer',
              marginBottom: '1rem',
            }}>×</button>
        </div>
        <div style={{ marginTop: 12 }}>{children}</div>
      </div>
    </div>
  );
}