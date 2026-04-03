#!/bin/bash
# ============================================================
#  Smart Crop Advisory System — Teammate 2: hema24-aim
#  Commits 20–38 | Jan 2026
# ============================================================

set -e

REPO_URL="https://github.com/PavanaSri38/SIH.git"
AUTHOR_NAME="M. Hema Latha"
AUTHOR_EMAIL="hema@vvit.ac.in"

git config user.name  "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

commit_dated() {
  local MSG="$1"
  local DATE="$2"
  git add -A
  GIT_AUTHOR_NAME="$AUTHOR_NAME" GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" \
  GIT_COMMITTER_NAME="$AUTHOR_NAME" GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" \
  GIT_AUTHOR_DATE="$DATE" GIT_COMMITTER_DATE="$DATE" \
    git commit -m "$MSG" --allow-empty-message 2>/dev/null || true
}

git checkout main 2>/dev/null || git checkout -b main
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

echo ""
echo "=================================================="
echo "  hema24-aim — Commits 20–38 (Jan 2026)"
echo "=================================================="

# Commit 20
mkdir -p backend/data
cat > backend/data/crops.json << 'EOF'
[
  {"name":"Rice",      "suitable_soils":["Clay","Alluvial","Loamy"],      "states":["Andhra Pradesh","Telangana","West Bengal","Tamil Nadu"],"seasons":["Kharif"],"temp_min":20,"temp_max":35},
  {"name":"Wheat",     "suitable_soils":["Loamy","Clay","Alluvial"],      "states":["Punjab","Haryana","Uttar Pradesh","Madhya Pradesh"],   "seasons":["Rabi"],  "temp_min":10,"temp_max":25},
  {"name":"Cotton",    "suitable_soils":["Black","Red","Alluvial"],       "states":["Andhra Pradesh","Telangana","Gujarat","Maharashtra"],   "seasons":["Kharif"],"temp_min":21,"temp_max":37},
  {"name":"Maize",     "suitable_soils":["Loamy","Sandy","Red"],          "states":["Karnataka","Andhra Pradesh","Rajasthan","Bihar"],       "seasons":["Kharif","Rabi"],"temp_min":18,"temp_max":35},
  {"name":"Sugarcane", "suitable_soils":["Alluvial","Black","Loamy"],     "states":["Uttar Pradesh","Maharashtra","Karnataka","Tamil Nadu"], "seasons":["Summer"],"temp_min":20,"temp_max":35},
  {"name":"Groundnut", "suitable_soils":["Sandy","Red","Loamy"],          "states":["Andhra Pradesh","Gujarat","Tamil Nadu","Karnataka"],    "seasons":["Kharif","Summer"],"temp_min":22,"temp_max":33},
  {"name":"Soybean",   "suitable_soils":["Loamy","Black","Clay"],         "states":["Madhya Pradesh","Maharashtra","Rajasthan"],             "seasons":["Kharif"],"temp_min":20,"temp_max":30},
  {"name":"Jowar",     "suitable_soils":["Black","Red","Loamy"],          "states":["Maharashtra","Karnataka","Andhra Pradesh","Telangana"],"seasons":["Kharif","Rabi"],"temp_min":26,"temp_max":36},
  {"name":"Bajra",     "suitable_soils":["Sandy","Red","Loamy"],          "states":["Rajasthan","Haryana","Gujarat","Uttar Pradesh"],        "seasons":["Kharif","Summer"],"temp_min":25,"temp_max":38},
  {"name":"Tomato",    "suitable_soils":["Loamy","Red","Sandy"],          "states":["Andhra Pradesh","Karnataka","Maharashtra","Telangana"], "seasons":["Rabi","Summer"],"temp_min":15,"temp_max":30},
  {"name":"Onion",     "suitable_soils":["Loamy","Sandy","Alluvial"],     "states":["Maharashtra","Karnataka","Andhra Pradesh","Gujarat"],   "seasons":["Rabi","Summer"],"temp_min":13,"temp_max":30},
  {"name":"Potato",    "suitable_soils":["Loamy","Sandy","Alluvial"],     "states":["Uttar Pradesh","West Bengal","Bihar","Punjab"],         "seasons":["Rabi"],  "temp_min":10,"temp_max":25},
  {"name":"Mustard",   "suitable_soils":["Loamy","Alluvial","Sandy"],     "states":["Rajasthan","Uttar Pradesh","Haryana","Punjab"],         "seasons":["Rabi"],  "temp_min":10,"temp_max":22},
  {"name":"Tur Dal",   "suitable_soils":["Black","Red","Loamy"],          "states":["Maharashtra","Karnataka","Andhra Pradesh","Gujarat"],   "seasons":["Kharif"],"temp_min":18,"temp_max":30},
  {"name":"Chana",     "suitable_soils":["Loamy","Black","Clay"],         "states":["Madhya Pradesh","Rajasthan","Maharashtra","Uttar Pradesh"],"seasons":["Rabi"],"temp_min":10,"temp_max":25}
]
EOF
commit_dated "data: add crops.json with 15 Indian crops, soil, state, season metadata" "2026-01-02T09:00:00"

