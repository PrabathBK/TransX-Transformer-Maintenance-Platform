# 📋 Inspection Workflow Guide - Phase 2 & 3

## 🔄 Complete Workflow (Correct Order)

### **Step 1: Create Transformer** (Phase 1)
1. Go to **Transformers** page
2. Click **"+ Add Transformer"**
3. Fill in details:
   - Transformer Code (e.g., TX-005)
   - Location (e.g., Colombo Central)
   - Installation Date
   - Capacity (kVA)
   - Type
   - Branch

### **Step 2: Upload Baseline Image** (Phase 1)
1. Still on transformer detail page
2. Click **"Upload Baseline Image"**
3. Select a thermal image (`.jpg`, `.png`, `.jpeg`)
4. Image is stored as **BASELINE** type
5. This image represents the transformer in **normal/healthy condition**

### **Step 3: Create Inspection** (Phase 2)
1. Go to **Inspections** page
2. Click **"+ Add Inspection"**
3. Fill in form:
   - **Inspection No.** (e.g., INS-005)
   - **Select Transformer** (choose the one you created)
   - **Weather Condition** (optional: SUNNY, CLOUDY, RAINY)
   - **Inspected By** (optional: inspector name/email)
   - **Notes** (optional)
4. Click **"Confirm"**

### **Step 4: Upload Inspection Image** (Phase 2)
**⚠️ This is currently missing from the new detail page!**

**Expected flow:**
1. Click the inspection you just created
2. On the detail page, there should be an **"Upload Inspection Image"** button
3. Upload the thermal image taken during inspection
4. Image is stored as **INSPECTION** type
5. This image shows the **current state** of the transformer

**Current workaround:**
- Use the old transformer detail page to upload inspection images
- Or use API directly: `POST /api/images` with `type=INSPECTION` and `inspectionId={id}`

### **Step 5: Trigger AI Detection** (Phase 2 - Main Feature!)
1. On inspection detail page (with uploaded inspection image)
2. Click **"🤖 Detect Anomalies"** button in toolbar
3. Backend sends image to ML service (port 5001)
4. YOLOv8 model analyzes the image
5. Returns bounding boxes for detected anomalies
6. Backend saves detections as **AI annotations**
7. Annotations appear on canvas with colors:
   - 🔴 **Faulty** (red)
   - 🟢 **Loose Joint** (green)
   - 🔵 **Point Overload** (blue)
   - 🟡 **Potential Faulty** (yellow)

### **Step 6: Review AI Detections** (Phase 3)
1. View annotations in sidebar
2. Each annotation shows:
   - Source: 🤖 **AI Detection**
   - Confidence: e.g., **87%**
   - Class name
   - Bounding box coordinates
3. Click **"✓ Approve"** to accept detection
4. Click **"✗ Reject"** to reject false positive
5. Approved/Rejected status is tracked

### **Step 7: Add Manual Annotations** (Phase 3)
1. Click **"Draw"** mode in toolbar
2. Select class from dropdown
3. Click and drag on image to draw bounding box
4. Release mouse to create annotation
5. Source marked as 👤 **Manual**
6. Confidence set to **100%**

### **Step 8: Edit Annotations** (Phase 3)
1. Click **"Edit"** mode in toolbar
2. Click any bounding box to select
3. **Drag** to move the box
4. **Drag corners** to resize
5. Press **Delete** key to remove
6. Changes saved automatically with version control

### **Step 9: Export Feedback** (Phase 3)
1. Click **"Export Feedback"** (not in UI yet)
2. Backend generates report comparing:
   - AI annotations vs Human annotations
   - Approved detections
   - Rejected detections
   - Manual additions
3. Export as **JSON** or **CSV**
4. Used to retrain ML model

---

## 🐛 Current Issues & Fixes

### Issue 1: Detection Endpoint 404 ✅ FIXED
**Error:** `POST /api/inspections/{id}/detect` returns 404

**Cause:** Frontend calling `/detect` but backend expects `/detect-anomalies`

**Fix Applied:**
```typescript
// frontend/src/api/inspections.ts
export async function detectAnomalies(id: string, confidenceThreshold: number = 0.25) {
  return api<{...}>(`/api/inspections/${id}/detect-anomalies?confidenceThreshold=${confidenceThreshold}`, {
    method: 'POST',
  });
}
```

**Backend Endpoint:**
```java
@PostMapping("/{id}/detect-anomalies")
public ResponseEntity<DetectionResponse> detectAnomalies(
    @PathVariable UUID id,
    @RequestParam(defaultValue = "0.25") Double confidenceThreshold
)
```

### Issue 2: Annotations Endpoint 404 ✅ FIXED
**Error:** `GET /api/annotations/inspection/{id}` returns 404

**Cause:** Frontend using path parameter but backend expects query parameter

**Fix Applied:**
```typescript
// frontend/src/api/annotations.ts
export async function getAnnotationsByInspection(inspectionId: string) {
  return api<Annotation[]>(`/api/annotations?inspectionId=${inspectionId}`);
}
```

**Backend Endpoint:**
```java
@GetMapping("/api/annotations")
public ResponseEntity<List<AnnotationDTO>> getAnnotations(
    @RequestParam(required = false) String inspectionId
)
```

