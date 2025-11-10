# 🗄️ TransX Database Architecture - Complete Guide

## Table of Contents
1. [Overview](#overview)
2. [Database Schema Diagram](#database-schema-diagram)
3. [Core Tables Explained](#core-tables-explained)
4. [Database Relationships](#database-relationships)
5. [Database Interactions Flow](#database-interactions-flow)
6. [Advanced Features](#advanced-features)

---

## Overview

**Database**: `en3350_db`  
**DBMS**: MySQL 8.0+ (tested on 9.4.0)  
**Storage Engine**: InnoDB  
**Character Set**: utf8mb4 (Unicode support)  
**Primary Key Strategy**: UUID (binary(16)) for distributed system compatibility

**Total Tables**: 11 (8 core + 2 views + 1 legacy)

---

## Database Schema Diagram

### 📊 Complete ER Diagram (Text Format)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TRANSX DATABASE ARCHITECTURE                          │
│                              (en3350_db)                                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│   TRANSFORMERS       │◄──────────────┐
├──────────────────────┤               │
│ PK id (UUID)         │               │
│ UK code              │               │ ONE Transformer
│    location          │               │ has MANY
│    capacityKVA       │               │ ThermalImages
│    region            │               │
│    pole_no           │               │
│    type              │               │
│    location_details  │               │
│    created_at        │               │
│    updated_at        │               │
└──────────────────────┘               │
         │                             │
         │ ONE Transformer             │
         │ has MANY                    │
         │ Inspections                 │
         │                             │
         ▼                             │
┌──────────────────────┐               │
│   INSPECTIONS        │               │
├──────────────────────┤               │
│ PK id (UUID)         │               │
│ UK inspection_number │               │
│ FK transformer_id    │───────────────┘
│ FK baseline_image_id │────────────┐
│ FK inspection_image_id│───────┐   │
│ FK original_inspection│──┐    │   │
│    _image_id         │  │    │   │
│    branch            │  │    │   │
│    weather_condition │  │    │   │
│    (ENUM)            │  │    │   │
│    status (ENUM)     │  │    │   │
│    notes             │  │    │   │
│    inspected_by      │  │    │   │
│    current_inspector │  │    │   │
│    inspected_at      │  │    │   │
│    completed_at      │  │    │   │
│    completed_by      │  │    │   │
│    created_at        │  │    │   │
│    updated_at        │  │    │   │
└──────────────────────┘  │    │   │
         │                │    │   │
         │                │    │   │
         ├────────────────┼────┼───┼──────────────┐
         │                │    │   │              │
         │ ONE Inspection │    │   │              │
         │ has MANY       │    │   │              │
         │                │    │   │              │
         ▼                │    │   │              │
┌──────────────────────┐ │    │   │              │
│   ANNOTATIONS        │ │    │   │              │
├──────────────────────┤ │    │   │              │
│ PK id (UUID)         │ │    │   │              │
│ FK inspection_id     │─┘    │   │              │
│ FK parent_annotation │──┐   │   │              │
│    _id (self-ref)    │  │   │   │              │
│    version           │  │   │   │              │
│    bbox_x1, y1       │  │   │   │              │
│    bbox_x2, y2       │  │   │   │              │
│    class_id          │  │   │   │              │
│    class_name        │  │   │   │              │
│    box_number        │  │   │   │              │
│    confidence        │  │   │   │              │
│    source (ENUM)     │  │   │   │              │
│    action_type (ENUM)│  │   │   │              │
│    created_by        │  │   │   │              │
│    current_inspector │  │   │   │              │
│    created_at        │  │   │   │              │
│    modified_by       │  │   │   │              │
│    modified_at       │  │   │   │              │
│    is_active         │  │   │   │              │
│    comments          │  │   │   │              │
└──────────────────────┘  │   │   │              │
         │                │   │   │              │
         │ Annotation     │   │   │              │
         │ has version    │   │   │              │
         │ history        │   │   │              │
         │ (self-ref)     │   │   │              │
         └────────────────┘   │   │              │
         │                    │   │              │
         │ ONE Annotation     │   │              │
         │ has MANY           │   │              │
         │ History Entries    │   │              │
         │                    │   │              │
         ▼                    │   │              │
┌──────────────────────┐      │   │              │
│ ANNOTATION_HISTORY   │      │   │              │
├──────────────────────┤      │   │              │
│ PK id (UUID)         │      │   │              │
│ FK annotation_id     │──────┘   │              │
│ FK inspection_id     │──────────┘              │
│    action_type       │                         │
│    snapshot_data(JSON)                         │
│    user_id           │                         │
│    created_at        │                         │
└──────────────────────┘                         │
                                                  │
┌──────────────────────┐                         │
│ INSPECTION_COMMENTS  │                         │
├──────────────────────┤                         │
│ PK id (UUID)         │                         │
│ FK inspection_id     │─────────────────────────┘
│    comment_text      │
│    author            │
│    created_at        │
│    updated_at        │
└──────────────────────┘

┌──────────────────────┐
│ INSPECTION_HISTORY   │
├──────────────────────┤
│ PK id (UUID)         │
│ FK inspection_id     │─────────────────────────┐
│    box_number        │                         │
│    action_type(ENUM) │                         │
│    action_description│                         │
│    user_name         │                         │
│    previous_data(JSON)                         │
│    new_data (JSON)   │                         │
│    created_at        │                         │
└──────────────────────┘                         │
                                                  │
┌──────────────────────┐                         │
│INSPECTION_ACCESS_LOG │                         │
├──────────────────────┤                         │
│ PK id (UUID)         │                         │
│ FK inspection_id     │─────────────────────────┘
│    user_name         │
│    access_type (ENUM)│
│    session_start     │
│    session_end       │
│    user_agent        │
│    ip_address        │
└──────────────────────┘

┌──────────────────────┐
│BOX_NUMBERING_SEQUENCE│
├──────────────────────┤
│ PK inspection_id     │─────────────────────────┐
│    next_box_number   │                         │
│    last_updated_at   │                         │
└──────────────────────┘                         │
                                                  │
┌──────────────────────┐      ┌──────────────┐  │
│   THERMAL_IMAGES     │      │              │  │
├──────────────────────┤      │              │  │
│ PK id (UUID)         │◄─────┤ References   │──┘
│ FK transformer_id    │──────┤ from         │
│ FK inspection_id     │──────┤ Inspections: │
│    type (ENUM)       │      │              │
│    env_condition     │      │ • baseline_image_id
│    (ENUM)            │      │ • inspection_image_id
│    original_filename │      │ • original_inspection_image_id
│    stored_filename   │      │              │
│    content_type      │      └──────────────┘
│    size_bytes        │
│    uploader          │
│    public_url        │
│    uploaded_at       │
└──────────────────────┘

═══════════════════════════════════════════════════════════════════

                        DATABASE VIEWS (Virtual Tables)

┌────────────────────────────────────────────────────────────────┐
│ VIEW: inspection_boxes_current                                 │
├────────────────────────────────────────────────────────────────┤
│ Purpose: Show only ACTIVE annotations with inspection details  │
│ Joins: annotations + inspections                               │
│ Filter: WHERE is_active = 1                                    │
│ Use Case: Display current state of inspection annotations      │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ VIEW: inspection_history_view                                  │
├────────────────────────────────────────────────────────────────┤
│ Purpose: Audit trail with inspection context                   │
│ Joins: inspection_history + inspections                        │
│ Order: created_at DESC                                          │
│ Use Case: Track all changes made to inspections               │
└────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════

                        LEGACY TABLES (Not Used)

┌──────────────────────┐
│   USERS              │  ← Sample/Demo table (not part of TransX)
├──────────────────────┤
│ PK id (INT)          │
│    username          │
│    password          │
│    role (ENUM)       │
│    email             │
└──────────────────────┘

┌──────────────────────┐
│   COURSES            │  ← Sample/Demo table (not part of TransX)
├──────────────────────┤
│ PK id (INT)          │
│    course_code       │
│    course_name       │
│    credits           │
└──────────────────────┘

┌──────────────────────┐
│   ENROLLMENTS        │  ← Sample/Demo table (not part of TransX)
├──────────────────────┤
│ PK id (INT)          │
│ FK user_id           │
│ FK course_id         │
│    enrolled_at       │
└──────────────────────┘

```

---

## Core Tables Explained

### 1️⃣ **transformers** (Phase 1 - Foundation)

**Purpose**: Store electrical transformer master data

**Key Fields**:
- `id` (UUID): Primary key
- `code` (UNIQUE): Business identifier (e.g., "TX-001", "TX-002")
- `location`: Geographic location
- `capacityKVA`: Transformer capacity in KVA
- `region`, `pole_no`, `type`: Additional metadata

**Business Rules**:
- Code must be unique
- CASCADE DELETE: Deleting a transformer deletes all related images and inspections

**JPA Entity**: `Transformer.java`

**Sample Query**:
```sql
SELECT * FROM transformers WHERE location LIKE '%Kandy%';
```

---

### 2️⃣ **thermal_images** (Phase 1 - Image Management)

**Purpose**: Store metadata for all uploaded thermal images

**Key Fields**:
- `id` (UUID): Primary key
- `transformer_id` (FK): Which transformer this image belongs to
- `inspection_id` (FK NULLABLE): Optional link to inspection
- `type` (ENUM): **BASELINE** | **MAINTENANCE** | **INSPECTION**
  - BASELINE: Reference image under normal conditions
  - MAINTENANCE: Periodic inspection images
  - INSPECTION: New inspection images (used in Phase 2+)
- `env_condition` (ENUM): **SUNNY** | **CLOUDY** | **RAINY** (required for BASELINE)
- `stored_filename`: UUID-based filename on disk
- `public_url`: Full URL to access the file

**Storage Path**:
```
uploads/
  └── {transformer_id}/
      ├── baseline/
      │   └── {uuid}_{original_filename}
      └── inspection/
          └── {uuid}_{original_filename}
```

**Business Rules**:
- Baseline images MUST have `env_condition` set
- Images are served via `/files/**` endpoint
- Actual files stored in `uploads/` directory

**JPA Entity**: `ThermalImage.java`

---

### 3️⃣ **inspections** (Phase 2 - Inspection Workflow)

**Purpose**: Track thermal inspection sessions

**Key Fields**:
- `id` (UUID): Primary key
- `inspection_number` (UNIQUE): Business identifier (e.g., "INS-001")
- `transformer_id` (FK): Which transformer is being inspected
- `baseline_image_id` (FK NULLABLE): Reference image for comparison
- `inspection_image_id` (FK NULLABLE): New inspection image
- `original_inspection_image_id` (FK NULLABLE): Backup before annotations
- `status` (ENUM): **DRAFT** | **IN_PROGRESS** | **UNDER_REVIEW** | **COMPLETED** | **CANCELLED**
- `weather_condition` (ENUM): Weather during inspection
- `current_inspector`: Who is currently working on this
- `notes`: Long-form inspection notes

**Status Workflow**:
```
DRAFT → IN_PROGRESS → UNDER_REVIEW → COMPLETED
   ↓                                      ↑
   └──────────────→ CANCELLED ←───────────┘
```

**Business Rules**:
- Status transitions are tracked in `inspection_history`
- Can have 0-3 image references (baseline, inspection, original)
- CASCADE DELETE: Deleting inspection removes all annotations, comments, history

**JPA Entity**: `Inspection.java`

---

### 4️⃣ **annotations** (Phase 2 & 3 - AI + Human Annotations)

**Purpose**: Store bounding box annotations (AI-detected + human-validated)

**Key Fields**:
- `id` (UUID): Primary key
- `inspection_id` (FK): Which inspection this annotation belongs to
- `bbox_x1, bbox_y1, bbox_x2, bbox_y2`: Bounding box coordinates (pixels)
- `class_id`: Fault class (0=faulty, 1=loose_joint, 2=point_overload, 3=potential)
- `class_name`: Human-readable class name
- `box_number`: Sequential number per inspection (for tracking)
- `confidence`: AI confidence score (0.0 - 1.0)
- `source` (ENUM): **ai** | **human**
- `action_type` (ENUM): **created** | **edited** | **deleted** | **approved** | **rejected**
- `is_active`: Boolean flag (soft delete - false = deleted)
- `version`: Version number for history tracking
- `parent_annotation_id` (FK SELF): Points to previous version

**Fault Classes** (from YOLOv8 model):
```
Class 0: faulty              (Red)    - General faults
Class 1: faulty_loose_joint  (Green)  - Loose connections
Class 2: faulty_point_overload (Blue)  - Overload points
Class 3: potential_faulty    (Yellow) - Potential issues
```

**Annotation Lifecycle**:
```
1. AI Detection    → source='ai', action_type='created', is_active=true
2. User Approves   → action_type='approved'
3. User Edits      → Create new version, increment version, set parent_annotation_id
4. User Deletes    → is_active=false, action_type='deleted'
5. User Rejects    → action_type='rejected'
```

**Business Rules**:
- Each edit creates a new row with incremented `version`
- Deleted annotations kept for history (is_active = false)
- Only active annotations displayed in UI

**JPA Entity**: `Annotation.java`

**Sample Query - Get Active Annotations**:
```sql
SELECT * FROM annotations 
WHERE inspection_id = ? 
  AND is_active = 1
ORDER BY box_number;
```

---

### 5️⃣ **annotation_history** (Phase 3 - Audit Trail)

**Purpose**: Store snapshot of every annotation change

**Key Fields**:
- `id` (UUID): Primary key
- `annotation_id` (FK): Which annotation changed
- `inspection_id` (FK): Context
- `action_type`: Type of action (string, e.g., "BOX_EDITED", "BOX_APPROVED")
- `snapshot_data` (JSON): Complete state before/after change
- `user_id`: Who made the change
- `created_at`: When it happened

**JSON Structure**:
```json
{
  "bbox": {"x1": 100, "y1": 200, "x2": 300, "y2": 400},
  "class_id": 0,
  "confidence": 0.85,
  "action_type": "approved",
  "modified_by": "engineer@example.com"
}
```

**Use Case**: Undo/Redo, Audit compliance, ML feedback loop

---

### 6️⃣ **inspection_comments** (Phase 3 - Collaboration)

**Purpose**: Multi-user discussion on inspections

**Key Fields**:
- `id` (UUID): Primary key
- `inspection_id` (FK): Which inspection
- `comment_text`: The actual comment (max 2048 chars)
- `author`: Username/email
- `created_at`, `updated_at`: Timestamps

**Business Rules**:
- Comments can be edited (tracked by `updated_at`)
- Real-time updates in frontend
- Threaded comments (flat structure for now)

**JPA Entity**: `InspectionComment.java`

---

### 7️⃣ **inspection_history** (Phase 3 - Complete Audit Log)

**Purpose**: Track every action on an inspection

**Key Fields**:
- `id` (UUID): Primary key
- `inspection_id` (FK): Context
- `box_number` (NULLABLE): If action relates to a specific box
- `action_type` (ENUM): Type of action (14 different types!)
- `action_description`: Human-readable description
- `user_name`: Who performed the action
- `previous_data` (JSON): State before
- `new_data` (JSON): State after
- `created_at`: Timestamp

**Action Types**:
```sql
ENUM(
  'INSPECTION_CREATED',
  'INSPECTOR_CHANGED',
  'AI_DETECTION_RUN',
  'BOX_CREATED',
  'BOX_EDITED',
  'BOX_MOVED',
  'BOX_RESIZED',
  'BOX_APPROVED',
  'BOX_REJECTED',
  'BOX_DELETED',
  'CLASS_CHANGED',
  'CONFIDENCE_UPDATED',
  'STATUS_CHANGED',
  'INSPECTION_COMPLETED'
)
```

**Sample Entry**:
```json
{
  "inspection_id": "...",
  "box_number": 3,
  "action_type": "BOX_APPROVED",
  "action_description": "Box #3 approved",
  "user_name": "engineer@example.com",
  "previous_data": {"action_type": "created"},
  "new_data": {"action_type": "approved"}
}
```

**Use Case**: 
- Show timeline of all changes
- Compliance reporting
- Debugging ML model performance

---

### 8️⃣ **inspection_access_log** (Phase 3 - Session Tracking)

**Purpose**: Track who accessed what, when

**Key Fields**:
- `id` (UUID): Primary key
- `inspection_id` (FK): Which inspection
- `user_name`: Who accessed
- `access_type` (ENUM): **VIEW** | **EDIT** | **CREATE**
- `session_start`, `session_end`: Session duration
- `user_agent`: Browser/device info
- `ip_address`: Source IP

**Use Case**:
- Concurrency control (prevent multiple editors)
- Usage analytics
- Security audit

---

### 9️⃣ **box_numbering_sequence** (Phase 3 - Auto-increment Box Numbers)

**Purpose**: Generate sequential box numbers per inspection

**Key Fields**:
- `inspection_id` (PK): One row per inspection
- `next_box_number`: Next available number
- `last_updated_at`: When it was last incremented

**Logic**:
```
When new annotation created:
1. Get current next_box_number for inspection
2. Assign to annotation.box_number
3. Increment next_box_number
4. Update last_updated_at
```

**Why Separate Table?**
- Ensures unique box numbers even with concurrent requests
- Avoids gaps in numbering
- Supports "Box #1, Box #2, Box #3..." display

---

## Database Relationships

### 🔗 Relationship Summary

| From Table | To Table | Type | Cardinality | ON DELETE |
|------------|----------|------|-------------|-----------|
| transformers | thermal_images | 1:N | One transformer has many images | CASCADE |
| transformers | inspections | 1:N | One transformer has many inspections | CASCADE |
| thermal_images | inspections | N:1 | Many images belong to one transformer | SET NULL |
| inspections | annotations | 1:N | One inspection has many annotations | CASCADE |
| inspections | inspection_comments | 1:N | One inspection has many comments | CASCADE |
| inspections | inspection_history | 1:N | One inspection has many history entries | CASCADE |
| inspections | inspection_access_log | 1:N | One inspection has many access logs | CASCADE |
| inspections | box_numbering_sequence | 1:1 | One inspection has one sequence | CASCADE |
| annotations | annotation_history | 1:N | One annotation has many history entries | CASCADE |
| annotations | annotations (self) | 1:N | Annotation versioning (parent-child) | SET NULL |

---

## Database Interactions Flow

### 📸 **Flow 1: Upload Baseline Image (Phase 1)**

```
Frontend → Backend → Database

1. User selects transformer "TX-001"
2. User uploads thermal image "baseline_sunny.jpg"
3. Frontend sends:
   POST /api/images
   FormData {
     file: baseline_sunny.jpg,
     transformerId: "uuid-of-tx-001",
     type: "BASELINE",
     envCondition: "SUNNY"
   }

4. Backend (ThermalImageController):
   a. Generate UUID for image
   b. Save file to: uploads/{transformer-uuid}/baseline/{image-uuid}_baseline_sunny.jpg
   c. Create ThermalImage entity:
      - id: new UUID
      - transformer_id: uuid-of-tx-001
      - type: BASELINE
      - env_condition: SUNNY
      - stored_filename: {uuid}_baseline_sunny.jpg
      - public_url: http://localhost:8080/files/{path}
   d. Save to database:
      INSERT INTO thermal_images (id, transformer_id, type, env_condition, ...) 
      VALUES (?, ?, 'BASELINE', 'SUNNY', ...);

5. Response to frontend with image URL
```

**Database Changes**:
- 1 new row in `thermal_images`
- File stored on disk

---

### 🔍 **Flow 2: Create Inspection & Detect Anomalies (Phase 2)**

```
Frontend → Backend → ML Service → Database

STEP 1: Create Inspection
1. User clicks "Create New Inspection" for transformer "TX-001"
2. Frontend sends:
   POST /api/inspections
   {
     "inspectionNumber": "INS-001",
     "transformerId": "uuid-of-tx-001",
     "branch": "Kandy",
     "weatherCondition": "SUNNY",
     "inspectedBy": "Engineer A"
   }

3. Backend (InspectionService):
   INSERT INTO inspections (id, inspection_number, transformer_id, status, ...)
   VALUES (new-uuid, 'INS-001', 'uuid-of-tx-001', 'DRAFT', ...);

   INSERT INTO inspection_history (id, inspection_id, action_type, user_name, ...)
   VALUES (new-uuid, inspection-id, 'INSPECTION_CREATED', 'Engineer A', ...);

STEP 2: Upload Inspection Image
4. User uploads new thermal image
5. Frontend sends:
   POST /api/images (creates thermal_image with type=INSPECTION)
   POST /api/inspections/{id}/upload-image?imageId={image-uuid}

6. Backend updates:
   UPDATE inspections 
   SET inspection_image_id = ?, original_inspection_image_id = ?
   WHERE id = ?;

STEP 3: Detect Anomalies
7. User clicks "Detect Anomalies"
8. Frontend sends:
   POST /api/inspections/{id}/detect-anomalies?confidenceThreshold=0.3

9. Backend (InspectionService):
   a. Load baseline image path from thermal_images
   b. Load inspection image path from thermal_images
   c. Call ML Service (MLServiceClient):
      POST http://localhost:5001/detect
      FormData {
        baseline_image: <file>,
        inspection_image: <file>,
        confidence_threshold: 0.3
      }

10. ML Service (Flask app.py):
    a. Load YOLOv8p2 model
    b. Run inference on inspection image
    c. Compare with baseline (similarity check)
    d. Return JSON:
       {
         "success": true,
         "detections": [
           {
             "id": "uuid",
             "class_id": 0,
             "class_name": "Faulty",
             "confidence": 0.87,
             "bbox": {"x1": 100, "y1": 150, "x2": 300, "y2": 400},
             "color": [255, 0, 0],
             "source": "ai"
           },
           ...
         ]
       }

11. Backend receives ML response:
    a. Get next_box_number from box_numbering_sequence
    b. For each detection, create Annotation:
       INSERT INTO annotations 
       (id, inspection_id, bbox_x1, bbox_y1, bbox_x2, bbox_y2, 
        class_id, class_name, confidence, source, action_type, 
        box_number, created_by, is_active)
       VALUES 
       (new-uuid, inspection-id, 100, 150, 300, 400,
        0, 'Faulty', 0.87, 'ai', 'created',
        1, 'AI-YOLOv8', true);
    
    c. Update box_numbering_sequence:
       UPDATE box_numbering_sequence
       SET next_box_number = next_box_number + 1
       WHERE inspection_id = ?;
    
    d. Log to inspection_history:
       INSERT INTO inspection_history 
       (id, inspection_id, box_number, action_type, user_name, new_data)
       VALUES 
       (new-uuid, inspection-id, 1, 'AI_DETECTION_RUN', 'AI-System', 
        '{"bbox": {...}, "class_id": 0, ...}');
    
    e. Update inspection status:
       UPDATE inspections
       SET status = 'IN_PROGRESS'
       WHERE id = ?;

12. Response to frontend with all detections
13. Frontend renders bounding boxes on AnnotationCanvas
```

**Database Changes**:
- 1 new row in `inspections`
- 1 new row in `thermal_images` (inspection image)
- N new rows in `annotations` (one per detection)
- N new rows in `inspection_history` (detection logs)
- 1 new row in `box_numbering_sequence`
- Multiple UPDATEs to `inspections` table

---

### ✏️ **Flow 3: User Annotates/Edits Boxes (Phase 3)**

```
Frontend → Backend → Database

SCENARIO A: User Approves AI Detection
1. User clicks "Approve" on Box #1
2. Frontend sends:
   POST /api/annotations/{annotation-id}/approve
   {
     "userId": "engineer@example.com"
   }

3. Backend (AnnotationController):
   a. Load annotation
   b. Update action_type:
      UPDATE annotations
      SET action_type = 'approved',
          modified_by = 'engineer@example.com',
          modified_at = NOW()
      WHERE id = ?;
   
   c. Log to annotation_history:
      INSERT INTO annotation_history
      (id, annotation_id, inspection_id, action_type, 
       snapshot_data, user_id)
      VALUES
      (new-uuid, annotation-id, inspection-id, 'approved',
       '{"bbox": {...}, "action_type": "approved"}', 
       'engineer@example.com');
   
   d. Log to inspection_history:
      INSERT INTO inspection_history
      (id, inspection_id, box_number, action_type, 
       user_name, previous_data, new_data)
      VALUES
      (new-uuid, inspection-id, 1, 'BOX_APPROVED',
       'engineer@example.com', 
       '{"action_type": "created"}',
       '{"action_type": "approved"}');

SCENARIO B: User Edits Bounding Box
1. User drags box to resize/move
2. Frontend sends:
   PUT /api/annotations/{annotation-id}
   {
     "bbox": {"x1": 110, "y1": 160, "x2": 310, "y2": 410},
     "userId": "engineer@example.com"
   }

3. Backend:
   a. Load current annotation
   b. Create new version:
      - Copy all fields
      - Increment version
      - Set parent_annotation_id to current annotation
      - Update bbox coordinates
      - Set is_active = true
   
   c. Deactivate old version:
      UPDATE annotations
      SET is_active = false
      WHERE id = old-annotation-id;
   
   d. Insert new version:
      INSERT INTO annotations
      (id, inspection_id, version, bbox_x1, bbox_y1, bbox_x2, bbox_y2,
       class_id, confidence, source, action_type, box_number,
       parent_annotation_id, is_active, modified_by)
      VALUES
      (new-uuid, inspection-id, 2, 110, 160, 310, 410,
       0, 0.87, 'ai', 'edited', 1,
       old-annotation-id, true, 'engineer@example.com');
   
   e. Log history (similar to approve)

SCENARIO C: User Creates New Annotation
1. User draws new box on canvas
2. Frontend sends:
   POST /api/annotations
   {
     "inspectionId": "uuid",
     "bbox": {"x1": 500, "y1": 600, "x2": 700, "y2": 800},
     "classId": 3,
     "className": "potential_faulty",
     "userId": "engineer@example.com"
   }

3. Backend:
   a. Get next box number:
      SELECT next_box_number FROM box_numbering_sequence
      WHERE inspection_id = ?;
   
   b. Insert annotation:
      INSERT INTO annotations
      (id, inspection_id, bbox_x1, bbox_y1, bbox_x2, bbox_y2,
       class_id, class_name, source, action_type, box_number,
       created_by, is_active)
      VALUES
      (new-uuid, inspection-id, 500, 600, 700, 800,
       3, 'potential_faulty', 'human', 'created', 2,
       'engineer@example.com', true);
   
   c. Increment box sequence:
      UPDATE box_numbering_sequence
      SET next_box_number = next_box_number + 1
      WHERE inspection_id = ?;
   
   d. Log to history

SCENARIO D: User Deletes Annotation
1. User clicks "Delete" on Box #2
2. Frontend sends:
   DELETE /api/annotations/{annotation-id}?userId=engineer@example.com

3. Backend:
   UPDATE annotations
   SET is_active = false,
       action_type = 'deleted',
       modified_by = 'engineer@example.com',
       modified_at = NOW()
   WHERE id = ?;
   
   (Soft delete - keeps data for history)
```

**Database Changes per Action**:
- **Approve**: 1 UPDATE to `annotations`, 2 INSERTs to history tables
- **Edit**: 1 UPDATE + 1 INSERT to `annotations`, 2 INSERTs to history
- **Create**: 1 INSERT to `annotations`, 1 UPDATE to sequence, 2 INSERTs to history
- **Delete**: 1 UPDATE to `annotations`, 2 INSERTs to history

---

### 💬 **Flow 4: Add Comment (Phase 3)**

```
1. User types comment and clicks "Add Comment"
2. Frontend sends:
   POST /api/inspections/{inspection-id}/comments
   {
     "commentText": "Found 2 critical faults",
     "author": "Engineer A"
   }

3. Backend:
   INSERT INTO inspection_comments
   (id, inspection_id, comment_text, author, created_at)
   VALUES
   (new-uuid, inspection-id, 'Found 2 critical faults', 
    'Engineer A', NOW());

4. Response to frontend
5. Frontend adds comment to UI without page reload
```

**Database Changes**:
- 1 new row in `inspection_comments`

---

### 📊 **Flow 5: Export Feedback for ML (Phase 3)**

```
1. Backend scheduled job or manual trigger
2. For each completed inspection:
   a. Query all annotations:
      SELECT * FROM annotations
      WHERE inspection_id = ?
        AND is_active = true;
   
   b. Generate JSON:
      {
        "inspection_id": "...",
        "annotations": [
          {
            "bbox": [x1, y1, x2, y2],
            "class_id": 0,
            "confidence": 0.87,
            "source": "ai",
            "action_type": "approved",
            "modified_by": "engineer@example.com"
          },
          ...
        ]
      }
   
   c. Save to: ml-service/feedback_data/feedback_{inspection-id}_{timestamp}.json

3. Python script (targeted_dataset_creator.py) processes JSON:
   a. Converts to YOLO format (.txt files)
   b. Creates training dataset
   c. Runs fine-tuning script

4. New model weights saved to: runs/detect/feedback_finetune/weights/best.pt

5. ML service (app.py) reloads new model
```

**Database Queries**:
- SELECT from `annotations`
- SELECT from `inspections`
- No writes (read-only export)

---

## Advanced Features

### 🔄 **Version Control System**

**How it works**:
1. Each edit creates a new `annotations` row
2. New row has:
   - Incremented `version` number
   - `parent_annotation_id` pointing to previous version
   - `is_active = true`
3. Old version marked `is_active = false`

**Query to get version history**:
```sql
SELECT * FROM annotations
WHERE id = :annotationId 
   OR parent_annotation_id = :annotationId
ORDER BY version DESC;
```

**Rollback logic**:
- Load previous version
- Create new row based on it
- Mark current version inactive

---

### 📈 **Indexes for Performance**

**Key Indexes**:
```sql
-- annotations table
CREATE INDEX idx_inspection_id ON annotations(inspection_id);
CREATE INDEX idx_inspection_active ON annotations(inspection_id, is_active);
CREATE INDEX idx_source ON annotations(source);
CREATE INDEX idx_version ON annotations(inspection_id, version);
CREATE INDEX idx_box_number ON annotations(inspection_id, box_number);

-- inspection_history table
CREATE INDEX idx_inspection_id ON inspection_history(inspection_id);
CREATE INDEX idx_created_at ON inspection_history(created_at);
CREATE INDEX idx_user ON inspection_history(user_name);
CREATE INDEX idx_action_type ON inspection_history(action_type);

-- inspections table
CREATE INDEX idx_transformer_id ON inspections(transformer_id);
CREATE INDEX idx_status ON inspections(status);
CREATE INDEX idx_inspected_at ON inspections(inspected_at);
```

**Why these indexes?**
- `inspection_id` - Most common filter (used in 90% of queries)
- `is_active` - Compound index for active annotations query
- `created_at` - For sorting history chronologically
- `status` - For filtering inspections by workflow state

---

### 🔐 **Data Integrity Rules**

**Foreign Key Constraints**:
- `ON DELETE CASCADE`: Parent deletion removes all children
  - Transformer → Inspections → Annotations → History
- `ON DELETE SET NULL`: Optional references
  - Inspection → Thermal Images (can exist without inspection)

**Unique Constraints**:
- `transformers.code` - Business key
- `inspections.inspection_number` - Business key

**NOT NULL Constraints**:
- All foreign keys except optional image references
- All ENUM fields have default values
- `is_active` defaults to `true`

---

### 📊 **Database Views Usage**

**1. inspection_boxes_current**
```sql
-- Used by frontend to display current annotations
SELECT * FROM inspection_boxes_current
WHERE inspection_id = ?
ORDER BY box_number;

-- Equivalent query without view:
SELECT a.*, i.inspection_number, i.status
FROM annotations a
JOIN inspections i ON a.inspection_id = i.id
WHERE a.is_active = 1 
  AND a.inspection_id = ?
ORDER BY a.box_number;
```

**2. inspection_history_view**
```sql
-- Used for audit reports
SELECT * FROM inspection_history_view
WHERE inspection_id = ?
ORDER BY created_at DESC
LIMIT 50;

-- Shows complete timeline with context
```

---

### 🎯 **Query Patterns Used in Application**

**Pattern 1: Get Active Annotations for Inspection**
```java
// AnnotationRepo.java
@Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true")
List<Annotation> findActiveByInspectionId(@Param("inspectionId") UUID inspectionId);
```

**Pattern 2: Search Inspections**
```java
// InspectionRepo.java
@Query("SELECT i FROM Inspection i WHERE " +
       "LOWER(i.inspectionNumber) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
       "LOWER(i.transformer.code) LIKE LOWER(CONCAT('%', :q, '%'))")
Page<Inspection> findBySearchQuery(@Param("q") String q, Pageable pageable);
```

**Pattern 3: Count Active Annotations**
```java
// AnnotationRepo.java
@Query("SELECT COUNT(a) FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true")
Long countActiveByInspectionId(@Param("inspectionId") UUID inspectionId);
```

---

### 🚀 **Performance Considerations**

**Database Size Estimates** (per 1000 inspections):
- `transformers`: ~5 MB (5 transformers × 1 KB)
- `thermal_images`: ~500 MB (files) + 5 MB (metadata)
- `inspections`: ~10 MB
- `annotations`: ~50 MB (avg 5 annotations per inspection)
- `annotation_history`: ~200 MB (avg 20 history entries per inspection)
- `inspection_history`: ~100 MB
- `inspection_comments`: ~20 MB

**Total**: ~890 MB for database + files

**Optimization Tips**:
1. Regularly archive old inspections (status = COMPLETED, older than 1 year)
2. Compress uploaded images before storage
3. Use database partitioning for `annotation_history` by date
4. Implement pagination for all list queries
5. Use database connection pooling (HikariCP in Spring Boot)

---

## Summary

**Database Design Highlights**:
✅ **UUID Primary Keys** - Distributed system ready  
✅ **Soft Deletes** - Data never lost (is_active flag)  
✅ **Version Control** - Full annotation edit history  
✅ **Audit Trail** - Every action logged  
✅ **JSON Storage** - Flexible metadata without schema changes  
✅ **Cascade Rules** - Data integrity enforced  
✅ **Indexes** - Optimized for common queries  
✅ **ENUM Types** - Type-safe status/classification  
✅ **Timestamps** - Automatic created_at/updated_at  

**Key Takeaways**:
1. Database supports complete workflow from image upload to ML feedback
2. Every user action is traceable through history tables
3. Annotation system supports both AI and human input
4. Version control enables undo/redo functionality
5. JSON fields provide flexibility for ML metadata

---

**Next Steps**:
1. Study the SQL schema file in detail
2. Try running the queries in MySQL Workbench
3. Trace a complete flow from frontend to database
4. Understand JPA entity mappings in Java code
5. Experiment with adding new fields/tables