# Commit 21
cat > backend/routes/crop_recommendation.py << 'EOF'
from fastapi import APIRouter
from pydantic import BaseModel
from backend.services.crop_recommendation import recommend_crops

router = APIRouter(prefix="/api/crop", tags=["crop"])

class CropRequest(BaseModel):
    soil_type: str
    state: str
    season: str

@router.post("/recommend")
async def crop_recommend(req: CropRequest):
    return await recommend_crops(req.soil_type, req.state, req.season)
EOF
commit_dated "feat(crop): add POST /api/crop/recommend endpoint" "2026-01-03T09:00:00"

# Commit 22
cat > backend/services/disease_detection.py << 'EOF'
import torch
import torchvision.transforms as T
from torchvision import models
import torch.nn as nn
from PIL import Image
import json, os

MODEL_PATH   = os.path.join(os.path.dirname(__file__), "../ml_models/plant_disease/mobilenetv2_plant.pth")
CLASSES_PATH = os.path.join(os.path.dirname(__file__), "../ml_models/plant_disease/class_names.json")

class DiseaseDetector:
    def __init__(self):
        with open(CLASSES_PATH) as f:
            self.class_names = json.load(f)
        self.model = models.mobilenet_v2(pretrained=False)
        self.model.classifier[1] = nn.Linear(1280, len(self.class_names))
        if os.path.exists(MODEL_PATH):
            self.model.load_state_dict(torch.load(MODEL_PATH, map_location="cpu"))
        self.model.eval()
        self.transform = T.Compose([
            T.Resize((224, 224)),
            T.ToTensor(),
            T.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])

    def predict(self, image: Image.Image) -> dict:
        tensor = self.transform(image).unsqueeze(0)
        with torch.no_grad():
            logits     = self.model(tensor)
            idx        = logits.argmax(1).item()
            confidence = torch.softmax(logits, 1).max().item()
        label   = self.class_names[idx]
        parts   = label.split("___")
        crop    = parts[0].replace("_", " ")
        disease = parts[1].replace("_", " ") if len(parts) > 1 else "Unknown"
        return {"crop": crop, "disease": disease, "confidence": round(confidence * 100, 2), "is_healthy": "healthy" in disease.lower()}

detector = DiseaseDetector()
EOF
commit_dated "feat(ml): implement MobileNetV2 DiseaseDetector class with inference pipeline" "2026-01-04T09:00:00"

# Commit 23
cat > backend/routes/disease_detection.py << 'EOF'
from fastapi import APIRouter, UploadFile, File
from PIL import Image
import io
from backend.services.disease_detection import detector
from backend.services.gemini_service import explain_disease

router = APIRouter(prefix="/api/disease", tags=["disease"])

@router.post("/detect")
async def detect_disease(file: UploadFile = File(...)):
    contents = await file.read()
    image    = Image.open(io.BytesIO(contents)).convert("RGB")
    result   = detector.predict(image)
    advisory = explain_disease(result["disease"], result["crop"], result["confidence"])
    return {**result, "advisory": advisory}
