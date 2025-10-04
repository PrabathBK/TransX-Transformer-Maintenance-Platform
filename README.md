# TransX - Transformer Maintenance Platform

> **Complete 4-Phase Implementation:** Transformer Management, Anomaly Detection, Annotation System, and Comprehensive Inspection Workflow

A full-stack application for managing electrical transformers with AI-powered thermal image analysis, annotation system, and comprehensive inspection workflow. Built with React, TypeScript, Spring Boot, MySQL, and YOLOv8 machine learning.

## Features

### Phase 1: Transformer & Image Management
- **Transformer Management** - Create, update, and manage transformers with code, location, and capacity information
- **Thermal Image Upload** - Upload thermal images tagged as **Baseline** (with environmental conditions: SUNNY/CLOUDY/RAINY) or **Maintenance**
- **Side-by-Side Comparison** - Compare images on transformer detail page with intelligent fallback display
- **Local File Storage** - Secure file uploads with organized storage structure

### Phase 2: AI-Powered Anomaly Detection
- **YOLOv8 Integration** - Real-time anomaly detection using trained YOLOv8p2 model
- **ML Service** - Flask-based microservice for machine learning inference
- **Confidence Thresholding** - Configurable detection sensitivity (default: 0.25)
- **Fault Classification** - Automatic detection of Faulty, Loose Joint, Point Overload, and Potential Faulty conditions

### Phase 3: Advanced Annotation System
- **Interactive Canvas** - Multi-mode annotation interface (View/Edit/Draw)
- **Bounding Box Annotations** - Manual drawing and editing of fault annotations
- **Annotation Workflow** - Approve/Reject detected anomalies with validation
- **Visual Feedback** - Color-coded fault types with legend
- **Image Scaling** - Automatic scaling for images of any size (handles 640×640 to 3077×1920+)
- **Zoom & Pan** - Full canvas navigation with zoom controls

### Phase 4: Inspection Management & Collaboration
- **Inspection Lifecycle** - Complete workflow from creation to completion
- **Multi-User Comments** - Real-time commenting system with author tracking
- **Notes System** - Inspection-specific notes and observations  
- **Status Tracking** - PENDING → IN_PROGRESS → COMPLETED workflow
- **Image Management** - Upload, remove, and re-upload inspection images before detection
- **Transformer Filtering** - Filter inspections by specific transformer

### Additional Features
- **Type-Safe APIs** - Full TypeScript support with defensive UI patterns
- **Real-time Updates** - Live comment updates and status changes
- **Responsive Design** - Works on desktop and tablet devices
- **Error Handling** - Comprehensive error boundaries and user feedback

## Technology Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | React 18, TypeScript, Vite, React Router, Konva.js (Canvas) |
| **Backend** | Spring Boot 3.3, Java 21, Spring Data JPA, RESTful APIs |
| **ML Service** | Flask, Python, YOLOv8p2, OpenCV, Pillow |
| **Database** | MySQL with comprehensive schema (transformers, inspections, annotations, comments) |
| **File Storage** | Local disk storage with HTTP serving and organized structure |
| **AI/ML** | YOLOv8p2 trained model for thermal anomaly detection |
| **CORS** | Configured for development environment |

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** ≥ 18 and npm
- **Java** 21 (or 17)
- **Python** ≥ 3.8 (for ML service)
- **Gradle** (handled by wrapper)
- **MySQL Community Server** ≥ 8.0 (version 9.4.0 recommended)
- **MySQL Workbench** (for database management)
- **IDE**: IntelliJ IDEA (recommended) or any Java IDE
- **curl** (optional, for API testing)

## Project Structure

