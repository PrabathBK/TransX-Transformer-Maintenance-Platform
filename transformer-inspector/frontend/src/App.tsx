import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import TransformersList from './pages/TransformersList';
import TransformerDetail from './pages/TransformerDetail';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Shell with sidebar */}
        <Route element={<Layout />}>
          <Route path="/" element={<Navigate to="/transformers" replace />} />
          <Route path="/transformers" element={<TransformersList />} />
          {/* use "new" for create mode; otherwise :id of an existing transformer */}
          <Route path="/transformers/:id" element={<TransformerDetail />} />
          <Route path="/settings" element={<div style={{ padding: 24 }}>Settings (coming soon)</div>} />
          <Route path="*" element={<div style={{ padding: 24 }}>Not found</div>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}