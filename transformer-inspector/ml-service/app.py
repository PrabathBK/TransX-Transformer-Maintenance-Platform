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
import json
import threading
from datetime import datetime

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
    logger.info("Similarity-based YOLO system imported successfully")
except ImportError as e:
    SIMILARITY_SYSTEM_AVAILABLE = False
    logger.warning(f"Could not import similarity system: {e}")
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

# Auto fine-tuning configuration
AUTO_FINETUNE_ENABLED = True
AUTO_FINETUNE_THRESHOLD = 2  # Number of human annotations to trigger fine-tuning
finetune_queue = []  # Queue for managing fine-tuning requests


def count_total_human_annotations():
    """Count total human annotations across all feedback files"""
    feedback_dir = Path("feedback_data")
    if not feedback_dir.exists():
        return 0
        
    total_count = 0
    for feedback_file in feedback_dir.glob("feedback_*.json"):
        try:
            with open(feedback_file, 'r') as f:
                feedback = json.load(f)
                for comparison in feedback.get('comparisons', []):
                    if comparison.get('humanAnnotation'):
                        total_count += 1
        except Exception as e:
            logger.error(f"Error counting annotations in {feedback_file}: {e}")
            
    return total_count


def check_auto_finetune_trigger(new_human_annotations):
    """Check if automatic fine-tuning should be triggered"""
    if not AUTO_FINETUNE_ENABLED:
        return
        
    total_annotations = count_total_human_annotations()
    
    logger.info(f"🤖 Auto fine-tuning check:")
    logger.info(f"   - New human annotations: {new_human_annotations}")
    logger.info(f"   - Total human annotations: {total_annotations}")
    logger.info(f"   - Threshold: {AUTO_FINETUNE_THRESHOLD}")
    
    if total_annotations >= AUTO_FINETUNE_THRESHOLD:
        logger.info("🚀 Auto fine-tuning threshold reached! Queuing fine-tuning...")
        queue_finetune_task()
    else:
        remaining = AUTO_FINETUNE_THRESHOLD - total_annotations
        logger.info(f"⏳ Need {remaining} more human annotations to trigger fine-tuning")


