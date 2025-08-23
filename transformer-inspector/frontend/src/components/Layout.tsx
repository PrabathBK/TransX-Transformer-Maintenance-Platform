

import { Outlet, NavLink } from 'react-router-dom';

export default function Layout() {
  return (
    <div className="app-container">
      <aside className="app-sidebar">
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
        <button className="btn" style={{ marginTop: 12, width: '100%', background: 'none', color: '#fff', fontWeight: 700, fontSize: 16, border: '1.5px solid #fff', borderRadius: 12 }}>Log out</button>
      </aside>
      <div className="app-main">
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