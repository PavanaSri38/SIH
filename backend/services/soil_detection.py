"""Rule-based soil type detection from manual selection or image colour."""
SOIL_CROP_MAP = {
    "Clay":     ["Rice", "Wheat", "Pulses"],
    "Sandy":    ["Millet", "Groundnut", "Watermelon"],
    "Loamy":    ["Vegetables", "Fruits", "Maize"],
    "Silty":    ["Vegetables", "Grass crops"],
    "Black":    ["Cotton", "Sugarcane", "Jowar"],
    "Red":      ["Groundnut", "Millets", "Tobacco"],
    "Alluvial": ["Rice", "Wheat", "Sugarcane", "Cotton"],
    "Laterite": ["Tea", "Coffee", "Cashew"],
}

def get_suitable_crops(soil_type: str) -> list:
    return SOIL_CROP_MAP.get(soil_type, ["Consult local Krishi Vigyan Kendra"])

def detect_soil_type_from_selection(soil_type: str) -> dict:
    crops = get_suitable_crops(soil_type)
    return {"soil_type": soil_type, "suitable_crops": crops, "confidence": 100.0}
