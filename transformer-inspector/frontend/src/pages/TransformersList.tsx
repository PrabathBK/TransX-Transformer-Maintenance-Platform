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
    <div style={{ maxWidth: 1200, margin: '0 auto' }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:16 }}>
        <h1 style={{ margin:0 }}>Transformers</h1>
        <button onClick={() => { resetForm(); setOpen(true); }} style={{ padding:'10px 14px', borderRadius: 10, border:'1px solid #ddd' }}>
          + Add Transformer
        </button>
      </div>

      {/* Search toolbar */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <Input placeholder="Search by transformer code or location" value={q} onChange={e => setQ(e.target.value)} />
        <button onClick={() => { setPage(0); load(); }}>Search</button>
        <button onClick={() => { setQ(''); setPage(0); load(); }}>Reset</button>
      </div>

      {loadErr && <div style={{ color: '#b00020', marginBottom: 12 }}>Error: {loadErr}</div>}

      {/* List */}
      <div style={{ overflowX: 'auto', background: '#fff', border: '1px solid #eee', borderRadius: 12 }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
          <tr style={{ background: '#f8f8ff' }}>
            <th style={{ textAlign: 'left', padding: 12 }}>Transformer No.</th>
            <th style={{ textAlign: 'left', padding: 12 }}>Pole No.</th>
            <th style={{ textAlign: 'left', padding: 12 }}>Region</th>
            <th style={{ textAlign: 'left', padding: 12 }}>Type</th>
            <th style={{ textAlign: 'left', padding: 12 }}>Location</th>
            <th style={{ textAlign: 'left', padding: 12 }}>Capacity (kVA)</th>
            <th style={{ padding: 12 }} />
          </tr>
          </thead>
          <tbody>
          {loading && <tr><td colSpan={7} style={{ padding: 24 }}>Loading…</td></tr>}
          {!loading && items.map(t => (
            <tr key={t.id} style={{ borderTop: '1px solid #eee' }}>
              <td style={{ padding: 12, cursor: 'pointer' }} onClick={() => nav(`/transformers/${t.id}`)}>{t.code}</td>
              <td style={{ padding: 12 }}>{t.poleNo ?? '-'}</td>
              <td style={{ padding: 12 }}>{t.region ?? '-'}</td>
              <td style={{ padding: 12 }}>{t.type ?? '-'}</td>
              <td style={{ padding: 12 }}>{t.location}</td>
              <td style={{ padding: 12 }}>{t.capacityKVA}</td>
              <td style={{ padding: 12, textAlign: 'right' }}>
                <button onClick={() => nav(`/transformers/${t.id}`)}>View</button>
                <button style={{ marginLeft: 8 }} onClick={async () => {
                  if (!confirm('Delete this transformer?')) return;
                  try { await deleteTransformer(t.id); load(); } catch (e:any) { alert(e?.message || 'Delete failed'); }
                }}>Delete</button>
              </td>
            </tr>
          ))}
          {!loading && items.length === 0 && !loadErr && (
            <tr><td colSpan={7} style={{ padding: 24, textAlign: 'center', color: '#666' }}>No transformers yet.</td></tr>
          )}
          </tbody>
        </table>
      </div>

      {/* Pager */}
      <div style={{ marginTop: 12, display:'flex', gap:8, alignItems:'center' }}>
        <button disabled={page === 0} onClick={() => setPage(p => Math.max(0, p - 1))}>Prev</button>
        <span>Page {page + 1} / {totalPages}</span>
        <button disabled={(page + 1) >= totalPages} onClick={() => setPage(p => p + 1)}>Next</button>
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

          {createErr && <div style={{ gridColumn:'1 / -1', color:'#b00020' }}>{createErr}</div>}

          <div style={{ gridColumn: '1 / -1', display:'flex', gap:8, justifyContent:'flex-end', marginTop: 4 }}>
            <button type="button" onClick={() => setOpen(false)}>Cancel</button>
            <button type="submit" disabled={createBusy}>{createBusy ? 'Saving…' : 'Confirm'}</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}