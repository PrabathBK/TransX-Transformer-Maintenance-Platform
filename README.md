# Transformer Inspector - TransX

> **Phase 1:** Transformer and Baseline Image Management

A full-stack application for managing electrical transformers and their thermal images, built with React, TypeScript, Spring Boot, and MySQL.

## Features

- **Transformer Management** - Create, update, and manage transformers with code, location, and capacity information
- **Thermal Image Upload** - Upload thermal images tagged as **Baseline** (with environmental conditions: SUNNY/CLOUDY/RAINY) or **Maintenance**
- **Side-by-Side Comparison** - Compare images on transformer detail page with intelligent fallback display
- **Type-Safe APIs** - Full TypeScript support with defensive UI patterns
- **Local File Storage** - Secure file uploads with organized storage structure

## Technology Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | React 18, TypeScript, Vite, React Router |
| **Backend** | Spring Boot 3.3, Java 21, Spring Data JPA |
| **Database** | MySQL (relational database) |
| **File Storage** | Local disk storage with HTTP serving |
| **CORS** | Configured for development environment |

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** ≥ 18 and npm
- **Java** 21 (or 17)
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
├── frontend/
│   ├── src/
│   │   ├── api/                           # API Client Layer
│   │   │   ├── client.ts
│   │   │   ├── images.ts
│   │   │   └── transformers.ts
│   │   ├── components/                    # Reusable UI Components
│   │   │   ├── ErrorBoundary.tsx
│   │   │   ├── FileDrop.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Layout.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Select.tsx
│   │   │   └── Table.tsx
│   │   ├── pages/                         # Page Components
│   │   │   ├── Dashboard.tsx
│   │   │   ├── ImagesList.tsx
│   │   │   ├── ImageUpload.tsx
│   │   │   ├── TransformerDetail.tsx
│   │   │   ├── TransformerForm.tsx
│   │   │   └── TransformersList.tsx
│   │   ├── App.tsx
│   │   └── main.tsx
│   └── package.json
│
└── Database-MYSQL/
    └── en3350_db.sql                      # Database schema and sample data
```

## Quick Start

### Database Setup

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

4. **Import the SQL dump**
   - In Workbench, go to **Server > Data Import**
   - Select **Import from Self-Contained File**
   - File path: `transformer-inspector/Database-MYSQL/en3350_db.sql`
   - Set **Default Target Schema** to `en3350_db`
   - Set **Import Options** to **Dump Structure and Data**
   - Click **Start Import**

5. **Verify the import**
   - Refresh the **Schemas** panel
   - Expand `en3350_db` → **Tables**
   - You should see tables: `transformers`, `thermal_images`, and `users`

### Backend Configuration

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
   app.storage.root=backend/uploads

   # CORS Configuration
   app.cors.allowed-origins=http://localhost:5173
   ```

3. **Start the backend server**
   ```bash
   ./gradlew bootRun
   ```
   
   🟢 Server will start at **http://localhost:8080**

### Frontend Setup

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

### One-Line Setup (TL;DR)

```bash
# Terminal 1: Start Backend
cd transformer-inspector/backend && ./gradlew bootRun

# Terminal 2: Start Frontend  
cd transformer-inspector/frontend && npm install && npm run dev
```

## Application URLs

### Frontend Routes
| URL | Description |
|-----|-------------|
| `http://localhost:5173` | Dashboard |
| `http://localhost:5173/transformers` | Transformer Overview |
| `http://localhost:5173/transformers/{ID}` | Transformer Details |

### API Endpoints

#### Transformer Management
- `GET /api/transformers` - List all transformers
- `POST /api/transformers` - Create new transformer
- `GET /api/transformers/{id}` - Get transformer details
- `PUT /api/transformers/{id}` - Update transformer
- `DELETE /api/transformers/{id}` - Delete transformer

#### Thermal Image Management
- `GET /api/images` - List all thermal images
- `POST /api/images` - Upload thermal image

#### File Serving
- `GET /files/**` - Serve uploaded files

## File Storage Structure

Files are organized as follows:
```
uploads/
├── {transformerId}/
│   ├── baseline/
│   │   └── filename.jpg
│   └── maintenance/
│       └── filename.jpg
```

- **Storage Path**: `<working-directory>/uploads/{transformerId}/{type}/filename`
- **Public Access**: Files served via `/files/**` endpoint
- **Organization**: Files organized by transformer ID and image type (baseline/maintenance)

## Development

### Hot Reload
- **Frontend**: Automatic reload via Vite HMR
- **Backend**: Use Spring Boot DevTools or manual restart

### Environment Variables
Create a `.env` file in the frontend directory:
```env
VITE_API_BASE_URL=http://localhost:8080
```

### Testing the API
```bash
# Get all transformers
curl http://localhost:8080/api/transformers

# Get transformer by ID
curl http://localhost:8080/api/transformers/1
```


---

**Built with ❤️ for electrical transformer management and thermal analysis**
