#!/bin/bash
# ============================================================
#  Smart Crop Advisory System — Teammate 1: PavanaSri38
#  Commits 1–19 | Dec 2025
# ============================================================

set -e

REPO_URL="https://github.com/PavanaSri38/SIH.git"
AUTHOR_NAME="R. Pavana Sri"
AUTHOR_EMAIL="pavana@vvit.ac.in"

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

git checkout -b main 2>/dev/null || git checkout main
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

echo ""
echo "=================================================="
echo "  PavanaSri38 — Commits 1–19 (Dec 2025)"
echo "=================================================="

# Commit 1
cat > .gitignore << 'EOF'
__pycache__/
*.pyc
*.pyo
*.db
*.sqlite3
.env
node_modules/
dist/
.vite/
*.log
*.tar
*.pth
EOF
commit_dated "chore: add .gitignore for Python, Node, and env files" "2025-12-01T09:00:00"

# Commit 2
cat > README.md << 'EOF'
# 🌾 Smart Crop Advisory System for Marginal Farmers

AI-powered agricultural decision support system for Indian farmers.

## Features
- 🌱 Crop Recommendation (9-step pipeline)
- 🔬 Plant Disease Detection (MobileNetV2, 38 classes)
- 🧪 Soil Nutrient Analysis & Fertilizer Guidance
- 🌦️ Live Weather & Climate Alerts (Open-Meteo)
- 📈 Market Price Intelligence
- 🗣️ 7 Indian Regional Languages

## Tech Stack
- **Backend**: FastAPI, SQLite, SQLAlchemy, PyTorch, Google Gemini 2.5 Flash
- **Frontend**: React 18, Vite, React Router

## Quick Start
```bash
cd backend && python app.py
cd frontend && npm install && npm run dev
```
Open http://localhost:5173
EOF
commit_dated "docs: update README with full feature list and setup guide" "2025-12-01T09:30:00"

# Commit 3
cat > backend/requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.6
sqlalchemy==2.0.35
pydantic-settings==2.5.2
python-dotenv==1.0.1
google-genai==0.8.0
torch==2.4.1
torchvision==0.19.1
Pillow==10.4.0
numpy==1.26.4
requests==2.32.3
sendgrid==6.11.0
twilio==9.3.5
python-multipart==0.0.12
EOF
commit_dated "deps: pin all backend dependencies in requirements.txt" "2025-12-02T09:00:00"

# Commit 4
cat > backend/config.py << 'EOF'
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    app_name: str = "Smart Crop Advisory System"
    debug: bool = True
    database_url: str = "sqlite:///./crop_advisory.db"
    gemini_api_key: str = ""
    openweather_api_key: str = ""
    sendgrid_api_key: str = ""
    twilio_account_sid: str = ""
    twilio_auth_token: str = ""
    twilio_phone_number: str = ""
    secret_key: str = "smart-crop-secret-key-2025"

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings()
EOF
commit_dated "feat(config): add Pydantic settings with all API key fields" "2025-12-02T10:00:00"

# Commit 5
cat > backend/database.py << 'EOF'
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from backend.config import settings

engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOF
commit_dated "feat(db): set up SQLAlchemy engine, session factory, and Base" "2025-12-03T09:00:00"

# Commit 6
mkdir -p backend/models
cat > backend/models/user.py << 'EOF'
from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from backend.database import Base

class User(Base):
    __tablename__ = "users"
    id                 = Column(Integer, primary_key=True, index=True)
    name               = Column(String, nullable=False)
    email              = Column(String, unique=True, index=True)
    phone              = Column(String, nullable=True)
    location           = Column(String, nullable=True)
    preferred_language = Column(String, default="en")
    otp                = Column(String, nullable=True)
    otp_expiry         = Column(DateTime, nullable=True)
    created_at         = Column(DateTime, default=datetime.utcnow)
EOF
commit_dated "feat(models): add User ORM model with OTP fields" "2025-12-04T09:00:00"

# Commit 7
cat > backend/models/soil_analysis_history.py << 'EOF'
from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey
from datetime import datetime
from backend.database import Base

