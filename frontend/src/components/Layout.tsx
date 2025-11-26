
import { Outlet, useNavigate } from 'react-router-dom';
import { logout } from '../api/auth';
import { useState, useEffect } from 'react';

export default function Layout() {
  const navigate = useNavigate();
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    const userStr = localStorage.getItem('transx_user');
    if (userStr) {
      try {
        setUser(JSON.parse(userStr));
      } catch (e) {
        console.error('Failed to parse user', e);
      }
    }
  }, []);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="app-container">
      <aside className="app-sidebar">
        <div style={{ fontFamily: 'Montserrat', fontWeight: 900, fontSize: 26, marginBottom: 36, letterSpacing: '-1px' }}>
          TransX
        </div>

        {user && (
          <div className="mb-6 flex items-center gap-3 px-2">
            {user.avatar ? (
              <img src={user.avatar} alt={user.name} className="w-10 h-10 rounded-full border-2 border-white/20" />
            ) : (
              <div className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold border-2 border-white/20">
                {user.name?.charAt(0).toUpperCase()}
              </div>
            )}
            <div className="flex flex-col overflow-hidden">
              <span className="text-sm font-bold text-white truncate">{user.name}</span>
              <span className="text-xs text-blue-200 truncate">{user.email}</span>
            </div>
          </div>
        )}

        <nav style={{ display: 'flex', flexDirection: 'column', gap: 18, width: '100%' }}>
          <button
            onClick={() => navigate('/')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              padding: '14px 20px',
              borderRadius: 12,
              textDecoration: 'none',
              color: window.location.pathname === '/' ? '#1e40af' : '#fff',
              background: window.location.pathname === '/' ? '#fff' : 'transparent',
              fontWeight: 700,
              fontFamily: 'Montserrat',
              fontSize: 18,
              boxShadow: window.location.pathname === '/' ? '0 2px 12px #a18cd122' : 'none',
              transition: 'all 0.18s',
              border: 'none',
              cursor: 'pointer',
              width: '100%'
            }}
          >
            <span>🏠</span> Dashboard
          </button>
          <button
            onClick={() => navigate('/transformers')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              padding: '14px 20px',
              borderRadius: 12,
              textDecoration: 'none',
              color: window.location.pathname === '/transformers' ? '#1e40af' : '#fff',
              background: window.location.pathname === '/transformers' ? '#fff' : 'transparent',
              fontWeight: 700,
              fontFamily: 'Montserrat',
              fontSize: 18,
              boxShadow: window.location.pathname === '/transformers' ? '0 2px 12px #a18cd122' : 'none',
              transition: 'all 0.18s',
              border: 'none',
              cursor: 'pointer',
              width: '100%'
            }}
          >
            <span>⚡</span> Transformers
          </button>
          <button
            onClick={() => navigate('/inspections')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              padding: '14px 20px',
              borderRadius: 12,
              textDecoration: 'none',
              color: window.location.pathname === '/inspections' ? '#1e40af' : '#fff',
              background: window.location.pathname === '/inspections' ? '#fff' : 'transparent',
              fontWeight: 700,
              fontFamily: 'Montserrat',
              fontSize: 18,
              boxShadow: window.location.pathname === '/inspections' ? '0 2px 12px #a18cd122' : 'none',
              transition: 'all 0.18s',
              border: 'none',
              cursor: 'pointer',
              width: '100%'
            }}
          >
            <span>🔍</span> Inspections
          </button>
          <button
            onClick={() => navigate('/settings')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              padding: '14px 20px',
              borderRadius: 12,
              textDecoration: 'none',
              color: window.location.pathname === '/settings' ? '#1e40af' : '#fff',
              background: window.location.pathname === '/settings' ? '#fff' : 'transparent',
              fontWeight: 700,
              fontFamily: 'Montserrat',
              fontSize: 18,
              boxShadow: window.location.pathname === '/settings' ? '0 2px 12px #a18cd122' : 'none',
              transition: 'all 0.18s',
              border: 'none',
              cursor: 'pointer',
              width: '100%'
            }}
          >
            <span>⚙️</span> Settings
          </button>
        </nav>
        <div style={{ flex: 1 }} />
        <button
          onClick={handleLogout}
          className="btn"
          style={{ marginTop: 12, width: '100%', background: 'none', color: '#fff', fontWeight: 700, fontSize: 16, border: '1.5px solid #fff', borderRadius: 12, cursor: 'pointer' }}
        >
          Log out
        </button>
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