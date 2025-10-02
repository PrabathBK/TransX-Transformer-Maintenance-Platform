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
        
        # For debugging: Return mock anomalies without running actual ML inference
        logger.info("🧪 === DEBUG MODE: RETURNING MOCK ANOMALIES ===")
        
        # Create mock detections for testing
        detections = []
        
        # Mock anomaly 1: Top-left area
        mock_detection_1 = {
            'id': str(uuid.uuid4()),
            'class_id': 0,  # Faulty
            'class_name': 'Faulty',
            'confidence': 0.85,
            'bbox': {
                'x1': int(width * 0.1),   # 10% from left
                'y1': int(height * 0.1),  # 10% from top
                'x2': int(width * 0.3),   # 30% from left
                'y2': int(height * 0.3)   # 30% from top
            },
            'color': [255, 0, 0],  # Red
            'source': 'ai'
        }
        detections.append(mock_detection_1)
        
        # Mock anomaly 2: Center area (if baseline comparison shows difference)
        if baseline_image_path:
            mock_detection_2 = {
                'id': str(uuid.uuid4()),
                'class_id': 2,  # faulty_point_overload
                'class_name': 'faulty_point_overload',
                'confidence': 0.72,
                'bbox': {
                    'x1': int(width * 0.4),   # 40% from left
                    'y1': int(height * 0.4),  # 40% from top
                    'x2': int(width * 0.6),   # 60% from left
                    'y2': int(height * 0.6)   # 60% from top
                },
                'color': [0, 0, 255],  # Blue
                'source': 'ai'
            }
            detections.append(mock_detection_2)
            logger.info("🔍 Added extra anomaly due to baseline comparison")
        
        logger.info(f"🎯 Generated {len(detections)} mock anomalies for testing")
        for i, det in enumerate(detections):
            bbox = det['bbox']
            logger.info(f"   Mock Anomaly {i+1}: {det['class_name']} @ ({bbox['x1']},{bbox['y1']},{bbox['x2']},{bbox['y2']}) conf={det['confidence']}")
            
        # Mock inference time
        inference_time = 125.5
        
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