```
transformer-inspector/
├── backend/                                # Spring Boot Application
│   ├── src/main/java/com/acme/backend/
│   │   ├── api/                           # REST Controllers
│   │   │   ├── TransformerController.java
│   │   │   ├── InspectionController.java
│   │   │   ├── InspectionCommentController.java
│   │   │   ├── AnnotationController.java
│   │   │   └── ThermalImageController.java
│   │   ├── api/dto/                       # Data Transfer Objects
│   │   │   ├── CreateTransformerReq.java, TransformerDTO.java
│   │   │   ├── CreateInspectionReq.java, InspectionDTO.java
│   │   │   ├── CreateAnnotationReq.java, AnnotationDTO.java
│   │   │   ├── InspectionCommentDTO.java
│   │   │   ├── DetectionResponse.java
│   │   │   └── ThermalImageDTO.java
│   │   ├── config/                        # Configuration Classes
│   │   │   ├── CorsConfig.java
│   │   │   ├── DataSeeder.java (with sample images)
│   │   │   └── StaticFileConfig.java
│   │   ├── domain/                        # Entity Models
│   │   │   ├── Inspection.java (with status workflow)
│   │   │   ├── Annotation.java (with fault classifications)
│   │   │   ├── InspectionComment.java (multi-user comments)
│   │   │   ├── Transformer.java
│   │   │   └── ThermalImage.java
│   │   ├── repo/                          # JPA Repositories
│   │   │   ├── InspectionRepo.java, TransformerRepo.java
│   │   │   ├── AnnotationRepo.java, InspectionCommentRepo.java
│   │   │   └── ThermalImageRepo.java
│   │   ├── service/                       # Business Logic
│   │   │   ├── InspectionService.java (with ML integration)
│   │   │   ├── InspectionCommentService.java
│   │   │   ├── MLServiceClient.java
│   │   │   └── FileStorageService.java
│   │   └── storage/                       # File Storage Service
│   │       └── FileStorageService.java
│   ├── src/main/resources/
│   │   └── application.properties (with ML service config)
│   └── build.gradle
│
├── frontend/
│   ├── src/
│   │   ├── api/                           # API Client Layer
│   │   │   ├── client.ts, transformers.ts, inspections.ts
│   │   │   ├── annotations.ts, inspectionComments.ts
│   │   │   └── images.ts
│   │   ├── components/                    # UI Components
│   │   │   ├── ErrorBoundary.tsx, Layout.tsx, FileDrop.tsx
│   │   │   ├── AnnotationCanvas.tsx (Konva.js canvas)
│   │   │   ├── AnnotationToolbar.tsx (mode controls)
│   │   │   ├── AnnotationLegend.tsx, AnnotationCard.tsx
│   │   │   ├── CommentsSection.tsx (real-time comments)
│   │   │   ├── NotesSection.tsx
│   │   │   └── Input.tsx, Select.tsx, Table.tsx, Modal.tsx
│   │   ├── pages/                         # Page Components
│   │   │   ├── Dashboard.tsx, TransformersList.tsx
│   │   │   ├── TransformerDetail.tsx, TransformerForm.tsx
│   │   │   ├── InspectionList.tsx
│   │   │   ├── InspectionDetailNew.tsx (full annotation interface)
│   │   │   ├── ImagesList.tsx, ImageUpload.tsx
│   │   │   └── InspectionDetail.tsx (legacy view)
│   │   ├── App.tsx, main.tsx
│   │   └── vite-env.d.ts
│   ├── package.json (with Konva.js dependencies)
│   └── tsconfig.json, vite.config.ts
│
├── ml-service/                            # Flask ML Microservice
│   ├── app.py                            # Flask application with YOLOv8
│   ├── requirements.txt                  # Python dependencies
│   ├── setup.sh                          # Setup script
│   └── README.md                         # ML service documentation
│
├── Faulty_Detection/                     # ML Model Training
│   ├── train_yolo_fixed.py              # Training script
│   ├── yolov8p2_single_inference.py     # Inference testing
│   ├── yolov8n.pt, yolov8p2.pt         # Model files
│   └── samples/                          # Training data
│
└── Database-MYSQL/
    └── en3350_db.sql            # Latest schema
```

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/PrabathBK/TransX-Transformer-Maintenance-Platform.git
cd TransX-Transformer-Maintenance-Platform
```

### 2. Database Setup

1. **Install MySQL Community Server**
   - Install **MySQL Community Server** (version **9.4.0** recommended, but ≥ 8.0 works)
   - Install **MySQL Workbench** during setup
   - During installation, set your own **root username and password** (keep these safe for later configuration)

2. **Verify MySQL Server is running**
   - Open **MySQL Workbench**
   - Check that your MySQL instance (e.g., *Local instance MySQL94*) is **running**
   - If stopped, start it using the **Server Start/Stop** button

3. **Create the database schema**
   ```sql
   CREATE DATABASE en3350_db;
   ```

4. **Import the complete SQL dump**
   - In Workbench, go to **Server > Data Import**
   - Select **Import from Self-Contained File**
   - File path: `Database-MYSQL/en3350_db.sql`
   - Set **Default Target Schema** to `en3350_db`
   - Set **Import Options** to **Dump Structure and Data**
   - Click **Start Import**

5. **Verify the import**
   - Refresh the **Schemas** panel
   - Expand `en3350_db` → **Tables**
   - You should see tables: `transformers`, `thermal_images`, `inspections`, `annotations`, `inspection_comments`

### 3. ML Service Setup

1. **Navigate to ML service directory**
   ```bash
   cd ml-service
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the ML service**
   ```bash
   python app.py
   ```
   
   🟢 ML Service will start at **http://localhost:5001**

