import { useState } from 'react'
const CITIES = ["Guntur","Hyderabad","Vijayawada","Bangalore","Chennai","Mumbai","Delhi","Jaipur","Kolkata","Ahmedabad"]
export default function Weather() {
  const [city, setCity]     = useState('Guntur')
  const [data, setData]     = useState(null)
  const [loading, setLoading] = useState(false)
  async function load() {
    setLoading(true)
    const res  = await fetch(`/api/weather/current?city=${encodeURIComponent(city)}`)
    const json = await res.json()
    setData(json)
    setLoading(false)
  }
  const w = data?.weather?.current
  return (
    <div style={{ padding:'2rem', maxWidth:'700px', margin:'0 auto' }}>
      <h2 style={{ color:'var(--navy)', marginBottom:'1.5rem' }}>🌦️ Weather & Climate Alerts</h2>
      <div className="card" style={{ display:'flex', gap:'1rem', marginBottom:'1rem', alignItems:'flex-end' }}>
        <div style={{ flex:1 }}>
          <label style={{ fontWeight:600, color:'var(--navy)' }}>Select City</label>
          <select value={city} onChange={e=>setCity(e.target.value)} style={{ marginTop:'0.5rem' }}>
            {CITIES.map(c=><option key={c}>{c}</option>)}
          </select>
        </div>
        <button className="btn-primary" onClick={load} disabled={loading}>{loading?'Loading...':'Get Weather'}</button>
      </div>
      {w && (
        <div className="card" style={{ marginBottom:'1rem', display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:'1rem', textAlign:'center' }}>
          <div><div style={{ fontSize:'2rem' }}>🌡️</div><strong style={{ fontSize:'1.5rem', color:'var(--orange)' }}>{w.temperature_2m}°C</strong><div>Temperature</div></div>
          <div><div style={{ fontSize:'2rem' }}>💧</div><strong style={{ fontSize:'1.5rem', color:'var(--blue)' }}>{w.relative_humidity_2m}%</strong><div>Humidity</div></div>
          <div><div style={{ fontSize:'2rem' }}>💨</div><strong style={{ fontSize:'1.5rem', color:'var(--navy)' }}>{w.wind_speed_10m} km/h</strong><div>Wind</div></div>
        </div>
      )}
      {data?.alerts?.length > 0 && (
        <div className="card" style={{ background:'#FFF2CC', borderLeft:'4px solid var(--orange)' }}>
          <h4 style={{ color:'var(--orange)', marginBottom:'0.5rem' }}>⚠️ Climate Alerts</h4>
          {data.alerts.map((a,i)=><p key={i} style={{ marginBottom:'0.3rem' }}>• {a.message}</p>)}
        </div>
      )}
    </div>
  )
}