def queue_finetune_task():
    """Queue a fine-tuning task to run in background"""
    import threading
    
    task_id = f"finetune_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    finetune_queue.append({
        'id': task_id,
        'status': 'queued',
        'created_at': datetime.now().isoformat(),
        'started_at': None,
        'completed_at': None,
        'error': None
    })
    
    # Start fine-tuning in background thread
    def run_background_finetune():
        try:
            # Update status
            for task in finetune_queue:
                if task['id'] == task_id:
                    task['status'] = 'running'
                    task['started_at'] = datetime.now().isoformat()
                    break
                    
            logger.info(f"🚀 Starting background fine-tuning: {task_id}")
            logger.info("🔄 Training runs in background - other images can still be processed")
            
            # Import and run fine-tuning (lazy import to avoid startup issues)
            from fine_tune_with_feedback import FeedbackFineTuner
            
            fine_tuner = FeedbackFineTuner(
                feedback_dir="feedback_data",
                output_dir="auto_finetune_dataset",
                base_model_path="../Faulty_Detection/yolov8p2.pt"
            )
            

            results = fine_tuner.run_complete_pipeline(epochs=5)
            
            # Update status
            for task in finetune_queue:
                if task['id'] == task_id:
                    task['status'] = 'completed' if results else 'failed'
                    task['completed_at'] = datetime.now().isoformat()
                    task['results'] = results
                    break
                    
            if results:
                logger.info(f"🎉 Background fine-tuning completed: {task_id}")
                logger.info(f"📁 Training model: {results['best_model_path']}")
                if 'production_model_path' in results:
                    logger.info(f"🚀 Production model: {results['production_model_path']}")
                    logger.info(f"🔄 Model deployed - next fine-tuning will use improved version")
            else:
                logger.error(f"❌ Background fine-tuning failed: {task_id}")
                
        except Exception as e:
            logger.error(f"❌ Fine-tuning error for {task_id}: {e}")
            # Update status
            for task in finetune_queue:
                if task['id'] == task_id:
                    task['status'] = 'failed'
                    task['completed_at'] = datetime.now().isoformat()
                    task['error'] = str(e)
                    break
    
    # Start background thread
    thread = threading.Thread(target=run_background_finetune, daemon=True)
    thread.start()
    
    logger.info(f"📋 Fine-tuning task queued: {task_id}")


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
            logger.info("Similarity-based YOLO system initialized (Flask-safe) with model: {selected_model_path}")
            return similarity_system
            
        except Exception as e:
            logger.error(f"Failed to initialize similarity system: {e}")
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
            
            logger.info("Found YOLOv8p2 model: {MODEL_PATH}")
            if "yolov8p2.pt" in MODEL_PATH:
                logger.info("Using your custom YOLOv8p2 weights!")
            elif "runs/detect" in MODEL_PATH:
                logger.info("Using trained YOLOv8p2 model from training runs")
            else:
                logger.info("Using fallback YOLOv8 model")
            
            model = YOLO(MODEL_PATH)
            logger.info("YOLOv8p2 model loaded successfully!")
            
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
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
        logger.info("SIMILARITY-BASED ANOMALY DETECTION")
        logger.info(f"Inspection Image: {inspection_image_path}")
        logger.info(f"Baseline Image: {baseline_image_path}")
        logger.info(f"Confidence Threshold: {confidence_threshold}")
        
        if not inspection_image_path:
            return jsonify({
                'success': False,
                'error': 'inspection_image_path is required'
            }), 400
        
        # Verify inspection image exists
        inspection_file = Path(inspection_image_path)
        if not inspection_file.exists():
            logger.error(f"Inspection image not found: {inspection_image_path}")
            return jsonify({
                'success': False,
                'error': f'Inspection image file not found: {inspection_image_path}'
            }), 404
        
        # Verify baseline image if provided
        if baseline_image_path:
            baseline_file = Path(baseline_image_path)
            if not baseline_file.exists():
                logger.warning(f"Baseline image not found: {baseline_image_path}")
                baseline_image_path = None
            else:
                logger.info(f"Baseline image found: {baseline_image_path}")
        
        # Read inspection image to get dimensions
        img = cv2.imread(str(inspection_file))
        if img is None:
            return jsonify({
                'success': False,
                'error': f'Could not read inspection image: {inspection_image_path}'
            }), 400
        
        height, width = img.shape[:2]
        logger.info(f"Image dimensions: {width}x{height}")
        
        import time
        start_time = time.time()
        
        # Choose inference method based on baseline availability
        if baseline_image_path and SIMILARITY_SYSTEM_AVAILABLE:
            # Use similarity-based YOLO system
            logger.info("SIMILARITY-BASED YOLO MODE")
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
                    logger.info(f"Similarity system found {len(target_detections)} detections")
                    
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
                            
                            logger.info(f"Detection: {detection_obj['className']} @ ({bbox['x1']},{bbox['y1']},{bbox['x2']},{bbox['y2']}) conf={conf:.3f}")
                
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
                
                logger.info(f"Similarity-based detection completed: {len(detections)} anomalies found in {inference_time:.1f}ms")
                logger.info(f"   Similarity: {similarity_data.get('confidence', 0.0):.1%}, Change detected: {combined_data.get('significant_change', False)}")
                
                return jsonify(response), 200
                
            except Exception as e:
                logger.error(f"Similarity system failed, falling back to single image: {e}")
                # Fall through to single image detection
        
        # Fallback: Single image inference (when no baseline or similarity system failed)
        logger.info("SINGLE IMAGE INFERENCE MODE")
        logger.info("Using standard YOLOv8 detection...")
        
        # Load standard model
        model = load_model()
        
        # Run YOLOv8 inference
        logger.info(f"Running YOLOv8 inference with confidence threshold: {confidence_threshold}")
        results = model(str(inspection_file), conf=confidence_threshold, verbose=False)
        result = results[0]
        
        # Process detections
        detections = []
        boxes = result.boxes
        
        if boxes is not None and len(boxes) > 0:
            logger.info(f"Found {len(boxes)} detections")
            
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
                
                logger.info(f"Detection: {detection_obj['className']} @ ({x1},{y1},{x2},{y2}) conf={conf:.3f}")
        else:
            logger.info("No anomalies detected")
        
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
        
        logger.info(f"Standard detection completed: {len(detections)} anomalies found in {inference_time:.1f}ms")
        
        return jsonify(response), 200
        
    except Exception as e:
        logger.error(f"Error during detection: {e}", exc_info=True)
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


