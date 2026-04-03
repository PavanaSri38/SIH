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
