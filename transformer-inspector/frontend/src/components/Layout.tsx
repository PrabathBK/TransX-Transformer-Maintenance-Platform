

import { Outlet, NavLink } from 'react-router-dom';

export default function Layout() {
  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      background: 'linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%)',
    }}>
      <aside style={{
        width: 250,
        background: 'linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%)',
        color: '#fff',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'flex-start',
        padding: '2.5rem 1.5rem 1rem 1.5rem',
        borderRadius: '24px',
        margin: '1.5rem',
        boxShadow: '0 8px 32px 0 #7c3aed33',
        minHeight: 'calc(100vh - 3rem)',
        position: 'sticky',
        top: 0,
        height: 'fit-content',
      }}>
        <div style={{ fontFamily: 'Montserrat', fontWeight: 900, fontSize: 26, marginBottom: 36, letterSpacing: '-1px' }}>
          TransX
        </div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 18, width: '100%' }}>
          <NavLink to="/" style={({isActive}) => ({
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '14px 20px',
            borderRadius: 12,
            textDecoration: 'none',
            color: isActive ? '#7c3aed' : '#fff',
            background: isActive ? '#fff' : 'transparent',
            fontWeight: 700,
            fontFamily: 'Montserrat',
            fontSize: 18,
            boxShadow: isActive ? '0 2px 12px #a18cd122' : 'none',
            transition: 'all 0.18s',
          })}>
            <span>🏠</span> Dashboard
          </NavLink>
          <NavLink to="/transformers" style={({isActive}) => ({
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '14px 20px',
            borderRadius: 12,
            textDecoration: 'none',
            color: isActive ? '#7c3aed' : '#fff',
            background: isActive ? '#fff' : 'transparent',
            fontWeight: 700,
            fontFamily: 'Montserrat',
            fontSize: 18,
            boxShadow: isActive ? '0 2px 12px #a18cd122' : 'none',
            transition: 'all 0.18s',
          })}>
            <span>⚡</span> Transformers
          </NavLink>
          <NavLink to="/settings" style={({isActive}) => ({
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '14px 20px',
            borderRadius: 12,
            textDecoration: 'none',
            color: isActive ? '#7c3aed' : '#fff',
            background: isActive ? '#fff' : 'transparent',
            fontWeight: 700,
            fontFamily: 'Montserrat',
            fontSize: 18,
            boxShadow: isActive ? '0 2px 12px #a18cd122' : 'none',
            transition: 'all 0.18s',
          })}>
            <span>⚙️</span> Settings
          </NavLink>
        </nav>
        <div style={{ flex: 1 }} />
        <button className="btn" style={{ marginTop: 32, width: '100%', background: '#fff', color: '#7c3aed', fontWeight: 900, fontSize: 16, borderRadius: 12, boxShadow: '0 2px 12px #a18cd122' }}>Add Transformer</button>
        <button className="btn" style={{ marginTop: 12, width: '100%', background: 'none', color: '#fff', fontWeight: 700, fontSize: 16, border: '1.5px solid #fff', borderRadius: 12 }}>Log out</button>
      </aside>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: '#f6f7fb', borderRadius: '32px', margin: '1.5rem 1.5rem 1.5rem 0', boxShadow: '0 8px 32px 0 #a18cd122' }}>
        <main style={{
          flex: 1,
          width: '100%',
          maxWidth: '100%',
          margin: '0',
          padding: '1rem',
        }}>
          <Outlet />
        </main>
        <footer style={{
          textAlign: 'center',
          color: '#a0aec0',
          fontSize: '0.85rem',
          padding: '1rem 0 0.5rem 0',
        }}>
          &copy; {new Date().getFullYear()} TransX Platform
        </footer>
      </div>
    </div>
  );
}