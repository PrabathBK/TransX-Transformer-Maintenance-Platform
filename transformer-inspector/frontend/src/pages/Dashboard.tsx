import { Link } from 'react-router-dom';

export default function Dashboard() {
  const card = {
    padding: 16,
    border: '1px solid #eee',
    borderRadius: 10,
    boxShadow: '0 1px 4px rgba(0,0,0,0.05)'
  } as const;

  return (
    <div style={{ maxWidth: 920, margin: '24px auto', padding: 16 }}>
      <h1>Transformer Inspector – Admin</h1>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginTop: 16 }}>
        <div style={card}>
          <h3>Transformers</h3>
          <p>Manage transformer records (ID, location, capacity).</p>
          <Link to="/transformers">Open</Link>
        </div>
        <div style={card}>
          <h3>Upload Images</h3>
          <p>Upload baseline or maintenance images with proper tags.</p>
          <Link to="/images/upload">Open</Link>
        </div>
        <div style={card}>
          <h3>Browse Images</h3>
          <p>View uploaded images and metadata.</p>
          <Link to="/images">Open</Link>
        </div>
      </div>
    </div>
  );
}