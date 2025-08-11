import { useEffect, useState } from 'react';
import Input from '../components/Input';
import Select from '../components/Select';
import FileDrop from '../components/FileDrop';
import { listTransformers } from '../api/transformers';
import type { Transformer } from '../api/transformers';
import { uploadImage } from '../api/images';

export default function ImageUpload() {
  const [transformers, setTransformers] = useState<Transformer[]>([]);
  const [transformerId, setTransformerId] = useState('');
  const [type, setType] = useState<'BASELINE'|'MAINTENANCE'>('BASELINE');
  const [env, setEnv] = useState<'SUNNY'|'CLOUDY'|'RAINY'|' '>(' ');
  const [uploader, setUploader] = useState('admin');
  const [file, setFile] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    (async () => {
      const res = await listTransformers('', 0, 100);
      setTransformers(res.content);
      if (res.content[0]) setTransformerId(res.content[0].id);
    })();
  }, []);

  async function submit() {
    if (!transformerId || !file) { alert('Select transformer and file'); return; }
    if (type === 'BASELINE' && env === ' ') { alert('Choose environmental condition'); return; }
    try {
      setBusy(true);
      await uploadImage({
        transformerId, type,
        envCondition: type === 'BASELINE' ? (env as any) : undefined,
        uploader, file
      });
      alert('Uploaded');
      setFile(null);
    } catch (e: any) {
      alert(e.message || 'Upload failed');
    } finally { setBusy(false); }
  }

  return (
    <div style={{ maxWidth: 720, margin: '24px auto', padding: 16 }}>
      <h2>Upload Thermal Image</h2>
      <Select
        label="Transformer"
        value={transformerId}
        onChange={e => setTransformerId(e.target.value)}
        options={transformers.map(t => ({ value: t.id, label: `${t.code} – ${t.location}` }))}
      />
      <Select
        label="Type"
        value={type}
        onChange={e => setType(e.target.value as any)}
        options={[{ value: 'BASELINE', label: 'Baseline' }, { value: 'MAINTENANCE', label: 'Maintenance' }]}
      />
      {type === 'BASELINE' && (
        <Select
          label="Environmental Condition"
          value={env}
          onChange={e => setEnv(e.target.value as any)}
          options={[
            { value: ' ', label: 'Select condition…' },
            { value: 'SUNNY', label: 'Sunny' },
            { value: 'CLOUDY', label: 'Cloudy' },
            { value: 'RAINY', label: 'Rainy' },
          ]}
        />
      )}
      <Input label="Uploader" value={uploader} onChange={e => setUploader(e.target.value)} />
      <FileDrop onFile={setFile} />
      {file && <div style={{ marginTop: 8 }}>Selected: <strong>{file.name}</strong></div>}
      <div style={{ marginTop: 12 }}>
        <button onClick={submit} disabled={busy}>{busy ? 'Uploading…' : 'Upload'}</button>
      </div>
    </div>
  );
}