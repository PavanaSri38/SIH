import { Link } from 'react-router-dom'
export default function Landing() {
  const features = [
    { icon: "🌱", title: "Crop Recommendation", desc: "AI-powered 9-step analysis" },
    { icon: "🔬", title: "Disease Detection",    desc: "MobileNetV2 ML model" },
    { icon: "🧪", title: "Soil Analysis",        desc: "NPK & fertilizer guidance" },
    { icon: "🌦", title: "Weather & Alerts",     desc: "Live Open-Meteo data" },
    { icon: "📈", title: "Market Prices",        desc: "Live mandi price trends" },
    { icon: "🗣", title: "7 Languages",          desc: "Hindi, Telugu, Tamil & more" },
  ]
  return (
    <div style={{ minHeight: "100vh" }}>
      <header style={{ background: "var(--navy)", color: "white", padding: "1rem 2rem", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={{ fontSize: "1.2rem" }}>🌾 Smart Crop Advisory</h1>
        <nav style={{ display: "flex", gap: "1rem" }}>
          <Link to="/login"    style={{ color: "white" }}>Login</Link>
          <Link to="/register" style={{ background: "var(--green)", color: "white", padding: "0.4rem 1rem", borderRadius: "6px" }}>Register</Link>
        </nav>
      </header>
      <section style={{ background: "linear-gradient(135deg, var(--navy) 0%, var(--green) 100%)", color: "white", padding: "4rem 2rem", textAlign: "center" }}>
        <h2 style={{ fontSize: "2.2rem", marginBottom: "1rem" }}>AI-Powered Crop Advisory for Indian Farmers</h2>
        <p style={{ fontSize: "1.1rem", opacity: 0.9, marginBottom: "2rem" }}>Smart recommendations in 7 regional languages</p>
        <Link to="/register" style={{ background: "var(--orange)", color: "white", padding: "0.9rem 2rem", borderRadius: "8px", fontWeight: 600 }}>Get Started Free</Link>
      </section>
      <section style={{ padding: "3rem 2rem", maxWidth: "1100px", margin: "0 auto" }}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: "1.5rem" }}>
          {features.map(f => (
            <div key={f.title} className="card" style={{ textAlign: "center" }}>
              <div style={{ fontSize: "2.5rem", marginBottom: "0.5rem" }}>{f.icon}</div>
              <h4 style={{ color: "var(--green)", marginBottom: "0.3rem" }}>{f.title}</h4>
              <p style={{ color: "var(--muted)", fontSize: "0.9rem" }}>{f.desc}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
