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
