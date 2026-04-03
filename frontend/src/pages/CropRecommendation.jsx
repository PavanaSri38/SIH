import { useState } from 'react'
import { Link } from 'react-router-dom'

export default function CropRecommendation() {
  const [form, setForm]     = useState({ soil_type:'Loamy', state:'Andhra Pradesh', season:'Kharif' })
  const [result, setResult] = useState(null)
  const [loading, setLoading] = useState(false)

  const soils   = ['Clay','Sandy','Loamy','Silty','Black','Red','Alluvial','Laterite']
  const states  = ['Andhra Pradesh','Telangana','Maharashtra','Karnataka','Tamil Nadu','Punjab','Haryana','Uttar Pradesh','Gujarat','Rajasthan','Madhya Pradesh','West Bengal','Bihar']
  const seasons = ['Kharif','Rabi','Summer']

  async function recommend() {
    setLoading(true)
    const res  = await fetch('/api/crop/recommend', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(form) })
    const data = await res.json()
    setResult(data)
    setLoading(false)
  }

  return (
    <div style={{ minHeight:'100vh', background:'var(--bg)' }}>
      <header style={{ background:'var(--navy)', color:'white', padding:'1rem 2rem', display:'flex', alignItems:'center', gap:'1rem' }}>
        <Link to="/dashboard" style={{ color:'white' }}>← Dashboard</Link>
        <h1>🌱 Crop Recommendation</h1>
      </header>
      <div style={{ padding:'2rem', maxWidth:'800px', margin:'0 auto' }}>
        <div className="card" style={{ marginBottom:'1.5rem' }}>
          <div style={{ display:'flex', gap:'1rem', flexWrap:'wrap' }}>
            <div style={{ flex:1 }}>
              <label style={{ display:'block', marginBottom:'0.3rem', color:'var(--muted)' }}>Soil Type</label>
              <select value={form.soil_type} onChange={e=>setForm({...form,soil_type:e.target.value})}>
                {soils.map(s=><option key={s}>{s}</option>)}
              </select>
            </div>
            <div style={{ flex:1 }}>
              <label style={{ display:'block', marginBottom:'0.3rem', color:'var(--muted)' }}>State</label>
              <select value={form.state} onChange={e=>setForm({...form,state:e.target.value})}>
                {states.map(s=><option key={s}>{s}</option>)}
              </select>
            </div>
            <div style={{ flex:1 }}>
              <label style={{ display:'block', marginBottom:'0.3rem', color:'var(--muted)' }}>Season</label>
              <select value={form.season} onChange={e=>setForm({...form,season:e.target.value})}>
                {seasons.map(s=><option key={s}>{s}</option>)}
              </select>
            </div>
          </div>
          <button className="btn-primary" style={{ marginTop:'1rem' }} onClick={recommend} disabled={loading}>
            {loading?'Getting recommendations...':'Get Crop Recommendations'}
          </button>
        </div>
        {result?.crops && (
          <div className="card">
            <h3 style={{ color:'var(--navy)', marginBottom:'1rem' }}>Recommended Crops</h3>
            <div style={{ display:'flex', flexWrap:'wrap', gap:'0.5rem' }}>
              {result.crops.map(c=><span key={c.name} className="badge badge-green">{c.name}</span>)}
            </div>
            {result.advisory && <p style={{ marginTop:'1rem', color:'var(--muted)', lineHeight:1.6 }}>{result.advisory}</p>}
          </div>
        )}
      </div>
    </div>
  )
}
