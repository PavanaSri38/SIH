from fastapi import APIRouter
from pydantic import BaseModel
from backend.services.crop_recommendation import recommend_crops

router = APIRouter(prefix="/api/crop", tags=["crop"])

class CropRequest(BaseModel):
    soil_type: str
    state: str
    season: str

@router.post("/recommend")
async def crop_recommend(req: CropRequest):
    return await recommend_crops(req.soil_type, req.state, req.season)
