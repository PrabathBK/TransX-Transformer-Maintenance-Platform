import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Input from '../components/Input';
import { listTransformers, createTransformer, deleteTransformer } from '../api/transformers';
import type { Transformer } from '../api/transformers';

type CreateForm = { code: string; location: string; capacityKVA: string };

export default function TransformersList() {
  // create form state
  const [form, setForm] = useState<CreateForm>({ code: '', location: '', capacityKVA: '' });
  const [createBusy, setCreateBusy] = useState(false);
  const [createErr, setCreateErr] = useState<string | null>(null);

  // list/search state
  const [q, setQ] = useState('');
  const [items, setItems] = useState<Transformer[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);
  const size = 10;
  const [loading, setLoading] = useState(false);
  const [loadErr, setLoadErr] = useState<string | null>(null);

  const nav = useNavigate();

  async function load() {
    try {
      setLoading(true);
      setLoadErr(null);
      const res = await listTransformers(q, page, size);
      setItems(res.content ?? []);
      setTotal(res.totalElements ?? 0);
    } catch (e: any) {
      console.error('listTransformers failed:', e);
      setLoadErr(e?.message || 'Failed to load transformers');
      setItems([]); setTotal(0);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [page]);

  const totalPages = useMemo(() => Math.max(1, Math.ceil(total / size)), [total]);

  async function onCreate(e: React.FormEvent) {
    e.preventDefault();
    const capacity = Number(form.capacityKVA);
    if (!form.code.trim() || !form.location.trim() || !capacity || capacity <= 0) {
      setCreateErr('Please fill all fields with valid values.');
      return;
    }
    try {
      setCreateBusy(true);
      setCreateErr(null);
      await createTransformer({ code: form.code.trim(), location: form.location.trim(), capacityKVA: capacity });
      setForm({ code: '', location: '', capacityKVA: '' });
      // Refresh list to show the new one
      setPage(0);
      await load();
    } catch (e: any) {
      setCreateErr(e?.message || 'Failed to create transformer');
    } finally {
      setCreateBusy(false);
    }
  }

  return (
    <div style={{ maxWidth: 1200, margin: '0 auto' }}>
      <h1 style={{ marginTop: 0 }}>Transformers</h1>

      {/* Create form (matches your image-2 flow) */}
      <form onSubmit={onCreate} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr auto', gap: 12, alignItems: 'end',
        background: '#fff', border: '1px solid #eee', borderRadius: 12, padding: 16, marginBottom: 16 }}>
        <Input label="Transformer No." placeholder="TX-001"
               value={form.code} onChange={e => setForm(f => ({ ...f, code: e.target.value }))} />
        <Input label="Location" placeholder="Substation A"
               value={form.location} onChange={e => setForm(f => ({ ...f, location: e.target.value }))} />
        <Input label="Capacity (kVA)" type="number" placeholder="1000"
               value={form.capacityKVA} onChange={e => setForm(f => ({ ...f, capacityKVA: e.target.value }))} />
        <button type="submit" disabled={createBusy} style={{ height: 40, borderRadius: 10, padding: '0 14px' }}>
          {createBusy ? 'Adding…' : 'Add'}
        </button>
        {createErr && <div style={{ gridColumn: '1 / -1', color: '#b00020' }}>{createErr}</div>}
      </form>

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
              <th style={{ textAlign: 'left', padding: 12 }}>Location</th>
              <th style={{ textAlign: 'left', padding: 12 }}>Capacity (kVA)</th>
              <th style={{ padding: 12 }} />
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr><td colSpan={4} style={{ padding: 24 }}>Loading…</td></tr>
            )}
            {!loading && items.map(t => (
              <tr key={t.id} style={{ borderTop: '1px solid #eee' }}>
                <td style={{ padding: 12, cursor: 'pointer' }} onClick={() => nav(`/transformers/${t.id}`)}>{t.code}</td>
                <td style={{ padding: 12 }}>{t.location}</td>
                <td style={{ padding: 12 }}>{t.capacityKVA}</td>
                <td style={{ padding: 12, textAlign: 'right' }}>
                  <button onClick={() => nav(`/transformers/${t.id}`)}>View</button>
                  <button style={{ marginLeft: 8 }} onClick={async () => {
                    if (!confirm('Delete this transformer?')) return;
                    try { await deleteTransformer(t.id); load(); } catch (e: any) { alert(e?.message || 'Delete failed'); }
                  }}>Delete</button>
                </td>
              </tr>
            ))}
            {!loading && items.length === 0 && !loadErr && (
              <tr><td colSpan={4} style={{ padding: 24, textAlign: 'center', color: '#666' }}>No transformers yet.</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pager */}
      <div style={{ marginTop: 12, display: 'flex', gap: 8, alignItems: 'center' }}>
        <button disabled={page === 0} onClick={() => setPage(p => Math.max(0, p - 1))}>Prev</button>
        <span>Page {page + 1} / {totalPages}</span>
        <button disabled={(page + 1) >= totalPages} onClick={() => setPage(p => p + 1)}>Next</button>
      </div>
    </div>
  );
}