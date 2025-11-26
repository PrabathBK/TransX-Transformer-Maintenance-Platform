
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { logout } from '../api/auth';
import { useState, useEffect } from 'react';
import { useTheme } from '../context/ThemeContext';

export default function Layout() {
  const navigate = useNavigate();
  const location = useLocation();
  const [user, setUser] = useState<any>(null);
  const { isDark } = useTheme();

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

  const isActive = (path: string) => location.pathname === path;

  const navButtonStyle = (path: string) => ({
    display: 'flex',
    alignItems: 'center',
    gap: 12,
    padding: '14px 20px',
    borderRadius: 12,
    textDecoration: 'none',
    color: isActive(path) 
      ? (isDark ? '#ffffff' : '#1e40af')
      : 'var(--sidebar-text)',
    background: isActive(path) 
      ? (isDark ? 'var(--primary)' : '#fff')
      : 'transparent',
    fontWeight: 700,
    fontFamily: 'Montserrat',
    fontSize: 18,
    boxShadow: isActive(path) ? 'var(--shadow-sm)' : 'none',
    transition: 'all 0.18s',
    border: 'none',
    cursor: 'pointer',
    width: '100%'
  });

  return (
    <div className="app-container">
      <aside className="app-sidebar">
        <div style={{ fontFamily: 'Montserrat', fontWeight: 900, fontSize: 26, marginBottom: 36, letterSpacing: '-1px', color: 'var(--sidebar-text)' }}>
          TransX
        </div>

        {user && (
          <div style={{ marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0 0.5rem' }}>
            {user.avatar ? (
              <img src={user.avatar} alt={user.name} style={{ width: 40, height: 40, borderRadius: '50%', border: '2px solid rgba(255,255,255,0.2)' }} />
            ) : (
              <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'var(--primary-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontWeight: 'bold', border: '2px solid rgba(255,255,255,0.2)' }}>
                {user.name?.charAt(0).toUpperCase()}
              </div>
            )}
            <div style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
              <span style={{ fontSize: '0.875rem', fontWeight: 'bold', color: 'var(--sidebar-text)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{user.name}</span>
              <span style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.7)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{user.email}</span>
            </div>
          </div>
        )}

        <nav style={{ display: 'flex', flexDirection: 'column', gap: 18, width: '100%' }}>
          <button onClick={() => navigate('/')} style={navButtonStyle('/')}>
            <span>🏠</span> Dashboard
          </button>
          <button onClick={() => navigate('/transformers')} style={navButtonStyle('/transformers')}>
            <span>⚡</span> Transformers
          </button>
          <button onClick={() => navigate('/inspections')} style={navButtonStyle('/inspections')}>
            <span>🔍</span> Inspections
          </button>
          <button onClick={() => navigate('/settings')} style={navButtonStyle('/settings')}>
            <span>⚙️</span> Settings
          </button>
        </nav>
        <div style={{ flex: 1 }} />
        <button
          onClick={handleLogout}
          style={{ 
            marginTop: 12, 
            width: '100%', 
            background: 'none', 
            color: 'var(--sidebar-text)', 
            fontWeight: 700, 
            fontSize: 16, 
            border: '1.5px solid var(--sidebar-text)', 
            borderRadius: 12, 
            cursor: 'pointer',
            padding: '0.8em 2em',
            transition: 'all 0.2s ease'
          }}
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
          color: 'var(--text-secondary)',
          fontSize: '0.85rem',
          padding: '1rem 0 0.5rem 0',
        }}>
          &copy; {new Date().getFullYear()} TransX Platform
        </footer>
      </div>
    </div>
  );
}