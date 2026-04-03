import { useState } from 'react'
import { Link } from 'react-router-dom'

export default function DiseaseDetection() {
  const [file,    setFile]    = useState(null)
  const [preview, setPreview] = useState(null)
  const [result,  setResult]  = useState(null)
  const [loading, setLoading] = useState(false)

  function onFileChange(e) {
    const f = e.target.files[0]
    if (!f) return
    setFile(f)
    setPreview(URL.createObjectURL(f))
    setResult(null)
  }

  async function detect() {
    if (!file) return
    setLoading(true)
    const fd = new FormData()
    fd.append('file', file)
    const res  = await fetch('/api/disease/detect', { method:'POST', body: fd })
    const data = await res.json()
    setResult(data)
    setLoading(false)
  }

  return (
    <div style={{ minHeight:'100vh', background:'var(--bg)' }}>
      <header style={{ background:'var(--navy)', color:'white', padding:'1rem 2rem', display:'flex', alignItems:'center', gap:'1rem' }}>
        <Link to="/dashboard" style={{ color:'white' }}>← Dashboard</Link>
        <h1>🔬 Disease Detection</h1>
      </header>
      <div style={{ padding:'2rem', maxWidth:'700px', margin:'0 auto' }}>
        <div className="card" style={{ marginBottom:'1.5rem' }}>
          <input type="file" accept="image/*" onChange={onFileChange}/>
          {preview && <img src={preview} alt="Preview" style={{ width:'100%', maxHeight:'300px', objectFit:'contain', marginTop:'1rem', borderRadius:'8px' }}/>}
          <button className="btn-primary" style={{ marginTop:'1rem' }} onClick={detect} disabled={!file||loading}>
            {loading?'Analyzing...':'Detect Disease'}
          </button>
        </div>
        {result && (
          <div className="card">
            <h3 style={{ color:'var(--navy)', marginBottom:'1rem' }}>Detection Result</h3>
            <p><strong>Crop:</strong> {result.crop}</p>
            <p><strong>Disease:</strong> {result.disease}</p>
            <p><strong>Confidence:</strong> {result.confidence}%</p>
            <span className={`badge ${result.is_healthy?'badge-green':'badge-orange'}`} style={{ marginTop:'0.5rem' }}>
              {result.is_healthy?'Healthy':'Disease Detected'}
            </span>
            {result.advisory && <p style={{ marginTop:'1rem', color:'var(--muted)', lineHeight:1.6 }}>{result.advisory}</p>}
          </div>
        )}
      </div>
    </div>
  )
}
