# ☕ Spring Boot Backend Architecture - Complete Teaching Guide

## Table of Contents
1. [What is Spring Boot?](#what-is-spring-boot)
2. [Core Concepts](#core-concepts)
3. [Spring Boot Architecture](#spring-boot-architecture)
4. [Dependency Injection & Beans](#dependency-injection--beans)
5. [TransX Backend Architecture](#transx-backend-architecture)
6. [Request Flow Diagrams](#request-flow-diagrams)
7. [Hands-On Examples](#hands-on-examples)

---

## What is Spring Boot?

### 🎯 Simple Definition

**Spring Boot** is a Java framework that makes it **ridiculously easy** to create production-ready web applications.

Think of it as:
- 🏗️ **Pre-built Building Blocks** - Like LEGO pieces for web apps
- 🚀 **Auto-Configuration** - It sets up common things automatically
- 📦 **All-in-One Package** - Includes web server, database connection, security, etc.

### 🤔 Why Spring Boot?

**Without Spring Boot** (Old Way):
```java
// You had to manually configure EVERYTHING
- Database connection pool (20+ lines of XML)
- Web server setup (Tomcat configuration)
- JSON serialization
- Error handling
- Security setup
- Transaction management
... 500+ lines of XML configuration files! 😱
```

**With Spring Boot** (Modern Way):
```java
@SpringBootApplication
public class BackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }
}

// Done! 🎉
// Spring Boot automatically configures:
// ✅ Embedded Tomcat server
// ✅ Database connection (if you add dependency)
// ✅ JSON converter (Jackson)
// ✅ Error pages
// ✅ Logging
```

### 📊 Spring vs Spring Boot

```
┌─────────────────────────────────────────────────────────────┐
│                    SPRING FRAMEWORK                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │   Spring   │  │   Spring   │  │   Spring   │            │
│  │    Core    │  │    MVC     │  │    Data    │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│       ↑               ↑                 ↑                    │
│       │               │                 │                    │
│       └───────────────┼─────────────────┘                    │
│                       │                                      │
│                       ▼                                      │
│            ┌──────────────────────┐                         │
│            │   SPRING BOOT        │                         │
│            │  (Auto-Configuration)│                         │
│            │  + Embedded Server   │                         │
│            └──────────────────────┘                         │
└─────────────────────────────────────────────────────────────┘

Spring Framework     = Car engine (powerful but needs assembly)
Spring Boot          = Complete car (ready to drive)
```

---

## Core Concepts

### 1. **Inversion of Control (IoC)** 🔄

**Traditional Programming** (You control objects):
```java
public class CarService {
    private Engine engine;
    
    public CarService() {
        // You create the object
        this.engine = new V8Engine();  // Tightly coupled!
    }
}
```

**Spring's IoC** (Spring controls objects):
```java
@Service
public class CarService {
    private Engine engine;
    
    // Spring automatically provides the engine
    public CarService(Engine engine) {
        this.engine = engine;  // Loosely coupled!
    }
}
```

**Why is this better?**
- ✅ Easy to test (can inject mock engine)
- ✅ Easy to swap implementations (V8Engine → ElectricEngine)
- ✅ Spring manages lifecycle (creation, destruction)

### 2. **Dependency Injection (DI)** 💉

**What is a Dependency?**
```
If Class A uses Class B, then B is a "dependency" of A.

Example:
┌─────────────────┐       needs      ┌──────────────┐
│ CarService      │─────────────────→│ Engine       │
│ (Class A)       │                  │ (Class B)    │
└─────────────────┘                  └──────────────┘
       CarService depends on Engine
```

**Three Types of Injection:**

#### **A. Constructor Injection** ⭐ (Best Practice - Used in TransX)
```java
@Service
public class InspectionService {
    private final InspectionRepo repo;
    private final MLServiceClient mlClient;
    
    // Spring injects dependencies via constructor
    public InspectionService(InspectionRepo repo, MLServiceClient mlClient) {
        this.repo = repo;
        this.mlClient = mlClient;
    }
}
```

**Why Constructor Injection?**
- ✅ Dependencies are required (can't create service without them)
- ✅ Immutable (`final` keyword)
- ✅ Easy to test (just pass mocks to constructor)
- ✅ Clear dependencies (you see all dependencies in one place)

#### **B. Field Injection** (Discouraged)
```java
@Service
public class InspectionService {
    @Autowired  // Don't do this!
    private InspectionRepo repo;
}
```

**Problems:**
- ❌ Can't make fields `final`
- ❌ Hard to test (need reflection to inject mocks)
- ❌ Hidden dependencies

#### **C. Setter Injection** (Rarely used)
```java
@Service
public class InspectionService {
    private InspectionRepo repo;
    
    @Autowired
    public void setRepo(InspectionRepo repo) {
        this.repo = repo;
    }
}
```

---

## Spring Boot Architecture

### 🏛️ Layered Architecture (TransX Project)

```
┌──────────────────────────────────────────────────────────────┐
│                    CLIENT (React Frontend)                    │
│                     http://localhost:5173                     │
└───────────────────────────┬──────────────────────────────────┘
                            │ HTTP Requests (REST API)
                            │ GET /api/transformers
                            │ POST /api/inspections/{id}/detect-anomalies
                            ▼
┌──────────────────────────────────────────────────────────────┐
│              SPRING BOOT APPLICATION LAYER                    │
│                   (Port 8080)                                 │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  1. CONTROLLER LAYER (@RestController)                 │  │
│  │     ┌─────────────────────────────────────────┐        │  │
│  │     │ InspectionController.java               │        │  │
│  │     │ TransformerController.java              │        │  │
│  │     │ AnnotationController.java               │        │  │
│  │     └─────────────────────────────────────────┘        │  │
│  │  • Handles HTTP requests/responses                     │  │
│  │  • Validates input (@Valid)                            │  │
│  │  • Maps URLs to methods (@GetMapping, @PostMapping)    │  │
│  │  • Returns DTOs (Data Transfer Objects)               │  │
│  └──────────────────┬─────────────────────────────────────┘  │
│                     │ Calls                                   │
│                     ▼                                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  2. SERVICE LAYER (@Service)                           │  │
│  │     ┌─────────────────────────────────────────┐        │  │
│  │     │ InspectionService.java                  │        │  │
│  │     │ AnnotationService.java                  │        │  │
│  │     │ MLServiceClient.java                    │        │  │
│  │     └─────────────────────────────────────────┘        │  │
│  │  • Contains BUSINESS LOGIC                             │  │
│  │  • Orchestrates operations (calls multiple repos)      │  │
│  │  • Manages transactions (@Transactional)               │  │
│  │  • Converts between Entity ↔ DTO                      │  │
│  └──────────────────┬─────────────────────────────────────┘  │
│                     │ Calls                                   │
│                     ▼                                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  3. REPOSITORY LAYER (@Repository)                     │  │
│  │     ┌─────────────────────────────────────────┐        │  │
│  │     │ InspectionRepo.java (Interface)         │        │  │
│  │     │ extends JpaRepository                   │        │  │
│  │     │ TransformerRepo.java                    │        │  │
│  │     │ AnnotationRepo.java                     │        │  │
│  │     └─────────────────────────────────────────┘        │  │
│  │  • Database access methods                             │  │
│  │  • CRUD operations (Create, Read, Update, Delete)      │  │
│  │  • Custom queries (@Query)                             │  │
│  │  • Spring Data JPA auto-implements methods             │  │
│  └──────────────────┬─────────────────────────────────────┘  │
│                     │ Uses                                    │
│                     ▼                                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  4. ENTITY/DOMAIN LAYER (@Entity)                      │  │
│  │     ┌─────────────────────────────────────────┐        │  │
│  │     │ Inspection.java                         │        │  │
│  │     │ Transformer.java                        │        │  │
│  │     │ Annotation.java                         │        │  │
│  │     └─────────────────────────────────────────┘        │  │
│  │  • JPA entities (mapped to database tables)            │  │
│  │  • Contain field definitions                           │  │
│  │  • Relationships (@ManyToOne, @OneToMany)              │  │
│  │  • NO business logic (just data + getters/setters)     │  │
│  └──────────────────┬─────────────────────────────────────┘  │
│                     │ Persisted to                            │
└─────────────────────┼─────────────────────────────────────────┘
                      ▼
        ┌─────────────────────────────┐
        │    DATABASE (MySQL)         │
        │    en3350_db               │
        │  Tables: transformers,      │
        │  inspections, annotations   │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│              CROSS-CUTTING CONCERNS                           │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  CONFIG LAYER (@Configuration)                         │  │
│  │  • CorsConfig.java - CORS settings                     │  │
│  │  • StaticFileConfig.java - File serving                │  │
│  │  • application.properties - App settings               │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### 🔄 Data Flow Through Layers

```
Example: GET /api/inspections/{id}

1. HTTP Request arrives
   ↓
2. DispatcherServlet (Spring's front controller)
   ↓
3. @RestController - InspectionController.getInspectionById(UUID id)
   ↓
4. @Service - InspectionService.getInspectionById(id)
   ↓
5. @Repository - InspectionRepo.findById(id)
   ↓
6. JPA/Hibernate - Generates SQL: SELECT * FROM inspections WHERE id = ?
   ↓
7. MySQL Database - Returns row
   ↓
8. JPA/Hibernate - Converts row to Inspection entity
   ↓
9. InspectionService - Converts Inspection entity to InspectionDTO
   ↓
10. InspectionController - Returns ResponseEntity<InspectionDTO>
    ↓
11. Jackson (JSON library) - Serializes DTO to JSON
    ↓
12. HTTP Response sent to frontend
```

---

## Dependency Injection & Beans

### 🫘 What is a Bean?

**Bean** = An object managed by Spring

```
Regular Java Object:
You create it → You manage it → You destroy it

Spring Bean:
Spring creates it → Spring manages it → Spring destroys it
```

### 📝 How to Create a Bean?

#### **Method 1: Component Scanning** (Most Common)

Spring automatically detects classes with these annotations:

```java
@Component      // Generic bean
@Service        // Business logic layer
@Repository     // Data access layer
@Controller     // Web MVC controller
@RestController // RESTful web service controller
@Configuration  // Configuration class
```

**Example from TransX:**
```java
@Service  // ← This makes it a bean!
public class InspectionService {
    // Spring will create ONE instance of this class
    // and inject it wherever needed
}
```

#### **Method 2: @Bean Annotation** (For third-party libraries)

```java
@Configuration
public class AppConfig {
    
    @Bean  // ← Manually create a bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

### 🔍 Spring Bean Container (ApplicationContext)

```
┌──────────────────────────────────────────────────────────┐
│        SPRING IOC CONTAINER (ApplicationContext)         │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Bean Definitions (Blueprints)                  │    │
│  │  • InspectionService                            │    │
│  │  • InspectionRepo                               │    │
│  │  • MLServiceClient                              │    │
│  │  • TransformerController                        │    │
│  └─────────────────────────────────────────────────┘    │
│              ↓                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Bean Instances (Actual Objects)                │    │
│  │  ┌──────────────────┐                           │    │
│  │  │ inspectionService│ ← Singleton (1 instance)  │    │
│  │  └──────────────────┘                           │    │
│  │  ┌──────────────────┐                           │    │
│  │  │ inspectionRepo   │ ← Singleton (1 instance)  │    │
│  │  └──────────────────┘                           │    │
│  │  ┌──────────────────┐                           │    │
│  │  │ mlServiceClient  │ ← Singleton (1 instance)  │    │
│  │  └──────────────────┘                           │    │
│  └─────────────────────────────────────────────────┘    │
│                                                           │
│  Spring manages:                                         │
│  • Creation (calls constructors)                         │
│  • Dependency Injection (passes dependencies)            │
│  • Lifecycle (startup/shutdown)                          │
│  • Scope (singleton, prototype, request, etc.)           │
└──────────────────────────────────────────────────────────┘
```

### 🔄 Bean Lifecycle

```
1. INSTANTIATION
   ┌──────────────────────────────────────┐
   │ Spring reads @Service annotation     │
   │ Creates instance:                    │
   │ new InspectionService(repo, client)  │
   └──────────────────────────────────────┘
                  ↓
2. DEPENDENCY INJECTION
   ┌──────────────────────────────────────┐
   │ Spring injects dependencies:         │
   │ • inspectionRepo                     │
   │ • mlServiceClient                    │
   └──────────────────────────────────────┘
                  ↓
3. INITIALIZATION
   ┌──────────────────────────────────────┐
   │ Spring calls initialization methods  │
   │ (if you have @PostConstruct)         │
   └──────────────────────────────────────┘
                  ↓
4. READY TO USE
   ┌──────────────────────────────────────┐
   │ Bean is available for injection      │
   │ Controllers can now use it           │
   └──────────────────────────────────────┘
                  ↓
5. DESTRUCTION (on app shutdown)
   ┌──────────────────────────────────────┐
   │ Spring calls @PreDestroy methods     │
   │ Releases resources                   │
   └──────────────────────────────────────┘
```

### 🎯 Bean Scopes

```java
@Service
@Scope("singleton")  // Default - ONE instance for entire app
public class InspectionService { }

@Service
@Scope("prototype")  // NEW instance every time it's injected
public class ReportGenerator { }

@Service
@Scope("request")    // NEW instance per HTTP request (web only)
public class UserSession { }
```

**TransX uses Singleton scope** (default) for all services.

---

## TransX Backend Architecture

### 📁 Package Structure

```
com.acme.backend/
├── BackendApplication.java    ← Main entry point
├── api/                        ← REST Controllers
│   ├── AnnotationController.java
│   ├── InspectionController.java
│   ├── TransformerController.java
│   └── dto/                    ← Data Transfer Objects
│       ├── AnnotationDTO.java
│       ├── InspectionDTO.java
│       └── DetectionResponse.java
├── config/                     ← Configuration classes
│   ├── CorsConfig.java
│   ├── StaticFileConfig.java
│   └── DataSeeder.java
├── domain/                     ← JPA Entities
│   ├── Annotation.java
│   ├── Inspection.java
│   ├── Transformer.java
│   └── ThermalImage.java
├── repo/                       ← Spring Data Repositories
│   ├── AnnotationRepo.java
│   ├── InspectionRepo.java
│   └── TransformerRepo.java
├── service/                    ← Business Logic
│   ├── InspectionService.java
│   ├── AnnotationService.java
│   ├── MLServiceClient.java
│   └── FileStorageService.java
└── storage/                    ← File handling
    └── FileStorageService.java
```

### 🎯 Bean Dependency Graph (TransX Project)

```
┌──────────────────────────────────────────────────────────────┐
│                   SPRING BEAN CONTAINER                       │
│                                                               │
│   ┌──────────────────────────────────────────────────┐      │
│   │ InspectionController (Bean)                      │      │
│   │  @RestController                                 │      │
│   │  ┌────────────────────────────────────┐          │      │
│   │  │ Depends on:                        │          │      │
│   │  │ • InspectionService                │          │      │
│   │  │ • MLServiceClient                  │          │      │
│   │  └────────────────────────────────────┘          │      │
│   └───────────────┬──────────────────────────────────┘      │
│                   │                                          │
│                   ▼ Spring injects                           │
│   ┌──────────────────────────────────────────────────┐      │
│   │ InspectionService (Bean)                         │      │
│   │  @Service                                        │      │
│   │  ┌────────────────────────────────────┐          │      │
│   │  │ Depends on:                        │          │      │
│   │  │ • InspectionRepo                   │          │      │
│   │  │ • AnnotationRepo                   │          │      │
│   │  │ • TransformerRepo                  │          │      │
│   │  │ • ThermalImageRepo                 │          │      │
│   │  │ • MLServiceClient                  │          │      │
│   │  │ • InspectionHistoryService         │          │      │
│   │  └────────────────────────────────────┘          │      │
│   └───────────────┬──────────────────────────────────┘      │
│                   │                                          │
│                   ▼ Spring injects                           │
│   ┌──────────────────────────────────────────────────┐      │
│   │ InspectionRepo (Bean)                            │      │
│   │  interface extends JpaRepository                 │      │
│   │  • Spring Data JPA auto-implements!              │      │
│   │  • No manual code needed                         │      │
│   └──────────────────────────────────────────────────┘      │
│                                                               │
│   ┌──────────────────────────────────────────────────┐      │
│   │ MLServiceClient (Bean)                           │      │
│   │  @Service                                        │      │
│   │  ┌────────────────────────────────────┐          │      │
│   │  │ Depends on:                        │          │      │
│   │  │ • RestTemplate (for HTTP calls)    │          │      │
│   │  └────────────────────────────────────┘          │      │
│   └──────────────────────────────────────────────────┘      │
│                                                               │
│   ┌──────────────────────────────────────────────────┐      │
│   │ CorsConfig (Bean)                                │      │
│   │  @Configuration                                  │      │
│   │  • Returns WebMvcConfigurer bean                 │      │
│   └──────────────────────────────────────────────────┘      │
└──────────────────────────────────────────────────────────────┘

Key Points:
• Controller depends on Service
• Service depends on Repositories
• Spring automatically wires everything together
• You just declare dependencies in constructor
```

### 🔄 How Beans are Wired in TransX

**Example: InspectionController**

```java
@RestController
@RequestMapping("/api/inspections")
public class InspectionController {
    
    private final InspectionService inspectionService;
    private final MLServiceClient mlServiceClient;
    
    // Constructor injection - Spring provides dependencies
    public InspectionController(
            InspectionService inspectionService,    // ← Spring finds this bean
            MLServiceClient mlServiceClient) {      // ← Spring finds this bean
        this.inspectionService = inspectionService;
        this.mlServiceClient = mlServiceClient;
    }
}
```

**What Spring does:**
```
1. Scan for @RestController annotation
2. Find constructor parameters: InspectionService, MLServiceClient
3. Look in bean container for these types
4. Find matching beans (both are @Service annotated)
5. Create InspectionController with these beans
6. Store InspectionController as a bean
```

---

## Request Flow Diagrams

### 🔍 Flow 1: Simple GET Request

**User Request**: `GET /api/transformers/123`

```
┌─────────────┐
│  FRONTEND   │ HTTP GET /api/transformers/123
│  (React)    │────────────────────┐
└─────────────┘                    │
                                   ▼
                    ┌──────────────────────────────┐
                    │  SPRING BOOT SERVER          │
                    │  (Port 8080)                 │
                    │                              │
                    │  ┌────────────────────────┐  │
                    │  │ 1. DispatcherServlet  │  │
                    │  │ (Spring's Router)     │  │
                    │  │ • Receives request    │  │
                    │  │ • Finds handler       │  │
                    │  └───────────┬───────────┘  │
                    │              │               │
                    │              ▼               │
                    │  ┌────────────────────────┐  │
                    │  │ 2. TransformerController│ 
                    │  │                        │  │
@RestController     │  │ @GetMapping("/{id}")  │  │
@RequestMapping     │  │ public TransformerDTO │  │
("/api/transformers")  │ get(@PathVariable     │  │
                    │  │     UUID id) {        │  │
                    │  │   return repo         │  │
                    │  │     .findById(id)     │  │
                    │  │     .map(this::toDTO) │  │
                    │  │ }                     │  │
                    │  └───────────┬───────────┘  │
                    │              │               │
                    │              ▼ Calls         │
                    │  ┌────────────────────────┐  │
                    │  │ 3. TransformerRepo    │  │
                    │  │ (Spring Data JPA)     │  │
                    │  │                       │  │
interface extends   │  │ Optional<Transformer> │  │
JpaRepository       │  │ findById(UUID id);    │  │
                    │  │                       │  │
                    │  │ Spring generates:     │  │
                    │  │ SELECT * FROM         │  │
                    │  │ transformers          │  │
                    │  │ WHERE id = ?          │  │
                    │  └───────────┬───────────┘  │
                    │              │               │
                    └──────────────┼───────────────┘
                                   ▼
                            ┌──────────────┐
                            │   MYSQL      │
                            │   Database   │
                            └──────┬───────┘
                                   │
                                   ▼ Returns row
                    ┌──────────────────────────────┐
                    │  JPA/Hibernate               │
                    │  • Converts row to entity    │
                    │  • Returns Transformer obj   │
                    └──────────┬───────────────────┘
                               │
                               ▼ Returns to Controller
                    ┌──────────────────────────────┐
                    │  Controller converts to DTO  │
                    │  Transformer → TransformerDTO│
                    └──────────┬───────────────────┘
                               │
                               ▼ Returns
                    ┌──────────────────────────────┐
                    │  Jackson (JSON Library)      │
                    │  Serializes DTO to JSON:     │
                    │  {                           │
                    │    "id": "123",              │
                    │    "code": "TX-001",         │
                    │    "location": "Kandy"       │
                    │  }                           │
                    └──────────┬───────────────────┘
                               │
                               ▼ HTTP Response
┌─────────────┐               
│  FRONTEND   │◄──────────────
│  Receives   │
│  JSON data  │
└─────────────┘
```

---

### 🤖 Flow 2: Complex POST with ML Integration

**User Request**: `POST /api/inspections/{id}/detect-anomalies`

```
┌──────────────────────────────────────────────────────────────────┐
│  FRONTEND (React)                                                │
│  User clicks "Detect Anomalies" button                          │
└──────────────┬───────────────────────────────────────────────────┘
               │
               │ POST /api/inspections/abc-123/detect-anomalies
               │ ?confidenceThreshold=0.3
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  SPRING BOOT - InspectionController                              │
│                                                                   │
│  @PostMapping("/{id}/detect-anomalies")                         │
│  public DetectionResponse detectAnomalies(                      │
│      @PathVariable UUID id,                                     │
│      @RequestParam Double confidenceThreshold) {                │
│                                                                   │
│      return inspectionService.detectAnomalies(                  │
│          id, confidenceThreshold);                              │
│  }                                                               │
└──────────────┬───────────────────────────────────────────────────┘
               │ Calls
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  SPRING BOOT - InspectionService                                 │
│                                                                   │
│  @Service                                                        │
│  @Transactional                                                  │
│  public DetectionResponse detectAnomalies(                      │
│      UUID inspectionId,                                         │
│      Double confidenceThreshold) {                              │
│                                                                   │
│    // STEP 1: Load inspection from database                     │
│    Inspection inspection = inspectionRepo                       │
│        .findById(inspectionId)                                  │
│        .orElseThrow();                                          │
│                                                                   │
│    // STEP 2: Get image paths                                   │
│    String inspectionImagePath = getPath(                        │
│        inspection.getInspectionImage());                        │
│    String baselineImagePath = getPath(                          │
│        inspection.getBaselineImage());                          │
│                                                                   │
│    // STEP 3: Call ML Service                                   │
│    DetectionResponse response = mlServiceClient                 │
│        .detectAnomalies(                                        │
│            inspectionImagePath,                                 │
│            baselineImagePath,                                   │
│            confidenceThreshold                                  │
│        );                                                        │
└──────────────┬───────────────────────────────────────────────────┘
               │ HTTP Call
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  SPRING BOOT - MLServiceClient                                   │
│                                                                   │
│  @Service                                                        │
│  public DetectionResponse detectAnomalies(                      │
│      String inspectionPath,                                     │
│      String baselinePath,                                       │
│      Double threshold) {                                        │
│                                                                   │
│    String url = "http://localhost:5001/api/detect";            │
│                                                                   │
│    Map<String, Object> request = new HashMap<>();               │
│    request.put("inspection_image_path", inspectionPath);        │
│    request.put("baseline_image_path", baselinePath);            │
│    request.put("confidence_threshold", threshold);              │
│                                                                   │
│    // Use RestTemplate (Spring HTTP client)                     │
│    ResponseEntity<DetectionResponse> response =                 │
│        restTemplate.postForEntity(url, request,                 │
│            DetectionResponse.class);                            │
│                                                                   │
│    return response.getBody();                                   │
│  }                                                               │
└──────────────┬───────────────────────────────────────────────────┘
               │ HTTP POST
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  PYTHON ML SERVICE (Flask)                                       │
│  Port 5001                                                       │
│                                                                   │
│  @app.route('/api/detect', methods=['POST'])                    │
│  def detect():                                                   │
│      data = request.get_json()                                  │
│      inspection_path = data['inspection_image_path']            │
│      baseline_path = data['baseline_image_path']                │
│      threshold = data['confidence_threshold']                   │
│                                                                   │
│      # Load YOLOv8 model                                        │
│      model = YOLO('yolov8p2.pt')                               │
│                                                                   │
│      # Run inference                                            │
│      results = model(inspection_path, conf=threshold)           │
│                                                                   │
│      # Compare with baseline (similarity check)                 │
│      if baseline_path:                                          │
│          results = compare_with_baseline(                       │
│              results, baseline_path)                            │
│                                                                   │
│      # Return detections                                        │
│      return jsonify({                                           │
│          "success": True,                                       │
│          "detections": [                                        │
│              {                                                  │
│                  "id": "uuid",                                  │
│                  "class_id": 0,                                 │
│                  "class_name": "Faulty",                        │
│                  "confidence": 0.87,                            │
│                  "bbox": {"x1": 100, "y1": 150,                │
│                           "x2": 300, "y2": 400},               │
│                  "source": "ai"                                 │
│              }                                                  │
│          ]                                                      │
│      })                                                         │
└──────────────┬───────────────────────────────────────────────────┘
               │ JSON Response
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  SPRING BOOT - InspectionService (continued)                     │
│                                                                   │
│    // STEP 4: Save AI detections as annotations                 │
│    for (Detection det : response.detections()) {                │
│        Annotation annotation = new Annotation();                │
│        annotation.setInspection(inspection);                    │
│        annotation.setBboxX1(det.bbox().x1());                   │
│        annotation.setBboxY1(det.bbox().y1());                   │
│        annotation.setBboxX2(det.bbox().x2());                   │
│        annotation.setBboxY2(det.bbox().y2());                   │
│        annotation.setClassId(det.classId());                    │
│        annotation.setClassName(det.className());                │
│        annotation.setConfidence(det.confidence());              │
│        annotation.setSource(Annotation.Source.ai);              │
│        annotation.setCreatedBy("AI-YOLOv8");                    │
│        annotation.setIsActive(true);                            │
│                                                                   │
│        annotationRepo.save(annotation);                         │
│    }                                                             │
│                                                                   │
│    // STEP 5: Update inspection status                          │
│    inspection.setStatus(Inspection.Status.IN_PROGRESS);         │
│    inspectionRepo.save(inspection);                             │
│                                                                   │
│    // STEP 6: Log to history                                    │
│    historyService.logAIDetection(inspectionId, response);       │
│                                                                   │
│    return response;                                              │
│  }                                                               │
└──────────────┬───────────────────────────────────────────────────┘
               │ Returns DetectionResponse
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  InspectionController                                            │
│  • Returns response to frontend                                  │
└──────────────┬───────────────────────────────────────────────────┘
               │ HTTP Response (JSON)
               ▼
┌──────────────────────────────────────────────────────────────────┐
│  FRONTEND (React)                                                │
│  • Receives detection results                                    │
│  • Renders bounding boxes on AnnotationCanvas                    │
│  • Shows confidence scores                                       │
└──────────────────────────────────────────────────────────────────┘

DATABASE CHANGES DURING THIS FLOW:
┌────────────────────────────────────────────────────────────────┐
│  MySQL - en3350_db                                             │
│                                                                 │
│  1. SELECT * FROM inspections WHERE id = ?                     │
│  2. SELECT * FROM thermal_images WHERE id IN (?, ?)            │
│  3. INSERT INTO annotations (inspection_id, bbox_x1, ...)      │
│     VALUES (?, ?, ...) × N detections                          │
│  4. UPDATE inspections SET status = 'IN_PROGRESS' WHERE id = ? │
│  5. INSERT INTO inspection_history (action_type, ...)          │
│     VALUES ('AI_DETECTION_RUN', ...)                           │
└────────────────────────────────────────────────────────────────┘
```

**Key Points:**
- ✅ Controller handles HTTP, delegates to Service
- ✅ Service contains business logic, orchestrates operations
- ✅ Service calls ML client for external service
- ✅ Repository handles database operations
- ✅ @Transactional ensures atomicity (all or nothing)

---

## Hands-On Examples

### 📝 Example 1: Understanding @RestController

**Code:**
```java
@RestController
@RequestMapping("/api/transformers")
public class TransformerController {
    
    private final TransformerRepo repo;
    
    public TransformerController(TransformerRepo repo) {
        this.repo = repo;
    }
    
    @GetMapping
    public List<TransformerDTO> getAll() {
        return repo.findAll()
            .stream()
            .map(this::toDTO)
            .toList();
    }
    
    @GetMapping("/{id}")
    public TransformerDTO getOne(@PathVariable UUID id) {
        return repo.findById(id)
            .map(this::toDTO)
            .orElseThrow(() -> new RuntimeException("Not found"));
    }
    
    @PostMapping
    public TransformerDTO create(@RequestBody CreateTransformerReq req) {
        Transformer t = new Transformer();
        t.setCode(req.code());
        t.setLocation(req.location());
        repo.save(t);
        return toDTO(t);
    }
    
    private TransformerDTO toDTO(Transformer t) {
        return new TransformerDTO(
            t.getId(),
            t.getCode(),
            t.getLocation(),
            t.getCapacityKVA(),
            t.getCreatedAt()
        );
    }
}
```

**What happens when you run the app?**

```
1. Spring scans com.acme.backend package
2. Finds @RestController annotation
3. Creates bean: transformerController
4. Looks for constructor dependencies: TransformerRepo
5. Creates/injects TransformerRepo bean
6. Registers HTTP endpoints:
   - GET  /api/transformers      → getAll()
   - GET  /api/transformers/{id} → getOne(id)
   - POST /api/transformers      → create(req)
```

---

### 📝 Example 2: Understanding @Service with Dependencies

**Code:**
```java
@Service
@Transactional
public class InspectionService {
    
    // Multiple dependencies injected via constructor
    private final InspectionRepo inspectionRepo;
    private final AnnotationRepo annotationRepo;
    private final TransformerRepo transformerRepo;
    private final ThermalImageRepo thermalImageRepo;
    private final MLServiceClient mlServiceClient;
    
    // Constructor injection (best practice)
    public InspectionService(
            InspectionRepo inspectionRepo,
            AnnotationRepo annotationRepo,
            TransformerRepo transformerRepo,
            ThermalImageRepo thermalImageRepo,
            MLServiceClient mlServiceClient) {
        
        this.inspectionRepo = inspectionRepo;
        this.annotationRepo = annotationRepo;
        this.transformerRepo = transformerRepo;
        this.thermalImageRepo = thermalImageRepo;
        this.mlServiceClient = mlServiceClient;
    }
    
    // Business logic method
    public InspectionDTO createInspection(CreateInspectionRequest req) {
        // Can use all injected dependencies
        Transformer transformer = transformerRepo
            .findById(req.transformerId())
            .orElseThrow();
        
        Inspection inspection = new Inspection();
        inspection.setTransformer(transformer);
        // ... set other fields
        
        inspection = inspectionRepo.save(inspection);
        
        return toDTO(inspection);
    }
}
```

**Dependency injection happens like this:**

```
Spring Boot starts:
↓
1. Create TransformerRepo bean (Spring Data JPA magic)
2. Create InspectionRepo bean
3. Create AnnotationRepo bean
4. Create ThermalImageRepo bean
5. Create MLServiceClient bean (depends on RestTemplate)
6. Create InspectionService bean:
   - Calls constructor with all 5 dependencies
   - new InspectionService(repo1, repo2, repo3, repo4, client)
7. Bean ready to use!
```

---

### 📝 Example 3: Understanding Spring Data JPA Repository

**Code:**
```java
public interface InspectionRepo extends JpaRepository<Inspection, UUID> {
    
    // Method 1: Spring generates query automatically
    Optional<Inspection> findByInspectionNumber(String inspectionNumber);
    // Generated SQL: SELECT * FROM inspections WHERE inspection_number = ?
    
    // Method 2: Custom query
    @Query("SELECT i FROM Inspection i WHERE " +
           "LOWER(i.inspectionNumber) LIKE LOWER(CONCAT('%', :q, '%'))")
    Page<Inspection> findBySearchQuery(@Param("q") String q, Pageable pageable);
    
    // Method 3: Relationship query
    List<Inspection> findByTransformerId(UUID transformerId);
    // Generated SQL: SELECT * FROM inspections WHERE transformer_id = ?
}
```

**You write:**
- Just the interface (no implementation!)
- Method signatures

**Spring Data JPA provides:**
- Complete implementation at runtime
- SQL generation
- Transaction management
- Exception handling

**Magic methods:**

```
Method Name Pattern → Generated SQL

findByInspectionNumber(String num)
→ SELECT * FROM inspections WHERE inspection_number = ?

findByTransformerId(UUID id)
→ SELECT * FROM inspections WHERE transformer_id = ?

findByStatusAndBranch(Status s, String b)
→ SELECT * FROM inspections WHERE status = ? AND branch = ?

countByStatus(Status s)
→ SELECT COUNT(*) FROM inspections WHERE status = ?
```

---

### 📝 Example 4: Understanding @Configuration

**Code:**
```java
@Configuration
public class CorsConfig {
    
    @Value("${app.cors.allowed-origins:}")
    private String allowedOrigins;  // From application.properties
    
    @Bean  // ← This method creates a bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                    .allowedOrigins(allowedOrigins)
                    .allowedMethods("GET", "POST", "PUT", "DELETE")
                    .allowedHeaders("*");
            }
        };
    }
}
```

**What happens?**

```
1. Spring sees @Configuration
2. Calls corsConfigurer() method
3. Takes the returned WebMvcConfigurer object
4. Registers it as a bean
5. Spring MVC uses this configuration to enable CORS
```

**Why use @Bean?**
- For objects you can't annotate (third-party libraries)
- For complex configuration logic
- For objects that need special initialization

---

### 📝 Example 5: Understanding @Value (Property Injection)

**application.properties:**
```properties
app.ml-service.url=http://localhost:5001
app.storage.root=/uploads
app.cors.allowed-origins=http://localhost:5173
```

**Java Code:**
```java
@Service
public class MLServiceClient {
    
    @Value("${app.ml-service.url:http://localhost:5000}")
    private String mlServiceUrl;
    // Reads from application.properties
    // Default value is http://localhost:5000 if not set
    
    public DetectionResponse detectAnomalies() {
        String url = mlServiceUrl + "/api/detect";
        // Uses http://localhost:5001/api/detect
    }
}
```

**Property Resolution:**
```
1. Check application.properties
2. Check application.yml
3. Check environment variables
4. Check system properties
5. Use default value (after colon :)
```

---

### 📝 Example 6: Understanding @Transactional

**Without @Transactional:**
```java
public void updateInspection(UUID id) {
    Inspection inspection = inspectionRepo.findById(id).get();
    inspection.setStatus(Status.COMPLETED);
    inspectionRepo.save(inspection);  // Commit 1
    
    // If this fails, above change is already saved!
    annotationRepo.deleteByInspectionId(id);  // Commit 2
}
// Problem: Partial updates if second operation fails!
```

**With @Transactional:**
```java
@Transactional
public void updateInspection(UUID id) {
    Inspection inspection = inspectionRepo.findById(id).get();
    inspection.setStatus(Status.COMPLETED);
    inspectionRepo.save(inspection);  // Not committed yet
    
    annotationRepo.deleteByInspectionId(id);  // Not committed yet
    
    // Both committed together when method completes
    // If any fails, BOTH are rolled back!
}
```

**Transaction Flow:**
```
Method starts
    ↓
Begin Transaction
    ↓
Execute all database operations
    ↓
Method completes successfully?
    ├─ YES → Commit (all changes saved)
    └─ NO  → Rollback (all changes discarded)
```

---

## Summary: Key Takeaways

### ✅ Spring Boot Fundamentals

1. **Spring Boot = Spring Framework + Auto-Configuration**
   - Convention over configuration
   - Embedded server (Tomcat)
   - Starter dependencies

2. **Inversion of Control (IoC)**
   - Spring manages objects (beans)
   - You declare dependencies, Spring wires them

3. **Dependency Injection**
   - Constructor injection (best practice)
   - Field injection (avoid)
   - Setter injection (rare)

### ✅ Bean Lifecycle

```
Scan → Instantiate → Inject → Initialize → Ready → Destroy
```

### ✅ Layered Architecture

```
Controller → Service → Repository → Database
```

- **Controller**: HTTP handling
- **Service**: Business logic
- **Repository**: Data access
- **Entity**: Database mapping

### ✅ Key Annotations

| Annotation | Purpose | Layer |
|------------|---------|-------|
| `@SpringBootApplication` | Main entry point | App |
| `@RestController` | REST API endpoint | Controller |
| `@Service` | Business logic | Service |
| `@Repository` | Data access | Repository |
| `@Entity` | Database table | Domain |
| `@Configuration` | Custom config | Config |
| `@Transactional` | Atomic operations | Service |
| `@Autowired` | Inject dependency | Any |
| `@Value` | Inject property | Any |

### ✅ TransX-Specific Flow

```
React Frontend
    ↓ HTTP Request
InspectionController (@RestController)
    ↓ Calls
InspectionService (@Service)
    ↓ Uses
MLServiceClient (@Service) → Flask ML Service (Python)
    ↓ Uses
InspectionRepo (Spring Data JPA)
    ↓ Queries
MySQL Database
```

---

## Practice Exercises

### 🎯 Exercise 1: Trace a Request

**Task**: Trace this request end-to-end:
```
POST /api/annotations/{id}/approve?userId=engineer@example.com
```

**Answer**:
1. Request arrives at `AnnotationController`
2. `@PostMapping("/{id}/approve")` method called
3. Calls `annotationService.approveAnnotation(id, userId)`
4. Service loads annotation: `annotationRepo.findById(id)`
5. Updates action_type to 'approved'
6. Saves: `annotationRepo.save(annotation)`
7. Returns DTO to controller
8. Controller returns HTTP 200 with JSON

### 🎯 Exercise 2: Add a New Endpoint

**Task**: Add endpoint to count inspections by transformer

**Steps**:
1. Add method to repository:
```java
Long countByTransformerId(UUID transformerId);
```

2. Add method to service:
```java
public Long countInspections(UUID transformerId) {
    return inspectionRepo.countByTransformerId(transformerId);
}
```

3. Add endpoint to controller:
```java
@GetMapping("/count/{transformerId}")
public Long getCount(@PathVariable UUID transformerId) {
    return inspectionService.countInspections(transformerId);
}
```

4. Test: `GET /api/inspections/count/abc-123`

### 🎯 Exercise 3: Understand Bean Dependencies

**Task**: Draw dependency graph for `InspectionController`

**Answer**:
```
InspectionController
    ├─ InspectionService
    │   ├─ InspectionRepo
    │   ├─ AnnotationRepo
    │   ├─ TransformerRepo
    │   ├─ ThermalImageRepo
    │   └─ MLServiceClient
    │       └─ RestTemplate
    └─ MLServiceClient (same instance as above)
```

---

## Next Steps

1. **Read the code** in this order:
   - `BackendApplication.java` (entry point)
   - `Transformer.java` (simple entity)
   - `TransformerRepo.java` (simple repository)
   - `TransformerController.java` (simple controller)
   - Then move to complex classes (InspectionService, etc.)

2. **Run the application** with debugger
   - Set breakpoints in controllers
   - Watch variables being injected
   - See SQL queries generated

3. **Experiment**:
   - Add new endpoints
   - Create new services
   - Write custom queries

4. **Learn Spring Boot documentation**:
   - https://spring.io/guides
   - https://docs.spring.io/spring-boot/docs/current/reference/

---

**You're now ready to teach Spring Boot! 🎓**

Use this guide as a reference, show the diagrams, and walk through the code examples step by step.
