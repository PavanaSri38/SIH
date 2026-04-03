from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    app_name: str = "Smart Crop Advisory System"
    debug: bool = True
    database_url: str = "sqlite:///./crop_advisory.db"
    gemini_api_key: str = ""
    openweather_api_key: str = ""
    sendgrid_api_key: str = ""
    twilio_account_sid: str = ""
    twilio_auth_token: str = ""
    twilio_phone_number: str = ""
    secret_key: str = "smart-crop-secret-key-2025"

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings()
