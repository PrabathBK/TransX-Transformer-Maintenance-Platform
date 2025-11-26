import { useState } from 'react';

type TabType = 'account' | 'security';

export default function Settings() {
  const [activeTab, setActiveTab] = useState<TabType>('account');

  const tabs: { id: TabType; label: string; icon: string }[] = [
    { id: 'account', label: 'Account', icon: '👤' },
    { id: 'security', label: 'Security', icon: '🔒' },
  ];

  const renderTabContent = () => {
    switch (activeTab) {
      case 'account':
        return <AccountSettings />;
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
        <p className="settings-subtitle">Manage your account settings</p>
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
