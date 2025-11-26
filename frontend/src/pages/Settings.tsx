import { useState } from 'react';
import { useTheme, type Theme } from '../context/ThemeContext';

type TabType = 'account' | 'preferences' | 'security';

export default function Settings() {
  const [activeTab, setActiveTab] = useState<TabType>('account');
  const { theme, setTheme } = useTheme();

  const tabs: { id: TabType; label: string; icon: string }[] = [
    { id: 'account', label: 'Account', icon: '👤' },
    { id: 'preferences', label: 'Preferences', icon: '🎨' },
    { id: 'security', label: 'Security', icon: '🔒' },
  ];

  const renderTabContent = () => {
    switch (activeTab) {
      case 'account':
        return <AccountSettings />;
      case 'preferences':
        return <PreferencesSettings theme={theme} setTheme={setTheme} />;
      case 'security':
        return <SecuritySettings />;
      default:
        return null;
    }
  };

  return (
    <div className="settings-page">
      <div className="settings-header">
        <h1 className="settings-title">Settings</h1>
        <p className="settings-subtitle">Manage your account and application preferences</p>
      </div>

      <div className="settings-container">
        <nav className="settings-tabs">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`settings-tab ${activeTab === tab.id ? 'active' : ''}`}
            >
              <span className="tab-icon">{tab.icon}</span>
              <span className="tab-label">{tab.label}</span>
            </button>
          ))}
        </nav>

        <div className="settings-content">
          {renderTabContent()}
        </div>
      </div>
    </div>
  );
}

function AccountSettings() {
  const userStr = localStorage.getItem('transx_user');
  const user = userStr ? JSON.parse(userStr) : null;

  return (
    <div className="settings-section">
      <h2 className="section-title">Account Information</h2>
      
      <div className="profile-card">
        <div className="profile-avatar">
          {user?.avatar ? (
            <img src={user.avatar} alt={user.name} className="avatar-image" />
          ) : (
            <div className="avatar-placeholder">
              {user?.name?.charAt(0).toUpperCase() || 'U'}
            </div>
          )}
        </div>
        <div className="profile-info">
          <h3 className="profile-name">{user?.name || 'User'}</h3>
          <p className="profile-email">{user?.email || 'email@example.com'}</p>
        </div>
      </div>

      <div className="form-group">
        <label className="form-label">Display Name</label>
        <input
          type="text"
          className="form-input"
          defaultValue={user?.name || ''}
          placeholder="Enter your name"
        />
      </div>

      <div className="form-group">
        <label className="form-label">Email Address</label>
        <input
          type="email"
          className="form-input"
          defaultValue={user?.email || ''}
          placeholder="Enter your email"
          disabled
        />
        <span className="form-hint">Email cannot be changed for Google accounts</span>
      </div>

      <button className="btn-primary">Save Changes</button>
    </div>
  );
}

interface PreferencesSettingsProps {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

function PreferencesSettings({ theme, setTheme }: PreferencesSettingsProps) {
  return (
    <div className="settings-section">
      <h2 className="section-title">Appearance</h2>
      <p className="section-description">Customize how TransX looks for you</p>

      <div className="theme-options">
        <button
          onClick={() => setTheme('light')}
          className={`theme-option ${theme === 'light' ? 'selected' : ''}`}
        >
          <div className="theme-preview light-preview">
            <div className="preview-sidebar"></div>
            <div className="preview-content">
              <div className="preview-header"></div>
              <div className="preview-cards">
                <div className="preview-card"></div>
                <div className="preview-card"></div>
              </div>
            </div>
          </div>
          <div className="theme-label">
            <span className="theme-icon">☀️</span>
            <span>Light</span>
          </div>
        </button>

        <button
          onClick={() => setTheme('dark')}
          className={`theme-option ${theme === 'dark' ? 'selected' : ''}`}
        >
          <div className="theme-preview dark-preview">
            <div className="preview-sidebar"></div>
            <div className="preview-content">
              <div className="preview-header"></div>
              <div className="preview-cards">
                <div className="preview-card"></div>
                <div className="preview-card"></div>
              </div>
            </div>
          </div>
          <div className="theme-label">
            <span className="theme-icon">🌙</span>
            <span>Dark</span>
          </div>
        </button>
      </div>

      <div className="current-theme-info">
        <span className="theme-status">
          Current theme: <strong>{theme === 'light' ? 'Light' : 'Dark'}</strong>
        </span>
      </div>
    </div>
  );
}

function SecuritySettings() {
  return (
    <div className="settings-section">
      <h2 className="section-title">Security</h2>
      
      <div className="security-item">
        <div className="security-info">
          <h3>Two-Factor Authentication</h3>
          <p>Add an extra layer of security to your account</p>
        </div>
        <button className="btn-secondary">Enable</button>
      </div>

      <div className="security-item">
        <div className="security-info">
          <h3>Active Sessions</h3>
          <p>Manage your active login sessions</p>
        </div>
        <button className="btn-secondary">View Sessions</button>
      </div>

      <div className="security-item danger">
        <div className="security-info">
          <h3>Delete Account</h3>
          <p>Permanently delete your account and all data</p>
        </div>
        <button className="btn-danger">Delete Account</button>
      </div>
    </div>
  );
}
