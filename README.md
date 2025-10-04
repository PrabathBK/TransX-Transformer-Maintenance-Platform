# Transformer Inspector - TransX

> **Phase 1:** Transformer and Baseline Image Management

A full-stack application for managing electrical transformers and their thermal images, built with React, TypeScript, and Spring Boot.

## 🚀 Features

- **Transformer Management**: Create, update, and manage transformers with code, location, and capacity information
- **Thermal Image Upload**: Upload thermal images tagged as **Baseline** (with environmental conditions: SUNNY/CLOUDY/RAINY) or **Maintenance**
- **Side-by-Side Comparison**: Compare images on transformer detail page with intelligent fallback display
- **Type-Safe APIs**: Full TypeScript support with defensive UI patterns
- **Local File Storage**: Secure file uploads with organized storage structure

## 🏗️ Architecture design

| Component | Technology |
|-----------|------------|
| **Frontend** | React 18, TypeScript, Vite, React Router |
| **Backend** | Spring Boot 3.3, Java 21, Spring Data JPA |
| **Database** | H2 (development) |
| **File Storage** | Local disk storage with HTTP serving |
| **CORS** | Configured for development environment |

## 📋 Prerequisites

- **Node.js** ≥ 18 and npm
- **Java** 21 (or 17) 
- **Gradle** (handled by wrapper)
- **IDE**: IntelliJ IDEA (recommended) or any Java IDE
- **curl** (optional, for API testing)

## 📁 Project Structure

```
transformer-inspector/
├── backend/                                # Spring Boot Application
│   ├── src/main/java/com/acme/backend/
│   │   ├── api/                           # REST Controllers
│   │   │   ├── TransformerController.java
│   │   │   └── ThermalImageController.java
│   │   ├── api/dto/                       # Data Transfer Objects
│   │   │   ├── CreateTransformerReq.java
│   │   │   ├── TransformerDTO.java
│   │   │   └── ThermalImageDTO.java
│   │   ├── config/                        # Configuration Classes
│   │   │   ├── CorsConfig.java
│   │   │   └── StaticFileConfig.java
│   │   ├── domain/                        # Entity Models
│   │   │   ├── Transformer.java
│   │   │   └── ThermalImage.java
│   │   ├── repo/                          # JPA Repositories
│   │   │   ├── TransformerRepo.java
│   │   │   └── ThermalImageRepo.java
│   │   └── storage/                       # File Storage Service
│   │       └── FileStorageService.java
│   ├── src/main/resources/
│   │   └── application.properties
│   └── build.gradle
│
└── frontend/                              # React + TypeScript Application
    ├── src/
    │   ├── api/                          # API Client Layer
    │   │   ├── client.ts
    │   │   ├── transformers.ts
    │   │   └── images.ts
    │   ├── components/                   # Reusable Components
    │   │   ├── FileDrop.tsx
    │   │   ├── Input.tsx
    │   │   ├── Layout.tsx
    │   │   └── Select.tsx
    │   ├── pages/                        # Page Components
    │   │   ├── TransformersList.tsx
    │   │   └── TransformerDetail.tsx
    │   ├── App.tsx
    │   └── main.tsx
    ├── .env
    └── package.json
```

## 🚀 Quick Start

### Option 1: Step-by-step Setup

#### Backend Setup

1. **Open the backend project**
   ```bash
   cd transformer-inspector/backend
   ```

2. **Configure your IDE** (IntelliJ)
   - Set **Project SDK** to Java 21 (or 17)
   - Set **Gradle JVM** to the same Java version

3. **Run the application**
   ```bash
   ./gradlew bootRun
   ```
   
   Server will start at **http://localhost:8080**

#### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd transformer-inspector/frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```
   
   Application will be available at **http://localhost:5173**

### Option 2: Quick Start (TL;DR)

```bash
# Terminal 1: Backend
cd transformer-inspector/backend
./gradlew bootRun

# Terminal 2: Frontend  
cd transformer-inspector/frontend
cp .env.example .env
npm install
npm run dev
```

## 🌐 API Testing

Test the backend API with curl:

```bash
# List transformers (initially empty)
curl "http://localhost:8080/api/transformers?page=0&size=10"

# Create a new transformer
curl -X POST "http://localhost:8080/api/transformers" \
  -H "Content-Type: application/json" \
  -d '{"code":"TX-001","location":"Kandy","capacityKVA":1000}'

# List transformers again
curl "http://localhost:8080/api/transformers?page=0&size=10"
```

## ⚙️ Configuration

### Backend Configuration (`application.properties`)

```properties
# Database (H2 for development)
spring.datasource.url=jdbc:h2:mem:ti;DB_CLOSE_DELAY=-1;MODE=PostgreSQL
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.h2.console.enabled=true
spring.h2.console.path=/h2

# File Storage Configuration
app.storage.root=uploads
app.server.public-base-url=http://localhost:8080

# CORS Configuration (allows Vite dev server)
app.cors.allowed-origins=http://localhost:5173
```

## 🗂️ File Storage

- **Storage Path**: `<working-directory>/uploads/{transformerId}/{type}/filename`
- **Public Access**: Files served via `/files/**` endpoint
- **Organization**: Files organized by transformer ID and image type (baseline/maintenance)

## 🧭 Application Routes

| Route | Description |
|-------|-------------|
| `/transformers` | List and create transformers |
| `/transformers/:id` | Transformer details, image upload, and comparison |
| `/settings` | Settings page (placeholder) |

## 🛠️ Development Tools

