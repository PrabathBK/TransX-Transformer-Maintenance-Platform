// src/pages/Settings.tsx
import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import type { UserPreferences } from '../context/AuthContext';

interface TabConfig {
  id: string;
  label: string;
  icon: string;
}

const tabs: TabConfig[] = [
  { id: 'profile', label: 'Profile', icon: '👤' },
  { id: 'security', label: 'Security', icon: '🔐' },
  { id: 'activity', label: 'Activity Log', icon: '📋' },
];

export default function Settings() {
  const { user, updateUser, updatePreferences, logout } = useAuth();
  const { theme: currentTheme, setTheme: applyTheme } = useTheme();
  const [activeTab, setActiveTab] = useState('profile');
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Profile state
  const [name, setName] = useState(user?.name || '');
  const [email, setEmail] = useState(user?.email || '');
  const [avatarPreview, setAvatarPreview] = useState(user?.avatar || '');

  // Preferences state - sync with actual theme
  const [theme, setTheme] = useState<Theme>(currentTheme);
  const [language, setLanguage] = useState(user?.preferences?.language || 'en');
  const [timezone, setTimezone] = useState(user?.preferences?.timezone || Intl.DateTimeFormat().resolvedOptions().timeZone);

  // Notification state
  const [notifications, setNotifications] = useState(user?.preferences?.notifications ?? true);
  const [emailNotifications, setEmailNotifications] = useState(user?.preferences?.emailNotifications ?? true);

  // Security state
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  useEffect(() => {
    if (user) {
      setName(user.name);
      setEmail(user.email);
      setAvatarPreview(user.avatar || '');
      if (user.preferences) {
        setLanguage(user.preferences.language);
        setTimezone(user.preferences.timezone);
        setNotifications(user.preferences.notifications);
        setEmailNotifications(user.preferences.emailNotifications);
      }
    }
  }, [user]);

  // Sync local theme state with context
  useEffect(() => {
    setTheme(currentTheme);
  }, [currentTheme]);

  // Apply theme immediately when changed
  const handleThemeChange = (newTheme: Theme) => {
    setTheme(newTheme);
    applyTheme(newTheme);
  };

  const showMessage = (type: 'success' | 'error', text: string) => {
    setMessage({ type, text });
    setTimeout(() => setMessage(null), 5000);
  };

  const handleSaveProfile = async () => {
    setIsSaving(true);
    try {
      await updateUser({ name, email, avatar: avatarPreview });
      showMessage('success', 'Profile updated successfully');
    } catch (err) {
      showMessage('error', err instanceof Error ? err.message : 'Failed to update profile');
    } finally {
      setIsSaving(false);
    }
  };

  const handleSavePreferences = async () => {
    setIsSaving(true);
    try {
      const prefs: Partial<UserPreferences> = {
        theme,
        language,
        timezone,
        notifications,
        emailNotifications,
      };
      await updatePreferences(prefs);
      showMessage('success', 'Preferences saved successfully');
    } catch (err) {
      showMessage('error', err instanceof Error ? err.message : 'Failed to save preferences');
    } finally {
      setIsSaving(false);
    }
  };

  const handleChangePassword = async () => {
    if (newPassword !== confirmPassword) {
      showMessage('error', 'Passwords do not match');
      return;
    }
    if (newPassword.length < 8) {
      showMessage('error', 'Password must be at least 8 characters');
      return;
    }

    setIsSaving(true);
    try {
      const token = localStorage.getItem('transx_token');
      const res = await fetch('http://localhost:8080/api/auth/change-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({ currentPassword, newPassword }),
      });

      if (!res.ok) throw new Error(await res.text());
      
      showMessage('success', 'Password changed successfully');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err) {
      showMessage('error', err instanceof Error ? err.message : 'Failed to change password');
    } finally {
      setIsSaving(false);
    }
  };

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setAvatarPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'profile':
        return (
          <div className="settings-section">
            <h2 className="section-title">Profile Information</h2>
            <p className="section-description">Update your personal information and profile picture</p>

            <div className="profile-avatar-section">
              <div className="avatar-container">
                {avatarPreview ? (
                  <img src={avatarPreview} alt="Profile" className="avatar-image" />
                ) : (
                  <div className="avatar-placeholder">
                    {name?.charAt(0)?.toUpperCase() || '?'}
                  </div>
                )}
                <label className="avatar-upload-btn">
                  📷
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleAvatarChange}
                    style={{ display: 'none' }}
                  />
                </label>
              </div>
              <div className="avatar-info">
                <h3>{name || 'User'}</h3>
                <p>{user?.role || 'Inspector'}</p>
              </div>
            </div>

            <div className="form-grid">
              <div className="form-group">
                <label className="form-label">Full Name</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="settings-input"
                  placeholder="Your full name"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Email Address</label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="settings-input"
                  placeholder="your@email.com"
                  disabled={user?.provider === 'google'}
                />
                {user?.provider === 'google' && (
                  <span className="input-hint">Email cannot be changed for Google accounts</span>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Role</label>
                <input
                  type="text"
                  value={user?.role || 'Inspector'}
                  className="settings-input"
                  disabled
                />
                <span className="input-hint">Contact admin to change your role</span>
              </div>

              <div className="form-group">
                <label className="form-label">Member Since</label>
                <input
                  type="text"
                  value={user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'N/A'}
                  className="settings-input"
                  disabled
                />
              </div>
            </div>

            <div className="section-actions">
              <button className="btn-secondary" onClick={() => {
                setName(user?.name || '');
                setEmail(user?.email || '');
                setAvatarPreview(user?.avatar || '');
              }}>
                Cancel
              </button>
              <button className="btn-primary" onClick={handleSaveProfile} disabled={isSaving}>
                {isSaving ? 'Saving...' : 'Save Changes'}
              </button>
            </div>
          </div>
        );

      case 'preferences':
        return (
          <div className="settings-section">
            <h2 className="section-title">Preferences</h2>
            <p className="section-description">Customize your TransX experience</p>

            <div className="preference-group">
              <h3 className="preference-title">🎨 Appearance</h3>
              <p className="preference-description">Choose your preferred color theme</p>
              <div className="theme-options">
                {(['light', 'dark'] as const).map((t) => (
                  <button
                    key={t}
                    className={`theme-option ${theme === t ? 'active' : ''}`}
                    onClick={() => handleThemeChange(t)}
                  >
                    <div className="theme-preview">
                      {t === 'light' ? (
                        <div className="theme-preview-light">
                          <div className="preview-header"></div>
                          <div className="preview-sidebar"></div>
                          <div className="preview-content"></div>
                        </div>
                      ) : (
                        <div className="theme-preview-dark">
                          <div className="preview-header"></div>
                          <div className="preview-sidebar"></div>
                          <div className="preview-content"></div>
                        </div>
                      )}
                    </div>
                    <span className="theme-icon">
                      {t === 'light' ? '☀️' : '🌙'}
                    </span>
                    <span className="theme-label">{t === 'light' ? 'Light Mode' : 'Dark Mode'}</span>
                    {theme === t && <span className="theme-check">✓</span>}
                  </button>
                ))}
              </div>
            </div>

            <div className="preference-group">
              <h3 className="preference-title">🌐 Localization</h3>
              <div className="form-grid">
                <div className="form-group">
                  <label className="form-label">Language</label>
                  <select
                    value={language}
                    onChange={(e) => setLanguage(e.target.value)}
                    className="settings-select"
                  >
                    <option value="en">English</option>
                    <option value="es">Español</option>
                    <option value="fr">Français</option>
                    <option value="de">Deutsch</option>
                    <option value="si">සිංහල</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Timezone</label>
                  <select
                    value={timezone}
                    onChange={(e) => setTimezone(e.target.value)}
                    className="settings-select"
                  >
                    <option value="Asia/Colombo">Asia/Colombo (GMT+5:30)</option>
                    <option value="UTC">UTC</option>
                    <option value="America/New_York">America/New_York (EST)</option>
                    <option value="Europe/London">Europe/London (GMT)</option>
                    <option value="Asia/Tokyo">Asia/Tokyo (JST)</option>
                  </select>
                </div>
              </div>
            </div>

            <div className="section-actions">
              <button className="btn-primary" onClick={handleSavePreferences} disabled={isSaving}>
                {isSaving ? 'Saving...' : 'Save Preferences'}
              </button>
            </div>
          </div>
        );

      case 'security':
        return (
          <div className="settings-section">
            <h2 className="section-title">Security Settings</h2>
            <p className="section-description">Manage your account security</p>

            {user?.provider === 'google' ? (
              <div className="info-banner">
                <span className="banner-icon">ℹ️</span>
                <div>
                  <h4>Google Account</h4>
                  <p>Your account is secured through Google. Password changes are managed through your Google account.</p>
                </div>
              </div>
            ) : (
              <div className="password-change-section">
                <h3>Change Password</h3>
                <div className="form-grid single-column">
                  <div className="form-group">
                    <label className="form-label">Current Password</label>
                    <input
                      type="password"
                      value={currentPassword}
                      onChange={(e) => setCurrentPassword(e.target.value)}
                      className="settings-input"
                      placeholder="Enter current password"
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">New Password</label>
                    <input
                      type="password"
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      className="settings-input"
                      placeholder="Enter new password"
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">Confirm New Password</label>
                    <input
                      type="password"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className="settings-input"
                      placeholder="Confirm new password"
                    />
                  </div>
                </div>

                <button className="btn-primary" onClick={handleChangePassword} disabled={isSaving}>
                  {isSaving ? 'Changing...' : 'Change Password'}
                </button>
              </div>
            )}

            <div className="security-info">
              <h3>Session Information</h3>
              <div className="session-item">
                <span className="session-label">Last Login</span>
                <span className="session-value">
                  {user?.lastLogin ? new Date(user.lastLogin).toLocaleString() : 'N/A'}
                </span>
              </div>
              <div className="session-item">
                <span className="session-label">Login Provider</span>
                <span className="session-value">
                  {user?.provider === 'google' ? '🔵 Google' : '📧 Email'}
                </span>
              </div>
            </div>

            <div className="danger-zone">
              <h3>⚠️ Danger Zone</h3>
              <div className="danger-item">
                <div>
                  <h4>Sign Out Everywhere</h4>
                  <p>Sign out from all devices</p>
                </div>
                <button className="btn-danger-outline" onClick={logout}>
                  Sign Out All
                </button>
              </div>
              <div className="danger-item">
                <div>
                  <h4>Delete Account</h4>
                  <p>Permanently delete your account and all data</p>
                </div>
                <button className="btn-danger">Delete Account</button>
              </div>
            </div>
          </div>
        );

      case 'activity':
        return (
          <div className="settings-section">
            <h2 className="section-title">Activity Log</h2>
            <p className="section-description">Review your recent activity on the platform</p>

            <div className="activity-list">
              <div className="activity-item">
                <div className="activity-icon">🔍</div>
                <div className="activity-content">
                  <h4>Completed inspection INS-081</h4>
                  <p>Approved 3 anomalies, rejected 1</p>
                </div>
                <span className="activity-time">2 hours ago</span>
              </div>
              <div className="activity-item">
                <div className="activity-icon">✏️</div>
                <div className="activity-content">
                  <h4>Added annotation to inspection</h4>
                  <p>Manual annotation for transformer T-001</p>
                </div>
                <span className="activity-time">Yesterday</span>
              </div>
              <div className="activity-item">
                <div className="activity-icon">💬</div>
                <div className="activity-content">
                  <h4>Added comment</h4>
                  <p>"Need to recheck this area"</p>
                </div>
                <span className="activity-time">2 days ago</span>
              </div>
              <div className="activity-item">
                <div className="activity-icon">📷</div>
                <div className="activity-content">
                  <h4>Uploaded thermal image</h4>
                  <p>Baseline image for transformer T-005</p>
                </div>
                <span className="activity-time">1 week ago</span>
              </div>
            </div>

            <button className="btn-secondary load-more">
              Load More Activity
            </button>
          </div>
        );

      default:
        return null;
    }
  };

  if (!user) {
    return (
      <div className="settings-page">
        <div className="loading-state">
          <span className="spinner large"></span>
          <p>Loading settings...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="settings-page">
      <div className="settings-header">
        <h1 className="page-title">⚙️ Settings</h1>
        <p className="page-subtitle">Manage your account and preferences</p>
      </div>

      {message && (
        <div className={`settings-message ${message.type}`}>
          <span>{message.type === 'success' ? '✅' : '❌'}</span>
          {message.text}
        </div>
      )}

      <div className="settings-container">
        <aside className="settings-nav">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              className={`nav-item ${activeTab === tab.id ? 'active' : ''}`}
              onClick={() => setActiveTab(tab.id)}
            >
              <span className="nav-icon">{tab.icon}</span>
              <span className="nav-label">{tab.label}</span>
            </button>
          ))}
        </aside>

        <main className="settings-content">
          {renderTabContent()}
        </main>
      </div>
    </div>
  );
}
