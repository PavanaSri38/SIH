from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from backend.database import get_db
from backend.models.user import User
from backend.services.otp_service import generate_otp, otp_expiry_time, is_otp_valid
from backend.services.email_service import send_email_otp

router = APIRouter(prefix="/api/auth", tags=["auth"])

class RegisterRequest(BaseModel):
    name: str
    email: str
    phone: str = ""
    location: str = ""
    preferred_language: str = "en"

class LoginRequest(BaseModel):
    email: str

class VerifyOTPRequest(BaseModel):
    email: str
    otp: str

@router.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == req.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    user = User(**req.dict())
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"message": "Registered successfully", "user_id": user.id}

@router.post("/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found. Please register first.")
    otp = generate_otp()
    user.otp = otp
    user.otp_expiry = otp_expiry_time()
    db.commit()
    send_email_otp(req.email, otp)
    return {"message": "OTP sent to email", "dev_otp": otp}

@router.post("/verify-otp")
def verify_otp(req: VerifyOTPRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user or not user.otp:
        raise HTTPException(status_code=400, detail="No OTP found. Request a new one.")
    if not is_otp_valid(user.otp, req.otp, user.otp_expiry):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    user.otp = None
    db.commit()
    return {"message": "Login successful", "user_id": user.id, "name": user.name, "preferred_language": user.preferred_language}
