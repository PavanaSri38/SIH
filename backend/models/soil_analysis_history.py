from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey
from datetime import datetime
from backend.database import Base

class SoilAnalysisHistory(Base):
    __tablename__ = "soil_analysis_history"
    id                       = Column(Integer, primary_key=True, index=True)
    user_id                  = Column(Integer, ForeignKey("users.id"), nullable=False)
    nitrogen                 = Column(Float)
    phosphorus               = Column(Float)
    potassium                = Column(Float)
    ph                       = Column(Float)
    organic_matter           = Column(Float)
    soil_health_score        = Column(Float)
    fertilizer_recommendation= Column(String)
    timestamp                = Column(DateTime, default=datetime.utcnow)