### 4. Backend Configuration

1. **Navigate to backend directory**
   ```bash
   cd transformer-inspector/backend
   ```

2. **Configure `application.properties`**
   ```properties
   # MySQL Database Configuration
   spring.datasource.url=jdbc:mysql://localhost:3306/en3350_db
   spring.datasource.username=YOUR_MYSQL_USERNAME
   spring.datasource.password=YOUR_MYSQL_PASSWORD
   spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
   spring.jpa.hibernate.ddl-auto=update
   spring.jpa.show-sql=true
   spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect

   # File Storage Configuration
   app.server.public-base-url=http://localhost:8080
   app.storage.root=uploads

   # ML Service Configuration (YOLOv8 Detection)
   app.ml-service.url=http://localhost:5001
   app.ml-service.timeout=30000

   # CORS Configuration
   app.cors.allowed-origins=http://localhost:5173
   ```

3. **Start the backend server**
   ```bash
   ./gradlew bootRun
   ```
   
   🟢 Server will start at **http://localhost:8080**

### 5. Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd transformer-inspector/frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```
   
   🟢 Application will be available at **http://localhost:5173**

### Quick Multi-Service Startup

```bash
# Terminal 1: Start ML Service
cd ml-service && pip install -r requirements.txt && python app.py

# Terminal 2: Start Backend
cd transformer-inspector/backend && ./gradlew bootRun

# Terminal 3: Start Frontend  
cd transformer-inspector/frontend && npm install && npm run dev
```

## Testing the Complete System

### 1. Access the Application
- Open browser to **http://localhost:5173**
- Navigate to **Transformers** → Select any transformer
- Click **"View Inspections"** → **"Create New Inspection"**

### 2. Test Anomaly Detection Workflow
1. **Upload Inspection Image** - Try different sizes (640×640, 3077×1920, etc.)
2. **Remove/Re-upload** - Use "Remove Image" button to test image management
3. **Detect Anomalies** - Click "Detect Anomalies" to trigger YOLOv8 analysis
4. **Review Results** - See detected faults with confidence scores
5. **Approve/Reject** - Validate each detection with approve/reject buttons

### 3. Test Annotation System
1. **Manual Annotation** - Switch to "Draw" mode and create bounding boxes
2. **Edit Annotations** - Switch to "Edit" mode to resize/move annotations  
3. **Zoom & Pan** - Test canvas navigation with large images
4. **Save & Complete** - Save annotated image and complete inspection

### 4. Test Comment System
1. **Add Comments** - Write inspection notes and observations
2. **Multi-User** - Test with different author names
3. **Real-time Updates** - Comments appear immediately

### 5. Verify Data Persistence
- Check that annotations, comments, and status changes persist
- Verify transformer-specific inspection filtering works
- Test inspection completion workflow

## Application URLs & API Reference

### Frontend Routes
| URL | Description |
|-----|-------------|
| `http://localhost:5173` | Dashboard |
| `http://localhost:5173/transformers` | Transformer Overview |
| `http://localhost:5173/transformers/{ID}` | Transformer Details with Inspections |
| `http://localhost:5173/inspections` | All Inspections List |
| `http://localhost:5173/inspections/{ID}` | Full Inspection Interface with Annotations |
| `http://localhost:5173/images` | Thermal Images Management |

### API Endpoints

#### Transformer Management
- `GET /api/transformers` - List all transformers
- `POST /api/transformers` - Create new transformer
- `GET /api/transformers/{id}` - Get transformer details
- `PUT /api/transformers/{id}` - Update transformer
- `DELETE /api/transformers/{id}` - Delete transformer

#### Inspection Management (Phase 2-4)
- `GET /api/inspections` - List inspections with filtering (`?transformerId=uuid`)
- `POST /api/inspections` - Create new inspection
- `GET /api/inspections/{id}` - Get inspection details
- `PUT /api/inspections/{id}` - Update inspection
- `PUT /api/inspections/{id}/status` - Update inspection status
- `DELETE /api/inspections/{id}` - Delete inspection
- `POST /api/inspections/{id}/upload-image` - Upload inspection image
- `DELETE /api/inspections/{id}/inspection-image` - Remove inspection image
- `POST /api/inspections/{id}/detect-anomalies` - Trigger YOLOv8 detection
- `POST /api/inspections/{id}/upload-annotated-image` - Save annotated canvas