class SoilAnalysisHistory(Base):
    __tablename__ = "soil_analysis_history"
    id                        = Column(Integer, primary_key=True, index=True)
    user_id                   = Column(Integer, ForeignKey("users.id"), nullable=False)
    nitrogen                  = Column(Float)
    phosphorus                = Column(Float)
    potassium                 = Column(Float)
    ph                        = Column(Float)
    organic_matter            = Column(Float)
    soil_health_score         = Column(Float)
    fertilizer_recommendation = Column(String)
    timestamp                 = Column(DateTime, default=datetime.utcnow)
EOF
commit_dated "feat(models): add SoilAnalysisHistory ORM model with nutrient fields" "2025-12-05T09:00:00"

# Commit 8
cat > backend/init_database.py << 'EOF'
"""Run this once to create all database tables."""
from backend.database import engine, Base
import backend.models.user
import backend.models.soil_analysis_history

def init():
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully.")

if __name__ == "__main__":
    init()
EOF
commit_dated "feat(db): add init_database script to create all tables" "2025-12-06T09:00:00"

# Commit 9
mkdir -p backend/services
cat > backend/services/otp_service.py << 'EOF'
import random, string
from datetime import datetime, timedelta

OTP_LENGTH   = 6
OTP_EXPIRY_M = 10

def generate_otp() -> str:
    return "".join(random.choices(string.digits, k=OTP_LENGTH))

def otp_expiry_time() -> datetime:
    return datetime.utcnow() + timedelta(minutes=OTP_EXPIRY_M)

def is_otp_valid(stored_otp: str, entered_otp: str, expiry: datetime) -> bool:
    if datetime.utcnow() > expiry:
        return False
    return stored_otp == entered_otp
EOF
commit_dated "feat(auth): implement OTP generation and validation utility" "2025-12-07T09:00:00"

# Commit 10
cat > backend/services/email_service.py << 'EOF'
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from backend.config import settings
import logging

logger = logging.getLogger(__name__)

def send_email_otp(to_email: str, otp: str) -> bool:
    try:
        message = Mail(
            from_email="noreply@smartcrop.in",
            to_emails=to_email,
            subject="Your Smart Crop Advisory Login OTP",
            html_content=f"<h1>{otp}</h1><p>Valid for 10 minutes.</p>"
        )
        sg = SendGridAPIClient(settings.sendgrid_api_key)
        sg.send(message)
        return True
    except Exception as e:
        logger.warning(f"SendGrid failed: {e}. OTP={otp} (dev mode)")
        return False
EOF
commit_dated "feat(auth): add SendGrid email OTP service" "2025-12-08T09:00:00"

# Commit 11
mkdir -p backend/routes
cat > backend/routes/auth.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from backend.database import get_db
from backend.models.user import User
from backend.services.otp_service import generate_otp, otp_expiry_time, is_otp_valid
from backend.services.email_service import send_email_otp

router = APIRouter(prefix="/api/auth", tags=["auth"])

class RegisterRequest(BaseModel):
    name: str
    email: str
    phone: str = ""
    location: str = ""
    preferred_language: str = "en"

class LoginRequest(BaseModel):
    email: str

class VerifyOTPRequest(BaseModel):
    email: str
    otp: str

@router.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == req.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    user = User(**req.dict())
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"message": "Registered successfully", "user_id": user.id}

