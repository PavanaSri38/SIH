import { useState } from 'react'
import { Link } from 'react-router-dom'

export default function SoilAnalysis() {
  const [form, setForm]     = useState({ nitrogen:0, phosphorus:0, potassium:0, ph:7, organic_matter:2 })
  const [result, setResult] = useState(null)
  const [loading, setLoading] = useState(false)

  async function analyze() {
    setLoading(true)
    const userId = localStorage.getItem('user_id') || 1
    const res  = await fetch('/api/soil/analyze', { method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({...form, user_id: parseInt(userId)}) })
    const data = await res.json()
    setResult(data)
    setLoading(false)
  }

  const fields = [['nitrogen','Nitrogen (kg/ha)',0,150],['phosphorus','Phosphorus (kg/ha)',0,60],
    ['potassium','Potassium (kg/ha)',0,80],['ph','Soil pH',0,14],['organic_matter','Organic Matter (%)',0,10]]

  return (
    <div style={{ minHeight:'100vh', background:'var(--bg)' }}>
      <header style={{ background:'var(--navy)', color:'white', padding:'1rem 2rem', display:'flex', alignItems:'center', gap:'1rem' }}>
        <Link to="/dashboard" style={{ color:'white' }}>← Dashboard</Link>
        <h1>🧪 Soil Analysis</h1>
      </header>
      <div style={{ padding:'2rem', maxWidth:'700px', margin:'0 auto' }}>
        <div className="card" style={{ marginBottom:'1.5rem' }}>
          <h3 style={{ color:'var(--navy)', marginBottom:'1rem' }}>Enter Soil Parameters</h3>
          <div style={{ display:'flex', flexDirection:'column', gap:'1rem' }}>
            {fields.map(([k,label,min,max])=>(
              <div key={k}>
                <label style={{ display:'block', marginBottom:'0.3rem', color:'var(--muted)', fontSize:'0.9rem' }}>{label}</label>
                <input type="number" min={min} max={max} value={form[k]} onChange={e=>setForm({...form,[k]:parseFloat(e.target.value)})}/>
              </div>
            ))}
            <button className="btn-primary" onClick={analyze} disabled={loading}>{loading?'Analyzing...':'Analyze Soil'}</button>
          </div>
        </div>
        {result && (
          <div className="card">
            <h3 style={{ color:'var(--navy)', marginBottom:'1rem' }}>Results</h3>
            <div style={{ fontSize:'2rem', textAlign:'center', marginBottom:'1rem' }}>
              Health Score: <strong style={{ color:'var(--green)' }}>{result.health_score}/100</strong>
            </div>
            <h4 style={{ marginBottom:'0.5rem' }}>Recommendations:</h4>
            {result.recommendations?.map((r,i)=><p key={i} style={{ marginBottom:'0.3rem' }}>• {r}</p>)}
            {result.advisory && <><h4 style={{ marginTop:'1rem', marginBottom:'0.5rem' }}>Gemini Advisory:</h4><p style={{ color:'var(--muted)', lineHeight:1.6 }}>{result.advisory}</p></>}
          </div>
        )}
      </div>
    </div>
  )
}