### Issue 3: Image Upload Missing ✅ FIXED
**Problem:** New inspection detail page didn't have image upload UI

**Solution Applied:**
Added FileDrop component and upload functionality to `InspectionDetailNew.tsx`:
- Shows warning banner when no inspection image uploaded
- FileDrop component for drag-and-drop or click to select
- Upload button with loading state
- Error handling
- Auto-refresh after successful upload

**How to use:**
1. Navigate to inspection detail page
2. If no image uploaded, you'll see a yellow warning banner
3. Drag & drop or click to select thermal image
4. Click "Upload Image" button
5. Wait for upload to complete
6. Image will appear on canvas
7. Now you can click "Detect Anomalies"

---

## 📝 API Endpoints Reference

### Inspections API
```bash
# Create inspection
POST /api/inspections
Body: {
  "inspectionNumber": "INS-005",
  "transformerId": "uuid",
  "weatherCondition": "SUNNY",
  "inspectedBy": "john@example.com"
}

# Get inspection
GET /api/inspections/{id}

# Upload inspection image
POST /api/inspections/{id}/upload-image?imageId={uuid}

# Trigger AI detection ✅ CORRECT ENDPOINT
POST /api/inspections/{id}/detect-anomalies?confidenceThreshold=0.25

# Update inspection
PUT /api/inspections/{id}
Body: {
  "status": "COMPLETED",
  "notes": "All anomalies resolved"
}

# Delete inspection
DELETE /api/inspections/{id}
```

### Annotations API
```bash
# Get annotations for inspection ✅ CORRECT ENDPOINT
GET /api/annotations?inspectionId={uuid}

# Create/update annotation
POST /api/annotations
Body: {
  "inspectionId": "uuid",
  "bbox": { "x1": 100, "y1": 150, "x2": 300, "y2": 400 },
  "className": "Faulty",
  "confidence": 0.87,
  "source": "HUMAN",
  "userId": "john@example.com"
}

# Approve annotation
PUT /api/annotations/{id}/approve?userId=john@example.com

# Reject annotation
PUT /api/annotations/{id}/reject?userId=john@example.com

# Delete annotation
DELETE /api/annotations/{id}?userId=john@example.com

# Get version history
GET /api/annotations/{id}/history
```

### Images API
```bash
# Upload image
POST /api/images
Content-Type: multipart/form-data
- file: thermal_image.jpg
- transformerId: uuid
- type: BASELINE | INSPECTION
- inspectionId: uuid (if type=INSPECTION)

# Download image
GET /api/images/{id}/download

# List images
GET /api/images?transformerId={uuid}&type=BASELINE
```

### ML Service API
```bash
# Check health
GET http://localhost:5001/api/health

# Detect anomalies (direct)
POST http://localhost:5001/api/detect
Body: {
  "image_path": "/path/to/image.jpg",
  "confidence_threshold": 0.25
}

# Get available classes
GET http://localhost:5001/api/classes
```

---

## 🧪 Testing Checklist

### Backend Tests
- [ ] Backend running on port 8080
- [ ] ML service running on port 5001
- [ ] Database connection working
- [ ] Test detect-anomalies endpoint with curl

```bash
# Test backend health
curl http://localhost:8080/api/health

# Test ML service health
curl http://localhost:5001/api/health

# Test detection (replace {id} with actual inspection ID)
curl -X POST http://localhost:8080/api/inspections/{id}/detect-anomalies
```

### Frontend Tests
- [ ] Frontend running on port 5174
- [ ] Can create inspection
- [ ] Can view inspection detail
- [ ] Canvas loads image
- [ ] Detect button triggers API
- [ ] Annotations display correctly
- [ ] Can draw manual annotations
- [ ] Can edit annotations
- [ ] Approve/reject works

---

## 🎯 Next Steps

1. **Add Image Upload to Detail Page**
   - Add FileDrop component
   - Add upload button
   - Show uploaded image preview

2. **Add Baseline Image Comparison**
   - Split canvas into two panels
   - Left: Baseline image
   - Right: Inspection image
   - Allow switching between single/dual view

3. **Add Undo/Redo**
   - Store annotation history in state
   - Add undo/redo buttons
   - Use version control from backend

4. **Add Export Feedback Button**
   - Add button to toolbar or sidebar
   - Call `/api/inspections/{id}/feedback-export`
   - Download JSON or CSV

5. **Improve Error Handling**
   - Better error messages
   - Show loading states
   - Handle network failures gracefully

---

## 💡 Tips

- **Confidence Threshold:** Default is 0.25 (25%). Lower = more detections but more false positives
- **Image Format:** JPG, PNG, JPEG supported. Thermal images work best
- **Model Classes:** Faulty, faulty_loose_joint, faulty_point_overload, potential_faulty
- **Version Control:** Every edit creates new version, parent_annotation_id tracks history
- **Soft Delete:** Deleted annotations set `is_active=false`, not removed from database

---

**Status:** Phase 2 & 3 Core Features ✅ Complete | Bug Fixes ✅ Applied | Testing 🔄 In Progress
