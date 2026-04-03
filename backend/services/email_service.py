from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from backend.config import settings
import logging

logger = logging.getLogger(__name__)

def send_email_otp(to_email: str, otp: str) -> bool:
    """Send OTP via SendGrid. Returns True on success."""
    try:
        message = Mail(
            from_email="noreply@smartcrop.in",
            to_emails=to_email,
            subject="Your Smart Crop Advisory Login OTP",
            html_content=f"""
            <h2>🌾 Smart Crop Advisory System</h2>
            <p>Your One-Time Password is:</p>
            <h1 style="color:#2E7D32;letter-spacing:8px">{otp}</h1>
            <p>Valid for 10 minutes. Do not share this OTP.</p>
            """
        )
        sg = SendGridAPIClient(settings.sendgrid_api_key)
        sg.send(message)
        return True
    except Exception as e:
        logger.warning(f"SendGrid failed: {e}. OTP={otp} (dev mode)")
        return False
