import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import Input from '../components/Input';
import Select from '../components/Select';
import FileDrop from '../components/FileDrop';
import { getTransformer, updateTransformer } from '../api/transformers';
import type { Transformer } from '../api/transformers';
import { listImages, uploadImage } from '../api/images';
import type { ThermalImage } from '../api/images';

export default function TransformerDetail() {
  const { id } = useParams();                 // expects an existing transformer ID
  const nav = useNavigate();

  const [t, setT] = useState<Transformer | null>(null);
  const [loadErr, setLoadErr] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  // form (edit basics if you want)
  const [code, setCode] = useState('');
  const [location, setLocation] = useState('');
  const [capacityKVA, setCapacity] = useState<number | ''>('');

  // images
  const [images, setImages] = useState<ThermalImage[]>([]);
  const [imgErr, setImgErr] = useState<string | null>(null);
  const [imgLoading, setImgLoading] = useState(false);

  // upload panel
  const [type, setType] = useState<'BASELINE'|'MAINTENANCE'>('BASELINE');
  const [env, setEnv] = useState<'SUNNY'|'CLOUDY'|'RAINY'|' '>(' ');
  const [uploader, setUploader] = useState('admin');
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        setLoadErr(null);
        if (!id) throw new Error('No transformer id in route');
        const data = await getTransformer(id);
        setT(data);
        setCode(data.code); setLocation(data.location); setCapacity(data.capacityKVA);
        await refreshImages(id);
      } catch (e: any) {
        console.error('detail init failed:', e);
        setLoadErr(e?.message || 'Failed to load transformer');
      }
    })();
  }, [id]);

  async function refreshImages(transformerId: string) {
    try {
      setImgLoading(true);
      setImgErr(null);
      const res = await listImages({ transformerId, page: 0, size: 200 });
      setImages(res.content ?? []);
    } catch (e: any) {
      console.error('listImages failed:', e);
      setImgErr(e?.message || 'Failed to load images');
      setImages([]);
    } finally {
      setImgLoading(false);
    }
  }

  async function saveBasics() {
    if (!t) return;
    try {
      setSaving(true);
      await updateTransformer(t.id, { code, location, capacityKVA: Number(capacityKVA || 0) });
      alert('Saved');
    } catch (e: any) {
      alert(e?.message || 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  async function doUpload() {
    if (!t || !file) { alert('Select a file'); return; }
    if (type === 'BASELINE' && env === ' ') { alert('Pick environmental condition'); return; }
    try {
      setUploading(true);
      await uploadImage({
        transformerId: t.id,
        type,
        envCondition: type === 'BASELINE' ? (env as any) : undefined,
        uploader,
        file
      });
      await refreshImages(t.id);
      setFile(null);
    } catch (e: any) {
      alert(e?.message || 'Upload failed');
    } finally {
      setUploading(false);
    }
  }

  // choose two images to display side-by-side
  const latestBaseline = useMemo(
    () => images.filter(i => i.type === 'BASELINE').sort((a,b) => +new Date(b.uploadedAt) - +new Date(a.uploadedAt))[0],
    [images]
  );
  const latestMaintenance = useMemo(
    () => images.filter(i => i.type === 'MAINTENANCE').sort((a,b) => +new Date(b.uploadedAt) - +new Date(a.uploadedAt))[0],
    [images]
  );
  const [leftImg, rightImg] = useMemo(() => {
    if (latestBaseline && latestMaintenance) return [latestBaseline, latestMaintenance];
    const one = latestBaseline || latestMaintenance || null;
    return one ? [one, one] : [null, null];   // requirement: show same image twice if only one exists
  }, [latestBaseline, latestMaintenance]);

  return (
    <div style={{ maxWidth: 1200, margin: '0 auto' }}>
      <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <h1 style={{ marginTop: 0 }}>{t ? `Transformer ${t.code}` : 'Transformer'}</h1>
        <button onClick={() => nav('/transformers')} style={{ borderRadius: 10, padding: '8px 12px' }}>Back to list</button>
      </div>

      {loadErr && <div style={{ color:'#b00020', marginBottom: 12 }}>Error: {loadErr}</div>}

      {/* Basics (optional edit) */}
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap: 12, background:'#fff', border:'1px solid #eee', borderRadius:12, padding:16, marginBottom:16 }}>
        <Input label="Transformer Code" value={code} onChange={e=>setCode(e.target.value)} placeholder="TX-001" />
        <Input label="Location" value={location} onChange={e=>setLocation(e.target.value)} placeholder="Substation A" />
        <Input label="Capacity (kVA)" type="number" value={capacityKVA} onChange={e=>setCapacity(e.target.value as any)} />
        <div style={{ gridColumn:'1 / -1', display:'flex', gap:8 }}>
          <button onClick={saveBasics} disabled={saving} style={{ borderRadius:10, padding:'10px 14px' }}>
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </div>

      {/* Only show image section when transformer exists */}
      {t && (
        <div style={{ display:'grid', gridTemplateColumns:'2fr 1fr', gap:16 }}>
          {/* Side-by-side comparison */}
          <div>
            <h3 style={{ margin:'12px 0' }}>Thermal Image Comparison</h3>
            <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
              <ImageBox title={leftImg?.type === 'BASELINE' ? 'Baseline' : leftImg ? 'Current' : '—'} img={leftImg} />
              <ImageBox title={rightImg?.type === 'MAINTENANCE' ? 'Current' : rightImg ? 'Baseline' : '—'} img={rightImg} />
            </div>

            {/* Gallery (optional) */}
            <div style={{ marginTop: 18 }}>
              <h3>All Images</h3>
              {imgErr && <div style={{ color:'#b00020' }}>Error: {imgErr}</div>}
              {imgLoading && <div>Loading images…</div>}
              {!imgLoading && images.length === 0 && <div style={{ color:'#666' }}>No images yet.</div>}
              {!imgLoading && images.length > 0 && (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px,1fr))', gap: 12 }}>
                  {images.map(img => (
                    <div key={img.id} style={{ border: '1px solid #eee', borderRadius: 8, padding: 8 }}>
                      <div style={{ height: 160, display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#fafafa', borderRadius: 6 }}>
                        <img src={img.publicUrl} alt={img.originalFilename} style={{ maxHeight: '100%', maxWidth: '100%', objectFit: 'contain' }} />
                      </div>
                      <div style={{ fontSize: 12, marginTop: 6 }}>
                        <div><strong>{img.type}</strong>{img.envCondition ? ` • ${img.envCondition}` : ''}</div>
                        <div>{new Date(img.uploadedAt).toLocaleString()}</div>
                        <div>{(img.sizeBytes/1024).toFixed(1)} KB</div>
                        <div>{img.uploader}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Upload panel */}
          <div style={{ background:'#fff', border:'1px solid #eee', borderRadius:12, padding:16 }}>
            <h3 style={{ marginTop:0 }}>Upload Image</h3>
            <Select
              label="Type"
              value={type}
              onChange={e=>setType(e.target.value as any)}
              options={[{ value:'BASELINE', label:'Baseline' }, { value:'MAINTENANCE', label:'Maintenance' }]}
            />
            {type === 'BASELINE' && (
              <Select
                label="Environmental Condition"
                value={env}
                onChange={e=>setEnv(e.target.value as any)}
                options={[
                  { value:' ', label:'Select condition…' },
                  { value:'SUNNY', label:'Sunny' },
                  { value:'CLOUDY', label:'Cloudy' },
                  { value:'RAINY', label:'Rainy' },
                ]}
              />
            )}
            <Input label="Uploader" value={uploader} onChange={e=>setUploader(e.target.value)} />
            <FileDrop onFile={setFile} />
            {file && <div style={{ marginTop: 6, fontSize: 12 }}>Selected: <strong>{file.name}</strong></div>}
            <div style={{ marginTop: 10 }}>
              <button onClick={doUpload} disabled={uploading} style={{ borderRadius: 10, padding: '10px 14px' }}>
                {uploading ? 'Uploading…' : 'Upload'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function ImageBox({ title, img }: { title: string; img: ThermalImage | null }) {
  return (
    <div style={{ background:'#fff', border:'1px solid #eee', borderRadius:12, padding:12 }}>
      <div style={{ display:'flex', justifyContent:'space-between', marginBottom:8 }}>
        <div style={{ fontWeight:600 }}>{title}</div>
        {img && <div style={{ fontSize:12, color:'#666' }}>{new Date(img.uploadedAt).toLocaleString()}</div>}
      </div>
      <div style={{ height:320, display:'flex', alignItems:'center', justifyContent:'center', background:'#0a0f3b', borderRadius:8 }}>
        {img
          ? <img src={img.publicUrl} alt={img.originalFilename} style={{ maxHeight:'100%', maxWidth:'100%', objectFit:'contain' }} />
          : <div style={{ color:'#cbd5ff' }}>No image</div>}
      </div>
    </div>
  );
}