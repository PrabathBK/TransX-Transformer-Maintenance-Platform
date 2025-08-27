import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import TransformersList from './pages/TransformersList';
import TransformerDetail from './pages/TransformerDetail';
import InspectionsList from './pages/InspectionsList';
import InspectionDetail from './pages/InspectionDetail';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Shell with sidebar */}
        <Route element={<Layout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/transformers" element={<TransformersList />} />
          <Route path="/transformers/:id" element={<TransformerDetail />} />
          <Route path="/inspections" element={<InspectionsList />} />
          <Route path="/inspections/:id" element={<InspectionDetail />} />
          <Route path="/settings" element={<div style={{ padding: 24 }}>Settings (coming soon)</div>} />
          <Route path="*" element={<div style={{ padding: 24 }}>Not found</div>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}