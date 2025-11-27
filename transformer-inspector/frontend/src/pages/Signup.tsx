// src/pages/Signup.tsx
import { useState, useEffect, useRef } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../components/Toast';

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID || '';

// Google Sign-In script URL
const GOOGLE_GSI_SCRIPT_URL = 'https://accounts.google.com/gsi/client';

export default function Signup() {
  const navigate = useNavigate();
  const { signup, loginWithGoogle } = useAuth();
  const toast = useToast();
  const googleButtonRef = useRef<HTMLDivElement>(null);
  
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [agreeTerms, setAgreeTerms] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const [googleScriptLoaded, setGoogleScriptLoaded] = useState(false);
  const [googleInitialized, setGoogleInitialized] = useState(false);

  // Load Google Sign-In script and render button
  useEffect(() => {
    if (!GOOGLE_CLIENT_ID) {
      console.log('Google OAuth not configured - skipping Google Sign-In');
      return;
    }

    const initializeGoogle = () => {
      try {
        const google = (window as any).google;
        if (google && googleButtonRef.current) {
          google.accounts.id.initialize({
            client_id: GOOGLE_CLIENT_ID,
            callback: handleGoogleCallback,
            auto_select: false,
            cancel_on_tap_outside: true,
            ux_mode: 'popup',
            context: 'signup',
          });
          
          // Render the Google button
          google.accounts.id.renderButton(googleButtonRef.current, {
            type: 'standard',
            theme: 'outline',
            size: 'large',
            text: 'signup_with',
            shape: 'rectangular',
            width: 300,
            logo_alignment: 'center',
          });
          
          setGoogleInitialized(true);
        }
      } catch (err) {
        console.warn('Google Sign-In initialization failed:', err);
        setGoogleInitialized(false);
      }
    };

    // Check if script already loaded
    if ((window as any).google) {
      setGoogleScriptLoaded(true);
      initializeGoogle();
      return;
    }

    // Check if script is already being loaded
    const existingScript = document.querySelector(`script[src="${GOOGLE_GSI_SCRIPT_URL}"]`);
    if (existingScript) {
      existingScript.addEventListener('load', () => {
        setGoogleScriptLoaded(true);
        setTimeout(initializeGoogle, 100);
      });
      return;
    }

    // Load script
    const script = document.createElement('script');
    script.src = GOOGLE_GSI_SCRIPT_URL;
    script.async = true;
    script.defer = true;
    script.onload = () => {
      setGoogleScriptLoaded(true);
      setTimeout(initializeGoogle, 100);
    };
    script.onerror = () => {
      console.error('Failed to load Google Sign-In script');
      setGoogleScriptLoaded(false);
    };
    document.body.appendChild(script);

    return () => {
      // Cleanup if needed
    };
  }, []);

  const handleGoogleCallback = async (response: { credential: string }) => {
    setGoogleLoading(true);
    setError(null);
    try {
      await loginWithGoogle(response.credential);
      toast.success('Welcome to TransX!', 'Your account has been created successfully');
      navigate('/');
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Google signup failed';
      setError(msg);
      toast.error('Signup Failed', msg);
    } finally {
      setGoogleLoading(false);
    }
  };

  // Fallback Google Sign-In using popup (when button render fails)
  const handleGoogleSignInFallback = () => {
    if (!GOOGLE_CLIENT_ID) {
      toast.error('Configuration Error', 'Google Sign-In is not configured');
      return;
    }

    const google = (window as any).google;
    if (!google) {
      toast.error('Script Error', 'Google Sign-In script not loaded. Please refresh the page.');
      return;
    }

    try {
      google.accounts.id.prompt();
    } catch (err) {
      console.error('Google prompt failed:', err);
      toast.error('Error', 'Failed to open Google Sign-In. Please try again.');
    }
  };

  // Password strength calculation
  const getPasswordStrength = (pwd: string): { score: number; label: string; color: string } => {
    let score = 0;
    if (pwd.length >= 8) score++;
    if (pwd.length >= 12) score++;
    if (/[a-z]/.test(pwd) && /[A-Z]/.test(pwd)) score++;
    if (/\d/.test(pwd)) score++;
    if (/[^a-zA-Z0-9]/.test(pwd)) score++;

    if (score <= 1) return { score, label: 'Weak', color: '#ef4444' };
    if (score <= 2) return { score, label: 'Fair', color: '#f59e0b' };
    if (score <= 3) return { score, label: 'Good', color: '#3b82f6' };
    return { score, label: 'Strong', color: '#22c55e' };
  };

  const passwordStrength = getPasswordStrength(password);

  const validateForm = (): string | null => {
    if (!name.trim()) return 'Name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    if (!email.trim()) return 'Email is required';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return 'Invalid email format';
    if (!password) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (password !== confirmPassword) return 'Passwords do not match';
    if (!agreeTerms) return 'You must agree to the terms and conditions';
    return null;
  };

  const handleEmailSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const validationError = validateForm();
    if (validationError) {
      setError(validationError);
      toast.warning('Validation Error', validationError);
      return;
    }

    setIsLoading(true);

    try {
      await signup(name.trim(), email.trim(), password);
      toast.success('Welcome to TransX!', 'Your account has been created successfully');
      navigate('/');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Signup failed. Please try again.';
      setError(errorMessage);
      toast.error('Signup Failed', errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card signup-card">
        {/* Logo and Header */}
        <div className="auth-header">
          <div className="auth-logo">
            <span className="logo-icon">⚡</span>
            <span className="logo-text">TransX</span>
          </div>
          <h1 className="auth-title">Create Account</h1>
          <p className="auth-subtitle">Join TransX Platform for transformer management</p>
        </div>

        {/* Error Message */}
        {error && (
          <div className="auth-error">
            <span className="error-icon">⚠️</span>
            {error}
          </div>
        )}

        {/* Signup Form */}
        <form onSubmit={handleEmailSignup} className="auth-form">
          <div className="form-group">
            <label htmlFor="name" className="form-label">Full Name</label>
            <div className="input-wrapper">
              <span className="input-icon">👤</span>
              <input
                id="name"
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Enter your full name"
                className="form-input"
                required
                disabled={isLoading}
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="email" className="form-label">Email Address</label>
            <div className="input-wrapper">
              <span className="input-icon">📧</span>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email"
                className="form-input"
                required
                disabled={isLoading}
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="password" className="form-label">Password</label>
            <div className="input-wrapper">
              <span className="input-icon">🔒</span>
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Create a password"
                className="form-input"
                required
                disabled={isLoading}
              />
              <button
                type="button"
                className="password-toggle"
                onClick={() => setShowPassword(!showPassword)}
                tabIndex={-1}
              >
                {showPassword ? '👁️' : '👁️‍🗨️'}
              </button>
            </div>
            {password && (
              <div className="password-strength">
                <div className="strength-bar">
                  <div
                    className="strength-fill"
                    style={{
                      width: `${(passwordStrength.score / 5) * 100}%`,
                      backgroundColor: passwordStrength.color,
                    }}
                  />
                </div>
                <span className="strength-label" style={{ color: passwordStrength.color }}>
                  {passwordStrength.label}
                </span>
              </div>
            )}
          </div>

          <div className="form-group">
            <label htmlFor="confirmPassword" className="form-label">Confirm Password</label>
            <div className="input-wrapper">
              <span className="input-icon">🔒</span>
              <input
                id="confirmPassword"
                type={showPassword ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Confirm your password"
                className="form-input"
                required
                disabled={isLoading}
              />
              {confirmPassword && password === confirmPassword && (
                <span className="input-valid">✓</span>
              )}
            </div>
          </div>

          <div className="form-options">
            <label className="checkbox-label">
              <input
                type="checkbox"
                className="checkbox-input"
                checked={agreeTerms}
                onChange={(e) => setAgreeTerms(e.target.checked)}
              />
              <span>
                I agree to the{' '}
                <Link to="/terms" className="terms-link">Terms of Service</Link>
                {' '}and{' '}
                <Link to="/privacy" className="terms-link">Privacy Policy</Link>
              </span>
            </label>
          </div>

          <button
            type="submit"
            className="auth-button primary"
            disabled={isLoading}
          >
            {isLoading ? (
              <>
                <span className="spinner"></span>
                Creating account...
              </>
            ) : (
              'Create Account'
            )}
          </button>
        </form>

        {/* Divider */}
        <div className="auth-divider">
          <span>or continue with</span>
        </div>

        {/* Google Sign-In Button */}
        <div className="social-buttons">
          {GOOGLE_CLIENT_ID ? (
            <>
              {/* Google rendered button container */}
              <div 
                ref={googleButtonRef} 
                className="google-signin-container"
                style={{ 
                  display: googleInitialized ? 'flex' : 'none', 
                  justifyContent: 'center',
                  minHeight: '44px'
                }}
              />
              
              {/* Fallback/Loading button */}
              {(!googleInitialized || googleLoading) && (
                <button
                  type="button"
                  className="google-signin-fallback"
                  onClick={handleGoogleSignInFallback}
                  disabled={googleLoading || !googleScriptLoaded}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '12px',
                    width: '300px',
                    height: '44px',
                    margin: '0 auto',
                    padding: '0 16px',
                    border: '1px solid #dadce0',
                    borderRadius: '4px',
                    backgroundColor: '#fff',
                    cursor: googleLoading || !googleScriptLoaded ? 'not-allowed' : 'pointer',
                    fontSize: '14px',
                    fontWeight: 500,
                    color: '#3c4043',
                    fontFamily: 'Google Sans, Roboto, Arial, sans-serif',
                    transition: 'background-color 0.2s, box-shadow 0.2s',
                  }}
                  onMouseOver={(e) => {
                    if (!googleLoading && googleScriptLoaded) {
                      e.currentTarget.style.backgroundColor = '#f8f9fa';
                      e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)';
                    }
                  }}
                  onMouseOut={(e) => {
                    e.currentTarget.style.backgroundColor = '#fff';
                    e.currentTarget.style.boxShadow = 'none';
                  }}
                >
                  {googleLoading ? (
                    <>
                      <span className="spinner" style={{ width: '18px', height: '18px' }}></span>
                      <span>Signing up...</span>
                    </>
                  ) : (
                    <>
                      <svg width="18" height="18" viewBox="0 0 48 48">
                        <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                        <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                        <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                        <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                      </svg>
                      <span>{googleScriptLoaded ? 'Sign up with Google' : 'Loading...'}</span>
                    </>
                  )}
                </button>
              )}
            </>
          ) : (
            <div style={{ textAlign: 'center', padding: '12px' }}>
              <p style={{ color: '#666', fontSize: '14px', margin: 0 }}>
                Google Sign-In not configured
              </p>
              <p style={{ color: '#999', fontSize: '12px', marginTop: '4px' }}>
                Add VITE_GOOGLE_CLIENT_ID to your .env file
              </p>
            </div>
          )}
        </div>

        {/* Sign In Link */}
        <p className="auth-footer">
          Already have an account?{' '}
          <Link to="/login" className="auth-link">
            Sign in
          </Link>
        </p>
      </div>

      {/* Background decoration */}
      <div className="auth-bg-decoration">
        <div className="decoration-circle circle-1"></div>
        <div className="decoration-circle circle-2"></div>
        <div className="decoration-circle circle-3"></div>
      </div>
    </div>
  );
}
