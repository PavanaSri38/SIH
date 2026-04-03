"""Run this once to create all database tables."""
from backend.database import engine, Base
import backend.models.user  # noqa – registers models
import backend.models.soil_analysis_history  # noqa

def init():
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully.")

if __name__ == "__main__":
    init()
