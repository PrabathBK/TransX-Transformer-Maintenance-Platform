#!/usr/bin/env python3

import torch
import sys
import os
from pathlib import Path

# PyTorch 2.6 compatibility fix
def patched_load(f, map_location=None, pickle_module=None, **pickle_load_args):
    return original_torch_load(f, map_location=map_location, pickle_module=pickle_module, weights_only=False, **pickle_load_args)

original_torch_load = torch.load
torch.load = patched_load

print("🔧 Applied PyTorch 2.6 compatibility fix")

from ultralytics import YOLO

def test_simple_training():
    """Test simple training to debug the weights issue"""
    
    print("🧪 DEBUGGING FINE-TUNING WEIGHTS ISSUE")
    print("="*50)
    
    # Use a working dataset
    dataset_yaml = "/home/jaliya/model/complete_workflow_manual/dataset/dataset.yaml"
    
    print(f"📊 Dataset: {dataset_yaml}")
    print(f"📦 Base model: models/base/yolov8p2_base_trained.pt")
    
    try:
        # Load base model
        model = YOLO("models/base/yolov8p2_base_trained.pt")
        print("✅ Base model loaded successfully")
        
        # Simple training with minimal epochs
        print("🚀 Starting training with debugging...")
        
        results = model.train(
            data=dataset_yaml,
            epochs=2,  # Very short training
            device='cuda:1',
            project='models/finetuned',
            name='debug_test',
            exist_ok=True,
            verbose=True,
            batch=4,  # Small batch
            workers=2,  # Fewer workers
            patience=10,
            save=True,  # Explicitly enable saving
            save_period=1,  # Save every epoch
            plots=False,  # Disable plots to focus on weights
        )
        
        print(f"🔍 Training completed. Results save_dir: {results.save_dir}")
        
        # Check what was actually saved
        weights_dir = Path(results.save_dir) / "weights"
        print(f"📁 Weights directory: {weights_dir}")
        
        if weights_dir.exists():
            weights_files = list(weights_dir.glob("*.pt"))
            print(f"📦 Found weights files: {weights_files}")
            
            for weight_file in weights_files:
                size = weight_file.stat().st_size / (1024*1024)  # MB
                print(f"   {weight_file.name}: {size:.1f} MB")
                
            if weights_files:
                print("✅ Weights saved successfully!")
                return True
            else:
                print("❌ No weight files found!")
                return False
        else:
            print(f"❌ Weights directory doesn't exist: {weights_dir}")
            return False
            
    except Exception as e:
        print(f"❌ Training failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_simple_training()
    if success:
        print("\n🎉 Debug training successful - weights issue resolved!")
    else:
        print("\n❌ Debug training failed - need to investigate further")