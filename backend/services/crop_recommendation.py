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
    if soil_type in crop.get("suitable_soils", []):  score += 3
    if state     in crop.get("states", []):           score += 2
    if season    in crop.get("seasons", []):          score += 2
    t_min, t_max = crop.get("temp_min", 0), crop.get("temp_max", 50)
    if t_min <= temp <= t_max:                        score += 1
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
