// src/pages/TransformerDetail.tsx
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
  const { id } = useParams();
  const nav = useNavigate();

  const [t, setT] = useState<Transformer | null>(null);
  const [loadErr, setLoadErr] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  // ------- editable basics -------
  const [code, setCode] = useState('');
  const [location, setLocation] = useState('');
  const [capacityKVA, setCapacity] = useState<number | ''>('');
  const [region, setRegion] = useState<string>('');
  const [poleNo, setPoleNo] = useState<string>('');
  const [type, setType] = useState<string>(''); // "Bulk" | "Distribution"
  const [locationDetails, setLocationDetails] = useState<string>('');

  // ------- images state -------
  const [images, setImages] = useState<ThermalImage[]>([]);
  const [imgErr, setImgErr] = useState<string | null>(null);
  const [imgLoading, setImgLoading] = useState(false);

  // upload panel
  const [imgType, setImgType] = useState<'BASELINE' | 'MAINTENANCE'>('BASELINE');
  const [env, setEnv] = useState<'SUNNY' | 'CLOUDY' | 'RAINY' | ' '>(' ');
  const [uploader, setUploader] = useState('admin');
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  // notification states
  const [successMsg, setSuccessMsg] = useState<string>('');
  const [errorMsg, setErrorMsg] = useState<string>('');
  const [warningMsg, setWarningMsg] = useState<string>('');

  useEffect(() => {
    (async () => {
      try {
        setLoadErr(null);
        if (!id) throw new Error('No transformer id in route');
        const data = await getTransformer(id);
        setT(data);

        // populate form
        setCode(data.code);
        setLocation(data.location);
        setCapacity(data.capacityKVA);
        setRegion(data.region ?? '');
        setPoleNo(data.poleNo ?? '');
        setType(data.type ?? '');
        setLocationDetails(data.locationDetails ?? '');

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
      await updateTransformer(t.id, {
        code,
        location,
        capacityKVA: Number(capacityKVA || 0),
        region: region || undefined,
        poleNo: poleNo || undefined,
        type: type || undefined,
        locationDetails: locationDetails || undefined,
      });
      setSuccessMsg('Transformer details saved successfully!');
      setTimeout(() => setSuccessMsg(''), 4000);
    } catch (e: any) {
      setErrorMsg(e?.message || 'Failed to save transformer details');
      setTimeout(() => setErrorMsg(''), 4000);
    } finally {
      setSaving(false);
    }
  }

  async function doUpload() {
    if (!t || !file) { 
      setWarningMsg('Please select a file');
      setTimeout(() => setWarningMsg(''), 4000);
      return; 
    }
    if (imgType === 'BASELINE' && env === ' ') { 
      setWarningMsg('Please pick environmental condition');
      setTimeout(() => setWarningMsg(''), 4000);
      return; 
    }
    try {
      setUploading(true);
      await uploadImage({
        transformerId: t.id,
        type: imgType,
        envCondition: imgType === 'BASELINE' ? (env as any) : undefined,
        uploader,
        file
      });
      await refreshImages(t.id);
      setFile(null);
      setSuccessMsg('Image uploaded successfully!');
      setTimeout(() => setSuccessMsg(''), 4000);
    } catch (e: any) {
      setErrorMsg(e?.message || 'Upload failed');
      setTimeout(() => setErrorMsg(''), 4000);
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
    return one ? [one, one] : [null, null];   // show same image twice if only one exists
  }, [latestBaseline, latestMaintenance]);

  return (
    <div className="page-container">
      {/* Notifications */}
      {successMsg && (
        <div className="success-message">
          <span className="message-icon">✓</span>
          {successMsg}
        </div>
      )}
      {errorMsg && (
        <div className="error-message">
          <span className="message-icon">✕</span>
          {errorMsg}
        </div>
      )}
      {warningMsg && (
        <div className="warning-message">
          <span className="message-icon">⚠</span>
          {warningMsg}
        </div>
      )}

      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
      <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <h1 style={{ marginTop: 0 }}>{t ? `Transformer ${t.code}` : 'Transformer'}</h1>
        <button 
          onClick={() => nav('/transformers')} 
          style={{ 
            borderRadius: 10, 
            padding: '8px 16px',
            background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
            color: 'white',
            border: 'none',
            cursor: 'pointer',
            fontWeight: '600',
            fontSize: '14px',
            opacity: 1,
            visibility: 'visible',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            boxShadow: '0 2px 8px rgba(124, 58, 237, 0.3)',
            transition: 'all 0.2s ease'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-1px)';
            e.currentTarget.style.boxShadow = '0 4px 12px rgba(124, 58, 237, 0.4)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 2px 8px rgba(124, 58, 237, 0.3)';
          }}
        >
          Back to list
        </button>
      </div>

      {loadErr && <div style={{ color:'#b00020', marginBottom: 12 }}>Error: {loadErr}</div>}

      {/* Basics (all fields) */}
      <div style={{
        display:'grid',
        gridTemplateColumns:'1fr 1fr 1fr',
        gap: 12, background:'#fff', border:'1px solid #eee',
        borderRadius:12, padding:16, marginBottom:16
      }}>
        <Input label="Transformer Code" value={code} onChange={e=>setCode(e.target.value)} placeholder="TX-001" />
        <Input label="Location" value={location} onChange={e=>setLocation(e.target.value)} placeholder="Substation A" />
        <Input label="Capacity (kVA)" type="number" value={capacityKVA} onChange={e=>setCapacity(e.target.value as any)} />

        <Select
          label="Region"
          value={region}
          onChange={e=>setRegion(e.target.value)}
          options={[
            { value: '', label: 'Select region…' },
            { value: 'Nugegoda', label: 'Nugegoda' },
            { value: 'Maharagama', label: 'Maharagama' },
            { value: 'Colombo', label: 'Colombo' },
          ]}
        />
        <Input label="Pole No." value={poleNo} onChange={e=>setPoleNo(e.target.value)} placeholder="EN-122-A" />
        <Select
          label="Type"
          value={type}
          onChange={e=>setType(e.target.value)}
          options={[
            { value: '', label: 'Select type…' },
            { value: 'Bulk', label: 'Bulk' },
            { value: 'Distribution', label: 'Distribution' },
          ]}
        />

        <div style={{ gridColumn:'1 / -1' }}>
          <label style={{ display:'block', fontWeight:600, marginBottom:6 }}>Location Details</label>
          <textarea
            value={locationDetails}
            onChange={e=>setLocationDetails(e.target.value)}
            placeholder="Notes / directions"
            style={{ width:'100%', minHeight: 80, padding:8, borderRadius:6, border:'1px solid #ccc', resize:'vertical' }}
          />
        </div>

        <div style={{ gridColumn:'1 / -1', display:'flex', gap:8 }}>
          <button 
            onClick={saveBasics} 
            disabled={saving} 
            style={{ 
              borderRadius: 10, 
              padding: '12px 20px',
              background: saving ? '#94a3b8' : 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
              color: 'white',
              border: 'none',
              cursor: saving ? 'not-allowed' : 'pointer',
              fontWeight: '600',
              fontSize: '14px',
              opacity: 1,
              visibility: 'visible',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              boxShadow: '0 2px 8px rgba(124, 58, 237, 0.3)',
              transition: 'all 0.2s ease'
            }}
            onMouseEnter={(e) => {
              if (!saving) {
                e.currentTarget.style.transform = 'translateY(-1px)';
                e.currentTarget.style.boxShadow = '0 4px 12px rgba(124, 58, 237, 0.4)';
              }
            }}
            onMouseLeave={(e) => {
              if (!saving) {
                e.currentTarget.style.transform = 'translateY(0)';
                e.currentTarget.style.boxShadow = '0 2px 8px rgba(124, 58, 237, 0.3)';
              }
            }}
          >
            {saving ? 'Saving…' : 'Save'}
          </button>
        </div>
      </div>

      {/* Image section */}
      {t && (
        <div>
          {/* Side-by-side comparison */}
          <div style={{ marginBottom: 24 }}>
            <h3 style={{ margin:'12px 0' }}>Thermal Image Comparison</h3>
            <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
              <ImageBox title={leftImg?.type === 'BASELINE' ? 'Baseline' : leftImg ? 'Current' : '—'} img={leftImg} />
              <ImageBox title={rightImg?.type === 'MAINTENANCE' ? 'Current' : rightImg ? 'Baseline' : '—'} img={rightImg} />
            </div>
          </div>

          {/* Gallery */}
          <div style={{ marginBottom: 32 }}>
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

          {/* Upload panel */}
          <div style={{ 
            background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)', 
            border: '1px solid rgba(124, 58, 237, 0.1)', 
            borderRadius: 16, 
            padding: 24,
            boxShadow: '0 4px 20px rgba(30, 64, 175, 0.08)'
          }}>
            <h3 style={{ marginTop: 0, marginBottom: 20, fontFamily: 'Montserrat', color: '#1e40af', display: 'flex', alignItems: 'center', gap: 8 }}>
              Upload New Image
            </h3>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 20 }}>
              <Select
                label="Image Type"
                value={imgType}
                onChange={e=>setImgType(e.target.value as any)}
                options={[{ value:'BASELINE', label:'Baseline' }, { value:'MAINTENANCE', label:'Maintenance' }]}
              />
              <Input label="Uploader Name" value={uploader} onChange={e=>setUploader(e.target.value)} />
            </div>
            
            {imgType === 'BASELINE' && (
              <div style={{ marginBottom: 20 }}>
                <Select
                  label="Environmental Condition"
                  value={env}
                  onChange={e=>setEnv(e.target.value as any)}
                  options={[
                    { value:' ', label:'Select weather condition…' },
                    { value:'SUNNY', label:'Sunny' },
                    { value:'CLOUDY', label:'Cloudy' },
                    { value:'RAINY', label:'Rainy' },
                  ]}
                />
              </div>
            )}
            
            <FileDrop onFile={setFile} />
            {file && (
              <div style={{ 
                marginTop: 12, 
                padding: 12, 
                background: 'rgba(34, 197, 94, 0.1)', 
                borderRadius: 8, 
                border: '1px solid rgba(34, 197, 94, 0.2)',
                fontSize: 14,
                display: 'flex',
                alignItems: 'center',
                gap: 8
              }}>
                <span>✅</span> Selected: <strong>{file.name}</strong>
              </div>
            )}
            <div style={{ marginTop: 16 }}>
              <button 
                onClick={doUpload} 
                disabled={uploading}
                style={{ 
                  background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
                  color: 'white',
                  border: 'none',
                  borderRadius: 12,
                  padding: '12px 24px',
                  fontSize: 16,
                  fontWeight: 600,
                  cursor: uploading ? 'not-allowed' : 'pointer',
                  opacity: uploading ? 0.7 : 1,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                  boxShadow: '0 4px 12px rgba(124, 58, 237, 0.25)',
                  transition: 'all 0.3s ease'
                }}
              >
                {uploading ? 'Uploading…' : 'Upload Image'}
              </button>
            </div>
          </div>
        </div>
      )}
      </div>
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