@app.route('/api/feedback/upload', methods=['POST'])
def upload_feedback():
    """
    Upload feedback data for model fine-tuning (Phase 3 - FR3.3)
    Accepts JSON feedback export from backend
    
    Expected JSON format:
    {
        "inspectionId": "uuid",
        "inspectionNumber": "string",
        "transformerCode": "string",
        "exportedAt": "timestamp",
        "comparisons": [...],
        "summary": {...}
    }
    """
    try:
        if not request.is_json:
            return jsonify({'error': 'Content-Type must be application/json'}), 400
        
        feedback_data = request.get_json()
        
        # Validate required fields
        required_fields = ['inspectionId', 'inspectionNumber', 'comparisons']
        for field in required_fields:
            if field not in feedback_data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        # Create feedback storage directory
        feedback_dir = Path('feedback_data')
        feedback_dir.mkdir(exist_ok=True)
        
        # Save feedback with timestamp
        inspection_id = feedback_data['inspectionId']
        feedback_file = feedback_dir / f"feedback_{inspection_id}.json"
        
        import json
        from datetime import datetime
        
        # Add received timestamp
        feedback_data['receivedAt'] = datetime.now().isoformat()
        
        # Analyze feedback data for human annotations
        comparisons = feedback_data.get('comparisons', [])
        human_annotation_count = 0
        ai_prediction_count = 0
        action_counts = {}
        
        # Extract image and inspection information
        inspection_id = feedback_data.get('inspectionId')
        inspection_number = feedback_data.get('inspectionNumber')
        transformer_code = feedback_data.get('transformerCode')
        exported_at = feedback_data.get('exportedAt')
        
        logger.info("=" * 60)
        logger.info("ANALYZING FEEDBACK DATA")
        logger.info("=" * 60)
        logger.info(f"Inspection ID: {inspection_id}")
        logger.info(f"Inspection Number: {inspection_number}")
        logger.info(f"Transformer Code: {transformer_code}")
        logger.info(f"Exported At: {exported_at}")
        logger.info("-" * 60)
        
        for i, comparison in enumerate(comparisons, 1):
            has_human = comparison.get('humanAnnotation') is not None
            has_ai = comparison.get('aiPrediction') is not None
            action = comparison.get('actionTaken', 'unknown')
            image_id = comparison.get('imageId')
            
            # Count actions
            action_counts[action] = action_counts.get(action, 0) + 1
            
            logger.info(f"Comparison {i}:")
            logger.info(f"  - Image ID: {image_id}")
            logger.info(f"  - Has AI Prediction: {has_ai}")
            logger.info(f"  - Has Human Annotation: {has_human}")
            logger.info(f"  - Action Taken: {action}")
            
            if has_human:
                human_annotation_count += 1
                human_ann = comparison['humanAnnotation']
                bbox = human_ann.get('bbox', {})
                
                logger.info(f"  🔴 HUMAN ANNOTATION DETECTED:")
                logger.info(f"    * Annotation ID: {human_ann.get('id')}")
                logger.info(f"    * Class Name: {human_ann.get('className')}")
                logger.info(f"    * Class ID: {human_ann.get('classId')}")
                logger.info(f"    * Coordinates: x1={bbox.get('x1')}, y1={bbox.get('y1')}, x2={bbox.get('x2')}, y2={bbox.get('y2')}")
                logger.info(f"    * Box Width: {bbox.get('x2', 0) - bbox.get('x1', 0)} pixels")
                logger.info(f"    * Box Height: {bbox.get('y2', 0) - bbox.get('y1', 0)} pixels")
                logger.info(f"    * Confidence: {human_ann.get('confidence')}")
                logger.info(f"    * Source: {human_ann.get('source')}")
                logger.info(f"    * Action Type: {human_ann.get('actionType')}")
                logger.info(f"    * Box Number: {human_ann.get('boxNumber')}")
                logger.info(f"    * Created By: {human_ann.get('createdBy')}")
                logger.info(f"    * Created At: {human_ann.get('createdAt')}")
                logger.info(f"    * Comments: {human_ann.get('comments')}")
            
            if has_ai:
                ai_prediction_count += 1
                ai_pred = comparison['aiPrediction']
                bbox = ai_pred.get('bbox', {})
                
                logger.info(f"  🤖 AI PREDICTION:")
                logger.info(f"    * Prediction ID: {ai_pred.get('id')}")
                logger.info(f"    * Class Name: {ai_pred.get('className')}")
                logger.info(f"    * Class ID: {ai_pred.get('classId')}")
                logger.info(f"    * Coordinates: x1={bbox.get('x1')}, y1={bbox.get('y1')}, x2={bbox.get('x2')}, y2={bbox.get('y2')}")
                logger.info(f"    * Box Width: {bbox.get('x2', 0) - bbox.get('x1', 0)} pixels")
                logger.info(f"    * Box Height: {bbox.get('y2', 0) - bbox.get('y1', 0)} pixels")
                logger.info(f"    * Confidence: {ai_pred.get('confidence')}")
                logger.info(f"    * Source: {ai_pred.get('source')}")
                logger.info(f"    * Action Type: {ai_pred.get('actionType')}")
                logger.info(f"    * Box Number: {ai_pred.get('boxNumber')}")
                logger.info(f"    * Created By: {ai_pred.get('createdBy')}")
                logger.info(f"    * Modified By: {ai_pred.get('modifiedBy')}")
                logger.info(f"    * Modified At: {ai_pred.get('modifiedAt')}")
            
            logger.info("")
        
        logger.info("FEEDBACK ANALYSIS SUMMARY:")
        logger.info(f"Total Comparisons: {len(comparisons)}")
        logger.info(f"Human Annotations Found: {human_annotation_count}")
        logger.info(f"AI Predictions Found: {ai_prediction_count}")
        logger.info(f"Action Breakdown: {action_counts}")
        
        # Check if human annotations exist
        has_human_annotations = human_annotation_count > 0
        logger.info(f"HUMAN ANNOTATIONS DETECTED: {'YES' if has_human_annotations else 'NO'}")
        
        if has_human_annotations:
            logger.info("🟢 This feedback contains human annotations - valuable for model training!")
        else:
            logger.info("🔵 This feedback contains only AI predictions - can be used for validation")
        
        # Extract all unique image IDs and try to get image paths
        unique_image_ids = set()
        for comparison in comparisons:
            image_id = comparison.get('imageId')
            if image_id:
                unique_image_ids.add(image_id)
        
        logger.info("-" * 60)
        logger.info("IMAGE INFORMATION EXTRACTION:")
        logger.info(f"Unique Image IDs found: {len(unique_image_ids)}")
        
        for image_id in unique_image_ids:
            logger.info(f"  📷 Image ID: {image_id}")
            # Try to construct potential image path (you may need to adjust this based on your backend structure)
            potential_paths = [
                f"/Users/jaliya/Desktop/Jaliya/Semester 7/Software/TransX-Transformer-Maintenance-Platform/transformer-inspector/backend/uploads/{inspection_id}/{image_id}.jpg",
                f"/Users/jaliya/Desktop/Jaliya/Semester 7/Software/TransX-Transformer-Maintenance-Platform/transformer-inspector/backend/uploads/{inspection_id}/{image_id}.png",
                f"./uploads/{inspection_id}/{image_id}.jpg",
                f"./uploads/{inspection_id}/{image_id}.png"
            ]
            
            image_found = False
            for path in potential_paths:
                if Path(path).exists():
                    logger.info(f"     ✅ Found image at: {path}")
                    image_found = True
                    break
            
            if not image_found:
                logger.info(f"     ❌ Image not found in expected locations")
                for path in potential_paths[:2]:  # Log first 2 paths tried
                    logger.info(f"        Tried: {path}")
        
        # Create detailed annotation summary
        logger.info("-" * 60)
        logger.info("ANNOTATION COORDINATES SUMMARY:")
        
        human_annotations = []
        ai_predictions = []
        
        for i, comparison in enumerate(comparisons, 1):
            if comparison.get('humanAnnotation'):
                human_ann = comparison['humanAnnotation']
                bbox = human_ann.get('bbox', {})
                human_annotations.append({
                    'comparison_index': i,
                    'image_id': comparison.get('imageId'),
                    'annotation_id': human_ann.get('id'),
                    'class_name': human_ann.get('className'),
                    'class_id': human_ann.get('classId'),
                    'coordinates': bbox,
                    'confidence': human_ann.get('confidence'),
                    'created_by': human_ann.get('createdBy'),
                    'action': comparison.get('actionTaken')
                })
            
            if comparison.get('aiPrediction'):
                ai_pred = comparison['aiPrediction']
                bbox = ai_pred.get('bbox', {})
                ai_predictions.append({
                    'comparison_index': i,
                    'image_id': comparison.get('imageId'),
                    'prediction_id': ai_pred.get('id'),
                    'class_name': ai_pred.get('className'),
                    'class_id': ai_pred.get('classId'),
                    'coordinates': bbox,
                    'confidence': ai_pred.get('confidence'),
                    'action': comparison.get('actionTaken')
                })
        
        if human_annotations:
            logger.info(f"🔴 HUMAN ANNOTATIONS ({len(human_annotations)}):")
            for ann in human_annotations:
                bbox = ann['coordinates']
                logger.info(f"  [{ann['comparison_index']}] {ann['class_name']} (ID:{ann['class_id']}) - "
                           f"({bbox.get('x1')},{bbox.get('y1')}) to ({bbox.get('x2')},{bbox.get('y2')}) - "
                           f"Action: {ann['action']} - By: {ann['created_by']}")
        
        if ai_predictions:
            logger.info(f"🤖 AI PREDICTIONS ({len(ai_predictions)}):")
            for pred in ai_predictions:
                bbox = pred['coordinates']
                logger.info(f"  [{pred['comparison_index']}] {pred['class_name']} (ID:{pred['class_id']}) - "
                           f"({bbox.get('x1')},{bbox.get('y1')}) to ({bbox.get('x2')},{bbox.get('y2')}) - "
                           f"Conf: {pred['confidence']:.3f} - Action: {pred['action']}")
        
        logger.info("=" * 60)
        
        with open(feedback_file, 'w') as f:
            json.dump(feedback_data, f, indent=2)
        
        logger.info(f"Feedback saved: {feedback_file}")
        logger.info(f"Total comparisons: {len(feedback_data.get('comparisons', []))}")
        
        summary = feedback_data.get('summary', {})
        logger.info(f"Summary - AI: {summary.get('totalAiDetections', 0)}, "
                   f"Human: {summary.get('totalHumanAnnotations', 0)}, "
                   f"Approved: {summary.get('approved', 0)}, "
                   f"Rejected: {summary.get('rejected', 0)}")
        
        # Check if we should trigger automatic fine-tuning
        if has_human_annotations:
            logger.info("🤖 Checking auto fine-tuning conditions...")
            check_auto_finetune_trigger(human_annotation_count)
        
        return jsonify({
            'status': 'success',
            'message': 'Feedback data received successfully',
            'inspectionId': inspection_id,
            'feedbackFile': str(feedback_file),
            'comparisonsCount': len(feedback_data.get('comparisons', [])),
            'summary': summary,
            'note': 'This data can be used for model fine-tuning. See feedback_data directory.'
        }), 200
        
    except Exception as e:
        logger.error(f"Error uploading feedback: {e}")
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500


