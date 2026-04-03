from fastapi import APIRouter
from backend.services.weather_service import fetch_weather
from backend.services.climate_alert import get_climate_alerts

router = APIRouter(prefix="/api/weather", tags=["weather"])

@router.get("/current")
def current_weather(city: str):
    data   = fetch_weather(city)
    alerts = get_climate_alerts(data)
    return {"weather": data, "alerts": alerts}
