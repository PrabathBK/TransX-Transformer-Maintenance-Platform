#!/usr/bin/env python3
"""
TransX ML Service - Phase 2 & 3
Python Flask service for YOLOv8 anomaly detection with similarity-based comparison
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
import os

# Add paths to import the similarity system
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Faulty_Detection'))

# Setup logging first
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Import similarity-based YOLO system
try:
    from similarity_yolo_system import SimilarityBasedYOLOSystem
    SIMILARITY_SYSTEM_AVAILABLE = True
    logger.info("✅ Similarity-based YOLO system imported successfully")
except ImportError as e:
    SIMILARITY_SYSTEM_AVAILABLE = False
    logger.warning(f"⚠️ Could not import similarity system: {e}")
    logger.warning("Falling back to single image inference")

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

# Similarity system instance
similarity_system = None

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


def load_similarity_system():
    """Initialize similarity-based YOLO system with Flask-safe configuration"""
    global similarity_system
    
    if similarity_system is None and SIMILARITY_SYSTEM_AVAILABLE:
        try:
            # Find the best model path for similarity system
            selected_model_path = None
            for path in MODEL_PATHS:
                model_file = Path(path)
                if model_file.exists():
                    selected_model_path = str(model_file)
                    break
            
            if selected_model_path is None:
                raise FileNotFoundError(f"No model found for similarity system! Searched paths: {MODEL_PATHS}")
            
            # Initialize with default parameters
            similarity_system = SimilarityBasedYOLOSystem(
                similarity_threshold=0.5,  # Default threshold for similarity
                change_threshold=0.2,      # Default threshold for significance
                model_path=selected_model_path
            )
            
            # Patch the visualization method to prevent GUI issues in Flask
            def dummy_visualization(*args, **kwargs):
                """Dummy visualization that returns None to avoid matplotlib GUI threading issues"""
                return None
                
            similarity_system.create_comparison_visualization = dummy_visualization
            logger.info(f"✅ Similarity-based YOLO system initialized (Flask-safe) with model: {selected_model_path}")
            return similarity_system
            
        except Exception as e:
            logger.error(f"❌ Failed to initialize similarity system: {e}")
            raise
    
    return similarity_system


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
    """Health check endpoint with similarity system status"""
    try:
        model_loaded = model is not None
        model_path_exists = Path(MODEL_PATH).exists() if MODEL_PATH else False
        similarity_loaded = similarity_system is not None
        
        return jsonify({
            'status': 'healthy',
            'model_loaded': model_loaded,
            'model_path': MODEL_PATH,
            'model_path_exists': model_path_exists,
            'similarity_system_available': SIMILARITY_SYSTEM_AVAILABLE,
            'similarity_system_loaded': similarity_loaded,
            'service': 'TransX ML Service with Similarity Engine',
            'version': '2.0.0',
            'features': [
                'Standard YOLOv8 inference',
                'Similarity-based comparison' if SIMILARITY_SYSTEM_AVAILABLE else 'Similarity system unavailable',
                'Configurable thresholds',
                'Smart detection filtering'
            ]
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 500


@app.route('/api/detect', methods=['POST'])
def detect_anomalies():
    """
    Main detection endpoint using similarity-based YOLO system
    
    Request JSON:
    {
        "inspection_image_path": "/absolute/path/to/inspection.jpg",
        "baseline_image_path": "/absolute/path/to/baseline.jpg",  // optional but recommended
        "confidence_threshold": 0.25  # threshold as decimal (0.0-1.0)
    }
    
    Response JSON:
    {
        "success": true,
        "detections": [...],
        "image_dimensions": {...},
        "inference_time_ms": 245.3,
        "model_info": {...},
        "similarity_analysis": {...}
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
        
        # Get parameters
        inspection_image_path = data.get('inspection_image_path') or data.get('image_path')  # backward compatibility
        baseline_image_path = data.get('baseline_image_path')
        confidence_threshold = data.get('confidence_threshold', 0.25)
        
        # Debug prints
        logger.info("🔍 === SIMILARITY-BASED ANOMALY DETECTION ===")
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
        
        # Read inspection image to get dimensions
        img = cv2.imread(str(inspection_file))
        if img is None:
            return jsonify({
                'success': False,
                'error': f'Could not read inspection image: {inspection_image_path}'
            }), 400
        
        height, width = img.shape[:2]
        logger.info(f"📐 Image dimensions: {width}x{height}")
        
        import time
        start_time = time.time()
        
        # Choose inference method based on baseline availability
        if baseline_image_path and SIMILARITY_SYSTEM_AVAILABLE:
            # Use similarity-based YOLO system
            logger.info("🎯 === SIMILARITY-BASED YOLO MODE ===")
            logger.info("Running advanced comparison analysis...")
            
            try:
                # Initialize similarity system if needed
                sim_system = load_similarity_system()
                
                # Run similarity-based analysis (disable visualization to prevent GUI threading issues)
                results = sim_system.analyze_image_pair(
                    baseline_image_path,  # reference image
                    inspection_image_path,  # target image
                    verbose=False  # Disable verbose to avoid matplotlib GUI issues in Flask
                )
                
                # Extract detections from similarity system results
                detections = []
                yolo_analysis = results.get('yolo_analysis', {})
                target_detections = yolo_analysis.get('target_detections', [])
                
                if target_detections:
                    logger.info(f"🎯 Similarity system found {len(target_detections)} detections")
                    
                    for detection in target_detections:
                        # Convert from similarity system format to API format
                        conf = detection['confidence']
                        
                        # Only include detections above threshold
                        if conf >= confidence_threshold:
                            class_name = detection.get('className', detection.get('class_name', 'unknown'))
                            bbox = detection['bbox']
                            
                            # Map class name to class ID
                            class_id = None
                            for cid, cname in CLASS_NAMES.items():
                                if cname.lower() == class_name.lower():
                                    class_id = cid
                                    break
                            
                            if class_id is None:
                                # Try to find partial match or default
                                class_id = 0  # Default to 'Faulty'
                                for cid, cname in CLASS_NAMES.items():
                                    if class_name.lower() in cname.lower() or cname.lower() in class_name.lower():
                                        class_id = cid
                                        break
                            
                            detection_obj = {
                                'id': str(uuid.uuid4()),
                                'classId': class_id,
                                'className': CLASS_NAMES.get(class_id, class_name),
                                'confidence': round(conf, 3),
                                'bbox': {
                                    'x1': bbox['x1'],
                                    'y1': bbox['y1'],
                                    'x2': bbox['x2'],
                                    'y2': bbox['y2']
                                },
                                'color': CLASS_COLORS.get(class_id, [255, 255, 255]),
                                'source': 'similarity_ai'
                            }
                            detections.append(detection_obj)
                            
                            logger.info(f"✅ Detection: {detection_obj['className']} @ ({bbox['x1']},{bbox['y1']},{bbox['x2']},{bbox['y2']}) conf={conf:.3f}")
                
                # Calculate inference time
                inference_time = (time.time() - start_time) * 1000
                
                # Build enhanced response with similarity analysis
                similarity_data = results.get('similarity_analysis', {})
                combined_data = results.get('combined_analysis', {})
                
                response = {
                    'success': True,
                    'detections': detections,
                    'image_dimensions': {
                        'width': width,
                        'height': height
                    },
                    'inference_time_ms': round(inference_time, 2),
                    'model_info': {
                        'type': 'SimilarityBasedYOLO',
                        'classes': CLASS_NAMES,
                        'engine': 'similarity_yolo_system.py'
                    },
                    'similarity_analysis': {
                        'is_similar': similarity_data.get('is_similar', False),
                        'confidence': similarity_data.get('confidence', 0.0),
                        'method': similarity_data.get('best_method', 'unknown'),
                        'change_detected': combined_data.get('significant_change', False),
                        'change_magnitude': combined_data.get('change_magnitude', 0.0)
                    }
                }
                
                logger.info(f"✅ Similarity-based detection completed: {len(detections)} anomalies found in {inference_time:.1f}ms")
                logger.info(f"   Similarity: {similarity_data.get('confidence', 0.0):.1%}, Change detected: {combined_data.get('significant_change', False)}")
                
                return jsonify(response), 200
                
            except Exception as e:
                logger.error(f"❌ Similarity system failed, falling back to single image: {e}")
                # Fall through to single image detection
        
        # Fallback: Single image inference (when no baseline or similarity system failed)
        logger.info("🎯 === SINGLE IMAGE INFERENCE MODE ===")
        logger.info("Using standard YOLOv8 detection...")
        
        # Load standard model
        model = load_model()
        
        # Run YOLOv8 inference
        logger.info(f"🔄 Running YOLOv8 inference with confidence threshold: {confidence_threshold}")
        results = model(str(inspection_file), conf=confidence_threshold, verbose=False)
        result = results[0]
        
        # Process detections
        detections = []
        boxes = result.boxes
        
        if boxes is not None and len(boxes) > 0:
            logger.info(f"🎯 Found {len(boxes)} detections")
            
            for i, box in enumerate(boxes):
                conf = float(box.conf[0].cpu().numpy())
                cls = int(box.cls[0].cpu().numpy())
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int).tolist()
                
                detection_obj = {
                    'id': str(uuid.uuid4()),
                    'classId': cls,
                    'className': CLASS_NAMES.get(cls, f'Class_{cls}'),
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
                
                logger.info(f"✅ Detection: {detection_obj['className']} @ ({x1},{y1},{x2},{y2}) conf={conf:.3f}")
        else:
            logger.info("ℹ️ No anomalies detected")
        
        # Calculate inference time
        inference_time = (time.time() - start_time) * 1000
        
        # Build standard response
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
        
        logger.info(f"✅ Standard detection completed: {len(detections)} anomalies found in {inference_time:.1f}ms")
        
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
    logger.info("=" * 80)
    logger.info("🚀 Starting TransX ML Service with Similarity-Based YOLOv8p2")
    logger.info("=" * 80)
    logger.info("🔍 Looking for YOLOv8p2 models in priority order:")
    for i, path in enumerate(MODEL_PATHS, 1):
        exists = "✅" if Path(path).exists() else "❌"
        logger.info(f"   {i}. {path} {exists}")
    logger.info(f"📋 Classes: {CLASS_NAMES}")
    logger.info(f"🔧 Similarity System Available: {'✅' if SIMILARITY_SYSTEM_AVAILABLE else '❌'}")
    logger.info("=" * 80)
    
    # Preload components on startup
    try:
        load_model()
        logger.info(f"✅ Standard model preloaded from: {MODEL_PATH}")
    except Exception as e:
        logger.error(f"⚠️  Could not preload standard model: {e}")
    
    if SIMILARITY_SYSTEM_AVAILABLE:
        try:
            load_similarity_system()
            logger.info("✅ Similarity-based YOLO system preloaded")
        except Exception as e:
            logger.error(f"⚠️  Could not preload similarity system: {e}")
    
    # Start Flask server
    logger.info("🌟 Server Features:")
    logger.info("   • Single image inference (standard YOLOv8)")
    logger.info("   • Similarity-based comparison (with baseline)")
    logger.info("   • Configurable confidence thresholds")
    logger.info("   • Smart detection filtering")
    logger.info("Starting Flask server on http://0.0.0.0:5001")
    app.run(host='0.0.0.0', port=5001, debug=True)
