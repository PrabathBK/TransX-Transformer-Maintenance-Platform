// src/pages/TransformersList.tsx
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Input from '../components/Input';
import Select from '../components/Select';
import Modal from '../components/Modal';
import { listTransformers, createTransformer, deleteTransformer } from '../api/transformers';
import type { Transformer } from '../api/transformers';

// Extended UI type (keeps page working even if API type changes)
type UITransformer = Transformer & {
  region?: string | null;
  poleNo?: string | null;
  type?: string | null;
  locationDetails?: string | null;
};

type CreateForm = {
  region: string;
  code: string;            // Transformer No.
  poleNo: string;
  type: string;            // "Bulk" | "Distribution"
  locationDetails: string;
  location: string;
  capacityKVA: string;
};

export default function TransformersList() {
  const [q, setQ] = useState('');
  const [items, setItems] = useState<UITransformer[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);
  const size = 10;
  const [loading, setLoading] = useState(false);
  const [loadErr, setLoadErr] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  const [open, setOpen] = useState(false);
  const [form, setForm] = useState<CreateForm>({
    region: '', code: '', poleNo: '', type: '', locationDetails: '',
    location: '', capacityKVA: '',
  });
  const [createBusy, setCreateBusy] = useState(false);
  const [createErr, setCreateErr] = useState<string | null>(null);

  const nav = useNavigate();

  async function load() {
    try {
      setLoading(true); setLoadErr(null);
      const res = await listTransformers(q, page, size);
      setItems((res.content ?? []) as unknown as UITransformer[]);
      setTotal(res.totalElements ?? 0);
    } catch (e: any) {
      console.error(e);
      setLoadErr(e?.message || 'Failed to load transformers');
      setItems([]); setTotal(0);
    } finally { setLoading(false); }
  }
  useEffect(() => { load(); /* eslint-disable-next-line */ }, [page]);

  const totalPages = useMemo(() => Math.max(1, Math.ceil(total / size)), [total, size]);

  function resetForm() {
    setForm({ region: '', code: '', poleNo: '', type: '', locationDetails: '', location: '', capacityKVA: '' });
    setCreateErr(null);
  }

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    const capacity = Number(form.capacityKVA || 0);
    if (!form.code.trim() || !form.location.trim()) {
      setCreateErr('Transformer No. and Location are required.');
      return;
    }
    try {
      setCreateBusy(true); setCreateErr(null);
      await createTransformer({
        code: form.code.trim(),
        location: form.location.trim(),
        capacityKVA: capacity > 0 ? capacity : 1,
        region: form.region || undefined,
        poleNo: form.poleNo || undefined,
        type: form.type || undefined,
        locationDetails: form.locationDetails || undefined,
      });
      setOpen(false);
      resetForm();
      setPage(0);
      await load();
      setSuccessMsg(`Transformer ${form.code} created successfully!`);
      setTimeout(() => setSuccessMsg(null), 5000); // Auto-hide after 5 seconds
    } catch (e: any) {
      const message = String(e?.message || '');
      if (message.toLowerCase().includes('already exists') || message.includes('409')) {
        setCreateErr('This Transformer No. already exists.');
      } else {
        setCreateErr(message || 'Failed to create transformer');
      }
    } finally {
      setCreateBusy(false);
    }
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title">Transformers</h1>
        <button className="primary-button add-button" onClick={() => { resetForm(); setOpen(true); }}>
          <span className="button-icon">+</span>
          Add Transformer
        </button>
      </div>

      {/* Search toolbar */}
      <div className="search-section">
        <div className="search-inputs">
          <input 
            className="search-input"
            placeholder="Search by transformer code or location..." 
            value={q} 
            onChange={e => setQ(e.target.value)} 
          />
          <button className="search-button" onClick={() => { setPage(0); load(); }}>
            <span>🔍</span> Search
          </button>
          <button className="reset-button" onClick={() => { setQ(''); setPage(0); load(); }}>
            Reset
          </button>
        </div>
      </div>

      {/* Notifications */}
      {successMsg && <div className="success-message">{successMsg}</div>}
      {deleteError && <div className="error-message">{deleteError}</div>}
      {loadErr && <div className="error-message">{loadErr}</div>}
      {loading && <div className="loading-message">Loading transformers...</div>}

      {/* List */}
      <div className="table-container">
        <table className="transformer-table">
          <thead>
          <tr>
            <th>Transformer No.</th>
            <th>Pole No.</th>
            <th>Region</th>
            <th>Type</th>
            <th>Location</th>
            <th>Capacity (kVA)</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          {loading && <tr><td colSpan={7} className="loading-cell">Loading transformers...</td></tr>}
          {!loading && items.map(t => (
            <tr key={t.id}>
              <td className="transformer-code" onClick={() => nav(`/transformers/${t.id}`)}>
                <div className="code-wrapper">
                  <span className="code-text">{t.code}</span>
                  <span className="status-badge active">Active</span>
                </div>
              </td>
              <td className="pole-data">
                <span className="pole-number">{t.poleNo ?? '-'}</span>
              </td>
              <td className="region-data">
                <div className="region-wrapper">
                  <span className="region-dot"></span>
                  <span>{t.region ?? '-'}</span>
                </div>
              </td>
              <td className="type-data">
                <span className={`type-badge ${t.type?.toLowerCase() || 'default'}`}>
                  {t.type ?? '-'}
                </span>
              </td>
              <td className="location-data">{t.location}</td>
              <td className="capacity-data">
                <div className="capacity-wrapper">
                  <div className="capacity-info">
                    <span className="capacity-value">{t.capacityKVA} kVA</span>
                    <span className="capacity-percentage">{Math.min(100, (t.capacityKVA / 500) * 100).toFixed(0)}%</span>
                  </div>
                  <div className="capacity-bar">
                    <div 
                      className="capacity-fill" 
                      style={{ width: `${Math.min(100, (t.capacityKVA / 500) * 100)}%` }}
                    ></div>
                  </div>
                </div>
              </td>
              <td className="actions-cell">
                <div className="action-buttons">
                  <button className="action-btn view-btn" onClick={() => nav(`/transformers/${t.id}`)}>
                    <span className="btn-icon">👁️</span>
                  </button>
                  <button className="action-btn delete-btn" onClick={async () => {
                    if (!confirm('Delete this transformer?')) return;
                    try { 
                      await deleteTransformer(t.id); 
                      await load(); 
                      setSuccessMsg(`Transformer ${t.code} deleted successfully!`);
                      setTimeout(() => setSuccessMsg(null), 5000);
                    } catch (e:any) { 
                      setDeleteError(e?.message || 'Delete failed');
                      setTimeout(() => setDeleteError(null), 5000);
                    }
                  }}>
                    <span className="btn-icon">🗑️</span>
                  </button>
                </div>
              </td>
            </tr>
          ))}
          {!loading && items.length === 0 && !loadErr && (
            <tr><td colSpan={7} className="empty-state">No transformers yet.</td></tr>
          )}
          </tbody>
        </table>
      </div>

      {/* Pager */}
      <div className="pagination-section">
        <button className="pagination-button" disabled={page === 0} onClick={() => setPage(p => Math.max(0, p - 1))}>
          ← Prev
        </button>
        <span className="pagination-info">Page {page + 1} of {totalPages}</span>
        <button className="pagination-button" disabled={(page + 1) >= totalPages} onClick={() => setPage(p => p + 1)}>
          Next →
        </button>
      </div>

      {/* Modal: Add Transformer */}
      <Modal open={open} onClose={() => setOpen(false)} title="Add Transformer" width={720}>
        <form onSubmit={onCreate} style={{ display: 'grid', gridTemplateColumns:'1fr 1fr', gap: 12 }}>
          <Select
            label="Region"
            value={form.region}
            onChange={e => setForm(f => ({ ...f, region: e.target.value }))}
            options={[
              { value: '', label: 'Select region…' },
              { value: 'Nugegoda', label: 'Nugegoda' },
              { value: 'Maharagama', label: 'Maharagama' },
              { value: 'Colombo', label: 'Colombo' },
            ]}
          />
          <Input label="Transformer No." placeholder="TX-001"
                 value={form.code} onChange={e => setForm(f => ({ ...f, code: e.target.value }))} />
          <Input label="Pole No." placeholder="EN-122-A"
                 value={form.poleNo} onChange={e => setForm(f => ({ ...f, poleNo: e.target.value }))} />
          <Select
            label="Type"
            value={form.type}
            onChange={e => setForm(f => ({ ...f, type: e.target.value }))}
            options={[
              { value: '', label: 'Select type…' },
              { value: 'Bulk', label: 'Bulk' },
              { value: 'Distribution', label: 'Distribution' },
            ]}
          />
          <Input label="Location" placeholder="Substation / Area"
                 value={form.location} onChange={e => setForm(f => ({ ...f, location: e.target.value }))} />
          <Input label="Capacity (kVA)" type="number" placeholder="1000"
                 value={form.capacityKVA} onChange={e => setForm(f => ({ ...f, capacityKVA: e.target.value }))} />
          <div style={{ gridColumn: '1 / -1' }}>
            <Input label="Location Details" placeholder="Notes / directions"
                   value={form.locationDetails} onChange={e => setForm(f => ({ ...f, locationDetails: e.target.value }))} />
          </div>

          {createErr && <div className="modal-error" style={{ gridColumn:'1 / -1' }}>{createErr}</div>}

          <div style={{ gridColumn: '1 / -1', display:'flex', gap:8, justifyContent:'flex-end', marginTop: 4 }}>
            <button type="button" onClick={() => setOpen(false)}>Cancel</button>
            <button type="submit" disabled={createBusy}>
              {createBusy ? 'Saving…' : 'Confirm'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}