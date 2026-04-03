# Plant Disease Detection Model

## Model: MobileNetV2
- **Architecture**: MobileNetV2 (pre-trained on ImageNet, fine-tuned on PlantVillage)
- **Classes**: 38 disease categories
- **Training Dataset**: PlantVillage (~87,000 images)
- **Input size**: 224x224 RGB
- **Output**: Softmax probabilities over 38 classes

## Files
- `mobilenetv2_plant.pth` — trained model weights (not included in repo, download separately)
- `class_names.json`      — list of 38 class label strings

## Download
Download model weights from the project release or contact the team.
