import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'

export default function Login() {
  const [email, setEmail] = useState('')
  const [otp,   setOtp]   = useState('')
  const [step,  setStep]  = useState(1)
  const [msg,   setMsg]   = useState('')
  const nav = useNavigate()

  async function requestOtp() {
    const res  = await fetch('/api/auth/login', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({email}) })
    const data = await res.json()
    if (res.ok) { setStep(2); setMsg(`OTP sent! (dev: ${data.dev_otp})`) }
    else setMsg(data.detail || 'Error')
  }

  async function verifyOtp() {
    const res  = await fetch('/api/auth/verify-otp', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({email, otp}) })
    const data = await res.json()
    if (res.ok) { localStorage.setItem('user_id', data.user_id); nav('/dashboard') }
    else setMsg(data.detail || 'Invalid OTP')
  }

  return (
    <div style={{ display:'flex', justifyContent:'center', alignItems:'center', minHeight:'100vh', background:'var(--lt-green)' }}>
      <div className="card" style={{ width:'100%', maxWidth:'400px' }}>
        <h2 style={{ color:'var(--navy)', marginBottom:'1.5rem', textAlign:'center' }}>🌾 Login</h2>
        {msg && <p style={{ color:'var(--green)', marginBottom:'1rem' }}>{msg}</p>}
        <div style={{ display:'flex', flexDirection:'column', gap:'1rem' }}>
          <input placeholder="Email address" value={email} onChange={e=>setEmail(e.target.value)} disabled={step===2}/>
          {step===1 && <button className="btn-primary" onClick={requestOtp}>Send OTP</button>}
          {step===2 && <>
            <input placeholder="Enter OTP" value={otp} onChange={e=>setOtp(e.target.value)}/>
            <button className="btn-primary" onClick={verifyOtp}>Verify & Login</button>
          </>}
          <p style={{ textAlign:'center', color:'var(--muted)', fontSize:'0.9rem' }}>No account? <Link to="/register" style={{color:'var(--green)'}}>Register</Link></p>
        </div>
      </div>
    </div>
  )
}
