from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from backend.database import Base

class User(Base):
    __tablename__ = "users"
    id                 = Column(Integer, primary_key=True, index=True)
    name               = Column(String, nullable=False)
    email              = Column(String, unique=True, index=True)
    phone              = Column(String, nullable=True)
    location           = Column(String, nullable=True)   # state
    preferred_language = Column(String, default="en")
    otp                = Column(String, nullable=True)
    otp_expiry         = Column(DateTime, nullable=True)
    created_at         = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<User id={self.id} email={self.email}>"
