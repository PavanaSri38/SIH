"""Manage user context for personalised advisory (recent soil analysis, preferences)."""
from sqlalchemy.orm import Session
from backend.models.soil_analysis_history import SoilAnalysisHistory

def get_latest_soil_context(user_id: int, db: Session) -> dict | None:
    record = (
        db.query(SoilAnalysisHistory)
          .filter(SoilAnalysisHistory.user_id == user_id)
          .order_by(SoilAnalysisHistory.timestamp.desc())
          .first()
    )
    if not record:
        return None
    return {
        "nitrogen":      record.nitrogen,
        "phosphorus":    record.phosphorus,
        "potassium":     record.potassium,
        "ph":            record.ph,
        "organic_matter":record.organic_matter,
        "health_score":  record.soil_health_score,
    }
