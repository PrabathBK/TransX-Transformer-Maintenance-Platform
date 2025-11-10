# ML Service Architecture Guide - TransX Platform
### Teaching Guide for Phase 4: ML Service Architecture (2-3 days)

---

## 📚 Table of Contents
1. [What is the ML Service?](#1-what-is-the-ml-service)
2. [Technology Stack](#2-technology-stack)
3. [System Architecture](#3-system-architecture)
4. [Core Components](#4-core-components)
5. [Request Flow](#5-request-flow)
6. [YOLOv8 Integration](#6-yolov8-integration)
7. [Auto Fine-Tuning System](#7-auto-fine-tuning-system)
8. [API Endpoints](#8-api-endpoints)
9. [Hands-On Examples](#9-hands-on-examples)
10. [Teaching Session Plan](#10-teaching-session-plan)

---

## 1. What is the ML Service?

### 🎯 Purpose
The ML Service is a **Python Flask microservice** that provides AI-powered thermal anomaly detection for transformer inspections using YOLOv8 (You Only Look Once version 8).

### 🔑 Key Responsibilities
- **Anomaly Detection**: Identify thermal faults in transformer images
- **Similarity Analysis**: Compare inspection images with baseline references
- **Auto Fine-Tuning**: Improve model accuracy using human feedback
- **REST API**: Expose ML capabilities to Spring Boot backend

### 🌟 Real-World Analogy
Think of the ML Service as a **specialist doctor** in a hospital:
- **Backend (Spring Boot)** = General practitioner who coordinates patient care
- **ML Service (Flask)** = Radiology specialist who analyzes X-rays (thermal images)
- **Database** = Medical records system
- **Frontend** = Patient portal

---

## 2. Technology Stack

### Core Technologies

```
┌─────────────────────────────────────────────────────────┐
│                    ML SERVICE STACK                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  🌐 Web Framework:     Flask 2.3.0 (Python)             │
│  🤖 ML Framework:      PyTorch 2.0+                     │
│  🎯 Object Detection:  YOLOv8 (Ultralytics)             │
│  📸 Image Processing:  OpenCV, NumPy, Pillow            │
│  🔄 HTTP Client:       Flask-CORS for API access        │
│  📊 Visualization:     Matplotlib (optional)            │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Why Flask?
- **Lightweight**: Fast startup, minimal overhead
- **Python-First**: Natural fit for ML/AI libraries (PyTorch, OpenCV)
- **Easy Integration**: Simple REST API creation
- **Microservice Pattern**: Separate ML concerns from business logic

### Why YOLOv8?
- **Real-time Speed**: ~100-300ms inference per image
- **High Accuracy**: State-of-the-art object detection
- **Transfer Learning**: Pre-trained on COCO dataset, fine-tuned for thermal images
- **Bounding Boxes**: Returns exact coordinates of anomalies

---

## 3. System Architecture

### 3.1 High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                      TRANSX PLATFORM                              │
└──────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐     ┌──────────────┐
│   FRONTEND   │      │   BACKEND    │     │  ML SERVICE  │
│   React +    │◄────►│  Spring Boot │◄───►│    Flask     │
│  TypeScript  │      │   (Port      │     │  (Port 5001) │
│ (Port 5173)  │      │    8080)     │     │              │
└──────────────┘      └──────┬───────┘     └──────┬───────┘
                             │                     │
                             ▼                     ▼
                      ┌──────────────┐     ┌──────────────┐
                      │   MySQL DB   │     │  YOLOv8 Model│
                      │  en3350_db   │     │ yolov8p2.pt  │
                      └──────────────┘     └──────────────┘
```

### 3.2 ML Service Internal Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    ML SERVICE (Flask App)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              FLASK APPLICATION (app.py)                 │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │                                                         │    │
│  │  📍 Endpoints:                                         │    │
│  │     • POST /api/detect          (Main detection)       │    │
│  │     • POST /api/feedback/upload (Model improvement)    │    │
│  │     • GET  /api/health          (Health check)         │    │
│  │     • GET  /api/classes         (Get detection classes)│    │
│  │                                                         │    │
│  └────────────────────────────────────────────────────────┘    │
│                            │                                     │
│         ┌──────────────────┼──────────────────┐                │
│         │                  │                  │                 │
│         ▼                  ▼                  ▼                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐        │
│  │  SIMILARITY │  │    YOLO     │  │ AUTO FINE-TUNE  │        │
│  │   ANALYZER  │  │  DETECTOR   │  │    SYSTEM       │        │
│  ├─────────────┤  ├─────────────┤  ├─────────────────┤        │
│  │ • Compare   │  │ • Load model│  │ • Parse feedback│        │
│  │   baseline  │  │ • Inference │  │ • Create dataset│        │
│  │   vs current│  │ • Filter by │  │ • Train model   │        │
│  │ • SSIM/ORB  │  │   confidence│  │ • Update weights│        │
│  │ • Histogram │  │ • NMS filter│  │                 │        │
│  └─────────────┘  └─────────────┘  └─────────────────┘        │
│         │                  │                  │                 │
│         └──────────────────┼──────────────────┘                │
│                            ▼                                     │
│                   ┌─────────────────┐                           │
│                   │  PyTorch + YOLO │                           │
│                   │   Model Engine  │                           │
│                   └─────────────────┘                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Core Components

### 4.1 Main Application (app.py)

**Purpose**: Flask application entry point, route handling, model management

**Key Features**:
- Model lazy loading (loads on first request, stays in memory)
- CORS configuration for cross-origin requests
- Error handling and logging
- Health monitoring

**Example Code**:
```python
from flask import Flask, request, jsonify
from ultralytics import YOLO

app = Flask(__name__)
CORS(app)

# Global model instance (loaded once, reused)
model = None

def load_model():
    """Lazy load YOLOv8 model"""
    global model
    if model is None:
        model = YOLO('yolov8p2.pt')
    return model

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'service': 'TransX ML Service'
    })
```

### 4.2 Similarity-Based YOLO System

**Purpose**: Compare baseline and inspection images to detect changes

**File**: `similarity_yolo_system.py`

If two images fail the similarity check, the system short-circuits the comparison pipeline and runs plain YOLO inference so results still flow back instantly.

**How It Works**:
```
┌──────────────────────────────────────────────────────────┐
│         SIMILARITY-BASED DETECTION PIPELINE              │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  Step 1: SIMILARITY FUSION                                │
│  ┌────────────────────────────────────────────┐         │
│  │ Input: Baseline Image + Inspection Image   │         │
│  │ SwiftMatcher blends:                        │         │
│  │  • SSIM (Structural Similarity)             │         │
│  │  • ORB keypoints + Hamming distance         │         │
│  │  • HSV Histogram delta                      │         │
│  │ Output: best method + per-metric scores     │         │
│  └────────────────────────────────────────────┘         │
│                      │                                    │
│          Are images similar?                             │
│             ├─ NO → Bypass similarity path               │
│             │        ▪ Run YOLO inference immediately    │
│             │        ▪ Return detections (no change chk) │
│             ▼ YES                                        │
│  Step 2: YOLO DETECTION (on inspection image only)       │
│  ┌────────────────────────────────────────────┐         │
│  │ • CleanThermalDetector loads yolov8p2       │         │
│  │ • Threshold fixed at 0.01 (show all boxes)  │         │
│  │ • Split detections into HIGH/LOW at 0.30    │         │
│  └────────────────────────────────────────────┘         │
│                      │                                    │
│                      ▼                                    │
│  Step 3: REGION COMPARISON                               │
│  ┌────────────────────────────────────────────┐         │
│  │ • Pair each target bbox with baseline crop  │         │
│  │ • Measure combined difference per region    │         │
│  │ • Compute change magnitude vs threshold     │         │
│  │ • Flag significant_change for UI toggles    │         │
│  └────────────────────────────────────────────┘         │
│                      │                                    │
│                      ▼                                    │
│  Step 4: VISUALIZATION + RESPONSE                        │
│  ┌────────────────────────────────────────────┐         │
│  │ • Matplotlib side-by-side panel (similar path)│      │
│  │ • Show boxes only if images differ or        │        │
│  │   change magnitude >= threshold              │        │
│  │ • Bypass case: format standard YOLO response │        │
│  │ • Always return JSON summary + rendered path │        │
│  └────────────────────────────────────────────┘         │
│                      │                                    │
│                      ▼                                    │
│  Output: Rich result (similarity + detections + viz)    │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

**Code Highlights**:
- Uses `SwiftMatcher` to blend SSIM, ORB keypoints, and histogram scores; returns the best method plus per-metric confidences so the Flask layer can explain why two images were judged similar or not.
- Wraps `CleanThermalDetector` but forces a very low detection threshold (`0.01`) to capture every candidate fault; a secondary confidence split at `0.30` labels each detection as HIGH or LOW for downstream reporting.
- Runs YOLO only on the inspection frame, compares each detection against the matching crop from the baseline image, and computes a change magnitude so quiet scenes can suppress boxes automatically.
- Builds a Matplotlib visualization that always shows both images; bounding boxes appear only if images differ or the computed change surpasses `change_threshold`, and a sidebar summarises region stats, confidences, and timing.
- If the blended similarity score says the images are not similar, the service bypasses the similarity system altogether—running the usual YOLO inference path and immediately returning those detections with no change analysis.
- Returns a rich JSON bundle (similarity verdict, high/low counts, per-region analysis, processing times, visualization path) that the API packs into the `/api/detect` response.

### 4.3 Clean Thermal Detector

**Purpose**: Pure YOLOv8 inference without similarity checking

**File**: `clean_thermal_detector.py`

**Process**:
```python
class CleanThermalDetector:
    def detect(self, image_path):
        # 1. Load image
        img = cv2.imread(image_path)
        
        # 2. Run YOLO inference
        results = self.model(img, conf=self.confidence_threshold)
        
        # 3. Extract detections
        detections = []
        for box in results[0].boxes:
            detection = {
                'bbox': box.xyxy[0].tolist(),  # [x1, y1, x2, y2]
                'confidence': float(box.conf[0]),
                'class_id': int(box.cls[0]),
                'class_name': self.class_names[int(box.cls[0])]
            }
            detections.append(detection)
        
        # 4. Apply NMS (Non-Maximum Suppression)
        filtered = self._apply_nms(detections)
        
        return img, filtered
```

### 4.4 Auto Fine-Tuning System

**Purpose**: Improve model accuracy using human feedback

**File**: `targeted_dataset_creator.py`

**Workflow**:
```
┌────────────────────────────────────────────────────────────┐
│            AUTO FINE-TUNING FEEDBACK LOOP                  │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  1. HUMAN FEEDBACK COLLECTION                              │
│  ┌──────────────────────────────────────────┐             │
│  │ Inspector reviews AI detections:          │             │
│  │  ✓ Approve correct detections             │             │
│  │  ✗ Reject false positives                 │             │
│  │  ✏️  Add missed detections (false neg.)    │             │
│  │  📝 Edit bounding boxes                    │             │
│  └──────────────────────────────────────────┘             │
│                    │                                        │
│                    ▼                                        │
│  2. FEEDBACK EXPORT (Backend → ML Service)                 │
│  ┌──────────────────────────────────────────┐             │
│  │ POST /api/feedback/upload                 │             │
│  │ {                                         │             │
│  │   "inspectionId": "uuid",                 │             │
│  │   "comparisons": [...],                   │             │
│  │   "summary": {                            │             │
│  │     "approved": 5,                        │             │
│  │     "rejected": 2,                        │             │
│  │     "added": 3                            │             │
│  │   }                                       │             │
│  │ }                                         │             │
│  └──────────────────────────────────────────┘             │
│                    │                                        │
│                    ▼                                        │
│  3. DATASET CREATION                                       │
│  ┌──────────────────────────────────────────┐             │
│  │ • Parse feedback & fix class IDs          │             │
│  │ • Pull latest inspection image            │             │
│  │ • Create >=20 augmentations (rotate/flip/ │             │
│  │   brightness/saturation/hue/noise/blur)   │             │
│  │ • Project real boxes + slight jitter      │             │
│  │ • Write YOLO labels, dataset.yaml, info   │             │
│  │   ├── images/train                        │             │
│  │   └── labels/train                        │             │
│  └──────────────────────────────────────────┘             │
│                    │                                        │
│                    ▼                                        │
│  4. YOLO FINE-TUNING (Background Thread)                   │
│  ┌──────────────────────────────────────────┐             │
│  │ • Spawn daemon thread                     │             │
│  │ • Load latest yolov8p2 weights            │             │
│  │ • model.train( data=dataset.yaml,         │             │
│  │   epochs=50, batch=8, lr0=1e-4, patience=3│             │
│  └──────────────────────────────────────────┘             │
│                    │                                        │
│                    ▼                                        │
│  5. MODEL UPDATE                                           │
│  ┌──────────────────────────────────────────┐             │
│  │ • Copy best.pt -> Faulty_Detection/       │             │
│  │   yolov8p2_<timestamp>.pt                 │             │
│  │ • Call load_model() to hot-swap weights   │             │
│  │ • Remove temp dataset & resume inference  │             │
│  └──────────────────────────────────────────┘             │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

**Trigger Conditions**:
- ≥1 human-added annotation (missed detection)
- OR ≥1 approved AI detection
- OR ≥1 rejected AI detection
- OR ≥1 edited bounding box

---

## 5. Request Flow

### 5.1 Standard Detection Flow (No Baseline)

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  FRONTEND   │         │   BACKEND   │         │ ML SERVICE  │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                        │
       │ 1. Click "Detect     │                        │
       │    Anomalies"         │                        │
       ├──────────────────────►│                        │
       │                       │                        │
       │                       │ 2. POST /api/detect    │
       │                       │    {                   │
       │                       │      inspection_image  │
       │                       │      confidence: 0.25  │
       │                       │    }                   │
       │                       ├───────────────────────►│
       │                       │                        │
       │                       │                   3. Load Model
       │                       │                      (if needed)
       │                       │                        │
       │                       │                   4. Read Image
       │                       │                        │
       │                       │                   5. YOLOv8
       │                       │                    Inference
       │                       │                        │
       │                       │                   6. Filter by
       │                       │                    Confidence
       │                       │                        │
       │                       │                   7. Apply NMS
       │                       │                        │
       │                       │ 8. Return Detections   │
       │                       │    {                   │
       │                       │      detections: [...] │
       │                       │      inference_ms: 245 │
       │                       │    }                   │
       │                       │◄───────────────────────┤
       │                       │                        │
       │                       │ 9. Save Annotations    │
       │                       │    to Database         │
       │                       │                        │
       │ 10. Return Updated    │                        │
       │     Annotations       │                        │
       │◄──────────────────────┤                        │
       │                       │                        │
       │ 11. Render Bounding   │                        │
       │     Boxes on Canvas   │                        │
       │                       │                        │
```

### 5.2 Similarity-Based Detection Flow (With Baseline)

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  BACKEND    │         │ ML SERVICE  │         │ SIMILARITY  │
└──────┬──────┘         └──────┬──────┘         │   SYSTEM    │
       │                       │                 └──────┬──────┘
       │ 1. POST /api/detect   │                        │
       │    {                  │                        │
       │      inspection_image │                        │
       │      baseline_image   │                        │
       │    }                  │                        │
       ├──────────────────────►│                        │
       │                       │                        │
       │                       │ 2. Initialize         │
       │                       │    Similarity System   │
       │                       ├───────────────────────►│
       │                       │                        │
       │                       │                   3. Compare
       │                       │                      Images
       │                       │                    • SSIM
       │                       │                    • ORB
       │                       │                    • Histogram
       │                       │                        │
       │                       │ 4. Similarity: 0.85    │
       │                       │◄───────────────────────┤
       │                       │                        │
       │                       │ 4a. Images similar?      │
       │                       │    • NO → Skip similarity│
       │                       │      workflows, run      │
       │                       │      standard YOLO and   │
       │                       │      return detections   │
       │                       │    • YES → continue      │
       │                       │                          │
       │                       │ 5. Run YOLO on           │
       │                       │    inspection image      │
       │                       ├───────────────────────►│
       │                       │                        │
       │                       │                   6. Detect
       │                       │                    Anomalies
       │                       │                        │
       │                       │ 7. Detections Found    │
       │                       │◄───────────────────────┤
       │                       │                        │
       │                       │ 8. Compare Regions     │
       │                       │    (inspect vs baseline)
       │                       ├───────────────────────►│
       │                       │                        │
       │                       │                   9. Calculate
       │                       │                    Changes
       │                       │                        │
       │                       │ 10. Change Analysis    │
       │                       │◄───────────────────────┤
       │                       │                        │
       │ 11. Return Results    │                        │
       │     {                 │                        │
       │       detections,     │                        │
       │       similarity: {}, │                        │
       │       change_detected │                        │
       │     }                 │                        │
       │◄──────────────────────┤                        │
       │                       │                        │
```

---

## 6. YOLOv8 Integration

### 6.1 What is YOLO?

**YOLO** = **Y**ou **O**nly **L**ook **O**nce

**Traditional Object Detection**:
```
Image → [Region Proposal] → [Classification] → [Refinement] → Output
        (slow)              (for each region)
```

**YOLO Approach**:
```
Image → [Single Neural Network] → Output (boxes + classes + confidence)
        (fast, real-time)
```

### 6.2 YOLOv8 Architecture (Simplified)

```
┌─────────────────────────────────────────────────────────────┐
│                    YOLOv8 NEURAL NETWORK                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  INPUT                                                       │
│  ┌────────────┐                                             │
│  │ 640×640×3  │  (Thermal Image resized to 640×640)         │
│  │   Image    │                                             │
│  └─────┬──────┘                                             │
│        │                                                     │
│        ▼                                                     │
│  ┌────────────────────────────────────────┐                │
│  │     BACKBONE (CSPDarknet53)            │                │
│  │  • Extract features from image         │                │
│  │  • Multiple convolutional layers       │                │
│  │  • Creates feature pyramids            │                │
│  └─────────────┬──────────────────────────┘                │
│                │                                             │
│                ▼                                             │
│  ┌────────────────────────────────────────┐                │
│  │     HEAD (Detection Head)              │                │
│  │  • Predict bounding boxes              │                │
│  │  • Predict class probabilities         │                │
│  │  • Predict confidence scores           │                │
│  └─────────────┬──────────────────────────┘                │
│                │                                             │
│                ▼                                             │
│  OUTPUT                                                      │
│  ┌────────────────────────────────────────┐                │
│  │ Detections:                            │                │
│  │  • Box 1: [x1,y1,x2,y2] Faulty 0.87    │                │
│  │  • Box 2: [x1,y1,x2,y2] Loose 0.76     │                │
│  │  • Box 3: [x1,y1,x2,y2] Overload 0.92  │                │
│  └────────────────────────────────────────┘                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 6.3 Supporting Vision Techniques

```
┌─────────────────────────────────────────────────────────────┐
│                SUPPORTING VISION TECH STACK                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Input Detections & Frames                                  │
│          │                                                  │
│          ├─► NMS (Non-Maximum Suppression)                  │
│          │     • Sort boxes by confidence                   │
│          │     • Drop overlaps above IoU threshold          │
│          │     • Forward clean detections                   │
│          │                                                  │
│          ├─► SRM (Statistical Region Merging)               │
│          │     • Start from pixel-size regions              │
│          │     • Merge neighbors if difference < Q          │
│          │     • Produce thermal ROIs for downstream use    │
│          │                                                  │
│          └─► ORB (Oriented FAST + Rotated BRIEF)            │
│                • Detect FAST keypoints                      │
│                • Build rotation-aware BRIEF descriptors     │
│                • Match/track components across frames       │
│                                                             │
│  Output:                                                    │
│    • Clean, non-overlapping detections                      │
│    • Region proposals for fine-tuning & analysis            │
│    • Feature matches for baseline comparisons               │
└─────────────────────────────────────────────────────────────┘
```

- **Non-Maximum Suppression (NMS)**: After the head proposes many overlapping boxes, NMS keeps the highest-confidence box for each object and discards nearby duplicates using an IoU threshold. This step yields clean, non-overlapping detections that the service can return downstream.
- **Statistical Region Merging (SRM)**: SRM begins with pixel-sized regions and merges neighbors whose color or intensity difference is statistically insignificant under a configurable confidence `Q`. It is useful for carving transformer images into coherent thermal regions before deeper analysis or for creating candidate ROIs for the detector.
- **Oriented FAST and Rotated BRIEF (ORB)**: ORB couples FAST keypoint detection with rotation-aware BRIEF descriptors to deliver lightweight, binary feature vectors that remain stable under rotation and lighting shifts. The ML service uses ORB features when comparing inspection images against baselines or tracking components frame to frame.

### 6.4 Detection Classes

TransX uses **4 custom classes** for thermal anomaly detection:

```python
CLASS_NAMES = {
    0: 'faulty',                # General fault (red)
    1: 'faulty_loose_joint',    # Loose connection (green)
    2: 'faulty_point_overload', # Overheated component (blue)
  3: 'potential_faulty'       # Potential issue (yellow)
}
```

### 6.5 Training YOLOv8

**File**: `train_yolov8p2.py`

```python
from ultralytics import YOLO

# 1. Load pre-trained model (transfer learning)
model = YOLO('yolov8n.pt')  # Nano model (fast)

# 2. Fine-tune on custom thermal dataset
results = model.train(
    data='dataset.yaml',    # Dataset config
    epochs=150,             # Training iterations
    imgsz=640,              # Image size
    batch=32,               # Batch size
    patience=25,            # Early stopping
    device='cuda',          # GPU if available
    amp=True,               # Mixed precision training
    cache=True              # Cache images in RAM
)

# 3. Save best weights
# Automatically saved to runs/detect/train/weights/best.pt
```

**Dataset Structure**:
```
dataset/
├── images/
│   ├── train/          # 80% of images
│   │   ├── img1.jpg
│   │   ├── img2.jpg
│   │   └── ...
│   └── val/            # 20% of images
│       ├── img100.jpg
│       └── ...
├── labels/
│   ├── train/          # YOLO format labels
│   │   ├── img1.txt    # class x_center y_center width height
│   │   ├── img2.txt
│   │   └── ...
│   └── val/
│       ├── img100.txt
│       └── ...
└── dataset.yaml        # Config file
```

**dataset.yaml**:
```yaml
path: /path/to/dataset
train: images/train
val: images/val

names:
  0: faulty
  1: faulty_loose_joint
  2: faulty_point_overload
  3: potential_faulty
```

**YOLO Label Format** (normalized coordinates):
```
# Format: class_id x_center y_center width height
0 0.5 0.3 0.2 0.15    # Faulty at center (0.5, 0.3), size 20%×15%
1 0.7 0.6 0.1 0.1     # Loose joint at (0.7, 0.6), size 10%×10%
```

---

## 7. Auto Fine-Tuning System

### 7.1 Feedback Data Structure

**Exported from Backend**:
```json
{
  "inspectionId": "abc-123",
  "inspectionNumber": "INS-081",
  "transformerCode": "TRF-001",
  "exportedAt": "2025-10-26T10:30:00Z",
  "comparisons": [
    {
      "aiAnnotation": {
        "id": "ai-1",
        "bbox": {"x1": 100, "y1": 50, "x2": 200, "y2": 150},
        "className": "faulty",
        "confidence": 0.87,
        "source": "ai",
        "status": "APPROVED"
      },
      "humanAnnotation": null,
      "comparisonType": "AI_ONLY",
      "action": "APPROVED"
    },
    {
      "aiAnnotation": null,
      "humanAnnotation": {
        "id": "human-1",
        "bbox": {"x1": 300, "y1": 200, "x2": 400, "y2": 300},
        "className": "faulty_loose_joint",
        "source": "human"
      },
      "comparisonType": "HUMAN_ONLY",
      "action": "ADDED"
    }
  ],
  "summary": {
    "totalAiAnnotations": 10,
    "totalHumanAnnotations": 3,
    "approved": 7,
    "rejected": 2,
    "added": 3,
    "edited": 1
  }
}
```

### 7.2 Fine-Tuning Process

When an engineer triggers fine-tuning, the service first bootstraps a mini dataset from the latest inspection feedback. Each annotated inspection image is augmented into 20 variants through rotations, flips, and color-safe perturbations so the model sees multiple viewpoints of the same issue. Only after this augmentation set is written to disk does the training job start, ensuring we have enough positive samples even if the original feedback is sparse.

```python
# 1. Parse feedback and create augmented dataset (20× copies via rotation/flipping)
dataset_creator = TargetedDatasetCreator()
dataset_path = dataset_creator.create_dataset_from_current_feedback(
    inspection_number="INS-081",
    feedback_data=feedback_json
)

# 2. Start training in background thread
def run_training():
    model = YOLO('yolov8p2.pt')  # Start from current best model
    model.train(
        data=f'{dataset_path}/dataset.yaml',
        epochs=50,       # Shorter for fine-tuning
        lr0=0.0001,      # Lower learning rate
        patience=3       # Early stopping
    )
    
    # 3. Copy new weights to production
    shutil.copy(
        'runs/detect/train/weights/best.pt',
        'Faulty_Detection/yolov8p2.pt'
    )
    
    # 4. Reload model
    global model
    model = None
    load_model()

threading.Thread(target=run_training, daemon=True).start()
```

### 7.3 Targeted Dataset Creator (`targeted_dataset_creator.py`)

- **Class Sync & Data Harvesting**: `TargetedDatasetCreator` imports `CLASS_NAMES` from `app.py` so YOLO labels always align with production classes. It parses every JSON inside `feedback_data`, separating human-added misses from AI predictions that inspectors approved, edited, or implicitly accepted.
- **Ground-Truth Cleanup**: While iterating feedback it fixes any frontend class-ID bugs by remapping class names (e.g., `classId == 4` becomes `potential_faulty`) before converting boxes into YOLO `[class cx cy w h]` format.
- **Latest Inspection Mining**: The creator locates the freshest inspection directory on disk and grabs the newest annotated image as the seed for augmentation.
- **Heavy Augmentation Loop**: It generates at least 20 training images (or 2× the feedback annotation count) by cycling through rotations, flips, brightness/contrast tweaks, blur, gamma, hue, saturation, scaling, and noise injection so even a single annotated photo yields a diverse mini-dataset.
- **Label Synthesis**: For each augmented frame it applies the real feedback boxes, adding slight jitter to bounding boxes to avoid perfect duplicates and, if feedback is sparse, sprinkles a few realistic synthetic faults to keep class balance.
- **Dataset Packaging**: The tool writes the classic YOLO structure (`images/train`, `labels/train`), emits a `dataset.yaml` with dynamic class names, and drops an `info.json` audit trail describing the run, total images, and annotation counts.

### 7.4 Auto Fine-Tuning Orchestration (`app.py`)

- **Trigger Logic**: `should_trigger_auto_finetune` tallies actions inside uploaded feedback and only proceeds when inspectors add/approve/reject/edit at least two items or when overall activity reaches three interactions—preventing noisy retrains.
- **Dataset Kickoff**: `trigger_auto_finetune` instantiates the dataset creator with the current feedback payload, names the run `auto_feedback_<inspection>_<timestamp>`, and captures the returned dataset path.
- **Background Training**: `start_yolo_training` spins up a daemon thread that loads the latest YOLOv8p2 weights, fine-tunes for ~50 epochs at a lower learning rate, and writes the run under `runs/detect/<model_name>`.
- **Live Model Swap & Cleanup**: After training, `update_model_path_after_training` copies `best.pt` into `Faulty_Detection` with a timestamped filename, reinitializes the Flask model via `load_model()`, and removes the temporary dataset folder so storage stays tidy.

---

## 8. API Endpoints

### 8.1 Health Check

**GET** `/api/health`

```bash
curl http://localhost:5001/api/health
```

**Response**:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "model_path": "/path/to/yolov8p2.pt",
  "similarity_system_available": true,
  "service": "TransX ML Service",
  "version": "2.0.0"
}
```

### 8.2 Detect Anomalies

**POST** `/api/detect`

**Request**:
```json
{
  "inspection_image_path": "/uploads/abc-123/inspection/img.jpg",
  "baseline_image_path": "/uploads/abc-123/baseline/img.jpg",
  "confidence_threshold": 0.25
}
```

**Response**:
```json
{
  "success": true,
  "detections": [
    {
      "id": "uuid-1",
      "classId": 0,
      "className": "faulty",
      "confidence": 0.87,
      "bbox": {
        "x1": 120,
        "y1": 150,
        "x2": 300,
        "y2": 400
      },
      "color": [255, 0, 0],
      "source": "similarity_ai"
    }
  ],
  "image_dimensions": {
    "width": 1920,
    "height": 1080
  },
  "inference_time_ms": 245.3,
  "similarity_analysis": {
    "is_similar": true,
    "confidence": 0.85,
    "method": "ORB",
    "change_detected": true
  }
}
```

### 8.3 Upload Feedback

**POST** `/api/feedback/upload`

**Request**:
```json
{
  "inspectionId": "abc-123",
  "inspectionNumber": "INS-081",
  "comparisons": [...],
  "summary": {
    "approved": 5,
    "rejected": 2,
    "added": 3
  }
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Feedback received",
  "autoFineTuning": {
    "status": "started",
    "message": "Fine-tuning initiated",
    "datasetPath": "/ml-service/auto_feedback_INS-081_20251026_103000"
  }
}
```

---

## 9. Hands-On Examples

### Example 1: Simple Detection Script

```python
#!/usr/bin/env python3
"""Simple thermal anomaly detection"""

from ultralytics import YOLO
import cv2

# Load model
model = YOLO('yolov8p2.pt')

# Read image
img_path = 'thermal_image.jpg'
img = cv2.imread(img_path)

# Run detection
results = model(img, conf=0.25)

# Process results
for box in results[0].boxes:
    x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int)
    conf = float(box.conf[0])
    cls = int(box.cls[0])
    
    print(f"Detection: Class {cls}, Confidence {conf:.2f}")
    print(f"  Bounding Box: ({x1}, {y1}) to ({x2}, {y2})")
    
    # Draw on image
    cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)

# Save result
cv2.imwrite('detected.jpg', img)
```

### Example 2: Flask Detection Endpoint

```python
from flask import Flask, request, jsonify
from ultralytics import YOLO
import cv2

app = Flask(__name__)
model = YOLO('yolov8p2.pt')

@app.route('/detect', methods=['POST'])
def detect():
    data = request.json
    img_path = data.get('image_path')
    
    # Run inference
    results = model(img_path, conf=0.25)
    
    # Extract detections
    detections = []
    for box in results[0].boxes:
        detection = {
            'bbox': box.xyxy[0].tolist(),
            'confidence': float(box.conf[0]),
            'class': int(box.cls[0])
        }
        detections.append(detection)
    
    return jsonify({
        'success': True,
        'detections': detections,
        'count': len(detections)
    })

if __name__ == '__main__':
    app.run(port=5001)
```

### Example 3: Compare Two Images

```python
import cv2
import numpy as np
from skimage.metrics import structural_similarity as ssim

def compare_images(img1_path, img2_path):
    # Read images
    img1 = cv2.imread(img1_path, cv2.IMREAD_GRAYSCALE)
    img2 = cv2.imread(img2_path, cv2.IMREAD_GRAYSCALE)
    
    # Resize to same size
    img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
    
    # Calculate SSIM
    similarity, diff = ssim(img1, img2, full=True)
    
    print(f"Similarity: {similarity:.2%}")
    
    # Threshold difference to find changes
    diff = (diff * 255).astype('uint8')
    thresh = cv2.threshold(diff, 0, 255, cv2.THRESH_BINARY_INV | cv2.THRESH_OTSU)[1]
    
    # Find contours of changes
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    print(f"Found {len(contours)} changed regions")
    
    return similarity, contours

# Usage
similarity, changes = compare_images('baseline.jpg', 'inspection.jpg')
```

---

## 10. Teaching Session Plan

### 📅 Session 1: ML Service Fundamentals (2 hours)

**Topics**:
- What is ML service and why separate from backend?
- Flask basics and REST API design
- YOLOv8 introduction
- System architecture overview

**Hands-On**:
- Install Python dependencies
- Run Flask app locally
- Test /api/health endpoint
- Examine app.py code structure

**Homework**:
- Read YOLOv8 documentation
- Set up local ML service
- Test detection endpoint with sample image

---

### 📅 Session 2: YOLOv8 Deep Dive (3 hours)

**Topics**:
- YOLO architecture (backbone, neck, head)
- Transfer learning concept
- Training process and hyperparameters
- Inference optimization

**Hands-On**:
- Load pre-trained YOLOv8 model
- Run inference on test images
- Examine detection results
- Adjust confidence thresholds

**Code Exercise**:
```python
# Load model
model = YOLO('yolov8n.pt')

# Experiment with different confidence levels
for conf in [0.1, 0.25, 0.5, 0.75]:
    results = model('test_image.jpg', conf=conf)
    print(f"Threshold {conf}: {len(results[0].boxes)} detections")
```

---

### 📅 Session 3: Similarity-Based Detection (2 hours)

**Topics**:
- Image similarity metrics (SSIM, ORB, Histogram)
- Baseline vs inspection comparison
- Change detection algorithms
- Smart filtering strategies

**Hands-On**:
- Compare two thermal images
- Calculate similarity scores
- Identify changed regions
- Visualize differences

**Exercise**:
- Implement simple SSIM comparison
- Find regions with significant pixel changes
- Overlay changes on original image

---

### 📅 Session 4: Auto Fine-Tuning System (2 hours)

**Topics**:
- Feedback loop design
- Dataset creation from annotations
- Fine-tuning vs training from scratch
- Model versioning

**Hands-On**:
- Parse feedback JSON
- Generate YOLO label files
- Create dataset.yaml
- Start fine-tuning process

**Real-World Scenario**:
- Inspector finds 3 missed faults
- Export feedback to ML service
- Watch dataset creation
- Monitor training progress

---

### 📅 Session 5: Integration & Deployment (2 hours)

**Topics**:
- Backend ↔ ML service communication
- Error handling and retry logic
- Performance optimization
- Monitoring and logging

**Hands-On**:
- Test full integration flow
- Handle API errors gracefully
- Measure inference times
- Review logs

**Best Practices**:
- Keep model in memory (lazy loading)
- Use background threads for training
- Implement health checks
- Log all requests/responses

---

### 📅 Session 6: Advanced Topics (2 hours)

**Topics**:
- Model quantization for faster inference
- GPU vs CPU performance
- Batch processing multiple images
- A/B testing new models

**Discussion Questions**:
1. How to handle multiple concurrent requests?
2. When to trigger auto fine-tuning?
3. How to validate model improvements?
4. Deployment strategies (Docker, cloud)

---

## 🎓 Summary

### Key Takeaways

1. **ML Service Role**: Specialized microservice for AI-powered anomaly detection
2. **YOLOv8**: Fast, accurate object detection using deep learning
3. **Similarity Analysis**: Baseline comparison for smarter detection
4. **Auto Fine-Tuning**: Continuous improvement from human feedback
5. **API Integration**: Clean REST interface for backend communication

### Architecture Patterns

- **Microservice Pattern**: Separate ML concerns from business logic
- **Lazy Loading**: Load model once, keep in memory
- **Background Processing**: Train models without blocking requests
- **Feedback Loop**: Human-in-the-loop for model improvement

### TransX-Specific Features

```
┌───────────────────────────────────────────────────────────┐
│              TRANSX ML SERVICE FEATURES                    │
├───────────────────────────────────────────────────────────┤
│                                                            │
│  ✅ Dual Detection Modes                                  │
│     • Standard YOLOv8 (single image)                      │
│     • Similarity-based (with baseline comparison)         │
│                                                            │
│  ✅ 4 Custom Thermal Anomaly Classes                      │
│     • Faulty, Loose Joint, Overload, Potential            │
│                                                            │
│  ✅ Automatic Model Fine-Tuning                           │
│     • Triggered by human feedback                         │
│     • Creates datasets automatically                      │
│     • Improves accuracy over time                         │
│                                                            │
│  ✅ Smart Filtering                                       │
│     • Configurable confidence thresholds                  │
│     • NMS (Non-Maximum Suppression)                       │
│     • Change magnitude analysis                           │
│                                                            │
│  ✅ Production-Ready                                      │
│     • Health monitoring                                   │
│     • Error handling                                      │
│     • Comprehensive logging                               │
│     • CORS support                                        │
│                                                            │
└───────────────────────────────────────────────────────────┘
```

---

## 📚 Additional Resources

- **YOLOv8 Docs**: https://docs.ultralytics.com/
- **PyTorch**: https://pytorch.org/docs/
- **OpenCV**: https://docs.opencv.org/
- **Flask**: https://flask.palletsprojects.com/

---

**End of ML Service Architecture Guide**
