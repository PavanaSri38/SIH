import { Link } from 'react-router-dom'
export default function NotFound() {
  return (
    <div style={{ display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', minHeight:'100vh' }}>
      <div style={{ fontSize:'4rem' }}>🌾</div>
      <h2 style={{ color:'var(--navy)', margin:'1rem 0' }}>404 — Page Not Found</h2>
      <p style={{ color:'var(--muted)', marginBottom:'1.5rem' }}>This field doesn't exist yet!</p>
      <Link to="/" style={{ background:'var(--green)', color:'white', padding:'0.7rem 1.5rem', borderRadius:'8px', fontWeight:600 }}>Go Home</Link>
    </div>
  )
}
