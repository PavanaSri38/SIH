from fastapi import APIRouter
from backend.services.market_price_service import get_market_prices

router = APIRouter(prefix="/api/market", tags=["market"])

@router.get("/prices")
def market_prices(crop: str, state: str):
    return get_market_prices(crop, state)