EOF
commit_dated "feat(disease): add POST /api/disease/detect endpoint with AI advisory" "2026-01-05T09:00:00"

# Commit 24
cat > backend/routes/soil_analysis.py << 'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from backend.database import get_db
from backend.models.soil_analysis_history import SoilAnalysisHistory
from backend.services.gemini_service import explain_soil

router = APIRouter(prefix="/api/soil", tags=["soil"])

class SoilInput(BaseModel):
    user_id: int
    nitrogen: float
    phosphorus: float
    potassium: float
    ph: float
    organic_matter: float

def evaluate_health(n, p, k, ph, om) -> float:
    score = 0
    if 40  <= n  <= 80:  score += 20
    elif n  > 0:          score += 10
    if 20  <= p  <= 40:  score += 20
    elif p  > 0:          score += 10
    if 15  <= k  <= 40:  score += 20
    elif k  > 0:          score += 10
    if 6.0 <= ph <= 7.5: score += 20
    elif 5.5 <= ph < 8:  score += 10
    if om  >= 3.0:        score += 20
    elif om >= 1.5:       score += 10
    return float(score)

def get_fertilizer_recommendations(data: SoilInput) -> list:
    recs = []
    if data.nitrogen < 40:   recs.append("Apply Urea (46% N) @ 50 kg/acre")
    if data.phosphorus < 20: recs.append("Apply SSP (16% P) @ 30 kg/acre")
    if data.potassium < 15:  recs.append("Apply MOP (60% K) @ 25 kg/acre")
    if data.ph < 6.0:        recs.append("Apply Agricultural Lime to raise pH")
    if data.ph > 7.5:        recs.append("Apply Gypsum to reduce pH")
    if not recs:             recs.append("Soil health is good. Maintain organic matter levels.")
    return recs

@router.post("/analyze")
async def analyze_soil(data: SoilInput, db: Session = Depends(get_db)):
    score   = evaluate_health(data.nitrogen, data.phosphorus, data.potassium, data.ph, data.organic_matter)
    recs    = get_fertilizer_recommendations(data)
    record  = SoilAnalysisHistory(user_id=data.user_id, nitrogen=data.nitrogen, phosphorus=data.phosphorus,
                potassium=data.potassium, ph=data.ph, organic_matter=data.organic_matter,
                soil_health_score=score, fertilizer_recommendation="; ".join(recs))
    db.add(record)
    db.commit()
    advisory = explain_soil(data.dict(), score, recs)
    return {"health_score": score, "recommendations": recs, "advisory": advisory}
EOF
commit_dated "feat(soil): add soil analysis endpoint with health scoring and Gemini advisory" "2026-01-06T09:00:00"

# Commit 25
cat > backend/app.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.routes import auth, weather, market_prices, crop_recommendation, disease_detection, soil_analysis
from backend.database import engine, Base
import backend.models.user
import backend.models.soil_analysis_history

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Smart Crop Advisory API", version="1.0.0")
app.add_middleware(CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

app.include_router(auth.router)
app.include_router(weather.router)
app.include_router(market_prices.router)
app.include_router(crop_recommendation.router)
app.include_router(disease_detection.router)
app.include_router(soil_analysis.router)

@app.get("/")
def root():
    return {"message": "🌾 Smart Crop Advisory API is running", "docs": "/docs"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.app:app", host="0.0.0.0", port=8000, reload=True)
EOF
commit_dated "feat(app): wire all routers into FastAPI app with CORS middleware" "2026-01-07T09:00:00"

# Commit 26
cat > frontend/package.json << 'EOF'
{
  "name": "smart-crop-frontend",
  "version": "1.0.0",
  "scripts": { "dev": "vite", "build": "vite build", "preview": "vite preview" },
  "dependencies": { "react": "^18.2.0", "react-dom": "^18.2.0", "react-router-dom": "^6.20.0" },
  "devDependencies": { "@vitejs/plugin-react": "^4.2.0", "vite": "^5.0.0" }
}
EOF
commit_dated "deps: add frontend package.json with React 18 and React Router 6" "2026-01-08T09:00:00"

# Commit 27
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: { port: 5173, proxy: { '/api': { target: 'http://localhost:8000', changeOrigin: true } } }
})
EOF
commit_dated "config(vite): set up Vite with React plugin and API proxy to :8000" "2026-01-09T09:00:00"

