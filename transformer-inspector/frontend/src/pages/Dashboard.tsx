
export default function Dashboard() {
  return (
    <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: '2.5rem' }}>
      <h2 className="fancy-heading" style={{
        fontSize: '2.2rem',
        marginBottom: 0,
        color: '#2d1e6b',
        letterSpacing: '-1.5px',
        animation: 'fadeIn 1.2s cubic-bezier(.4,0,.2,1)'
      }}>
        Recent activity
      </h2>
      <div style={{ display: 'flex', gap: '1.5rem', margin: '1.5rem 0', flexWrap: 'wrap' }}>
        {[
          { label: 'NEW ITEMS', value: 741 },
          { label: 'NEW ORDERS', value: 123 },
          { label: 'REFUNDS', value: 12 },
          { label: 'MESSAGE', value: 1 },
          { label: 'GROUPS', value: 4 },
        ].map((card, idx) => (
          <div key={card.label} style={{
            background: '#fff',
            borderRadius: 18,
            boxShadow: '0 2px 12px #a18cd122',
            padding: '1.5rem 2.5rem',
            minWidth: 140,
            textAlign: 'center',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            fontFamily: 'Montserrat',
            fontWeight: 700,
            fontSize: 22,
            color: '#7c3aed',
            marginRight: idx !== 4 ? 12 : 0,
            marginBottom: 12,
            position: 'relative',
            transition: 'box-shadow 0.18s',
          }}>
            <div style={{ fontSize: 32, fontWeight: 900, color: '#7c3aed', marginBottom: 4 }}>{card.value}</div>
            <div style={{ fontSize: 13, color: '#a0aec0', fontWeight: 600, letterSpacing: 1 }}>{card.label}</div>
            <span style={{ position: 'absolute', right: 16, top: 16, color: '#e0e7ff', fontSize: 18, fontWeight: 900 }}>&gt;</span>
          </div>
        ))}
      </div>
    </div>
  );
}