@app.route('/api/finetune/trigger', methods=['POST'])
def trigger_manual_finetune():
    """Manually trigger fine-tuning process"""
    try:
        logger.info("📝 Manual fine-tuning trigger requested")
        
        # Check if there are human annotations available
        total_annotations = count_total_human_annotations()
        
        if total_annotations == 0:
            return jsonify({
                'error': 'No human annotations available for fine-tuning',
                'human_annotations': 0
            }), 400
        
        # Queue the fine-tuning task
        queue_finetune_task()
        
        return jsonify({
            'message': 'Fine-tuning queued successfully',
            'human_annotations': total_annotations,
            'queue_length': len(finetune_queue),
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error triggering manual fine-tuning: {e}")
        return jsonify({
            'error': 'Failed to trigger fine-tuning',
            'details': str(e)
        }), 500


@app.route('/api/finetune/status', methods=['GET'])
def get_finetune_status():
    """Get current fine-tuning status"""
    try:
        total_annotations = count_total_human_annotations()
        
        # Check if training is currently running
        training_in_progress = any(task['status'] == 'running' for task in finetune_queue)
        
        return jsonify({
            'auto_finetune_enabled': AUTO_FINETUNE_ENABLED,
            'threshold': AUTO_FINETUNE_THRESHOLD,
            'total_human_annotations': total_annotations,
            'annotations_needed': max(0, AUTO_FINETUNE_THRESHOLD - total_annotations),
            'training_in_progress': training_in_progress,
            'background_processing': True,  # Always runs in background
            'detection_available': True,   # Detection is always available during training
            'queue': finetune_queue,
            'queue_length': len(finetune_queue),
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error getting fine-tuning status: {e}")
        return jsonify({
            'error': 'Failed to get status',
            'details': str(e)
        }), 500


@app.route('/api/finetune/config', methods=['POST'])
def update_finetune_config():
    """Update fine-tuning configuration"""
    try:
        global AUTO_FINETUNE_ENABLED, AUTO_FINETUNE_THRESHOLD
        
        data = request.get_json()
        
        if 'enabled' in data:
            AUTO_FINETUNE_ENABLED = bool(data['enabled'])
            logger.info(f"Auto fine-tuning {'enabled' if AUTO_FINETUNE_ENABLED else 'disabled'}")
            
        if 'threshold' in data:
            threshold = int(data['threshold'])
            if threshold > 0:
                AUTO_FINETUNE_THRESHOLD = threshold
                logger.info(f"Auto fine-tuning threshold set to {AUTO_FINETUNE_THRESHOLD}")
            else:
                return jsonify({'error': 'Threshold must be positive'}), 400
        
        return jsonify({
            'message': 'Configuration updated',
            'auto_finetune_enabled': AUTO_FINETUNE_ENABLED,
            'threshold': AUTO_FINETUNE_THRESHOLD,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error updating fine-tuning config: {e}")
        return jsonify({
            'error': 'Failed to update configuration',
            'details': str(e)
        }), 500


if __name__ == '__main__':
    logger.info("=" * 80)
    logger.info("Starting TransX ML Service with Similarity-Based YOLOv8p2")
    logger.info("=" * 80)
    logger.info("Looking for YOLOv8p2 models in priority order:")
    for i, path in enumerate(MODEL_PATHS, 1):
        exists = "Yes" if Path(path).exists() else "No"
        logger.info(f"   {i}. {path} {exists}")
    logger.info(f"Classes: {CLASS_NAMES}")
    logger.info(f"Similarity System Available: {'Yes' if SIMILARITY_SYSTEM_AVAILABLE else 'No'}")
    logger.info("=" * 80)
    
    # Preload components on startup
    try:
        load_model()
        logger.info("Standard model preloaded from: {MODEL_PATH}")
    except Exception as e:
        logger.error(f"Could not preload standard model: {e}")
    
    if SIMILARITY_SYSTEM_AVAILABLE:
        try:
            load_similarity_system()
            logger.info("Similarity-based YOLO system preloaded")
        except Exception as e:
            logger.error(f"Could not preload similarity system: {e}")
    
    # Start Flask server
    logger.info("Server Features:")
    logger.info("Single image inference (standard YOLOv8)")
    logger.info("Similarity-based comparison (with baseline)")
    logger.info("Configurable confidence thresholds")
    logger.info("Smart detection filtering")
    logger.info("Feedback upload for model fine-tuning (FR3.3)")
    logger.info("Starting Flask server on http://0.0.0.0:5001")
    app.run(host='0.0.0.0', port=5001, debug=True)
