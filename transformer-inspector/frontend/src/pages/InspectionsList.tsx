// src/pages/InspectionsList.tsx
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Input from '../components/Input';
import Select from '../components/Select';
import Modal from '../components/Modal';
import { listInspections, createInspection, deleteInspection } from '../api/inspections';
import { listTransformers } from '../api/transformers';
import type { Inspection } from '../api/inspections';
import type { Transformer } from '../api/transformers';

type CreateInspectionForm = {
  inspectionNo: string;
  transformerId: string;
  branch: string;
  inspectionDate: string;
  inspectionTime: string;
  maintenanceDate: string;
  maintenanceTime: string;
  inspectedBy: string;
  notes: string;
};

export default function InspectionsList() {
  const [q, setQ] = useState('');
  const [items, setItems] = useState<Inspection[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);
  const size = 10;
  const [loading, setLoading] = useState(false);
  const [loadErr, setLoadErr] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  const [open, setOpen] = useState(false);
  const [form, setForm] = useState<CreateInspectionForm>({
    inspectionNo: '',
    transformerId: '',
    branch: '',
    inspectionDate: '',
    inspectionTime: '07:00',
    maintenanceDate: '',
    maintenanceTime: '',
    inspectedBy: '',
    notes: '',
  });
  const [createBusy, setCreateBusy] = useState(false);
  const [createErr, setCreateErr] = useState<string | null>(null);

  const [transformers, setTransformers] = useState<Transformer[]>([]);

  const nav = useNavigate();

  async function load() {
    try {
      setLoading(true); setLoadErr(null);
      const res = await listInspections(q, '', page, size);
      setItems(res.content ?? []);
      setTotal(res.totalElements ?? 0);
    } catch (e: any) {
      console.error(e);
      setLoadErr(e?.message || 'Failed to load inspections');
      setItems([]); setTotal(0);
    } finally { setLoading(false); }
  }

  async function loadTransformers() {
    try {
      const res = await listTransformers('', 0, 100);
      setTransformers(res.content ?? []);
    } catch (e: any) {
      console.error(e);
    }
  }

  useEffect(() => { load(); }, [page, q]);
  useEffect(() => { loadTransformers(); }, []);

  const totalPages = useMemo(() => Math.max(1, Math.ceil(total / size)), [total, size]);

  function resetForm() {
    setForm({
      inspectionNo: '',
      transformerId: '',
      branch: '',
      inspectionDate: '',
      inspectionTime: '07:00',
      maintenanceDate: '',
      maintenanceTime: '',
      inspectedBy: '',
      notes: '',
    });
    setCreateErr(null);
  }

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!form.inspectionNo.trim() || !form.transformerId || !form.branch.trim() || 
        !form.inspectionDate || !form.inspectedBy.trim()) {
      setCreateErr('Please fill all required fields.');
      return;
    }
    try {
      setCreateBusy(true); setCreateErr(null);
      await createInspection({
        inspectionNo: form.inspectionNo.trim(),
        transformerId: form.transformerId,
        branch: form.branch.trim(),
        inspectionDate: form.inspectionDate,
        inspectionTime: form.inspectionTime,
        maintenanceDate: form.maintenanceDate || undefined,
        maintenanceTime: form.maintenanceTime || undefined,
        inspectedBy: form.inspectedBy.trim(),
        notes: form.notes || undefined,
      });
      setOpen(false);
      resetForm();
      setPage(0);
      await load();
      setSuccessMsg(`Inspection ${form.inspectionNo} created successfully!`);
      setTimeout(() => setSuccessMsg(null), 5000);
    } catch (e: any) {
      const message = String(e?.message || '');
      if (message.toLowerCase().includes('already exists') || message.includes('409')) {
        setCreateErr('This Inspection No. already exists.');
      } else {
        setCreateErr(message || 'Failed to create inspection');
      }
    } finally {
      setCreateBusy(false);
    }
  }

  function getStatusBadge(status: string) {
    const statusClass = status.toLowerCase().replace('_', '-');
    return <span className={`status-badge ${statusClass}`}>{status.replace('_', ' ')}</span>;
  }

  function formatDateTime(date: string, time?: string) {
    if (!date) return '-';
    const dateObj = new Date(date);
    const dateStr = dateObj.toLocaleDateString();
    return time ? `${dateStr} ${time}` : dateStr;
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title">Inspections</h1>
        <button className="primary-button add-button" onClick={() => { resetForm(); setOpen(true); }}>
          <span className="button-icon">+</span>
          Add Inspection
        </button>
      </div>

      {/* Search toolbar */}
      <div className="search-section">
        <div className="search-inputs">
          <input 
            className="search-input"
            placeholder="Search by inspection no, transformer code, or branch..." 
            value={q} 
            onChange={e => setQ(e.target.value)} 
          />
          <button className="search-button" onClick={() => { setPage(0); load(); }}>
            Search
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
      {loading && <div className="loading-message">Loading inspections...</div>}

      {/* List */}
      <div className="table-container">
        <table className="transformer-table">
          <thead>
          <tr>
            <th>Inspection No.</th>
            <th>Transformer No.</th>
            <th>Branch</th>
            <th>Inspected Date</th>
            <th>Maintenance Date</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
          </thead>
          <tbody>
          {!loading && items.map(i => (
            <tr key={i.id}>
              <td className="code-data">
                <div className="code-info">
                  <span className="code-number">{i.inspectionNo}</span>
                  <div className="inspected-by">by {i.inspectedBy}</div>
                </div>
              </td>
              <td className="transformer-data">
                <span className="transformer-code">{i.transformerCode}</span>
              </td>
              <td className="branch-data">{i.branch}</td>
              <td className="date-data">
                {formatDateTime(i.inspectionDate, i.inspectionTime)}
              </td>
              <td className="date-data">
                {i.maintenanceDate ? formatDateTime(i.maintenanceDate, i.maintenanceTime || undefined) : '-'}
              </td>
              <td className="status-data">
                {getStatusBadge(i.status)}
              </td>
              <td className="actions-cell">
                <div className="action-buttons" style={{ display: 'flex', gap: '0.5rem' }}>
                  <button 
                    className="action-btn view-btn" 
                    onClick={() => nav(`/inspections/${i.id}`)}
                    style={{ 
                      display: 'flex', 
                      width: '32px',
                      height: '32px',
                      background: '#3b82f6',
                      color: 'white',
                      border: 'none',
                      borderRadius: '6px',
                      cursor: 'pointer',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <span className="btn-icon" style={{ fontSize: '0.9rem' }}>👁️</span>
                  </button>
                  <button 
                    className="action-btn delete-btn" 
                    onClick={async () => {
                      if (!confirm('Delete this inspection?')) return;
                      try { 
                        await deleteInspection(i.id); 
                        await load(); 
                        setSuccessMsg(`Inspection ${i.inspectionNo} deleted successfully!`);
                        setTimeout(() => setSuccessMsg(null), 5000);
                      } catch (e: any) { 
                        setDeleteError(e?.message || 'Delete failed');
                        setTimeout(() => setDeleteError(null), 5000);
                      }
                    }}
                    style={{ 
                      display: 'flex', 
                      width: '32px',
                      height: '32px',
                      background: '#ef4444',
                      color: 'white',
                      border: 'none',
                      borderRadius: '6px',
                      cursor: 'pointer',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <span className="btn-icon" style={{ fontSize: '0.9rem' }}>🗑️</span>
                  </button>
                </div>
              </td>
            </tr>
          ))}
          {!loading && items.length === 0 && !loadErr && (
            <tr><td colSpan={7} className="empty-state">No inspections yet.</td></tr>
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

      {/* Modal: Add Inspection */}
      <Modal open={open} onClose={() => setOpen(false)} title="Add Inspection" width={720}>
        <form onSubmit={onCreate} style={{ display: 'grid', gridTemplateColumns:'1fr 1fr', gap: 12 }}>
          <Input 
            label="Inspection No." 
            placeholder="000123589"
            value={form.inspectionNo} 
            onChange={e => setForm(f => ({ ...f, inspectionNo: e.target.value }))} 
          />
          <Select
            label="Transformer"
            value={form.transformerId}
            onChange={e => setForm(f => ({ ...f, transformerId: e.target.value }))}
            options={[
              { value: '', label: 'Select transformer…' },
              ...transformers.map(t => ({ value: t.id, label: `${t.code} - ${t.location}` }))
            ]}
          />
          <Input 
            label="Branch" 
            placeholder="Nugegoda"
            value={form.branch} 
            onChange={e => setForm(f => ({ ...f, branch: e.target.value }))} 
          />
          <Input 
            label="Inspected By" 
            placeholder="Inspector Name"
            value={form.inspectedBy} 
            onChange={e => setForm(f => ({ ...f, inspectedBy: e.target.value }))} 
          />
          <Input 
            label="Inspection Date" 
            type="date"
            value={form.inspectionDate} 
            onChange={e => setForm(f => ({ ...f, inspectionDate: e.target.value }))} 
          />
          <Input 
            label="Inspection Time" 
            type="time"
            value={form.inspectionTime} 
            onChange={e => setForm(f => ({ ...f, inspectionTime: e.target.value }))} 
          />
          <Input 
            label="Maintenance Date (Optional)" 
            type="date"
            value={form.maintenanceDate} 
            onChange={e => setForm(f => ({ ...f, maintenanceDate: e.target.value }))} 
          />
          <Input 
            label="Maintenance Time (Optional)" 
            type="time"
            value={form.maintenanceTime} 
            onChange={e => setForm(f => ({ ...f, maintenanceTime: e.target.value }))} 
          />
          <div style={{ gridColumn: '1 / -1' }}>
            <Input 
              label="Notes (Optional)" 
              placeholder="Additional notes or comments"
              value={form.notes} 
              onChange={e => setForm(f => ({ ...f, notes: e.target.value }))} 
            />
          </div>

          {createErr && <div className="modal-error" style={{ gridColumn:'1 / -1' }}>{createErr}</div>}

          <div style={{ gridColumn: '1 / -1', display:'flex', gap:8, justifyContent:'flex-end', marginTop: 4 }}>
            <button 
              type="button" 
              onClick={() => setOpen(false)}
              style={{ 
                borderRadius: 10, 
                padding: '12px 20px',
                background: 'linear-gradient(135deg, #6b7280 0%, #9ca3af 100%)',
                color: 'white',
                border: 'none',
                cursor: 'pointer',
                fontWeight: '600',
                fontSize: '14px'
              }}
            >
              Cancel
            </button>
            <button 
              type="submit" 
              disabled={createBusy}
              style={{ 
                borderRadius: 10, 
                padding: '12px 20px',
                background: createBusy ? '#94a3b8' : 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
                color: 'white',
                border: 'none',
                cursor: createBusy ? 'not-allowed' : 'pointer',
                fontWeight: '600',
                fontSize: '14px'
              }}
            >
              {createBusy ? 'Saving…' : 'Confirm'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
