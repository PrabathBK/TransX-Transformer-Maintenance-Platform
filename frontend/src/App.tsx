import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { GoogleOAuthProvider } from '@react-oauth/google';
import './App.css';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import TransformersList from './pages/TransformersList';
import TransformerDetail from './pages/TransformerDetail';
import InspectionsList from './pages/InspectionsList';
import InspectionDetailNew from './pages/InspectionDetailNew';
import MaintenanceRecordPage from './pages/MaintenanceRecordPage';
import Login from './pages/Login';

// Replace with your actual Google Client ID
// Ideally this should come from an environment variable
const GOOGLE_CLIENT_ID = "656702563579-jn27q8n9hja9e0d2ttn5to9tb9r9bi32.apps.googleusercontent.com";


function PrivateRoute({ children }: { children: React.ReactNode }) {
  const token = localStorage.getItem('transx_token');
  const location = useLocation();

  if (!token) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}

export default function App() {
  return (
    <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />

          {/* Protected Routes */}
          <Route element={
            <PrivateRoute>
              <Layout />
            </PrivateRoute>
          }>
            <Route path="/" element={<Dashboard />} />
            <Route path="/transformers" element={<TransformersList />} />
            <Route path="/transformers/:id" element={<TransformerDetail />} />
            <Route path="/inspections" element={<InspectionsList />} />
            <Route path="/inspections/:id" element={<InspectionDetailNew />} />
            <Route path="/inspections/:inspectionId/maintenance-record" element={<MaintenanceRecordPage />} />
            <Route path="/maintenance-records/:recordId" element={<MaintenanceRecordPage />} />
            <Route path="/settings" element={<div style={{ padding: 24 }}>Settings (coming soon)</div>} />
          </Route>

          <Route path="*" element={<div style={{ padding: 24 }}>Not found</div>} />
        </Routes>
      </BrowserRouter>
    </GoogleOAuthProvider>
  );
}