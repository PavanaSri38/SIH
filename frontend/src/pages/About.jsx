export default function About() {
  return (
    <div style={{ padding:'2rem', maxWidth:'750px', margin:'0 auto' }}>
      <div className="card">
        <h2 style={{ color:'var(--navy)', marginBottom:'1rem' }}>About Smart Crop Advisory System</h2>
        <p style={{ marginBottom:'1rem', lineHeight:1.7 }}>
          The Smart Crop Advisory System is an AI-powered web platform designed to help Indian farmers make
          data-driven agricultural decisions. Built for SIH 2025, it bridges the last-mile knowledge gap
          between agricultural research and the farmer.
        </p>
        <h3 style={{ color:'var(--green)', marginBottom:'0.5rem' }}>Team</h3>
        <ul style={{ paddingLeft:'1.5rem', marginBottom:'1rem' }}>
          <li>R. Pavana Sri — Team Leader, Project Manager</li>
          <li>M. Hema Latha — Web Design & Cloud Deployment</li>
          <li>D.J.V.V. Bhaskar — ML Model Training & Optimization</li>
          <li>S. Chaitanya — Backend & GitHub Maintenance</li>
        </ul>
        <h3 style={{ color:'var(--green)', marginBottom:'0.5rem' }}>Guide</h3>
        <p>Dr. V. Muralidhar — VVIT, CSE-AIML Department</p>
        <h3 style={{ color:'var(--green)', marginBottom:'0.5rem', marginTop:'1rem' }}>Technologies</h3>
        <p>FastAPI · PyTorch · Google Gemini 2.5 Flash · React 18 · Open-Meteo · SQLite</p>
      </div>
    </div>
  )
}
