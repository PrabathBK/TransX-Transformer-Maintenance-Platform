#!/usr/bin/env python3
"""
YOLOv8p2 Smart Inference Tool
Automatically asks if fine-tuning is needed after base model inference
"""

import os
import sys
import torch
import json
import argparse
from pathlib import Path

# PyTorch 2.6 compatibility fix
def patched_load(f, map_location=None, pickle_module=None, **pickle_load_args):
    return original_torch_load(f, map_location=map_location, pickle_module=pickle_module, weights_only=False, **pickle_load_args)

original_torch_load = torch.load
torch.load = patched_load

def setup_system():
    """Initialize the system directories"""
    base_dir = Path(__file__).parent.parent
    models_dir = base_dir / "models"
    base_models_dir = models_dir / "base"
    finetuned_models_dir = models_dir / "finetuned"
    
    # Create directories if they don't exist
    finetuned_models_dir.mkdir(parents=True, exist_ok=True)
    
    return base_dir, models_dir, base_models_dir, finetuned_models_dir

def get_base_model_path():
    """Get the base model path"""
    _, _, base_models_dir, _ = setup_system()
    base_model = base_models_dir / "yolov8p2_base_trained.pt"
    
    if not base_model.exists():
        print(f"❌ Base model not found: {base_model}")
        print("Please ensure the base model is in: models/base/yolov8p2_base_trained.pt")
        return None
    
    return str(base_model)

def run_inference(image_path, model_path, device='cuda:1'):
    """Run inference and return results"""
    try:
        from ultralytics import YOLO
        
        print(f"🔍 Running inference on: {image_path}")
        print(f"📦 Using model: {Path(model_path).name}")
        print(f"📱 Device: {device}")
        
        model = YOLO(model_path)
        results = model(image_path, device=device, verbose=False)
        
        class_names = {0: 'Faulty', 1: 'faulty_loose_joint', 2: 'faulty_point_overload', 3: 'Good'}
        
        detections = []
        for result in results:
            if result.boxes is not None:
                boxes = result.boxes.xyxy.cpu().numpy()
                confidences = result.boxes.conf.cpu().numpy()
                class_ids = result.boxes.cls.cpu().numpy()
                
                for i, (box, conf, cls_id) in enumerate(zip(boxes, confidences, class_ids)):
                    class_name = class_names.get(int(cls_id), f'class_{int(cls_id)}')
                    detections.append({
                        'class': class_name,
                        'confidence': float(conf),
                        'bbox': box.tolist()
                    })
                    print(f"   {i+1}. {class_name} (confidence: {conf:.3f})")
        
        if not detections:
            print("   No detections found")
        
        print(f"✅ Found {len(detections)} detections")
        return detections
        
    except ImportError:
        print("❌ ultralytics not found. Please install: pip install ultralytics")
        return []
    except Exception as e:
        print(f"❌ Error during inference: {e}")
        return []

def ask_for_finetuning(detections, image_path):
    """Ask user if they want to fine-tune based on results"""
    print(f"\n📊 Base Model Results Summary:")
    print("=" * 40)
    print(f"   Total detections: {len(detections)}")
    
    if len(detections) > 0:
        avg_conf = sum(d['confidence'] for d in detections) / len(detections)
        print(f"   Average confidence: {avg_conf:.3f}")
        
        high_conf = sum(1 for d in detections if d['confidence'] > 0.8)
        med_conf = sum(1 for d in detections if 0.5 <= d['confidence'] <= 0.8)
        low_conf = sum(1 for d in detections if d['confidence'] < 0.5)
        
        print(f"   High confidence (>80%): {high_conf}")
        print(f"   Medium confidence (50-80%): {med_conf}")
        print(f"   Low confidence (<50%): {low_conf}")
        
        print(f"\n   Detected classes:")
        for det in detections:
            print(f"      - {det['class']} ({det['confidence']:.3f})")
    
    print(f"\n❓ What would you like to do?")
    print("   1️⃣  Use these results (satisfied)")
    print("   2️⃣  Add manual corrections and fine-tune")
    print("   3️⃣  Exit")
    
    while True:
        try:
            choice = input("\nEnter choice (1/2/3): ").strip()
            if choice in ['1', '2', '3']:
                return choice
            else:
                print("Please enter 1, 2, or 3")
        except KeyboardInterrupt:
            print("\n👋 Exiting...")
            return '3'

