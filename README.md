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
