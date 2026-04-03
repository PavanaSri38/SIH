"""Quick test to verify Gemini API key is working."""
import google.generativeai as genai
from backend.config import settings

def test():
    genai.configure(api_key=settings.gemini_api_key)
    model    = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content("Say: Gemini API is working!")
    print(response.text)

if __name__ == "__main__":
    test()
