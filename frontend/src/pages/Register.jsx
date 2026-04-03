import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'

export default function Register() {
  const [form, setForm] = useState({ name:'', email:'', phone:'', location:'', preferred_language:'en' })
  const [msg,  setMsg]  = useState('')
  const nav = useNavigate()

  const langs = [['en','English'],['hi','हिंदी'],['te','తెలుగు'],['ta','தமிழ்'],['mr','मराठी'],['gu','ગુજરાતી'],['bn','বাংলা']]

  async function handleSubmit() {
    const res  = await fetch('/api/auth/register', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(form) })
    const data = await res.json()
    if (res.ok) { setMsg('Registered! Redirecting to login...'); setTimeout(()=>nav('/login'), 1500) }
    else setMsg(data.detail || 'Registration failed')
  }

  return (
    <div style={{ display:'flex', justifyContent:'center', alignItems:'center', minHeight:'100vh', background:'var(--lt-green)' }}>
      <div className="card" style={{ width:'100%', maxWidth:'450px' }}>
        <h2 style={{ color:'var(--navy)', marginBottom:'1.5rem', textAlign:'center' }}>🌾 Register</h2>
        {msg && <p style={{ color:'var(--green)', marginBottom:'1rem' }}>{msg}</p>}
        <div style={{ display:'flex', flexDirection:'column', gap:'1rem' }}>
          {['name','email','phone','location'].map(k=>(
            <input key={k} placeholder={k.charAt(0).toUpperCase()+k.slice(1)} value={form[k]} onChange={e=>setForm({...form,[k]:e.target.value})}/>
          ))}
          <select value={form.preferred_language} onChange={e=>setForm({...form,preferred_language:e.target.value})}>
            {langs.map(([v,l])=><option key={v} value={v}>{l}</option>)}
          </select>
          <button className="btn-primary" onClick={handleSubmit}>Register</button>
          <p style={{ textAlign:'center', color:'var(--muted)', fontSize:'0.9rem' }}>Have account? <Link to="/login" style={{color:'var(--green)'}}>Login</Link></p>
        </div>
      </div>
    </div>
  )
}
