import random

# Simulated base prices per crop (₹/quintal)
BASE_PRICES = {
    "Rice": 2100, "Wheat": 2275, "Cotton": 6400, "Sugarcane": 305,
    "Maize": 1870, "Soybean": 4600, "Groundnut": 5850, "Tomato": 1200,
    "Onion": 900,  "Potato": 800,  "Jowar": 3180, "Bajra": 2500,
    "Tur Dal": 7000, "Chana": 5440, "Mustard": 5650,
}

def get_market_prices(crop: str, state: str) -> dict:
    base  = BASE_PRICES.get(crop, 2000)
    variation = random.uniform(-0.08, 0.12)
    price = round(base * (1 + variation))
    trend_pct = round(variation * 100, 1)
    trend = "UP" if trend_pct > 0 else ("DOWN" if trend_pct < -5 else "STABLE")
    return {
        "crop": crop, "state": state,
        "price_per_quintal": price,
        "trend": trend, "trend_pct": trend_pct,
        "currency": "INR"
    }
