import google.generativeai as genai
from backend.config import settings

genai.configure(api_key=settings.gemini_api_key)
model = genai.GenerativeModel("gemini-2.5-flash")

_cache: dict = {}

def _call(prompt: str) -> str:
    if prompt in _cache:
        return _cache[prompt]
    response = model.generate_content(prompt)
    result   = response.text
    _cache[prompt] = result
    return result

def explain_soil(nutrients: dict, score: float, recommendations: list) -> str:
    prompt = f"""You are an agricultural advisor. Explain these soil analysis results to an Indian farmer in simple language.
Nutrients: {nutrients}
Health Score: {score}/100
Recommendations: {recommendations}
Provide: Summary, Nutrient Analysis, Fertilizer Guidance, Precautions (4 bullet points each section)."""
    return _call(prompt)

def generate_crop_advisory(crops: list, weather: dict, market: dict, alerts: list) -> str:
    prompt = f"""You are an expert Indian agricultural advisor.
Top Crops: {crops}
Weather: {weather}
Market Data: {market}
Climate Alerts: {alerts}
Give a ranked crop recommendation with reasons. Keep it practical for a small farmer."""
    return _call(prompt)

def explain_disease(disease: str, crop: str, confidence: float) -> str:
    prompt = f"""An Indian farmer's {crop} plant has been diagnosed with: {disease} (confidence: {confidence}%).
Provide: Summary, Analysis, Treatment steps, Prevention tips, Key actions in simple language."""
    return _call(prompt)
