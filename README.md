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
| **Database** | MySQL (relational database) |
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

### Database Configuration 
The backend uses **MySQL** as the relational database.  

We have already exported the schema and sample data into a single SQL file:
[`Database-MYSQL/en3350_db.sql`](./transformer-inspector/Database-MYSQL/en3350_db.sql).

1. **Install MySQL Community Server**
   - Install **MySQL Community Server** (version **9.4.0** recommended, but ≥ 8.0 works).  
   - Install **MySQL Workbench** during setup.  
   - During installation, set your own **root username and password** → keep these safe, you’ll need them for configuration later.

2. **Verify MySQL Server is running**
   - Open **MySQL Workbench**.  
   - Check that your MySQL instance (e.g., *Local instance MySQL94*) is **running**.  
   - If it’s stopped, start it using the **Server Start/Stop** button.

3. **Create a new schema**
   - In Workbench, open a new query tab and run:  
     ```sql
     CREATE DATABASE en3350_db;
     ```
   - Or: Right-click inside the **Schemas** panel → *Create Schema* → enter `en3350_db`.  
   - Refresh schemas to confirm `en3350_db` is created.

4. **Import the SQL dump**
   - In Workbench, go to **Server > Data Import**.  
   - Select **Import from Self-Contained File**.  
     - File path:  
       ```
       transformer-inspector/Database-MYSQL/en3350_db.sql 
       ```
       
   - Set **Default Target Schema** to `en3350_db`.  
   - Set **Import Options** to **Dump Structure and Data**.  
   - Click **Start Import**.

5. **Verify imported tables**
   - Refresh the **Schemas** panel.  
   - Expand `en3350_db` → **Tables**.  
   - You should see tables such as `transformers`, `thermal_images`, and `users`.

```properties
# --- MySQL (persistent DB) ---
spring.datasource.url=jdbc:mysql://localhost:3306/en3350_db
spring.datasource.username=#YOUR_MYSQL_USERNAME
spring.datasource.password=#YOUR_MYSQL_PASSWORD
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect

# --- File storage ---
app.server.public-base-url=http://localhost:8080
app.storage.root=backend//uploads #Put the relative path, works across machines

# --- CORS (frontend) ---
app.cors.allowed-origins=http://localhost:5173

```
Then you can run the backend

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

### Hot Reload

- **Frontend**: Automatic reload via Vite HMR
- **Backend**: Use Spring Boot DevTools or manual restart
