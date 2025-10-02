#!/usr/bin/env python3
"""
TransX ML Service - Phase 2 & 3
Python Flask service for YOLOv8 anomaly detection
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
import torch
import cv2
import numpy as np
from pathlib import Path
import uuid
import logging
import sys

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Model configuration - Updated to use YOLOv8p2 weights
MODEL_PATHS = [
    "../Faulty_Detection/yolov8p2.pt",  # Your new YOLOv8p2 weights
    "/home/jaliya/model/runs/detect/yolov8p2_train/weights/best.pt",
    "/home/jaliya/model/runs/detect/yolov8p2_train/weights/last.pt",
    "/home/jaliya/model/runs/detect/yolov8p2_high_performance/weights/best.pt",
    "/home/jaliya/model/runs/detect/yolov8p2_quick/weights/best.pt",
    "/home/jaliya/model/runs/detect/train4/weights/best.pt",
    "/home/jaliya/model/runs/detect/train4/weights/last.pt",
    "../Faulty_Detection/yolov8n.pt",  # Fallback to original
    "yolov8s.pt"  # Final fallback to pretrained
]
MODEL_PATH = None  # Will be determined dynamically
model = None

# Class mapping from rules.txt
CLASS_NAMES = {
    0: 'Faulty',
    1: 'faulty_loose_joint',
    2: 'faulty_point_overload',
    3: 'potential_faulty'
}

# Color mapping for visualization (RGB for JSON response)
CLASS_COLORS = {
    0: [255, 0, 0],      # Red - Faulty
    1: [0, 255, 0],      # Green - faulty_loose_joint
    2: [0, 0, 255],      # Blue - faulty_point_overload
    3: [255, 255, 0]     # Yellow - potential_faulty
}


def patch_torch_load():
    """Apply PyTorch compatibility patch for weights_only parameter"""
    original_load = torch.load
    
    def patched_load(f, map_location=None, pickle_module=None, weights_only=None, **kwargs):
        # Force weights_only=False for .pt files
        if isinstance(f, (str, Path)):
            if str(f).endswith('.pt'):
                weights_only = False
        elif hasattr(f, 'name') and f.name.endswith('.pt'):
            weights_only = False
        
        return original_load(
            f, 
            map_location=map_location, 
            pickle_module=pickle_module, 
            weights_only=weights_only, 
            **kwargs
        )
    
    torch.load = patched_load
    logger.info("PyTorch compatibility patch applied")


def load_model():
    """Load YOLOv8p2 model with dynamic path selection (lazy loading, keeps in memory)"""
    global model, MODEL_PATH
    
    if model is None:
        try:
            # Apply PyTorch patch first
            patch_torch_load()
            
            # Find the best available model (same logic as yolov8p2_single_inference.py)
            selected_model_path = None
            for path in MODEL_PATHS:
                model_file = Path(path)
                if model_file.exists():
                    selected_model_path = str(model_file)
                    break
            
            if selected_model_path is None:
                raise FileNotFoundError(f"No YOLOv8p2 model found! Searched paths: {MODEL_PATHS}")
            
            MODEL_PATH = selected_model_path  # Update global for reference
            
            logger.info(f"🔍 Found YOLOv8p2 model: {MODEL_PATH}")
            if "yolov8p2.pt" in MODEL_PATH:
                logger.info("🎯 Using your custom YOLOv8p2 weights!")
            elif "runs/detect" in MODEL_PATH:
                logger.info("🎯 Using trained YOLOv8p2 model from training runs")
            else:
                logger.info("⚠️  Using fallback YOLOv8 model")
            
            model = YOLO(MODEL_PATH)
            logger.info("✅ YOLOv8p2 model loaded successfully!")
            
        except Exception as e:
            logger.error(f"❌ Failed to load model: {e}")
            raise
    
    return model


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        model_loaded = model is not None
        model_path_exists = Path(MODEL_PATH).exists()
        
        return jsonify({
            'status': 'healthy',
            'model_loaded': model_loaded,
            'model_path': MODEL_PATH,
            'model_path_exists': model_path_exists,
            'service': 'TransX ML Service',
            'version': '1.0.0'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 500


@app.route('/api/detect', methods=['POST'])
def detect_anomalies():
    """
    Main detection endpoint for anomaly detection with baseline comparison
    
    Request JSON:
    {
        "inspection_image_path": "/absolute/path/to/inspection.jpg",
        "baseline_image_path": "/absolute/path/to/baseline.jpg",  // optional
        "confidence_threshold": 0.25  # optional
    }
    
    Response JSON:
    {
        "success": true,
        "detections": [...],
        "image_dimensions": {...},
        "inference_time_ms": 245.3,
        "model_info": {...}
    }
    """
    try:
        # Parse request
        data = request.json
        if not data:
            return jsonify({
                'success': False,
                'error': 'No JSON data provided'
            }), 400
        
        # Get both image paths
        inspection_image_path = data.get('inspection_image_path') or data.get('image_path')  # backward compatibility
        baseline_image_path = data.get('baseline_image_path')
        confidence_threshold = data.get('confidence_threshold', 0.25)
        
        # Debug prints
        logger.info("🔍 === ANOMALY DETECTION DEBUG ===")
        logger.info(f"📥 Inspection Image: {inspection_image_path}")
        logger.info(f"📥 Baseline Image: {baseline_image_path}")
        logger.info(f"🎯 Confidence Threshold: {confidence_threshold}")
        
        if not inspection_image_path:
            return jsonify({
                'success': False,
                'error': 'inspection_image_path is required'
            }), 400
        
        # Verify inspection image exists
        inspection_file = Path(inspection_image_path)
        if not inspection_file.exists():
            logger.error(f"❌ Inspection image not found: {inspection_image_path}")
            return jsonify({
                'success': False,
                'error': f'Inspection image file not found: {inspection_image_path}'
            }), 404
        
        # Verify baseline image if provided
        if baseline_image_path:
            baseline_file = Path(baseline_image_path)
            if not baseline_file.exists():
                logger.warning(f"⚠️ Baseline image not found: {baseline_image_path}")
                baseline_image_path = None
            else:
                logger.info(f"✅ Baseline image found: {baseline_image_path}")
        else:
            logger.info("ℹ️ No baseline image provided")
        
        logger.info(f"🔄 Processing anomaly detection...")
        
        # Read inspection image to get dimensions
        img = cv2.imread(str(inspection_file))
        if img is None:
            return jsonify({
                'success': False,
                'error': f'Could not read inspection image: {inspection_image_path}'
            }), 400
        
        height, width = img.shape[:2]
        logger.info(f"📐 Image dimensions: {width}x{height}")
        
        # Run real YOLOv8p2 inference on inspection image only
        logger.info("🎯 === REAL YOLOv8p2 INFERENCE MODE ===")
        logger.info(f"🔄 Running inference on inspection image: {inspection_file.name}")
        if baseline_image_path:
            logger.info(f"ℹ️  Baseline received but not used for inference (single image approach)")
        
        # Load model if not already loaded
        model = load_model()
        
        # Run YOLOv8 inference on inspection image only
        import time
        start_time = time.time()
        
        logger.info(f"🎯 Running YOLOv8 inference with confidence threshold: {confidence_threshold}")
        results = model(str(inspection_file), conf=confidence_threshold, verbose=False)
        result = results[0]
        
        # Calculate inference time
        inference_time = (time.time() - start_time) * 1000
        
        # Process detections using same logic as yolov8p2_single_inference.py
        detections = []
        boxes = result.boxes
        
        if boxes is not None and len(boxes) > 0:
            logger.info(f"🎯 Raw detections found: {len(boxes)}")
            
            # Collect all detections with details (same as yolov8p2_single_inference.py)
            raw_detections = []
            for i, box in enumerate(boxes):
                conf = float(box.conf[0].cpu().numpy())
                cls = int(box.cls[0].cpu().numpy())
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int).tolist()
                
                raw_detections.append({
                    'index': i,
                    'confidence': conf,
                    'class_id': cls,
                    'bbox': [x1, y1, x2, y2]
                })
            
            # Sort by confidence (descending)
            raw_detections.sort(key=lambda x: x['confidence'], reverse=True)
            
            # Smart filtering: same logic as yolov8p2_single_inference.py
            if len(raw_detections) > 3:
                top_3 = raw_detections[:3]
                distances = []
                
                for i in range(len(top_3)):
                    for j in range(i + 1, len(top_3)):
                        x1_center = (top_3[i]['bbox'][0] + top_3[i]['bbox'][2]) / 2
                        y1_center = (top_3[i]['bbox'][1] + top_3[i]['bbox'][3]) / 2
                        x2_center = (top_3[j]['bbox'][0] + top_3[j]['bbox'][2]) / 2
                        y2_center = (top_3[j]['bbox'][1] + top_3[j]['bbox'][3]) / 2
                        
                        distance = ((x1_center - x2_center)**2 + (y1_center - y2_center)**2)**0.5
                        distances.append(distance)
                
                avg_distance = sum(distances) / len(distances) if distances else 0
                max_distance = max(distances) if distances else 0
                
                logger.info(f"📏 Distance analysis: avg={avg_distance:.1f}, max={max_distance:.1f}")
                
                if avg_distance < 100 and max_distance < 150:
                    logger.info(f"🎯 Found {len(raw_detections)} detections, using top 3 (clustered)")
                    final_detections = raw_detections[:3]
                else:
                    logger.info(f"🎯 Found {len(raw_detections)} detections (spread apart, using all)")
                    final_detections = raw_detections
            else:
                final_detections = raw_detections
            
            # Convert to API format
            for detection in final_detections:
                conf = detection['confidence']
                cls = detection['class_id']
                x1, y1, x2, y2 = detection['bbox']
                
                detection_obj = {
                    'id': str(uuid.uuid4()),
                    'class_id': cls,
                    'class_name': CLASS_NAMES.get(cls, f'Class_{cls}'),
                    'confidence': round(conf, 3),
                    'bbox': {
                        'x1': x1,
                        'y1': y1,
                        'x2': x2,
                        'y2': y2
                    },
                    'color': CLASS_COLORS.get(cls, [255, 255, 255]),
                    'source': 'ai'
                }
                detections.append(detection_obj)
                
                logger.info(f"✅ Detection: {detection_obj['class_name']} @ ({x1},{y1},{x2},{y2}) conf={conf:.3f}")
        else:
            logger.info("ℹ️  No anomalies detected in inspection image")
        
        # Build response
        response = {
            'success': True,
            'detections': detections,
            'image_dimensions': {
                'width': width,
                'height': height
            },
            'inference_time_ms': round(inference_time, 2),
            'model_info': {
                'type': 'YOLOv8',
                'classes': CLASS_NAMES
            }
        }
        
        logger.info(f"✅ Detection completed: {len(detections)} anomalies found in {inference_time:.1f}ms")
        
        return jsonify(response), 200
        
    except Exception as e:
        logger.error(f"❌ Error during detection: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/classes', methods=['GET'])
def get_classes():
    """Get available detection classes"""
    return jsonify({
        'classes': CLASS_NAMES,
        'colors': CLASS_COLORS
    }), 200


if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("🚀 Starting TransX ML Service with YOLOv8p2")
    logger.info("=" * 60)
    logger.info("🔍 Looking for YOLOv8p2 models in priority order:")
    for i, path in enumerate(MODEL_PATHS, 1):
        logger.info(f"   {i}. {path}")
    logger.info(f"📋 Classes: {CLASS_NAMES}")
    logger.info("=" * 60)
    
    # Preload model on startup
    try:
        load_model()
        logger.info(f"✅ Model preloaded successfully from: {MODEL_PATH}")
    except Exception as e:
        logger.error(f"⚠️  Could not preload model: {e}")
        logger.error("Model will be loaded on first request")
    
    # Start Flask server
    logger.info("Starting Flask server on http://0.0.0.0:5001")
    app.run(host='0.0.0.0', port=5001, debug=True)