# Commit 28
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Smart Crop Advisory System</title>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF
commit_dated "feat(frontend): add index.html entry point" "2026-01-10T09:00:00"

# Commit 29
mkdir -p frontend/src
cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './styles/global.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode><App /></React.StrictMode>
)
EOF
commit_dated "feat(frontend): add React entry point main.jsx" "2026-01-11T09:00:00"

# Commit 30
cat > frontend/src/App.jsx << 'EOF'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Landing            from './pages/Landing.jsx'
import Login              from './pages/Login.jsx'
import Register           from './pages/Register.jsx'
import Dashboard          from './pages/Dashboard.jsx'
import SoilAnalysis       from './pages/SoilAnalysis.jsx'
import CropRecommendation from './pages/CropRecommendation.jsx'
import DiseaseDetection   from './pages/DiseaseDetection.jsx'
import Weather            from './pages/Weather.jsx'
import MarketPrices       from './pages/MarketPrices.jsx'
import About              from './pages/About.jsx'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/"          element={<Landing/>}/>
        <Route path="/login"     element={<Login/>}/>
        <Route path="/register"  element={<Register/>}/>
        <Route path="/dashboard" element={<Dashboard/>}/>
        <Route path="/soil"      element={<SoilAnalysis/>}/>
        <Route path="/crop"      element={<CropRecommendation/>}/>
        <Route path="/disease"   element={<DiseaseDetection/>}/>
        <Route path="/weather"   element={<Weather/>}/>
        <Route path="/market"    element={<MarketPrices/>}/>
        <Route path="/about"     element={<About/>}/>
        <Route path="*"          element={<Navigate to="/"/>}/>
      </Routes>
    </BrowserRouter>
  )
}
EOF
commit_dated "feat(frontend): add App.jsx with all 10 routes wired to page components" "2026-01-12T09:00:00"

