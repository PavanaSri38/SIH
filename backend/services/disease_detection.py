import torch
import torchvision.transforms as T
from torchvision import models
import torch.nn as nn
from PIL import Image
import json, os

MODEL_PATH   = os.path.join(os.path.dirname(__file__), "../ml_models/plant_disease/mobilenetv2_plant.pth")
CLASSES_PATH = os.path.join(os.path.dirname(__file__), "../ml_models/plant_disease/class_names.json")

class DiseaseDetector:
    def __init__(self):
        with open(CLASSES_PATH) as f:
            self.class_names = json.load(f)
        self.model = models.mobilenet_v2(pretrained=False)
        self.model.classifier[1] = nn.Linear(1280, len(self.class_names))
        if os.path.exists(MODEL_PATH):
            self.model.load_state_dict(torch.load(MODEL_PATH, map_location="cpu"))
        self.model.eval()
        self.transform = T.Compose([
            T.Resize((224, 224)),
            T.ToTensor(),
            T.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])

    def predict(self, image: Image.Image) -> dict:
        tensor = self.transform(image).unsqueeze(0)
        with torch.no_grad():
            logits     = self.model(tensor)
            idx        = logits.argmax(1).item()
            confidence = torch.softmax(logits, 1).max().item()
        label   = self.class_names[idx]
        parts   = label.split("___")
        crop    = parts[0].replace("_", " ")
        disease = parts[1].replace("_", " ") if len(parts) > 1 else "Unknown"
        return {"crop": crop, "disease": disease, "confidence": round(confidence * 100, 2), "is_healthy": "healthy" in disease.lower()}

detector = DiseaseDetector()
