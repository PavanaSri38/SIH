import random, string
from datetime import datetime, timedelta

OTP_LENGTH   = 6
OTP_EXPIRY_M = 10   # minutes

def generate_otp() -> str:
    return "".join(random.choices(string.digits, k=OTP_LENGTH))

def otp_expiry_time() -> datetime:
    return datetime.utcnow() + timedelta(minutes=OTP_EXPIRY_M)

def is_otp_valid(stored_otp: str, entered_otp: str, expiry: datetime) -> bool:
    if datetime.utcnow() > expiry:
        return False
    return stored_otp == entered_otp
