// src/components/Layout.tsx
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useState, useRef, useEffect } from 'react';

export default function Layout() {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout, isLoading } = useAuth();
  const [showUserMenu, setShowUserMenu] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setShowUserMenu(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const navItems = [
    { path: '/', label: 'Dashboard', icon: '🏠' },
    { path: '/transformers', label: 'Transformers', icon: '⚡' },
    { path: '/inspections', label: 'Inspections', icon: '🔍' },
    { path: '/settings', label: 'Settings', icon: '⚙️' },
  ];

  const isActivePath = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  const handleNavigation = (path: string) => {
    navigate(path);
  };

  const handleLogout = () => {
    setShowUserMenu(false);
    logout();
  };

  const getInitials = (name: string): string => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const getRoleBadgeColor = (role: string): string => {
    switch (role) {
      case 'admin': return '#ef4444';
      case 'inspector': return '#3b82f6';
      default: return '#6b7280';
    }
  };

  if (isLoading) {
    return (
      <div className="loading-screen">
        <div className="loading-content">
          <div className="loading-logo">⚡</div>
          <div className="loading-spinner"></div>
          <p>Loading TransX...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="app-container">
      <aside className="app-sidebar">
        <div style={{ fontFamily: 'Montserrat', fontWeight: 900, fontSize: 26, marginBottom: 36, letterSpacing: '-1px' }}>
          TransX
        </div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 18, width: '100%' }}>
          {navItems.map((item) => (
            <button 
              key={item.path}
              onClick={() => handleNavigation(item.path)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '14px 20px',
                borderRadius: 12,
                textDecoration: 'none',
                color: isActivePath(item.path) ? '#1e40af' : '#fff',
                background: isActivePath(item.path) ? '#fff' : 'transparent',
                fontWeight: 700,
                fontFamily: 'Montserrat',
                fontSize: 18,
                boxShadow: isActivePath(item.path) ? '0 2px 12px #a18cd122' : 'none',
                transition: 'all 0.18s',
                border: 'none',
                cursor: 'pointer',
                width: '100%'
              }}
            >
              <span>{item.icon}</span> {item.label}
            </button>
          ))}
        </nav>
        <div style={{ flex: 1 }} />
        
        {/* User info at bottom of sidebar */}
        {user && (
          <div className="sidebar-user-info">
            <div className="sidebar-user-avatar">
              {user.avatar ? (
                <img src={user.avatar} alt={user.name} />
              ) : (
                <span>{getInitials(user.name)}</span>
              )}
            </div>
            <div className="sidebar-user-details">
              <span className="sidebar-user-name">{user.name}</span>
              <span className="sidebar-user-email">{user.email}</span>
            </div>
          </div>
        )}
        
        <button 
          className="btn" 
          style={{ 
            marginTop: 12, 
            width: '100%', 
            background: 'none', 
            color: '#fff', 
            fontWeight: 700, 
            fontSize: 16, 
            border: '1.5px solid #fff', 
            borderRadius: 12 
          }}
          onClick={handleLogout}
        >
          Log out
        </button>
      </aside>
      
      <div className="app-main">
        {/* Top Bar with User Info */}
        <header className="top-bar">
          <div className="top-bar-left">
            <h2 className="page-breadcrumb">
              {location.pathname === '/' && 'Dashboard'}
              {location.pathname === '/transformers' && 'Transformers'}
              {location.pathname.startsWith('/transformers/') && 'Transformer Details'}
              {location.pathname === '/inspections' && 'Inspections'}
              {location.pathname.startsWith('/inspections/') && 'Inspection Details'}
              {location.pathname === '/settings' && 'Settings'}
            </h2>
          </div>
          
          <div className="top-bar-right">
            {/* Notifications */}
            <button className="top-bar-icon-btn" title="Notifications">
              <span>🔔</span>
              <span className="notification-badge">3</span>
            </button>
            
            {/* User Menu */}
            {user && (
              <div className="user-menu-container" ref={menuRef}>
                <button 
                  className="user-menu-trigger"
                  onClick={() => setShowUserMenu(!showUserMenu)}
                >
                  <div className="user-avatar">
                    {user.avatar ? (
                      <img src={user.avatar} alt={user.name} />
                    ) : (
                      <span className="avatar-initials">{getInitials(user.name)}</span>
                    )}
                  </div>
                  <div className="user-info">
                    <span className="user-name">{user.name}</span>
                    <span 
                      className="user-role"
                      style={{ color: getRoleBadgeColor(user.role) }}
                    >
                      {user.role.charAt(0).toUpperCase() + user.role.slice(1)}
                    </span>
                  </div>
                  <span className={`menu-arrow ${showUserMenu ? 'open' : ''}`}>▼</span>
                </button>
                
                {showUserMenu && (
                  <div className="user-dropdown">
                    <div className="dropdown-header">
                      <div className="dropdown-avatar">
                        {user.avatar ? (
                          <img src={user.avatar} alt={user.name} />
                        ) : (
                          <span>{getInitials(user.name)}</span>
                        )}
                      </div>
                      <div className="dropdown-user-info">
                        <span className="dropdown-name">{user.name}</span>
                        <span className="dropdown-email">{user.email}</span>
                      </div>
                    </div>
                    
                    <div className="dropdown-divider" />
                    
                    <button 
                      className="dropdown-item"
                      onClick={() => {
                        setShowUserMenu(false);
                        navigate('/settings');
                      }}
                    >
                      <span className="dropdown-icon">👤</span>
                      My Profile
                    </button>
                    <button 
                      className="dropdown-item"
                      onClick={() => {
                        setShowUserMenu(false);
                        navigate('/settings');
                      }}
                    >
                      <span className="dropdown-icon">⚙️</span>
                      Settings
                    </button>
                    <button 
                      className="dropdown-item"
                      onClick={() => {
                        setShowUserMenu(false);
                        navigate('/settings');
                      }}
                    >
                      <span className="dropdown-icon">📋</span>
                      Activity Log
                    </button>
                    
                    <div className="dropdown-divider" />
                    
                    <button 
                      className="dropdown-item logout"
                      onClick={handleLogout}
                    >
                      <span className="dropdown-icon">🚪</span>
                      Sign Out
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        </header>
        
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
          {user && <span> | Logged in as {user.name}</span>}
        </footer>
      </div>
    </div>
  );
}