#### Annotation Management
- `GET /api/annotations/inspection/{inspectionId}` - Get annotations for inspection
- `POST /api/annotations` - Create new annotation
- `PUT /api/annotations/{id}` - Update annotation
- `DELETE /api/annotations/{id}` - Delete annotation
- `POST /api/annotations/{id}/approve` - Approve detected annotation
- `POST /api/annotations/{id}/reject` - Reject detected annotation

#### Comment System
- `GET /api/inspections/{inspectionId}/comments` - Get inspection comments
- `POST /api/inspections/{inspectionId}/comments` - Add new comment
- `PUT /api/inspection-comments/{id}` - Update comment
- `DELETE /api/inspection-comments/{id}` - Delete comment

#### Thermal Image Management
- `GET /api/images` - List all thermal images
- `POST /api/images` - Upload thermal image
- `GET /api/images/{id}` - Get image details

#### ML Service Integration
- `GET /api/inspections/ml-service/health` - Check ML service status
- Backend automatically calls ML service for anomaly detection

#### File Serving
- `GET /files/**` - Serve uploaded files and images

## File Storage Structure

Files are organized as follows:
```
uploads/
├── {UUID}/                              # Generated UUID for each upload
│   └── filename.jpg                     # Original filename preserved
├── {UUID}/
│   └── thermal_image_001.png
└── {UUID}/
    └── annotated_image_with_boxes.jpg   # Canvas-captured annotated images
```

- **Storage Path**: `<backend-root>/uploads/{uuid}/filename`
- **Public Access**: Files served via `/files/**` endpoint at `http://localhost:8080/files/{uuid}/filename`
- **Organization**: Each upload gets a unique UUID directory
- **Supported Formats**: JPG, PNG, JPEG for thermal images
- **Image Scaling**: Frontend automatically handles images from 640×640 to 3077×1920+ resolution

## Development & Advanced Usage

### Hot Reload & Development
- **Frontend**: Automatic reload via Vite HMR
- **Backend**: Use Spring Boot DevTools or manual restart
- **ML Service**: Manual restart required after model changes

### Environment Variables
Create a `.env` file in the frontend directory:
```env
VITE_API_BASE_URL=http://localhost:8080
```

### ML Service Configuration
The ML service can be configured in `ml-service/app.py`:
```python
# Model confidence threshold
DEFAULT_CONFIDENCE = 0.25

# Model path
MODEL_PATH = "yolov8p2.pt"  # Place your trained model here

# Server port
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
```

### Sample API Testing
```bash
# Get all transformers
curl http://localhost:8080/api/transformers

# Get inspections for a transformer
curl "http://localhost:8080/api/inspections?transformerId=TRANSFORMER_UUID"

# Check ML service health
curl http://localhost:8080/api/inspections/ml-service/health

# Trigger anomaly detection
curl -X POST "http://localhost:8080/api/inspections/INSPECTION_ID/detect-anomalies?confidenceThreshold=0.3"
```

### Troubleshooting

#### Common Issues
1. **ML Service Connection Failed**
   - Ensure Python dependencies installed: `pip install -r ml-service/requirements.txt`
   - Verify ML service running on port 5001
   - Check model file `yolov8p2.pt` exists in ml-service directory

2. **Large Images Not Displaying in Canvas**
   - Issue resolved: Canvas now auto-scales images of any size
   - Supports images from 640×640 to 3077×1920+ resolution

3. **Inspection Complete Button 404 Error**
   - Issue resolved: Added `/api/inspections/{id}/status` endpoint
   - Restart backend after code changes

4. **Database Connection Issues**
   - Verify MySQL server is running
   - Check credentials in `application.properties`
   - Ensure database `en3350_db` exists with proper schema

### Performance Notes
- **Image Processing**: Large thermal images (3000+ pixels) are handled efficiently
- **ML Inference**: YOLOv8 detection typically takes 1-3 seconds per image
- **Real-time Comments**: Updates appear immediately without page refresh
- **Canvas Performance**: Smooth zoom/pan even with high-resolution images

---

## License
This project is part of an academic assignment and is for educational purposes.

## Contributing
This is a complete implementation of the 4-phase transformer maintenance platform with AI-powered anomaly detection and comprehensive annotation system.
