import { Link, useNavigate } from 'react-router-dom'

export default function Dashboard() {
  const nav = useNavigate()
  const name = localStorage.getItem('user_name') || 'Farmer'
  const modules = [
    { icon:'🧪', title:'Soil Analysis',        path:'/soil',    desc:'Check NPK levels & get fertilizer advice' },
    { icon:'🌱', title:'Crop Recommendation',  path:'/crop',    desc:'AI-powered crop suggestions' },
    { icon:'🔬', title:'Disease Detection',    path:'/disease', desc:'Upload leaf photo for diagnosis' },
    { icon:'🌦', title:'Weather & Alerts',     path:'/weather', desc:'Live weather & climate warnings' },
    { icon:'📈', title:'Market Prices',        path:'/market',  desc:'Current mandi prices & trends' },
    { icon:'ℹ️', title:'About',               path:'/about',   desc:'System info & team details' },
  ]
  return (
    <div style={{ minHeight:'100vh', background:'var(--bg)' }}>
      <header style={{ background:'var(--navy)', color:'white', padding:'1rem 2rem', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <h1>🌾 Smart Crop Advisory</h1>
        <button className="btn-orange" onClick={()=>{localStorage.clear();nav('/')}}>Logout</button>
      </header>
      <div style={{ padding:'2rem', maxWidth:'1100px', margin:'0 auto' }}>
        <h2 style={{ color:'var(--navy)', marginBottom:'0.5rem' }}>Welcome, {name}! 👋</h2>
        <p style={{ color:'var(--muted)', marginBottom:'2rem' }}>What would you like to do today?</p>
        <div style={{ display:'grid', gridTemplateColumns:'repeat(auto-fit, minmax(280px, 1fr))', gap:'1.5rem' }}>
          {modules.map(m=>(
            <Link key={m.path} to={m.path}>
              <div className="card" style={{ cursor:'pointer', transition:'transform 0.2s' }}
                onMouseEnter={e=>e.currentTarget.style.transform='translateY(-4px)'}
                onMouseLeave={e=>e.currentTarget.style.transform='translateY(0)'}>
                <div style={{ fontSize:'2rem', marginBottom:'0.5rem' }}>{m.icon}</div>
                <h3 style={{ color:'var(--green)', marginBottom:'0.3rem' }}>{m.title}</h3>
                <p style={{ color:'var(--muted)', fontSize:'0.9rem' }}>{m.desc}</p>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  )
}
