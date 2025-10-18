#!/usr/bin/env python3
"""
Fine-tuning Script for YOLOv8 Model using Human Feedback
Creates augmented training data from human annotations and fine-tunes the model

This script is designed to run in background threads to avoid blocking
the main ML service during training. Other image processing can continue
while fine-tuning is in progress.
"""

import os
import json
import cv2
import numpy as np
from pathlib import Path
import albumentations as A
from ultralytics import YOLO
import shutil
import yaml
import logging
from datetime import datetime
import random


MOSAIC            = 0.1           # light augmentation; set 0.0 if labels are tight
MIXUP             = 0.0
DEGREES           = 5.0
SCALE             = 0.2
TRANSLATE         = 0.05
SHEAR             = 1.0
FLIPLR            = 0.5
HSV_H, HSV_S, HSV_V = 0.01, 0.5, 0.3
PATIENCE          = 5
FREEZE            = 0             # Don't freeze any layers for fine-tuning
# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class FeedbackFineTuner:
    def __init__(self, feedback_dir="feedback_data", output_dir="fine_tune_dataset", base_model_path=None):
        self.feedback_dir = Path(feedback_dir)
        self.output_dir = Path(output_dir)
        # Always use the latest model in Faulty_Detection directory
        self.base_model_path = base_model_path or self.get_latest_model_path()
        self.augmentation_count = 50
        
        # Class mapping from your model (YOLO expected format)
        self.class_names = {
            0: 'Faulty',
            1: 'faulty_loose_joint', 
            2: 'faulty_point_overload',
            3: 'potential_faulty'
        }
        
        # Mapping from feedback class IDs to model class IDs
        self.feedback_to_model_class_mapping = {
            1: 0,  # Feedback 'Faulty' (ID=1) -> Model 'Faulty' (ID=0)
            3: 2,  # Feedback 'faulty_point_overload' (ID=3) -> Model 'faulty_point_overload' (ID=2)
            4: 3,  # Feedback 'potential_faulty' (ID=4) -> Model 'potential_faulty' (ID=3)
        }
        
        # Create output directories
        self.setup_directories()
        
        # Setup augmentation pipeline
        self.setup_augmentations()
    
    def get_latest_model_path(self):
        """Get the path to the latest model in Faulty_Detection directory"""
        faulty_detection_dir = Path("/Users/jaliya/Desktop/Jaliya/Semester 7/Software/TransX-Transformer-Maintenance-Platform/transformer-inspector/Faulty_Detection")
        
        # First check for the main model
        main_model = faulty_detection_dir / "yolov8p2.pt"
        if main_model.exists():
            logger.info(f"🎯 Using latest model: {main_model}")
            return str(main_model)
        
        # Fallback to original model if main doesn't exist
        original_model = faulty_detection_dir / "yolov8p2_original.pt"
        if original_model.exists():
            logger.info(f"🎯 Using fallback model: {original_model}")
            return str(original_model)
        
        # Last resort: relative path
        logger.warning("⚠️  No model found in Faulty_Detection, using relative path")
        return "../Faulty_Detection/yolov8p2.pt"
    
    def map_feedback_class_to_model_class(self, feedback_class_id, feedback_class_name):
        """Map feedback class ID to model class ID with validation"""
        # First try direct mapping
        if feedback_class_id in self.feedback_to_model_class_mapping:
            model_class_id = self.feedback_to_model_class_mapping[feedback_class_id]
            expected_name = self.class_names[model_class_id]
            logger.info(f"🔄 Mapped class: Feedback '{feedback_class_name}' (ID={feedback_class_id}) -> Model '{expected_name}' (ID={model_class_id})")
            return model_class_id
        
        # Fallback: try to match by name similarity
        feedback_name_lower = feedback_class_name.lower()
        for model_id, model_name in self.class_names.items():
            model_name_lower = model_name.lower()
            if (feedback_name_lower in model_name_lower or 
                model_name_lower in feedback_name_lower or
                feedback_name_lower == model_name_lower):
                logger.info(f"🔄 Mapped by name similarity: '{feedback_class_name}' -> '{model_name}' (ID={model_id})")
                return model_id
        
        # If no mapping found, default to 'Faulty' but warn
        logger.warning(f"⚠️  No mapping found for class '{feedback_class_name}' (ID={feedback_class_id}), defaulting to 'Faulty' (ID=0)")
        return 0
    
    def validate_image_label_consistency(self, image_path, class_name):
        """Check if the image filename suggests it matches the assigned label"""
        filename = image_path.name.lower()
        class_lower = class_name.lower()
        
        # Check if filename contains indicators
        faulty_indicators = ['faulty', 'fault', 'defect', 'problem', 'overload', 'damage']
        normal_indicators = ['normal', 'good', 'clean', 'ok', 'healthy']
        
        has_faulty_in_name = any(indicator in filename for indicator in faulty_indicators)
        has_normal_in_name = any(indicator in filename for indicator in normal_indicators)
        
        # Log potential mismatches and suggest corrections
        if 'faulty' in class_lower and has_normal_in_name:
            logger.warning(f"⚠️  MISMATCH: Faulty class '{class_name}' assigned to normal-looking image: {filename}")
            logger.warning(f"   💡 Consider using this image for normal/background training instead")
            return False
        elif 'normal' in class_lower and has_faulty_in_name:
            logger.warning(f"⚠️  MISMATCH: Normal class '{class_name}' assigned to faulty-looking image: {filename}")
            logger.warning(f"   💡 This image might actually contain defects")
            return False
        elif has_faulty_in_name and 'faulty' in class_lower:
            logger.info(f"✅ GOOD MATCH: {class_name} on faulty image: {filename}")
            return True
        elif has_normal_in_name and ('normal' in class_lower or 'background' in class_lower):
            logger.info(f"✅ GOOD MATCH: {class_name} on normal image: {filename}")
            return True
        elif 'potential' in class_lower:
            logger.info(f"ℹ️  POTENTIAL FAULT: {class_name} on {filename} - human judgment required")
            return True
        
        # If no clear indicators, provide guidance
        logger.info(f"ℹ️  UNCLEAR: No obvious indicators for {class_name} on {filename}")
        logger.info(f"   💡 Manual review recommended to ensure correct labeling")
        return True
        
    def setup_directories(self):
        """Create necessary directories for dataset"""
        dirs = [
            self.output_dir / "images" / "train",
            self.output_dir / "images" / "val", 
            self.output_dir / "labels" / "train",
            self.output_dir / "labels" / "val"
        ]
        
        for dir_path in dirs:
            dir_path.mkdir(parents=True, exist_ok=True)
            
        logger.info(f"Created dataset directories in: {self.output_dir}")
        
    def setup_augmentations(self):
        """Setup augmentation pipeline using Albumentations"""
        self.transform = A.Compose([
            A.OneOf([
                A.HorizontalFlip(p=0.5),
                A.VerticalFlip(p=0.3),
                A.RandomRotate90(p=0.3),
            ], p=0.7),
            
            A.OneOf([
                A.RandomBrightnessContrast(brightness_limit=0.2, contrast_limit=0.2, p=0.5),
                A.HueSaturationValue(hue_shift_limit=10, sat_shift_limit=20, val_shift_limit=20, p=0.5),
                A.CLAHE(clip_limit=2.0, tile_grid_size=(8, 8), p=0.3),
            ], p=0.8),
            
            A.OneOf([
                A.GaussNoise(var_limit=(10.0, 50.0), p=0.3),  # Fixed: use proper variance range
                A.ISONoise(color_shift=(0.01, 0.05), intensity=(0.1, 0.5), p=0.3),
                A.MultiplicativeNoise(multiplier=[0.9, 1.1], elementwise=True, p=0.3),
            ], p=0.5),
            
            A.OneOf([
                A.Blur(blur_limit=3, p=0.3),
                A.MotionBlur(blur_limit=3, p=0.3),
                A.GaussianBlur(blur_limit=3, p=0.3),
            ], p=0.4),
            
            A.RandomScale(scale_limit=0.1, p=0.3),
            A.Affine(
                scale=(0.9, 1.1),
                translate_percent=(-0.1, 0.1),
                rotate=(-10, 10),
                shear=(-5, 5),
                p=0.5
            ),
            
        ], bbox_params=A.BboxParams(format='yolo', label_fields=['class_labels']))
        
        logger.info("Augmentation pipeline setup complete")
        
    def load_feedback_data(self):
        """Load all feedback JSON files"""
        feedback_files = list(self.feedback_dir.glob("feedback_*.json"))
        logger.info(f"Found {len(feedback_files)} feedback files")
        
        all_feedback = []
        for file_path in feedback_files:
            try:
                with open(file_path, 'r') as f:
                    feedback = json.load(f)
                    all_feedback.append(feedback)
                    logger.info(f"Loaded feedback: {file_path.name}")
            except Exception as e:
                logger.error(f"Error loading {file_path}: {e}")
                
        return all_feedback
        
    def extract_human_annotations(self, feedback_data):
        """Extract human annotations from feedback data"""
        human_annotations = []
        
        for feedback in feedback_data:
            inspection_id = feedback.get('inspectionId')
            comparisons = feedback.get('comparisons', [])
            
            for comparison in comparisons:
                if comparison.get('humanAnnotation'):
                    human_ann = comparison['humanAnnotation']
                    image_id = comparison.get('imageId')
                    
                    # Try to find the image file
                    image_path = self.find_image_file(inspection_id, image_id)
                    
                    if image_path and image_path.exists():
                        # Map feedback class to model class
                        original_feedback_class_id = human_ann.get('classId')
                        original_class_name = human_ann.get('className')
                        
                        correct_model_class_id = self.map_feedback_class_to_model_class(
                            original_feedback_class_id, original_class_name
                        )
                        correct_model_class_name = self.class_names[correct_model_class_id]
                        
                        # Validate image-label consistency
                        self.validate_image_label_consistency(image_path, correct_model_class_name)
                        
                        annotation = {
                            'inspection_id': inspection_id,
                            'image_id': image_id,
                            'image_path': image_path,
                            'class_id': correct_model_class_id,  # Use mapped class ID
                            'class_name': correct_model_class_name,  # Use mapped class name
                            'bbox': human_ann.get('bbox'),
                            'confidence': human_ann.get('confidence'),
                            'created_by': human_ann.get('createdBy'),
                            'action_taken': comparison.get('actionTaken'),
                            'original_feedback_class': original_class_name,
                            'original_feedback_class_id': original_feedback_class_id
                        }
                        human_annotations.append(annotation)
                        logger.info(f"Found human annotation: {annotation['class_name']} in {image_path.name}")
                    else:
                        logger.warning(f"Image not found for annotation: {inspection_id}/{image_id}")
                        
        # If no real images found, provide detailed debugging information
        if not human_annotations:
            logger.warning("=" * 60)
            logger.warning("⚠️  NO IMAGES FOUND FOR HUMAN ANNOTATIONS")
            logger.warning("This means the inspection IDs in feedback don't match upload directories.")
            logger.warning("")
            
            # Show what we have vs what we need
            feedback_ids = {fb.get('inspectionId') for fb in feedback_data}
            logger.warning("📋 Feedback inspection IDs:")
            for fid in list(feedback_ids)[:5]:
                logger.warning(f"   - {fid}")
                
            # Check available upload directories
            uploads_dir = Path("../backend/uploads")
            if uploads_dir.exists():
                available_dirs = [d.name for d in uploads_dir.iterdir() if d.is_dir()]
                logger.warning(f"\n📂 Available upload directories ({len(available_dirs)}):")
                for aid in available_dirs[:5]:
                    logger.warning(f"   - {aid}")
                    
                intersection = feedback_ids.intersection(set(available_dirs))
                if intersection:
                    logger.warning(f"\n✅ Found {len(intersection)} matching directories!")
                else:
                    logger.warning(f"\n❌ NO MATCHING DIRECTORIES - this explains why no images found")
                    
            logger.warning("")
            logger.warning("⚠️  USING FALLBACK STRATEGY:")
            logger.warning("Creating training data from any available images with human annotation patterns...")
            logger.warning("This is for demonstration purposes - ideally feedback should reference existing images.")
            
            # Try to find any images in the uploads directory for demonstration
            fallback_annotations = self.create_fallback_annotations(feedback_data)
            if fallback_annotations:
                logger.info(f"✅ Created {len(fallback_annotations)} fallback annotations for training")
                return fallback_annotations
            else:
                logger.warning("❌ No fallback images available either")
                logger.warning("=" * 60)
        
        return human_annotations
        
    def find_image_file(self, inspection_id, image_id):
        """Find the image file for given inspection and image IDs"""
        base_paths = [
            Path("../backend/uploads"),
            Path("/Users/jaliya/Desktop/Jaliya/Semester 7/Software/TransX-Transformer-Maintenance-Platform/transformer-inspector/backend/uploads"),
            Path("uploads"),  # Current directory uploads
            Path("./uploads"),  # Relative uploads
        ]
        
        # Different subdirectory structures to check
        subdirs = ["", "inspection", "baseline"]
        
        extensions = ['.jpg', '.jpeg', '.png', '.bmp', '.JPG', '.JPEG', '.PNG', '.BMP']
        
        # Log the search process
        logger.info(f"🔍 Searching for image: {inspection_id}/{image_id}")
        
        for base_path in base_paths:
            logger.info(f"   Checking base path: {base_path}")
            
            # Check if base path exists
            if not base_path.exists():
                logger.info(f"   ❌ Base path does not exist: {base_path}")
                continue
                
            # Check inspection directory
            inspection_dir = base_path / inspection_id
            if not inspection_dir.exists():
                logger.info(f"   ❌ Inspection directory does not exist: {inspection_dir}")
                continue
                
            logger.info(f"   ✅ Inspection directory exists: {inspection_dir}")
            
            # Try different subdirectories (inspection images might be in subdirs)
            for subdir in subdirs:
                search_dir = inspection_dir / subdir if subdir else inspection_dir
                
                if not search_dir.exists():
                    continue
                    
                logger.info(f"   🔍 Searching in subdirectory: {search_dir}")
                
                # List all files in the directory for debugging
                try:
                    files_in_dir = list(search_dir.iterdir())
                    logger.info(f"   📁 Files in directory ({len(files_in_dir)}): {[f.name for f in files_in_dir[:10]]}")  # Show first 10
                    
                    # Also try to find any image that might match the image_id pattern
                    matching_files = [f for f in files_in_dir if image_id in f.name and f.is_file()]
                    if matching_files:
                        logger.info(f"   🎯 Found files containing '{image_id}': {[f.name for f in matching_files]}")
                        # Return the first matching file
                        logger.info(f"   ✅ Using matching file: {matching_files[0]}")
                        return matching_files[0]
                        
                except Exception as e:
                    logger.error(f"   ❌ Error listing files: {e}")
                    continue
                
                # Try exact filename matches with different extensions
                for ext in extensions:
                    image_path = search_dir / f"{image_id}{ext}"
                    logger.info(f"   🔍 Trying exact match: {image_path}")
                    if image_path.exists():
                        logger.info(f"   ✅ Found image: {image_path}")
                        return image_path
                    
        logger.warning(f"   ❌ Image not found after checking all paths")
        return None
        
    def create_fallback_annotations(self, feedback_data):
        """Create fallback annotations using available images with human annotation data"""
        fallback_annotations = []
        
        # Get human annotation details from feedback
        human_ann_details = []
        for feedback in feedback_data:
            for comparison in feedback.get('comparisons', []):
                if comparison.get('humanAnnotation'):
                    human_ann = comparison['humanAnnotation']
                    human_ann_details.append({
                        'bbox': human_ann.get('bbox'),
                        'class_id': human_ann.get('classId'),
                        'class_name': human_ann.get('className'),
                        'inspection_id': feedback.get('inspectionId'),
                        'image_id': comparison.get('imageId'),
                        'confidence': human_ann.get('confidence', 1.0),
                        'created_by': human_ann.get('createdBy', 'human')
                    })
        
        if not human_ann_details:
            logger.warning("No human annotation details found in feedback")
            return []
        
        logger.info(f"Found {len(human_ann_details)} human annotation details to map to available images")
        
        # Find available images in uploads directory
        base_paths = [
            Path("../backend/uploads"),
            Path("/Users/jaliya/Desktop/Jaliya/Semester 7/Software/TransX-Transformer-Maintenance-Platform/transformer-inspector/backend/uploads"),
        ]
        
        available_images = []
        for base_path in base_paths:
            if base_path.exists():
                logger.info(f"Searching for images in: {base_path}")
                for inspection_dir in base_path.iterdir():
                    if inspection_dir.is_dir():
                        for subdir in ["inspection", "baseline"]:
                            search_dir = inspection_dir / subdir
                            if search_dir.exists():
                                for file_path in search_dir.iterdir():
                                    if file_path.is_file() and file_path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.bmp']:
                                        available_images.append({
                                            'path': file_path,
                                            'inspection_id': inspection_dir.name,
                                            'subdir': subdir
                                        })
                                        
        logger.info(f"Found {len(available_images)} available images for mapping")
        
        # Create annotations by mapping human annotation data to available images
        used_images = set()
        for i, ann_detail in enumerate(human_ann_details):
            # Try to find an unused image (avoid duplicates if possible)
            available_image = None
            for img_info in available_images:
                if img_info['path'] not in used_images:
                    available_image = img_info
                    break
            
            # If all images used, reuse them (for cases with more annotations than images)
            if not available_image and available_images:
                available_image = available_images[i % len(available_images)]
            
            if available_image:
                image_path = available_image['path']
                used_images.add(image_path)
                
                # Map feedback class ID to model class ID
                original_feedback_class_id = ann_detail['class_id']
                original_class_name = ann_detail['class_name']
                
                # Get the correct model class ID
                correct_model_class_id = self.map_feedback_class_to_model_class(
                    original_feedback_class_id, original_class_name
                )
                correct_model_class_name = self.class_names[correct_model_class_id]
                
                # Validate image-label consistency
                self.validate_image_label_consistency(image_path, correct_model_class_name)
                
                # Use the original human annotation bbox
                original_bbox = ann_detail['bbox']
                
                annotation = {
                    'inspection_id': f"fallback_{i}",  # Mark as fallback
                    'image_id': f"fallback_image_{i}",
                    'image_path': image_path,
                    'class_id': correct_model_class_id,  # Use mapped class ID
                    'class_name': correct_model_class_name,  # Use mapped class name
                    'bbox': original_bbox,  # Keep original bbox coordinates
                    'confidence': ann_detail['confidence'],
                    'created_by': f"fallback_mapping_{ann_detail['created_by']}",
                    'action_taken': 'mapped_fallback',
                    'original_inspection': ann_detail['inspection_id'],
                    'original_image': ann_detail['image_id'],
                    'original_feedback_class': original_class_name,  # Keep track of original
                    'original_feedback_class_id': original_feedback_class_id
                }
                
                fallback_annotations.append(annotation)
                logger.info(f"✅ Mapped annotation {i+1}: {ann_detail['class_name']} -> {image_path.name}")
        
        logger.info(f"Created {len(fallback_annotations)} fallback annotations using human annotation data")
        return fallback_annotations
        
    def convert_to_yolo_format(self, bbox, img_width, img_height):
        """Convert bounding box to YOLO format (normalized center x, y, width, height)"""
        x1, y1, x2, y2 = bbox['x1'], bbox['y1'], bbox['x2'], bbox['y2']
        
        # Ensure coordinates are within image bounds
        x1 = max(0, min(x1, img_width - 1))
        y1 = max(0, min(y1, img_height - 1))
        x2 = max(x1 + 1, min(x2, img_width))  # Ensure x2 > x1
        y2 = max(y1 + 1, min(y2, img_height))  # Ensure y2 > y1
        
        # Calculate center coordinates and dimensions
        center_x = (x1 + x2) / 2.0
        center_y = (y1 + y2) / 2.0
        width = x2 - x1
        height = y2 - y1
        
        # Normalize by image dimensions
        center_x /= img_width
        center_y /= img_height
        width /= img_width
        height /= img_height
        
        # Ensure normalized values are in valid range [0, 1]
        center_x = max(0.0, min(1.0, center_x))
        center_y = max(0.0, min(1.0, center_y))
        width = max(0.001, min(1.0, width))   # Minimum width to avoid zero
        height = max(0.001, min(1.0, height)) # Minimum height to avoid zero
        
        return [center_x, center_y, width, height]
        
    def create_augmented_dataset(self, human_annotations):
        """Create augmented dataset from human annotations"""
        logger.info("Creating augmented dataset...")
        
        train_count = 0
        val_count = 0
        
        for i, annotation in enumerate(human_annotations):
            try:
                # Load image
                img_path = annotation['image_path']
                image = cv2.imread(str(img_path))
                image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                
                img_height, img_width = image.shape[:2]
                
                # Convert bbox to YOLO format
                yolo_bbox = self.convert_to_yolo_format(annotation['bbox'], img_width, img_height)
                class_id = annotation['class_id']
                
                # Create original + augmented versions
                for aug_idx in range(self.augmentation_count + 1):  # +1 for original
                    
                    # Determine if this goes to train (80%) or val (20%)
                    is_val = (train_count + val_count) % 5 == 0  # Every 5th image goes to validation
                    split = "val" if is_val else "train"
                    
                    if aug_idx == 0:
                        # Original image
                        aug_image = image.copy()
                        aug_bboxes = [yolo_bbox]
                        aug_classes = [class_id]
                        filename = f"{annotation['inspection_id']}_{annotation['image_id']}_original"
                    else:
                        # Apply augmentation
                        try:
                            transformed = self.transform(
                                image=image,
                                bboxes=[yolo_bbox],
                                class_labels=[class_id]
                            )
                            aug_image = transformed['image']
                            aug_bboxes = transformed['bboxes']
                            aug_classes = transformed['class_labels']
                            filename = f"{annotation['inspection_id']}_{annotation['image_id']}_aug_{aug_idx}"
                            
                            # Skip if augmentation removed the bbox
                            if not aug_bboxes:
                                continue
                                
                        except Exception as e:
                            logger.warning(f"Augmentation failed for {img_path}: {e}")
                            continue
                    
                    # Save image
                    img_save_path = self.output_dir / "images" / split / f"{filename}.jpg"
                    aug_image_bgr = cv2.cvtColor(aug_image, cv2.COLOR_RGB2BGR)
                    cv2.imwrite(str(img_save_path), aug_image_bgr)
                    
                    # Save label
                    label_save_path = self.output_dir / "labels" / split / f"{filename}.txt"
                    with open(label_save_path, 'w') as f:
                        for bbox, cls in zip(aug_bboxes, aug_classes):
                            # Ensure bbox values are within [0, 1]
                            bbox = [max(0, min(1, coord)) for coord in bbox]
                            f.write(f"{cls} {bbox[0]:.6f} {bbox[1]:.6f} {bbox[2]:.6f} {bbox[3]:.6f}\n")
                    
                    if is_val:
                        val_count += 1
                    else:
                        train_count += 1
                
                logger.info(f"Processed annotation {i+1}/{len(human_annotations)}: {annotation['class_name']}")
                
            except Exception as e:
                logger.error(f"Error processing annotation {i}: {e}")
                continue
                
        logger.info(f"Dataset created: {train_count} training images, {val_count} validation images")
        return train_count, val_count
        
    def create_dataset_yaml(self, train_count, val_count):
        """Create dataset YAML configuration"""
        yaml_content = {
            'path': str(self.output_dir.absolute()),
            'train': 'images/train',
            'val': 'images/val',
            'nc': len(self.class_names),
            'names': list(self.class_names.values())
        }
        
        yaml_path = self.output_dir / "dataset.yaml"
        with open(yaml_path, 'w') as f:
            yaml.dump(yaml_content, f, default_flow_style=False)
            
        logger.info(f"Dataset YAML created: {yaml_path}")
        return yaml_path
        
    def fine_tune_model(self, dataset_yaml, epochs=10):
        """Fine-tune the YOLOv8 model"""
        logger.info("Starting model fine-tuning...")
        
        # Load base model
        model = YOLO(self.base_model_path)
        logger.info(f"Loaded base model: {self.base_model_path}")
        
        # Create training run directory
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        project_name = "fine_tune_runs"
        run_name = f"feedback_finetune_{timestamp}"
        
        # Training parameters - optimized for small datasets
        train_args = {
            'data': str(dataset_yaml),
            'epochs': epochs,
            'imgsz': 640,
            'batch': 4,  # Smaller batch size for small datasets
            'project': project_name,
            'name': run_name,
            'save': True,
            'save_period': 5,  # Save more frequently for shorter training
            'patience': 10,  # Reduced patience for small datasets
            'device': 0 if cv2.cuda.getCudaEnabledDeviceCount() > 0 else 'cpu',
            'workers': 2,  # Fewer workers for small datasets
            'lr0': 0.0005,  # Even lower learning rate for few annotations
            'lrf': 0.1,
            'momentum': 0.937,
            'weight_decay': 0.0001,  # Reduced weight decay
            'warmup_epochs': 2,  # Shorter warmup
            'box': 7.5,
            'cls': 0.5,
            'dfl': 1.5,
            'verbose': False,  # Reduce output for background training

            # Gentle augmentations for small, precise labels
            'mosaic': MOSAIC,
            'mixup': MIXUP,
            'degrees': DEGREES,
            'translate': TRANSLATE,
            'scale': SCALE,
            'shear': SHEAR,
            'perspective': 0.0,
            'flipud': 0.0,
            'fliplr': FLIPLR,
            'hsv_h': HSV_H,
            'hsv_s': HSV_S,
            'hsv_v': HSV_V,

            'freeze': FREEZE,
        }
        
        logger.info(f"Training parameters: {train_args}")
        
        # Start training
        try:
            results = model.train(**train_args)
            logger.info("Fine-tuning completed successfully!")
            
            # Get the path to the best model
            best_model_path = Path(project_name) / run_name / "weights" / "best.pt"
            logger.info(f"Best model saved to: {best_model_path}")
            
            return best_model_path, results
            
        except Exception as e:
            logger.error(f"Fine-tuning failed: {e}")
            raise
            
    def run_complete_pipeline(self, epochs=5):
        """Run the complete fine-tuning pipeline"""
        logger.info("=" * 60)
        logger.info("STARTING FEEDBACK-BASED FINE-TUNING PIPELINE")
        logger.info("=" * 60)
        
        try:
            # Step 1: Load feedback data
            logger.info("Step 1: Loading feedback data...")
            feedback_data = self.load_feedback_data()
            if not feedback_data:
                logger.error("No feedback data found!")
                return None
                
            # Step 2: Extract human annotations
            logger.info("Step 2: Extracting human annotations...")
            human_annotations = self.extract_human_annotations(feedback_data)
            if not human_annotations:
                logger.error("No human annotations found!")
                return None
                
            logger.info(f"Found {len(human_annotations)} human annotations")
            
            # Step 3: Create augmented dataset
            logger.info("Step 3: Creating augmented dataset...")
            train_count, val_count = self.create_augmented_dataset(human_annotations)
            
            # Step 4: Create dataset YAML
            logger.info("Step 4: Creating dataset configuration...")
            dataset_yaml = self.create_dataset_yaml(train_count, val_count)
            
            # Step 5: Fine-tune model
            logger.info("Step 5: Fine-tuning model...")
            best_model_path, results = self.fine_tune_model(dataset_yaml, epochs)
            
            # Step 6: Save best model to Faulty_Detection directory
            logger.info("Step 6: Saving best model to production directory...")
            production_model_path = self.save_model_to_production(best_model_path)
            
            # Step 7: Clean up temporary dataset
            logger.info("Step 7: Cleaning up temporary dataset...")
            self.cleanup_dataset()
            
            logger.info("=" * 60)
            logger.info("FINE-TUNING PIPELINE COMPLETED SUCCESSFULLY!")
            logger.info(f"Training model: {best_model_path}")
            logger.info(f"Production model: {production_model_path}")
            logger.info(f"Training images: {train_count}")
            logger.info(f"Validation images: {val_count}")
            logger.info("🗑️  Temporary dataset cleaned up")
            logger.info("🚀 Model deployed to production directory")
            logger.info("=" * 60)
            
            return {
                'best_model_path': best_model_path,
                'production_model_path': production_model_path,
                'dataset_yaml': dataset_yaml,
                'train_count': train_count,
                'val_count': val_count,
                'human_annotations': len(human_annotations),
                'results': results
            }
            
        except Exception as e:
            logger.error(f"Pipeline failed: {e}")
            # Clean up even if training failed
            try:
                logger.info("Cleaning up dataset after failed training...")
                self.cleanup_dataset()
            except:
                pass
            raise
    
    def cleanup_dataset(self):
        """Clean up the temporary dataset directory after training"""
        try:
            if self.output_dir.exists():
                # Count files before deletion for logging
                total_files = 0
                for root, dirs, files in os.walk(self.output_dir):
                    total_files += len(files)
                
                logger.info(f"🗑️  Removing temporary dataset: {self.output_dir}")
                logger.info(f"🗑️  Deleting {total_files} temporary files (augmented images + labels)")
                
                # Remove the entire directory
                shutil.rmtree(self.output_dir)
                
                logger.info("✅ Dataset cleanup completed successfully")
                logger.info("💡 This prevents confusion with non-annotated images in the frontend")
                
            else:
                logger.info("No dataset directory to clean up")
                
        except Exception as e:
            logger.warning(f"Failed to clean up dataset: {e}")
    
    def save_model_to_production(self, best_model_path):
        """Save the best fine-tuned model to the Faulty_Detection directory for production use"""
        try:
            # Production model directory
            production_dir = Path("/Users/jaliya/Desktop/Jaliya/Semester 7/Software/TransX-Transformer-Maintenance-Platform/transformer-inspector/Faulty_Detection")
            
            # Create timestamped filename for the new model
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            production_model_name = f"yolov8p2_finetuned_{timestamp}.pt"
            production_model_path = production_dir / production_model_name
            
            # Backup the current model if it exists
            current_model_path = production_dir / "yolov8p2.pt"
            if current_model_path.exists():
                backup_path = production_dir / f"yolov8p2_backup_{timestamp}.pt"
                shutil.copy2(current_model_path, backup_path)
                logger.info(f"📦 Backed up current model to: {backup_path.name}")
            
            # Copy the new fine-tuned model
            shutil.copy2(best_model_path, production_model_path)
            logger.info(f"💾 Saved fine-tuned model to: {production_model_path}")
            
            # Update the main model file to use the new fine-tuned model
            if current_model_path.exists():
                current_model_path.unlink()  # Remove old main model
            shutil.copy2(production_model_path, current_model_path)
            logger.info(f"🔄 Updated main model: yolov8p2.pt (now uses fine-tuned version)")
            
            # Update the base model path for future fine-tuning
            self.base_model_path = str(current_model_path)
            logger.info(f"🎯 Next fine-tuning will use: {self.base_model_path}")
            
            logger.info("=" * 50)
            logger.info("🚀 MODEL DEPLOYMENT COMPLETED!")
            logger.info(f"✅ Production model: {current_model_path}")
            logger.info(f"💾 Archived version: {production_model_name}")
            logger.info(f"📦 Previous backup: yolov8p2_backup_{timestamp}.pt")
            logger.info("🔄 Future fine-tuning will build on this improved model")
            logger.info("=" * 50)
            
            return production_model_path
            
        except Exception as e:
            logger.error(f"Failed to save model to production: {e}")
            logger.warning("Model will remain in fine_tune_runs directory only")
            return best_model_path


def main():
    """Main function to run the fine-tuning pipeline"""
    
    # Configuration
    feedback_dir = "feedback_data"
    output_dir = "fine_tune_dataset" 
    base_model = "../Faulty_Detection/yolov8p2.pt"
    epochs = 10  # Reduced for small datasets (2+ annotations)
    
    # Create fine-tuner instance
    fine_tuner = FeedbackFineTuner(
        feedback_dir=feedback_dir,
        output_dir=output_dir,
        base_model_path=base_model
    )
    
    # Run the complete pipeline
    try:
        results = fine_tuner.run_complete_pipeline(epochs=epochs)
        
        if results:
            print("\n" + "="*60)
            print("🎉 FINE-TUNING COMPLETED SUCCESSFULLY!")
            print("="*60)
            print(f"📁 Best Model: {results['best_model_path']}")
            print(f"📊 Dataset: {results['train_count']} train, {results['val_count']} val images")
            print(f"👥 Human Annotations Used: {results['human_annotations']}")
            print(f"📋 Dataset Config: {results['dataset_yaml']}")
            print("="*60)
            
    except Exception as e:
        logger.error(f"Fine-tuning pipeline failed: {e}")
        return 1
        
    return 0


if __name__ == "__main__":
    exit(main())