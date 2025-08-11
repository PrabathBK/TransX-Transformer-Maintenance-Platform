
import { NavLink, Outlet } from 'react-router-dom';

export default function Layout() {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '260px 1fr', minHeight: '100vh' }}>
      <aside style={{ borderRight: '1px solid #eee', padding: 20, background: '#fafafa' }}>
        <div style={{ fontWeight: 800, fontSize: 20, marginBottom: 16 }}>TransX</div>
        <nav style={{ display: 'grid', gap: 8 }}>
          <NavLink to="/transformers" style={({isActive})=>({
            padding:'10px 12px', borderRadius:10, textDecoration:'none',
            background: isActive ? '#eef2ff' : 'transparent', color:'#111'
          })}>⚡ Transformer</NavLink>
          <NavLink to="/settings" style={({isActive})=>({
            padding:'10px 12px', borderRadius:10, textDecoration:'none',
            background: isActive ? '#eef2ff' : 'transparent', color:'#111'
          })}>⚙️ Settings</NavLink>
        </nav>
      </aside>
      <main style={{ padding: 24 }}>
        <Outlet />
      </main>
    </div>
  );
}