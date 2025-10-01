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

# Model configuration
MODEL_PATH = "../Faulty_Detection/yolov8n.pt"
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
    """Load YOLOv8 model (lazy loading, keeps in memory)"""
    global model
    
    if model is None:
        try:
            # Apply PyTorch patch first
            patch_torch_load()
            
            model_file = Path(MODEL_PATH)
            if not model_file.exists():
                raise FileNotFoundError(f"Model file not found: {MODEL_PATH}")
            
            logger.info(f"Loading YOLOv8 model from: {MODEL_PATH}")
            model = YOLO(str(model_file))
            logger.info("✅ YOLOv8 model loaded successfully!")
            
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
    Main detection endpoint
    
    Request JSON:
    {
        "image_path": "/absolute/path/to/image.jpg",
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
        
        image_path = data.get('image_path')
        confidence_threshold = data.get('confidence_threshold', 0.25)
        
        if not image_path:
            return jsonify({
                'success': False,
                'error': 'image_path is required'
            }), 400
        
        image_file = Path(image_path)
        if not image_file.exists():
            return jsonify({
                'success': False,
                'error': f'Image file not found: {image_path}'
            }), 404
        
        logger.info(f"Processing detection request: {image_path}")
        
        # Load model
        model = load_model()
        
        # Read image to get dimensions
        img = cv2.imread(str(image_file))
        if img is None:
            return jsonify({
                'success': False,
                'error': f'Could not read image: {image_path}'
            }), 400
        
        height, width = img.shape[:2]
        logger.info(f"Image dimensions: {width}x{height}")
        
        # Run inference
        logger.info(f"Running inference with confidence threshold: {confidence_threshold}")
        results = model(str(image_file), conf=confidence_threshold, verbose=False)
        result = results[0]
        
        # Process detections
        detections = []
        boxes = result.boxes
        
        if boxes is not None and len(boxes) > 0:
            logger.info(f"Found {len(boxes)} detections")
            
            for box in boxes:
                conf = float(box.conf[0].cpu().numpy())
                cls = int(box.cls[0].cpu().numpy())
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int).tolist()
                
                detection = {
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
                detections.append(detection)
                
                logger.debug(f"Detection: {detection['class_name']} @ ({x1},{y1},{x2},{y2}) conf={conf:.3f}")
        else:
            logger.info("No detections found")
        
        # Get inference time
        inference_time = 0
        if hasattr(result, 'speed') and result.speed:
            if isinstance(result.speed, dict):
                inference_time = sum(result.speed.values())
            else:
                inference_time = result.speed
        
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
    logger.info("🚀 Starting TransX ML Service")
    logger.info("=" * 60)
    logger.info(f"Model path: {MODEL_PATH}")
    logger.info(f"Classes: {CLASS_NAMES}")
    logger.info("=" * 60)
    
    # Preload model on startup
    try:
        load_model()
        logger.info("✅ Model preloaded successfully")
    except Exception as e:
        logger.error(f"⚠️  Could not preload model: {e}")
        logger.error("Model will be loaded on first request")
    
    # Start Flask server
    logger.info("Starting Flask server on http://0.0.0.0:5001")
    app.run(host='0.0.0.0', port=5001, debug=True)