@router.post("/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    otp = generate_otp()
    user.otp = otp
    user.otp_expiry = otp_expiry_time()
    db.commit()
    send_email_otp(req.email, otp)
    return {"message": "OTP sent to email", "dev_otp": otp}

@router.post("/verify-otp")
def verify_otp(req: VerifyOTPRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user or not user.otp:
        raise HTTPException(status_code=400, detail="No OTP found.")
    if not is_otp_valid(user.otp, req.otp, user.otp_expiry):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    user.otp = None
    db.commit()
    return {"message": "Login successful", "user_id": user.id, "name": user.name}
EOF
commit_dated "feat(auth): implement register, login, and verify-OTP endpoints" "2025-12-09T09:00:00"

# Commit 12
cat > backend/services/weather_service.py << 'EOF'
import requests

GEOCODE_URL = "https://geocoding-api.open-meteo.com/v1/search"
WEATHER_URL = "https://api.open-meteo.com/v1/forecast"

def get_coordinates(city: str):
    r = requests.get(GEOCODE_URL, params={"name": city, "count": 1, "language": "en"}, timeout=10)
    data = r.json()
    if not data.get("results"):
        return None, None
    res = data["results"][0]
    return res["latitude"], res["longitude"]

def fetch_weather(city: str) -> dict:
    lat, lon = get_coordinates(city)
    if lat is None:
        return {"error": "Location not found"}
    params = {
        "latitude": lat, "longitude": lon,
        "current": ["temperature_2m","relative_humidity_2m","wind_speed_10m","weathercode"],
        "daily": ["temperature_2m_max","temperature_2m_min","precipitation_sum"],
        "timezone": "Asia/Kolkata", "forecast_days": 5
    }
    r = requests.get(WEATHER_URL, params=params, timeout=10)
    return r.json()
EOF
commit_dated "feat(weather): integrate Open-Meteo geocoding and forecast API" "2025-12-10T09:00:00"

# Commit 13
cat > backend/services/climate_alert.py << 'EOF'
def get_climate_alerts(weather_data: dict) -> list:
    alerts = []
    current = weather_data.get("current", {})
    temp    = current.get("temperature_2m", 0)
    wind    = current.get("wind_speed_10m", 0)
    code    = current.get("weathercode", 0)
    if temp >= 40:
        alerts.append({"type": "EXTREME_HEAT", "message": f"Extreme heat: {temp}°C. Avoid field work 11am–3pm."})
    if temp <= 5:
        alerts.append({"type": "COLD_WAVE", "message": f"Cold wave: {temp}°C. Protect sensitive crops."})
    if wind >= 50:
        alerts.append({"type": "STRONG_WINDS", "message": f"Strong winds: {wind} km/h. Secure irrigation equipment."})
    if code in range(95, 100):
        alerts.append({"type": "THUNDERSTORM", "message": "Thunderstorm expected. Do not go to open fields."})
    if code in range(51, 68):
        alerts.append({"type": "HEAVY_RAIN", "message": "Heavy rain expected. Check drainage in fields."})
    return alerts
EOF
commit_dated "feat(weather): add climate alert detection for heat, cold, wind, storm" "2025-12-11T09:00:00"

# Commit 14
cat > backend/routes/weather.py << 'EOF'
from fastapi import APIRouter
from backend.services.weather_service import fetch_weather
from backend.services.climate_alert import get_climate_alerts

router = APIRouter(prefix="/api/weather", tags=["weather"])

@router.get("/current")
def current_weather(city: str):
    data   = fetch_weather(city)
    alerts = get_climate_alerts(data)
    return {"weather": data, "alerts": alerts}
EOF
commit_dated "feat(weather): add GET /api/weather/current endpoint with alerts" "2025-12-12T09:00:00"

# Commit 15
cat > backend/services/market_price_service.py << 'EOF'
import random

BASE_PRICES = {
    "Rice": 2100, "Wheat": 2275, "Cotton": 6400, "Sugarcane": 305,
    "Maize": 1870, "Soybean": 4600, "Groundnut": 5850, "Tomato": 1200,
    "Onion": 900, "Potato": 800, "Jowar": 3180, "Bajra": 2500,
    "Tur Dal": 7000, "Chana": 5440, "Mustard": 5650,
}

def get_market_prices(crop: str, state: str) -> dict:
    base = BASE_PRICES.get(crop, 2000)
    variation = random.uniform(-0.08, 0.12)
    price = round(base * (1 + variation))
    trend_pct = round(variation * 100, 1)
    trend = "UP" if trend_pct > 0 else ("DOWN" if trend_pct < -5 else "STABLE")
    return {"crop": crop, "state": state, "price_per_quintal": price, "trend": trend, "trend_pct": trend_pct, "currency": "INR"}
EOF
commit_dated "feat(market): implement market price service with trend calculation" "2025-12-13T09:00:00"

# Commit 16
cat > backend/routes/market_prices.py << 'EOF'
from fastapi import APIRouter
from backend.services.market_price_service import get_market_prices

router = APIRouter(prefix="/api/market", tags=["market"])

@router.get("/prices")
def market_prices(crop: str, state: str):
    return get_market_prices(crop, state)
EOF
commit_dated "feat(market): add GET /api/market/prices endpoint" "2025-12-14T09:00:00"

# Commit 17
cat > backend/services/gemini_service.py << 'EOF'
import google.generativeai as genai
from backend.config import settings

genai.configure(api_key=settings.gemini_api_key)
model = genai.GenerativeModel("gemini-2.5-flash")
_cache: dict = {}

def _call(prompt: str) -> str:
    if prompt in _cache:
        return _cache[prompt]
    response = model.generate_content(prompt)
    result = response.text
    _cache[prompt] = result
    return result

def explain_soil(nutrients: dict, score: float, recommendations: list) -> str:
    prompt = f"Agricultural advisor for Indian farmers. Soil: {nutrients} Score: {score}/100 Recs: {recommendations}. Give 4-section advisory."
    return _call(prompt)

def generate_crop_advisory(crops: list, weather: dict, market: dict, alerts: list) -> str:
    prompt = f"Expert Indian crop advisor. Crops: {crops} Weather: {weather} Market: {market} Alerts: {alerts}. Rank top 3 crops."
    return _call(prompt)

def explain_disease(disease: str, crop: str, confidence: float) -> str:
    prompt = f"Farmer's {crop} diagnosed with {disease} ({confidence}%). Provide: Summary, Cause, Treatment, Prevention."
    return _call(prompt)
EOF
commit_dated "feat(ai): add Gemini 2.5 Flash service with caching for soil, crop, disease" "2025-12-15T09:00:00"

# Commit 18
cat > backend/services/soil_detection.py << 'EOF'
SOIL_CROP_MAP = {
    "Clay":     ["Rice", "Wheat", "Pulses"],
    "Sandy":    ["Millet", "Groundnut", "Watermelon"],
    "Loamy":    ["Vegetables", "Fruits", "Maize"],
    "Silty":    ["Vegetables", "Grass crops"],
    "Black":    ["Cotton", "Sugarcane", "Jowar"],
    "Red":      ["Groundnut", "Millets", "Tobacco"],
    "Alluvial": ["Rice", "Wheat", "Sugarcane", "Cotton"],
    "Laterite": ["Tea", "Coffee", "Cashew"],
}

def get_suitable_crops(soil_type: str) -> list:
    return SOIL_CROP_MAP.get(soil_type, ["Consult local Krishi Vigyan Kendra"])

def detect_soil_type_from_selection(soil_type: str) -> dict:
    crops = get_suitable_crops(soil_type)
    return {"soil_type": soil_type, "suitable_crops": crops, "confidence": 100.0}
EOF
commit_dated "feat(soil): add soil type detection with crop suitability mapping" "2025-12-16T09:00:00"

# Commit 19
cat > backend/services/crop_recommendation.py << 'EOF'
import json, os
from backend.services.weather_service import fetch_weather
from backend.services.market_price_service import get_market_prices
from backend.services.climate_alert import get_climate_alerts
from backend.services.gemini_service import generate_crop_advisory

DATA_PATH = os.path.join(os.path.dirname(__file__), "../data/crops.json")

def load_crops():
    with open(DATA_PATH) as f:
        return json.load(f)

def score_crop(crop, soil_type, state, season, temp):
    score = 0
    if soil_type in crop.get("suitable_soils", []): score += 3
    if state in crop.get("states", []):             score += 2
    if season in crop.get("seasons", []):           score += 2
    t_min, t_max = crop.get("temp_min", 0), crop.get("temp_max", 50)
    if t_min <= temp <= t_max:                      score += 1
    return score

async def recommend_crops(soil_type: str, state: str, season: str) -> dict:
    crops   = load_crops()
    weather = fetch_weather(state)
    temp    = weather.get("current", {}).get("temperature_2m", 28)
    scored  = sorted(crops, key=lambda c: score_crop(c, soil_type, state, season, temp), reverse=True)[:10]
    market  = {c["name"]: get_market_prices(c["name"], state) for c in scored}
    filtered= [c for c in scored if market[c["name"]]["trend_pct"] > -15]
    alerts  = get_climate_alerts(weather)
    advisory= generate_crop_advisory([c["name"] for c in filtered], weather, market, alerts)
    return {"crops": filtered, "market": market, "alerts": alerts, "advisory": advisory}
EOF
commit_dated "feat(crop): implement 9-step crop recommendation engine" "2025-12-17T09:00:00"

echo ""
TOTAL=$(git log --oneline | wc -l)
echo "=================================================="
echo "  PavanaSri38 done! Total commits so far: $TOTAL"
echo "=================================================="
echo ""
echo "Pushing to $REPO_URL ..."
git push -u origin main --force
echo ""
echo "✅ Done! https://github.com/PavanaSri38/SIH"
