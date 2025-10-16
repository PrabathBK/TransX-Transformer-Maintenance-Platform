#!/usr/bin/env python3
"""
YOLOv8p2 Fine-tuning Tool
Fine-tune the base model with new data
"""

import torch
import sys
import os
from pathlib import Path
from datetime import datetime

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

class YOLOv8p2FineTuner:
    def __init__(self):
        self.device = 'cuda:1'
        
    def finetune_model(self, dataset_yaml, epochs=50, model_name=None):
        """Fine-tune the base model"""
        
        if not os.path.exists(BASE_MODEL_PATH):
            print(f"❌ Base model not found: {BASE_MODEL_PATH}")
            return None
            
        if not os.path.exists(dataset_yaml):
            print(f"❌ Dataset not found: {dataset_yaml}")
            return None
            
        # Generate model name if not provided
        if model_name is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            model_name = f"finetuned_{timestamp}"
            
        print(f"🚀 Starting Fine-tuning Process")
        print("=" * 40)
        print(f"📦 Base model: {BASE_MODEL_PATH}")
        print(f"📊 Dataset: {dataset_yaml}")
        print(f"🔄 Epochs: {epochs}")
        print(f"💾 Output name: {model_name}")
        print(f"📱 Device: {self.device}")
        
        try:
            # Load base model
            model = YOLO(BASE_MODEL_PATH)
            print("✅ Base model loaded successfully")
            
            # Fine-tuning parameters
            # Training configuration - save directly to finetuned directory
            clean_model_name = model_name.replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
            training_params = {
                'data': dataset_yaml,
                'epochs': epochs,
                'device': 'cuda:1',
                'project': FINETUNED_MODEL_DIR,
                'name': clean_model_name,
                'exist_ok': True,
                'verbose': True,
                
                # Optimized for fine-tuning
                'batch': 16,
                'workers': 8,
                'lr0': 0.0005,  # Lower learning rate for fine-tuning
                'lrf': 0.001,
                'momentum': 0.95,
                'weight_decay': 0.001,
                'warmup_epochs': 5,
                'cos_lr': True,
                'patience': 20,
                
                # Enhanced augmentations
                'mosaic': 0.8,
                'mixup': 0.2,
                'copy_paste': 0.2,
                'degrees': 20.0,
                'translate': 0.15,
                'scale': 0.3,
                'shear': 5.0,
                'perspective': 0.0005,
                'fliplr': 0.5,
                'flipud': 0.1,
                'hsv_h': 0.02,
                'hsv_s': 0.8,
                'hsv_v': 0.5,
                
                # Training strategy
                'close_mosaic': 15,
                'amp': True,
                'save_period': 10,
                'plots': True,
            }
            
            # Start training
            results = model.train(**training_params)
            
            # Get the path where YOLO saved the model
            training_output_dir = str(results.save_dir)
            source_best_pt = f"{training_output_dir}/weights/best.pt"
            
            # Create final destination path - just the .pt file
            final_model_path = f"{FINETUNED_MODEL_DIR}/{clean_model_name}_best.pt"
            
            if os.path.exists(source_best_pt):
                # Copy only the best.pt file to the final location
                import shutil
                shutil.copy2(source_best_pt, final_model_path)
                
                # Clean up the full training directory
                shutil.rmtree(training_output_dir)
                
                print(f"✅ Fine-tuned model saved: {final_model_path}")
                print(f"🧹 Cleaned up training files")
                print(f"🎉 Fine-tuning completed successfully!")
                return f"models/finetuned/{clean_model_name}_best.pt"
            else:
                print(f"⚠️ Training completed but model not found at: {source_best_pt}")
                return None
            
        except Exception as e:
            print(f"❌ Fine-tuning failed: {e}")
            import traceback
            traceback.print_exc()
            return None

def main():
    if len(sys.argv) < 2:
        print("YOLOv8p2 Fine-tuning Tool")
        print("=" * 30)
        print("Usage:")
        print("  python finetune.py <dataset.yaml> [epochs] [model_name]")
        print("")
        print("Examples:")
        print("  python finetune.py dataset.yaml")
        print("  python finetune.py dataset.yaml 30")
        print("  python finetune.py dataset.yaml 50 custom_model")
        print("")
        print("Note: Dataset should be in YOLO format with train/val directories")
        return
    
    dataset_yaml = sys.argv[1]
    
    # Handle different argument patterns
    if len(sys.argv) == 3:
        # Check if second argument is a number (epochs) or string (model_name)
        try:
            epochs = int(sys.argv[2])
            model_name = None
        except ValueError:
            # It's a model name, use default epochs
            epochs = 50
            model_name = sys.argv[2].replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
    elif len(sys.argv) == 4:
        epochs = int(sys.argv[2])
        model_name = sys.argv[3].replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
    else:
        epochs = 50
        model_name = None
    
    finetuner = YOLOv8p2FineTuner()
    result = finetuner.finetune_model(dataset_yaml, epochs, model_name)
    
    if result:
        print(f"\n✅ Fine-tuning successful!")
        print(f"🎯 New model: {result}")
        print(f"💡 Use: python inference.py <image> {result}")
    else:
        print(f"\n❌ Fine-tuning failed!")

if __name__ == "__main__":
    main()