def collect_annotations(image_path):
    """Collect manual annotations from user"""
    print(f"\n✏️  Manual Annotation for: {Path(image_path).name}")
    print("=" * 50)
    print("📝 Class IDs:")
    print("   0 = Faulty")
    print("   1 = faulty_loose_joint") 
    print("   2 = faulty_point_overload")
    print("   3 = Good")
    print("\n📐 Format: class_id center_x center_y width height")
    print("   (All coordinates normalized 0-1)")
    print("   Example: 0 0.5 0.3 0.2 0.1")
    print("\n💡 Type 'done' when finished")
    
    annotations = []
    annotation_count = 0
    
    while True:
        try:
            user_input = input(f"\nAnnotation {annotation_count + 1}: ").strip()
            
            if user_input.lower() == 'done':
                break
            
            parts = user_input.split()
            if len(parts) != 5:
                print("❌ Invalid format. Use: class_id center_x center_y width height")
                continue
            
            try:
                class_id, cx, cy, w, h = map(float, parts)
                class_id = int(class_id)
                
                if not (0 <= class_id <= 3):
                    print("❌ Class ID must be 0-3")
                    continue
                
                if not all(0 <= val <= 1 for val in [cx, cy, w, h]):
                    print("❌ Coordinates must be between 0 and 1")
                    continue
                
                annotation_line = f"{class_id} {cx} {cy} {w} {h}"
                annotations.append(annotation_line)
                annotation_count += 1
                print(f"✅ Added annotation {annotation_count}: {annotation_line}")
                
            except ValueError:
                print("❌ Invalid numbers. Please use decimal format.")
                continue
                
        except KeyboardInterrupt:
            print("\n👋 Stopping annotation collection...")
            break
    
    print(f"\n📝 Collected {len(annotations)} annotations")
    return annotations

def create_training_dataset(image_path, annotations):
    """Create a training dataset from image and annotations with augmentation"""
    print(f"\n🔄 Creating training dataset...")
    
    base_dir, _, _, _ = setup_system()
    timestamp = Path(image_path).stem
    dataset_dir = base_dir / f"training_data_{timestamp}"
    
    # Create dataset structure
    train_dir = dataset_dir / "train"
    train_dir.mkdir(parents=True, exist_ok=True)
    
    # If we have only one image, create augmented versions
    if len(annotations) > 0:
        print(f"📈 Creating augmented versions for better training...")
        
        import cv2
        import numpy as np
        
        # Load original image
        image = cv2.imread(str(image_path))
        base_name = Path(image_path).stem
        
        # Create original + 9 augmented versions (10 total)
        for i in range(10):
            if i == 0:
                # Original image
                aug_image = image.copy()
                aug_name = f"{base_name}_orig"
            else:
                # Create augmented version
                aug_image = image.copy()
                
                # Random brightness
                brightness = np.random.uniform(0.7, 1.3)
                aug_image = cv2.convertScaleAbs(aug_image, alpha=brightness, beta=0)
                
                # Random horizontal flip
                if np.random.random() > 0.5:
                    aug_image = cv2.flip(aug_image, 1)
                    # Flip annotations horizontally
                    flipped_annotations = []
                    for ann in annotations:
                        parts = ann.split()
                        class_id = parts[0]
                        center_x = 1.0 - float(parts[1])  # Flip x coordinate
                        center_y = float(parts[2])
                        width = float(parts[3])
                        height = float(parts[4])
                        flipped_annotations.append(f"{class_id} {center_x} {center_y} {width} {height}")
                    current_annotations = flipped_annotations
                else:
                    current_annotations = annotations
                
                aug_name = f"{base_name}_aug{i}"
            
            # Save augmented image
            aug_image_path = train_dir / f"{aug_name}.jpg"
            cv2.imwrite(str(aug_image_path), aug_image)
            
            # Save annotations
            aug_label_path = train_dir / f"{aug_name}.txt"
            with open(aug_label_path, 'w') as f:
                for ann in (current_annotations if i > 0 and 'current_annotations' in locals() else annotations):
                    f.write(ann + '\n')
        
        print(f"✅ Created 10 augmented versions for training")
    
    else:
        # Fallback to single image if no annotations
        import shutil
        image_name = Path(image_path).name
        train_image = train_dir / image_name
        shutil.copy2(image_path, train_image)
        
        # Save single annotation file
        annotation_file = train_dir / f"{Path(image_path).stem}.txt"
        with open(annotation_file, 'w') as f:
            for ann in annotations:
                f.write(f"{ann}\n")
    
    # Create dataset.yaml
    dataset_yaml = dataset_dir / "dataset.yaml"
    yaml_content = f"""path: {dataset_dir.absolute()}
train: train
val: train

names:
  0: Faulty
  1: faulty_loose_joint
  2: faulty_point_overload
  3: Good
"""
    
    with open(dataset_yaml, 'w') as f:
        f.write(yaml_content)
    
    print(f"✅ Dataset created: {dataset_dir}")
    return str(dataset_yaml)

