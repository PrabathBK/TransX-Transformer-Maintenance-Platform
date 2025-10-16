#!/usr/bin/env python3
"""
YOLOv8p2 Inference Tool
Simple inference using the base trained model
"""

import torch
import sys
import os
from pathlib import Path

# PyTorch 2.6 compatibility fix
def patch_torch_load():
    original_load = torch.load
    def patched_load(f, map_location=None, pickle_module=None, weights_only=None, **kwargs):
        if weights_only is None:
            weights_only = False
        return original_load(f, map_location=map_location, pickle_module=pickle_module, 
                           weights_only=weights_only, **kwargs)
    torch.load = patched_load

patch_torch_load()

from ultralytics import YOLO

# Model paths
BASE_MODEL_PATH = "models/base/yolov8p2_base_trained.pt"
FINETUNED_MODEL_DIR = "models/finetuned"

class YOLOv8p2Inference:
    def __init__(self):
        self.class_names = {
            0: 'Faulty', 
            1: 'faulty_loose_joint', 
            2: 'faulty_point_overload', 
            3: 'Good'
        }
        self.device = 'cuda:1'
        
    def run_inference(self, image_path, model_path=None):
        """Run inference on image"""
        if model_path is None:
            model_path = BASE_MODEL_PATH
            
        print(f"🔍 Running inference on: {image_path}")
        print(f"📦 Using model: {model_path}")
        print(f"📱 Device: {self.device}")
        
        try:
            # Load model
            model = YOLO(model_path)
            
            # Run inference
            results = model(image_path, device=self.device, verbose=False)
            
            detections = []
            for result in results:
                if result.boxes is not None:
                    boxes = result.boxes.xyxy.cpu().numpy()
                    confidences = result.boxes.conf.cpu().numpy()
                    class_ids = result.boxes.cls.cpu().numpy()
                    
                    for i, (box, conf, cls_id) in enumerate(zip(boxes, confidences, class_ids)):
                        class_name = self.class_names.get(int(cls_id), f'class_{int(cls_id)}')
                        detection = {
                            'id': i+1,
                            'class': class_name,
                            'confidence': float(conf),
                            'bbox': box.tolist()
                        }
                        detections.append(detection)
                        print(f"   {i+1}. {class_name} (confidence: {conf:.3f})")
            
            if not detections:
                print("   No detections found")
                
            print(f"✅ Found {len(detections)} detections")
            return detections
            
        except Exception as e:
            print(f"❌ Inference failed: {e}")
            return []
    
    def list_available_models(self):
        """List all available models"""
        print("📦 Available Models:")
        
        # Base model
        if os.path.exists(BASE_MODEL_PATH):
            print(f"   🏆 Base: {BASE_MODEL_PATH}")
        else:
            print(f"   ❌ Base model not found: {BASE_MODEL_PATH}")
            
        # Fine-tuned models
        finetuned_dir = Path(FINETUNED_MODEL_DIR)
        if finetuned_dir.exists():
            finetuned_models = list(finetuned_dir.glob("*.pt"))
            if finetuned_models:
                print(f"   🔧 Fine-tuned models:")
                for model in finetuned_models:
                    print(f"      - {model}")
            else:
                print(f"   📝 No fine-tuned models yet")
        else:
            print(f"   📝 No fine-tuned models directory")

def main():
    if len(sys.argv) < 2:
        print("YOLOv8p2 Inference Tool")
        print("=" * 30)
        print("Usage:")
        print("  python inference.py <image_path> [model_path]")
        print("")
        print("Examples:")
        print("  python inference.py test_image.jpg")
        print("  python inference.py test_image.jpg models/finetuned/custom_model.pt")
        print("")
        
        inference = YOLOv8p2Inference()
        inference.list_available_models()
        return
    
    image_path = sys.argv[1]
    model_path = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(image_path):
        print(f"❌ Image not found: {image_path}")
        return
        
    inference = YOLOv8p2Inference()
    detections = inference.run_inference(image_path, model_path)
    
    print(f"\n📊 Summary: {len(detections)} detections found")

if __name__ == "__main__":
    main()