### Database Console

Access H2 database console at: **http://localhost:8080/h2**

- **JDBC URL**: `jdbc:h2:mem:ti`
- **Username**: `sa`
- **Password**: *(empty)*

### Hot Reload

- **Frontend**: Automatic reload via Vite HMR
- **Backend**: Use Spring Boot DevTools or manual restart

## 🔍 Smart Thermal Detector

The Smart Thermal Detector is an advanced AI-powered system for thermal image analysis that combines similarity detection with YOLO-based anomaly detection.

### 🎯 Features

- **Intelligent Similarity Detection**: Compares thermal images using multiple algorithms
- **YOLO-based Anomaly Detection**: Detects thermal anomalies with high precision
- **Smart Visualization**: Conditional bounding box display based on change significance
- **Region Comparison**: Advanced analysis of detected regions between images
- **Multiple Detection Classes**: Supports various fault types including:
  - `Faulty` - General fault detection
  - `faulty_loose_joint` - Loose connection detection
  - `faulty_point_overload` - Overload point detection
  - `potential_faulty` - Early warning detection
  - `normal` - Normal thermal signature

### 📋 Prerequisites for Smart Thermal Detector

```bash
# Required Python packages
pip install opencv-python numpy matplotlib ultralytics
```

### 🚀 How to Run Smart Thermal Detector

#### Basic Usage
```bash
# Navigate to the model directory
cd path/to/TransX-Transformer-Maintenance-Platform/transformer-inspector/Faulty_Detection/

# Basic comparison (uses default thresholds)
python similarity_yolo_system.py reference_image.jpg target_image.jpg

# With custom similarity threshold
python similarity_yolo_system.py reference_image.jpg target_image.jpg 0.5

# With custom similarity and change thresholds
python similarity_yolo_system.py reference_image.jpg target_image.jpg 0.5 0.2
```

#### Parameter Explanation
```bash
python similarity_yolo_system.py <reference_image> <target_image> [similarity_threshold] [change_threshold]
```

- **`reference_image`**: Path to baseline thermal image
- **`target_image`**: Path to inspection thermal image  
- **`similarity_threshold`**: Images must be this similar for comparison analysis (default: 0.5)
- **`change_threshold`**: Change magnitude threshold for visualization (default: 0.2)

#### Smart Bounding Box Logic

The system intelligently decides when to show bounding boxes:

**For DIFFERENT Images (Independent Analysis):**
- ✅ Always shows bounding boxes
- 🎯 Logic: Different scenes = independent YOLO analysis
- 📊 Use case: Analyzing completely different thermal images

**For SIMILAR Images (Change Analysis):**
- ✅ Shows bounding boxes only if change ≥ threshold
- 🎯 Logic: Similar scenes = comparison analysis with significance threshold
- 📊 Use case: Monitoring changes in the same equipment over time

#### Example Usage Scenarios

```bash
# Scenario 1: Different transformer locations (always show detections)
python similarity_yolo_system.py transformer_A.jpg transformer_B.jpg

# Scenario 2: Same transformer, high sensitivity to changes
python similarity_yolo_system.py baseline.jpg inspection.jpg 0.7 0.1

# Scenario 3: Same transformer, low sensitivity (only major changes)
python similarity_yolo_system.py baseline.jpg inspection.jpg 0.6 0.5
```

### 📊 Output and Results

The system generates:

1. **Console Analysis**: Detailed step-by-step analysis output
2. **Visualization Images**: Side-by-side comparison with conditional bounding boxes
3. **JSON Results**: Complete analysis data saved to `similarity_yolo_results_[timestamp].json`
4. **Detection Images**: Individual detection results in `clean_detection_results/`

#### Sample Output Structure
```
Step 1: Similarity Analysis
Step 2: YOLO Inference (Target image only)
Step 3: Region Comparison Analysis  
Step 4: Visualization Generation

ANALYSIS SUMMARY:
- Similarity: DIFFERENT/SIMILAR (confidence %)
- YOLO Analysis: X total detections (Y high, Z low confidence)
- Region Analysis: Significant changes detected/No significant changes
- Processing Time: Detailed timing breakdown
```

### 🎨 Visualization Features

- **High Confidence Detections**: Solid lines, full opacity, white text labels
- **Low Confidence Detections**: Dashed lines, reduced opacity, black text labels  
- **Color Coding**: Red/pink for faulty conditions, orange/yellow for normal
- **Confidence Indicators**: [H] for high confidence, [L] for low confidence
- **Change Status**: Visual indicators for condition changes (OK/WARN/etc.)

### 🔧 Model Configuration

The system uses a pre-trained YOLOv8 model (`yolov8p2.pt`) specifically trained for thermal anomaly detection in electrical equipment. The model path is automatically configured to:

```
/path/to/TransX-Transformer-Maintenance-Platform/transformer-inspector/Faulty_Detection/yolov8p2.pt
```

### 🚀 Integration with Main Application

The Smart Thermal Detector can be integrated with the main TransX application for:

- Automated anomaly detection during image uploads
- Scheduled monitoring of baseline vs maintenance images
- Alert generation for significant thermal changes
- Historical trend analysis of thermal conditions

### 📈 Performance Optimization

- **Swift Similarity Matching**: Optimized algorithms for fast image comparison
- **Efficient YOLO Inference**: Single-pass detection on target images only
- **Smart Threshold Logic**: Reduces unnecessary processing for insignificant changes
- **Batch Processing**: Supports multiple image analysis workflows