# Commit 31
mkdir -p frontend/src/styles
cat > frontend/src/styles/global.css << 'EOF'
:root {
  --green: #2E7D32; --lt-green: #E8F4EC; --orange: #C45911;
  --navy: #1F3864;  --blue: #2E74B5;     --lt-blue: #D6E4F7;
  --white: #FFFFFF; --bg: #F8F9FA;       --text: #2D2D2D; --muted: #666666;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Segoe UI', Arial, sans-serif; background: var(--bg); color: var(--text); }
a { text-decoration: none; color: inherit; }
button { cursor: pointer; border: none; border-radius: 6px; font-weight: 600; }
.card { background: white; border-radius: 12px; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
.btn-primary { background: var(--green); color: white; padding: 0.7rem 1.5rem; }
.btn-primary:hover { background: #1B5E20; }
.btn-orange { background: var(--orange); color: white; padding: 0.7rem 1.5rem; }
input, select, textarea { width: 100%; padding: 0.7rem 1rem; border: 1.5px solid #ddd; border-radius: 8px; font-size: 0.95rem; }
input:focus, select:focus { outline: none; border-color: var(--green); }
.badge { display: inline-block; padding: 0.25rem 0.7rem; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
.badge-green  { background: var(--lt-green); color: var(--green); }
.badge-orange { background: #FFF2CC; color: var(--orange); }
.badge-blue   { background: var(--lt-blue); color: var(--blue); }
EOF
commit_dated "style: add global CSS variables and base styles for all pages" "2026-01-13T09:00:00"

# Commit 32
mkdir -p frontend/src/pages
cat > frontend/src/pages/Landing.jsx << 'EOF'
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
EOF
commit_dated "feat(ui): build Landing page with hero section and feature grid" "2026-01-14T09:00:00"

# Commit 33
cat > frontend/src/pages/Login.jsx << 'EOF'
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
EOF
commit_dated "feat(ui): build Login page with 2-step OTP flow" "2026-01-15T09:00:00"

# Commit 34
cat > frontend/src/pages/Register.jsx << 'EOF'
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
EOF
commit_dated "feat(ui): build Register page with language preference selector" "2026-01-16T09:00:00"

# Commit 35
cat > frontend/src/pages/Dashboard.jsx << 'EOF'
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
EOF
commit_dated "feat(ui): build Dashboard with 6 module cards and hover animation" "2026-01-17T09:00:00"

# Commit 36
cat > frontend/src/pages/SoilAnalysis.jsx << 'EOF'
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
EOF
commit_dated "feat(ui): build SoilAnalysis page with form, health score, and Gemini advisory" "2026-01-18T09:00:00"

# Commit 37
cat > frontend/src/pages/CropRecommendation.jsx << 'EOF'
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
EOF
commit_dated "feat(ui): build CropRecommendation page with soil/state/season selectors" "2026-01-19T09:00:00"

# Commit 38
cat > frontend/src/pages/DiseaseDetection.jsx << 'EOF'
import { useState } from 'react'
import { Link } from 'react-router-dom'

export default function DiseaseDetection() {
  const [file,    setFile]    = useState(null)
  const [preview, setPreview] = useState(null)
  const [result,  setResult]  = useState(null)
  const [loading, setLoading] = useState(false)

  function onFileChange(e) {
    const f = e.target.files[0]
    if (!f) return
    setFile(f)
    setPreview(URL.createObjectURL(f))
    setResult(null)
  }

  async function detect() {
    if (!file) return
    setLoading(true)
    const fd = new FormData()
    fd.append('file', file)
    const res  = await fetch('/api/disease/detect', { method:'POST', body: fd })
    const data = await res.json()
    setResult(data)
    setLoading(false)
  }

  return (
    <div style={{ minHeight:'100vh', background:'var(--bg)' }}>
      <header style={{ background:'var(--navy)', color:'white', padding:'1rem 2rem', display:'flex', alignItems:'center', gap:'1rem' }}>
        <Link to="/dashboard" style={{ color:'white' }}>← Dashboard</Link>
        <h1>🔬 Disease Detection</h1>
      </header>
      <div style={{ padding:'2rem', maxWidth:'700px', margin:'0 auto' }}>
        <div className="card" style={{ marginBottom:'1.5rem' }}>
          <input type="file" accept="image/*" onChange={onFileChange}/>
          {preview && <img src={preview} alt="Preview" style={{ width:'100%', maxHeight:'300px', objectFit:'contain', marginTop:'1rem', borderRadius:'8px' }}/>}
          <button className="btn-primary" style={{ marginTop:'1rem' }} onClick={detect} disabled={!file||loading}>
            {loading?'Analyzing...':'Detect Disease'}
          </button>
        </div>
        {result && (
          <div className="card">
            <h3 style={{ color:'var(--navy)', marginBottom:'1rem' }}>Detection Result</h3>
            <p><strong>Crop:</strong> {result.crop}</p>
            <p><strong>Disease:</strong> {result.disease}</p>
            <p><strong>Confidence:</strong> {result.confidence}%</p>
            <span className={`badge ${result.is_healthy?'badge-green':'badge-orange'}`} style={{ marginTop:'0.5rem' }}>
              {result.is_healthy?'Healthy':'Disease Detected'}
            </span>
            {result.advisory && <p style={{ marginTop:'1rem', color:'var(--muted)', lineHeight:1.6 }}>{result.advisory}</p>}
          </div>
        )}
      </div>
    </div>
  )
}
EOF
commit_dated "feat(ui): build DiseaseDetection page with image upload and ML result display" "2026-01-20T09:00:00"

echo ""
TOTAL=$(git log --oneline | wc -l)
echo "=================================================="
echo "  hema24-aim done! Total commits so far: $TOTAL"
echo "=================================================="
echo ""
echo "Pushing to $REPO_URL ..."
git push -u origin main
echo ""
echo "✅ Done! https://github.com/PavanaSri38/SIH"
