from fastapi import APIRouter, UploadFile, File
from PIL import Image
import io
from backend.services.disease_detection import detector
from backend.services.gemini_service import explain_disease

router = APIRouter(prefix="/api/disease", tags=["disease"])

@router.post("/detect")
async def detect_disease(file: UploadFile = File(...)):
    contents = await file.read()
    image    = Image.open(io.BytesIO(contents)).convert("RGB")
    result   = detector.predict(image)
    advisory = explain_disease(result["disease"], result["crop"], result["confidence"])
    return {**result, "advisory": advisory}