def run_finetuning(dataset_yaml, model_name):
    """Run fine-tuning with the dataset"""
    print(f"\n🚀 Starting Fine-tuning Process...")
    print("=" * 40)
    
    try:
        # Use the finetune.py tool
        finetune_script = Path(__file__).parent / "finetune.py"
        
        if not finetune_script.exists():
            print(f"❌ Fine-tuning script not found: {finetune_script}")
            return False
        
        import subprocess
        
        # Create command that activates YOLO environment and runs finetune
        bash_cmd = f"""
        source /home/jaliya/miniconda3/bin/activate YOLO && \
        cd /home/jaliya/model/yolov8p2_system && \
        python tools/finetune.py "{dataset_yaml}" "{model_name}"
        """
        
        print(f"🔄 Running fine-tuning with YOLO environment...")
        
        result = subprocess.run(bash_cmd, shell=True, capture_output=True, text=True, executable='/bin/bash')
        
        if result.returncode == 0:
            print("✅ Fine-tuning completed successfully!")
            # Create safe model name for file paths
            safe_model_name = model_name.replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
            model_path = f"models/finetuned/{safe_model_name}_best.pt"
            print(f"📁 New model saved: {model_path}")
            return True
        else:
            print(f"❌ Fine-tuning failed:")
            if result.stdout:
                print("STDOUT:", result.stdout)
            if result.stderr:
                print("STDERR:", result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Error during fine-tuning: {e}")
        return False

def main():
    print("🎯 YOLOv8p2 Smart Inference Tool")
    print("   (Automatically offers fine-tuning if needed)")
    print("=" * 55)
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python smart_inference.py <image_path>")
        print("\nExample:")
        print("  python smart_inference.py test_image.jpg")
        
        # Show available models
        _, _, base_models_dir, finetuned_models_dir = setup_system()
        
        print("\n📦 Available Models:")
        base_model = base_models_dir / "yolov8p2_base_trained.pt"
        if base_model.exists():
            print(f"   🏆 Base: models/base/yolov8p2_base_trained.pt")
        else:
            print("   ❌ Base model not found")
        
        finetuned_models = list(finetuned_models_dir.glob("*.pt"))
        if finetuned_models:
            for model in finetuned_models:
                print(f"   🔧 Fine-tuned: {model}")
        else:
            print("   📝 No fine-tuned models yet")
        
        return
    
    image_path = sys.argv[1]
    
    # Check if image exists
    if not Path(image_path).exists():
        print(f"❌ Image not found: {image_path}")
        return
    
    # Get base model
    base_model_path = get_base_model_path()
    if not base_model_path:
        return
    
    # Step 1: Run base model inference
    print(f"\n🎯 Step 1: Base Model Inference")
    print("-" * 35)
    detections = run_inference(image_path, base_model_path)
    
    # Step 2: Ask for fine-tuning
    choice = ask_for_finetuning(detections, image_path)
    
    if choice == '1':
        print("\n✅ Using current results. Process completed!")
        
        # Save results
        results_file = f"{Path(image_path).stem}_results.json"
        with open(results_file, 'w') as f:
            json.dump({
                'image': image_path,
                'model': 'base_model',
                'detections': detections,
                'summary': {
                    'total_detections': len(detections),
                    'classes_found': list(set(d['class'] for d in detections))
                }
            }, f, indent=2)
        print(f"💾 Results saved to: {results_file}")
        
    elif choice == '2':
        print(f"\n🎯 Step 2: Manual Annotation & Fine-tuning")
        print("-" * 45)
        
        # Collect annotations
        annotations = collect_annotations(image_path)
        
        if not annotations:
            print("❌ No annotations provided. Skipping fine-tuning.")
            return
        
        # Create dataset
        dataset_yaml = create_training_dataset(image_path, annotations)
        
        # Generate model name
        model_name = f"custom_{Path(image_path).stem}"
        
        # Run fine-tuning
        success = run_finetuning(dataset_yaml, model_name)
        
        if success:
            print(f"\n🎉 Fine-tuning Process Completed!")
            print("=" * 35)
            print(f"📁 New model: models/finetuned/{model_name}_best.pt")
            print(f"\n💡 Test your fine-tuned model:")
            print(f"   python inference.py {image_path} models/finetuned/{model_name}_best.pt")
        else:
            print("\n❌ Fine-tuning failed. Check the error messages above.")
    
    elif choice == '3':
        print("\n👋 Exiting...")
    
    print(f"\n✅ Smart inference process completed!")

if __name__ == "__main__":
    main()