import { useState } from 'react'
const CROPS  = ["Rice","Wheat","Cotton","Sugarcane","Maize","Soybean","Groundnut","Tomato","Onion","Potato","Jowar","Bajra","Tur Dal","Chana","Mustard"]
const STATES = ["Andhra Pradesh","Telangana","Maharashtra","Gujarat","Punjab","Karnataka","Uttar Pradesh","Tamil Nadu","Rajasthan"]
export default function MarketPrices() {
  const [crop,  setCrop]  = useState('Cotton')
  const [state, setState] = useState('Andhra Pradesh')
  const [data,  setData]  = useState(null)
  const [loading, setLoading] = useState(false)
  async function load() {
    setLoading(true)
    const res  = await fetch(`/api/market/prices?crop=${encodeURIComponent(crop)}&state=${encodeURIComponent(state)}`)
    const json = await res.json()
    setData(json)
    setLoading(false)
  }
  const trendColor = data?.trend==='UP'?'var(--green)':data?.trend==='DOWN'?'#C62828':'var(--navy)'
  return (
    <div style={{ padding:'2rem', maxWidth:'650px', margin:'0 auto' }}>
      <h2 style={{ color:'var(--navy)', marginBottom:'1.5rem' }}>📈 Market Price Intelligence</h2>
      <div className="card" style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:'1rem', marginBottom:'1rem' }}>
        <div><label style={{ fontWeight:600, color:'var(--navy)' }}>Crop</label><select value={crop} onChange={e=>setCrop(e.target.value)} style={{ marginTop:'0.5rem' }}>{CROPS.map(c=><option key={c}>{c}</option>)}</select></div>
        <div><label style={{ fontWeight:600, color:'var(--navy)' }}>State</label><select value={state} onChange={e=>setState(e.target.value)} style={{ marginTop:'0.5rem' }}>{STATES.map(s=><option key={s}>{s}</option>)}</select></div>
      </div>
      <button className="btn-primary" onClick={load} disabled={loading} style={{ width:'100%', padding:'0.9rem' }}>{loading?'Loading...':'Get Price'}</button>
      {data && (
        <div className="card" style={{ marginTop:'1.5rem', textAlign:'center' }}>
          <h3 style={{ color:'var(--navy)', marginBottom:'0.5rem' }}>{data.crop} — {data.state}</h3>
          <div style={{ fontSize:'2.5rem', fontWeight:800, color:'var(--green)' }}>₹{data.price_per_quintal}<span style={{ fontSize:'1rem', fontWeight:400, color:'var(--muted)' }}>/quintal</span></div>
          <div style={{ marginTop:'0.5rem' }}>
            <span className="badge" style={{ background: data.trend==='UP'?'var(--lt-green)':'#FFEBEE', color:trendColor }}>
              {data.trend==='UP'?'▲':'▼'} {Math.abs(data.trend_pct)}%
            </span>
          </div>
        </div>
      )}
    </div>
  )
}
