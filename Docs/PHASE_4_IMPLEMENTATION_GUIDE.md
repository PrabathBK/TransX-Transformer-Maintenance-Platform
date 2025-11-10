# Phase 4 - Maintenance Record Sheet Generation
## Step-by-Step Implementation Guide

**Project**: TransX - Transformer Maintenance Platform  
**Phase**: 4 (Final Phase)  
**Status**: Planning & Design  
**Last Updated**: October 26, 2025

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Requirements Summary](#requirements-summary)
3. [Database Schema Changes](#database-schema-changes)
4. [Backend Implementation](#backend-implementation)
5. [Frontend Implementation](#frontend-implementation)
6. [PDF Generation](#pdf-generation)
7. [Implementation Timeline](#implementation-timeline)
8. [Testing Checklist](#testing-checklist)

---

## Overview

### What is Phase 4?
Phase 4 implements **digital maintenance record generation** for transformers. After thermal inspection and anomaly detection (Phases 1-3), engineers need to create official maintenance records that include:
- Auto-detected anomalies (AI)
- User-validated annotations (human review)
- Additional engineer input (notes, readings, actions)
- PDF-exportable format for audit trails

### Business Flow
```
┌─────────────────────────────────────────────────────────────────┐
│                   PHASE 4 WORKFLOW                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Inspection Completed (Phase 3)                              │
│     └─> Status: COMPLETED                                       │
│     └─> Annotations validated                                   │
│                                                                  │
│  2. Generate Maintenance Record Form (FR4.1)                    │
│     └─> Pre-filled with inspection data                         │
│     └─> Includes thermal image with markers                     │
│     └─> Lists all anomalies detected                            │
│                                                                  │
│  3. Engineer Fills Editable Fields (FR4.2)                      │
│     └─> Inspector name                                          │
│     └─> Transformer status (dropdown)                           │
│     └─> Electrical readings (voltage, current)                  │
│     └─> Recommended actions                                     │
│     └─> Additional remarks                                      │
│                                                                  │
│  4. Save Maintenance Record (FR4.3)                             │
│     └─> Store in database (versioned)                           │
│     └─> Generate PDF for download                               │
│     └─> Link to transformer & inspection                        │
│                                                                  │
│  5. View Record History                                         │
│     └─> Filter by transformer                                   │
│     └─> Filter by date range                                    │
│     └─> Export to PDF                                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Requirements Summary

### FR4.1: Generate Maintenance Record Form
**System-Generated Content (Read-Only)**:
- Transformer metadata (ID, code, location, capacity)
- Inspection timestamp
- Weather condition
- Thermal image thumbnail with anomaly bounding boxes
- List of detected/annotated anomalies with:
  - Box number
  - Fault type (class_name)
  - Confidence score
  - Source (AI/Human)
  - Coordinates

### FR4.2: Editable Engineer Input Fields
**User-Editable Content**:
- Inspector name (text input)
- Transformer status (dropdown: OK / Needs Maintenance / Urgent Attention)
- Electrical readings:
  - Voltage (V) - number input
  - Current (A) - number input
  - Load (kVA) - number input
  - Temperature (°C) - number input
- Recommended action (textarea)
- Additional remarks (textarea)
- Maintenance date (date picker)

### FR4.3: Save and Retrieve Completed Records
- Save record to database with timestamp
- Associate with transformer and inspection
- Support versioning (if record is edited after save)
- Retrieve all records for a transformer
- Filter by date range
- Export to PDF

---

## Database Schema Changes

### Step 1: Create `maintenance_records` Table

```sql
-- New table for Phase 4
CREATE TABLE maintenance_records (
    id BINARY(16) NOT NULL PRIMARY KEY,
    record_number VARCHAR(50) NOT NULL UNIQUE,
    
    -- Foreign keys
    transformer_id BINARY(16) NOT NULL,
    inspection_id BINARY(16) NOT NULL,
    
    -- System-generated (from inspection)
    inspection_date TIMESTAMP NULL,
    weather_condition VARCHAR(20) NULL,
    thermal_image_url VARCHAR(500) NULL,
    anomaly_count INT DEFAULT 0,
    
    -- Engineer input fields
    inspector_name VARCHAR(100) NULL,
    transformer_status ENUM('OK', 'NEEDS_MAINTENANCE', 'URGENT_ATTENTION') DEFAULT 'OK',
    
    -- Electrical readings
    voltage_reading DECIMAL(10, 2) NULL COMMENT 'Voltage in V',
    current_reading DECIMAL(10, 2) NULL COMMENT 'Current in A',
    load_reading DECIMAL(10, 2) NULL COMMENT 'Load in kVA',
    temperature_reading DECIMAL(5, 2) NULL COMMENT 'Temperature in °C',
    
    -- Actions and notes
    recommended_action TEXT NULL,
    additional_remarks TEXT NULL,
    
    -- Metadata
    maintenance_date DATE NULL,
    status ENUM('DRAFT', 'FINALIZED') DEFAULT 'DRAFT',
    version INT DEFAULT 1,
    created_by VARCHAR(100) NULL,
    updated_by VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    finalized_at TIMESTAMP NULL,
    
    -- Soft delete
    is_deleted TINYINT(1) DEFAULT 0,
    
    -- Foreign key constraints
    CONSTRAINT fk_maintenance_transformer 
        FOREIGN KEY (transformer_id) REFERENCES transformers(id) ON DELETE CASCADE,
    CONSTRAINT fk_maintenance_inspection 
        FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_transformer_id (transformer_id),
    INDEX idx_inspection_id (inspection_id),
    INDEX idx_record_number (record_number),
    INDEX idx_maintenance_date (maintenance_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Step 2: Create `maintenance_record_anomalies` Table

```sql
-- Snapshot of anomalies at the time record was created
CREATE TABLE maintenance_record_anomalies (
    id BINARY(16) NOT NULL PRIMARY KEY,
    maintenance_record_id BINARY(16) NOT NULL,
    
    -- Snapshot data from annotations table
    box_number INT NULL,
    class_id INT NULL,
    class_name VARCHAR(50) NULL,
    confidence DECIMAL(5, 3) NULL,
    bbox_x1 INT NOT NULL,
    bbox_y1 INT NOT NULL,
    bbox_x2 INT NOT NULL,
    bbox_y2 INT NOT NULL,
    source ENUM('ai', 'human') NOT NULL,
    
    -- Foreign key
    CONSTRAINT fk_mra_maintenance_record 
        FOREIGN KEY (maintenance_record_id) 
        REFERENCES maintenance_records(id) ON DELETE CASCADE,
    
    INDEX idx_maintenance_record_id (maintenance_record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Step 3: Update Existing Tables (Optional)

```sql
-- Add maintenance_record_count to transformers (for quick stats)
ALTER TABLE transformers 
ADD COLUMN maintenance_record_count INT DEFAULT 0;

-- Add has_maintenance_record flag to inspections
ALTER TABLE inspections 
ADD COLUMN has_maintenance_record TINYINT(1) DEFAULT 0;
```

---

## Backend Implementation

### Step 1: Create Domain Entity

**File**: `backend/src/main/java/com/acme/backend/domain/MaintenanceRecord.java`

```java
package com.acme.backend.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "maintenance_records")
public class MaintenanceRecord {
    
    public enum Status {
        DRAFT,
        FINALIZED
    }
    
    public enum TransformerStatus {
        OK,
        NEEDS_MAINTENANCE,
        URGENT_ATTENTION
    }

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "record_number", unique = true, nullable = false, length = 50)
    private String recordNumber;

    // Foreign keys
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "transformer_id")
    private Transformer transformer;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "inspection_id")
    private Inspection inspection;

    // System-generated
    @Column(name = "inspection_date")
    private Instant inspectionDate;

    @Column(name = "weather_condition", length = 20)
    private String weatherCondition;

    @Column(name = "thermal_image_url", length = 500)
    private String thermalImageUrl;

    @Column(name = "anomaly_count")
    private Integer anomalyCount = 0;

    // Engineer input
    @Column(name = "inspector_name", length = 100)
    private String inspectorName;

    @Enumerated(EnumType.STRING)
    @Column(name = "transformer_status")
    private TransformerStatus transformerStatus = TransformerStatus.OK;

    // Electrical readings
    @Column(name = "voltage_reading", precision = 10, scale = 2)
    private BigDecimal voltageReading;

    @Column(name = "current_reading", precision = 10, scale = 2)
    private BigDecimal currentReading;

    @Column(name = "load_reading", precision = 10, scale = 2)
    private BigDecimal loadReading;

    @Column(name = "temperature_reading", precision = 5, scale = 2)
    private BigDecimal temperatureReading;

    // Actions
    @Column(name = "recommended_action", columnDefinition = "TEXT")
    private String recommendedAction;

    @Column(name = "additional_remarks", columnDefinition = "TEXT")
    private String additionalRemarks;

    @Column(name = "maintenance_date")
    private LocalDate maintenanceDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.DRAFT;

    @Column(nullable = false)
    private Integer version = 1;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(name = "updated_by", length = 100)
    private String updatedBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "finalized_at")
    private Instant finalizedAt;

    @Column(name = "is_deleted")
    private Boolean isDeleted = false;

    // One-to-many: anomalies snapshot
    @OneToMany(mappedBy = "maintenanceRecord", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MaintenanceRecordAnomaly> anomalies = new ArrayList<>();

    // Getters and setters...
    public UUID getId() { return id; }
    public String getRecordNumber() { return recordNumber; }
    public void setRecordNumber(String recordNumber) { this.recordNumber = recordNumber; }
    public Transformer getTransformer() { return transformer; }
    public void setTransformer(Transformer transformer) { this.transformer = transformer; }
    public Inspection getInspection() { return inspection; }
    public void setInspection(Inspection inspection) { this.inspection = inspection; }
    // ... (add all getters/setters)
}
```

**File**: `backend/src/main/java/com/acme/backend/domain/MaintenanceRecordAnomaly.java`

```java
package com.acme.backend.domain;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "maintenance_record_anomalies")
public class MaintenanceRecordAnomaly {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "maintenance_record_id")
    private MaintenanceRecord maintenanceRecord;

    @Column(name = "box_number")
    private Integer boxNumber;

    @Column(name = "class_id")
    private Integer classId;

    @Column(name = "class_name", length = 50)
    private String className;

    @Column(precision = 5, scale = 3)
    private BigDecimal confidence;

    @Column(name = "bbox_x1", nullable = false)
    private Integer bboxX1;

    @Column(name = "bbox_y1", nullable = false)
    private Integer bboxY1;

    @Column(name = "bbox_x2", nullable = false)
    private Integer bboxX2;

    @Column(name = "bbox_y2", nullable = false)
    private Integer bboxY2;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Annotation.Source source;

    // Getters and setters...
}
```

### Step 2: Create Repository

**File**: `backend/src/main/java/com/acme/backend/repo/MaintenanceRecordRepo.java`

```java
package com.acme.backend.repo;

import com.acme.backend.domain.MaintenanceRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface MaintenanceRecordRepo extends JpaRepository<MaintenanceRecord, UUID> {

    Optional<MaintenanceRecord> findByRecordNumber(String recordNumber);

    Optional<MaintenanceRecord> findByInspectionId(UUID inspectionId);

    Page<MaintenanceRecord> findByTransformerIdAndIsDeletedFalse(
        UUID transformerId, Pageable pageable);

    @Query("SELECT m FROM MaintenanceRecord m WHERE m.transformer.id = :transformerId " +
           "AND m.maintenanceDate BETWEEN :startDate AND :endDate " +
           "AND m.isDeleted = false")
    Page<MaintenanceRecord> findByTransformerAndDateRange(
        @Param("transformerId") UUID transformerId,
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate,
        Pageable pageable);

    Page<MaintenanceRecord> findByTransformerStatusAndIsDeletedFalse(
        MaintenanceRecord.TransformerStatus status, Pageable pageable);

    Long countByTransformerIdAndIsDeletedFalse(UUID transformerId);
}
```

### Step 3: Create DTOs

**File**: `backend/src/main/java/com/acme/backend/api/dto/CreateMaintenanceRecordRequest.java`

```java
package com.acme.backend.api.dto;

import com.acme.backend.domain.MaintenanceRecord;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateMaintenanceRecordRequest(
    @NotNull UUID inspectionId,
    
    // Engineer inputs
    @Size(max = 100) String inspectorName,
    MaintenanceRecord.TransformerStatus transformerStatus,
    
    @DecimalMin("0.0") BigDecimal voltageReading,
    @DecimalMin("0.0") BigDecimal currentReading,
    @DecimalMin("0.0") BigDecimal loadReading,
    @DecimalMin("-50.0") @DecimalMax("200.0") BigDecimal temperatureReading,
    
    @Size(max = 2000) String recommendedAction,
    @Size(max = 5000) String additionalRemarks,
    
    LocalDate maintenanceDate,
    
    String createdBy
) {}
```

**File**: `backend/src/main/java/com/acme/backend/api/dto/MaintenanceRecordDTO.java`

```java
package com.acme.backend.api.dto;

import com.acme.backend.domain.MaintenanceRecord;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record MaintenanceRecordDTO(
    UUID id,
    String recordNumber,
    UUID transformerId,
    String transformerCode,
    String transformerLocation,
    UUID inspectionId,
    String inspectionNumber,
    Instant inspectionDate,
    String weatherCondition,
    String thermalImageUrl,
    Integer anomalyCount,
    List<AnomalySnapshotDTO> anomalies,
    
    // Engineer inputs
    String inspectorName,
    MaintenanceRecord.TransformerStatus transformerStatus,
    BigDecimal voltageReading,
    BigDecimal currentReading,
    BigDecimal loadReading,
    BigDecimal temperatureReading,
    String recommendedAction,
    String additionalRemarks,
    LocalDate maintenanceDate,
    
    // Metadata
    MaintenanceRecord.Status status,
    Integer version,
    String createdBy,
    String updatedBy,
    Instant createdAt,
    Instant updatedAt,
    Instant finalizedAt
) {}

record AnomalySnapshotDTO(
    UUID id,
    Integer boxNumber,
    Integer classId,
    String className,
    BigDecimal confidence,
    Integer bboxX1,
    Integer bboxY1,
    Integer bboxX2,
    Integer bboxY2,
    String source
) {}
```

### Step 4: Create Service Layer

**File**: `backend/src/main/java/com/acme/backend/service/MaintenanceRecordService.java`

```java
package com.acme.backend.service;

import com.acme.backend.api.dto.*;
import com.acme.backend.domain.*;
import com.acme.backend.repo.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class MaintenanceRecordService {

    private final MaintenanceRecordRepo recordRepo;
    private final InspectionRepo inspectionRepo;
    private final AnnotationRepo annotationRepo;

    public MaintenanceRecordService(
        MaintenanceRecordRepo recordRepo,
        InspectionRepo inspectionRepo,
        AnnotationRepo annotationRepo
    ) {
        this.recordRepo = recordRepo;
        this.inspectionRepo = inspectionRepo;
        this.annotationRepo = annotationRepo;
    }

    /**
     * Generate maintenance record from completed inspection
     */
    public MaintenanceRecordDTO createFromInspection(CreateMaintenanceRecordRequest request) {
        // Get inspection
        Inspection inspection = inspectionRepo.findById(request.inspectionId())
            .orElseThrow(() -> new RuntimeException("Inspection not found"));

        // Check if record already exists
        recordRepo.findByInspectionId(inspection.getId())
            .ifPresent(r -> {
                throw new RuntimeException("Maintenance record already exists for this inspection");
            });

        // Generate record number
        String recordNumber = generateRecordNumber(inspection.getTransformer());

        // Create maintenance record
        MaintenanceRecord record = new MaintenanceRecord();
        record.setRecordNumber(recordNumber);
        record.setTransformer(inspection.getTransformer());
        record.setInspection(inspection);

        // Copy system-generated data from inspection
        record.setInspectionDate(inspection.getInspectedAt());
        record.setWeatherCondition(
            inspection.getWeatherCondition() != null ? 
            inspection.getWeatherCondition().toString() : null
        );
        record.setThermalImageUrl(
            inspection.getInspectionImage() != null ? 
            inspection.getInspectionImage().getPublicUrl() : null
        );

        // Get anomalies count and snapshot
        List<Annotation> annotations = annotationRepo
            .findByInspectionIdAndIsActiveTrue(inspection.getId());
        record.setAnomalyCount(annotations.size());

        // Copy engineer inputs
        record.setInspectorName(request.inspectorName());
        record.setTransformerStatus(request.transformerStatus());
        record.setVoltageReading(request.voltageReading());
        record.setCurrentReading(request.currentReading());
        record.setLoadReading(request.loadReading());
        record.setTemperatureReading(request.temperatureReading());
        record.setRecommendedAction(request.recommendedAction());
        record.setAdditionalRemarks(request.additionalRemarks());
        record.setMaintenanceDate(request.maintenanceDate());
        record.setCreatedBy(request.createdBy());

        // Save record
        record = recordRepo.save(record);

        // Snapshot anomalies
        for (Annotation annotation : annotations) {
            MaintenanceRecordAnomaly anomaly = new MaintenanceRecordAnomaly();
            anomaly.setMaintenanceRecord(record);
            anomaly.setBoxNumber(annotation.getBoxNumber());
            anomaly.setClassId(annotation.getClassId());
            anomaly.setClassName(annotation.getClassName());
            anomaly.setConfidence(annotation.getConfidence());
            anomaly.setBboxX1(annotation.getBboxX1());
            anomaly.setBboxY1(annotation.getBboxY1());
            anomaly.setBboxX2(annotation.getBboxX2());
            anomaly.setBboxY2(annotation.getBboxY2());
            anomaly.setSource(annotation.getSource());
            record.getAnomalies().add(anomaly);
        }

        record = recordRepo.save(record);

        // Update inspection flag
        inspection.setHasMaintenanceRecord(true);
        inspectionRepo.save(inspection);

        return toDTO(record);
    }

    /**
     * Update existing maintenance record
     */
    public MaintenanceRecordDTO updateRecord(UUID id, UpdateMaintenanceRecordRequest request) {
        MaintenanceRecord record = recordRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Maintenance record not found"));

        if (record.getStatus() == MaintenanceRecord.Status.FINALIZED) {
            throw new RuntimeException("Cannot edit finalized record");
        }

        // Update editable fields
        record.setInspectorName(request.inspectorName());
        record.setTransformerStatus(request.transformerStatus());
        record.setVoltageReading(request.voltageReading());
        record.setCurrentReading(request.currentReading());
        record.setLoadReading(request.loadReading());
        record.setTemperatureReading(request.temperatureReading());
        record.setRecommendedAction(request.recommendedAction());
        record.setAdditionalRemarks(request.additionalRemarks());
        record.setMaintenanceDate(request.maintenanceDate());
        record.setUpdatedBy(request.updatedBy());
        record.setVersion(record.getVersion() + 1);

        record = recordRepo.save(record);
        return toDTO(record);
    }

    /**
     * Finalize record (lock for editing)
     */
    public MaintenanceRecordDTO finalizeRecord(UUID id, String finalizedBy) {
        MaintenanceRecord record = recordRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Maintenance record not found"));

        record.setStatus(MaintenanceRecord.Status.FINALIZED);
        record.setFinalizedAt(Instant.now());
        record.setUpdatedBy(finalizedBy);

        record = recordRepo.save(record);
        return toDTO(record);
    }

    /**
     * Get all records for a transformer
     */
    @Transactional(readOnly = true)
    public Page<MaintenanceRecordDTO> getRecordsForTransformer(
        UUID transformerId, Pageable pageable
    ) {
        return recordRepo.findByTransformerIdAndIsDeletedFalse(transformerId, pageable)
            .map(this::toDTO);
    }

    /**
     * Get records by date range
     */
    @Transactional(readOnly = true)
    public Page<MaintenanceRecordDTO> getRecordsByDateRange(
        UUID transformerId, LocalDate startDate, LocalDate endDate, Pageable pageable
    ) {
        return recordRepo.findByTransformerAndDateRange(
            transformerId, startDate, endDate, pageable
        ).map(this::toDTO);
    }

    /**
     * Get single record
     */
    @Transactional(readOnly = true)
    public MaintenanceRecordDTO getRecord(UUID id) {
        return recordRepo.findById(id)
            .map(this::toDTO)
            .orElseThrow(() -> new RuntimeException("Maintenance record not found"));
    }

    /**
     * Delete record (soft delete)
     */
    public void deleteRecord(UUID id) {
        MaintenanceRecord record = recordRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Maintenance record not found"));
        record.setIsDeleted(true);
        recordRepo.save(record);
    }

    // Helper methods
    private String generateRecordNumber(Transformer transformer) {
        long count = recordRepo.countByTransformerIdAndIsDeletedFalse(transformer.getId());
        return String.format("MR-%s-%04d", transformer.getCode(), count + 1);
    }

    private MaintenanceRecordDTO toDTO(MaintenanceRecord record) {
        List<AnomalySnapshotDTO> anomalies = record.getAnomalies().stream()
            .map(a -> new AnomalySnapshotDTO(
                a.getId(), a.getBoxNumber(), a.getClassId(), a.getClassName(),
                a.getConfidence(), a.getBboxX1(), a.getBboxY1(), 
                a.getBboxX2(), a.getBboxY2(), a.getSource().toString()
            ))
            .collect(Collectors.toList());

        return new MaintenanceRecordDTO(
            record.getId(),
            record.getRecordNumber(),
            record.getTransformer().getId(),
            record.getTransformer().getCode(),
            record.getTransformer().getLocation(),
            record.getInspection().getId(),
            record.getInspection().getInspectionNumber(),
            record.getInspectionDate(),
            record.getWeatherCondition(),
            record.getThermalImageUrl(),
            record.getAnomalyCount(),
            anomalies,
            record.getInspectorName(),
            record.getTransformerStatus(),
            record.getVoltageReading(),
            record.getCurrentReading(),
            record.getLoadReading(),
            record.getTemperatureReading(),
            record.getRecommendedAction(),
            record.getAdditionalRemarks(),
            record.getMaintenanceDate(),
            record.getStatus(),
            record.getVersion(),
            record.getCreatedBy(),
            record.getUpdatedBy(),
            record.getCreatedAt(),
            record.getUpdatedAt(),
            record.getFinalizedAt()
        );
    }
}
```

### Step 5: Create REST Controller

**File**: `backend/src/main/java/com/acme/backend/api/MaintenanceRecordController.java`

```java
package com.acme.backend.api;

import com.acme.backend.api.dto.*;
import com.acme.backend.service.MaintenanceRecordService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/maintenance-records")
public class MaintenanceRecordController {

    private final MaintenanceRecordService recordService;

    public MaintenanceRecordController(MaintenanceRecordService recordService) {
        this.recordService = recordService;
    }

    @PostMapping
    public ResponseEntity<MaintenanceRecordDTO> createRecord(
        @Valid @RequestBody CreateMaintenanceRecordRequest request
    ) {
        MaintenanceRecordDTO record = recordService.createFromInspection(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(record);
    }

    @PutMapping("/{id}")
    public ResponseEntity<MaintenanceRecordDTO> updateRecord(
        @PathVariable UUID id,
        @Valid @RequestBody UpdateMaintenanceRecordRequest request
    ) {
        MaintenanceRecordDTO record = recordService.updateRecord(id, request);
        return ResponseEntity.ok(record);
    }

    @PostMapping("/{id}/finalize")
    public ResponseEntity<MaintenanceRecordDTO> finalizeRecord(
        @PathVariable UUID id,
        @RequestParam String finalizedBy
    ) {
        MaintenanceRecordDTO record = recordService.finalizeRecord(id, finalizedBy);
        return ResponseEntity.ok(record);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MaintenanceRecordDTO> getRecord(@PathVariable UUID id) {
        MaintenanceRecordDTO record = recordService.getRecord(id);
        return ResponseEntity.ok(record);
    }

    @GetMapping("/transformer/{transformerId}")
    public ResponseEntity<Page<MaintenanceRecordDTO>> getRecordsForTransformer(
        @PathVariable UUID transformerId,
        Pageable pageable
    ) {
        Page<MaintenanceRecordDTO> records = 
            recordService.getRecordsForTransformer(transformerId, pageable);
        return ResponseEntity.ok(records);
    }

    @GetMapping("/transformer/{transformerId}/date-range")
    public ResponseEntity<Page<MaintenanceRecordDTO>> getRecordsByDateRange(
        @PathVariable UUID transformerId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
        Pageable pageable
    ) {
        Page<MaintenanceRecordDTO> records = recordService.getRecordsByDateRange(
            transformerId, startDate, endDate, pageable
        );
        return ResponseEntity.ok(records);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRecord(@PathVariable UUID id) {
        recordService.deleteRecord(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

## Frontend Implementation

### Step 1: Create TypeScript Types

**File**: `frontend/src/api/maintenance-records.ts`

```typescript
import { api } from './client';

export type TransformerStatus = 'OK' | 'NEEDS_MAINTENANCE' | 'URGENT_ATTENTION';
export type RecordStatus = 'DRAFT' | 'FINALIZED';

export interface AnomalySnapshot {
  id: string;
  boxNumber: number;
  classId: number;
  className: string;
  confidence: number;
  bboxX1: number;
  bboxY1: number;
  bboxX2: number;
  bboxY2: number;
  source: 'ai' | 'human';
}

export interface MaintenanceRecord {
  id: string;
  recordNumber: string;
  transformerId: string;
  transformerCode: string;
  transformerLocation: string;
  inspectionId: string;
  inspectionNumber: string;
  inspectionDate: string;
  weatherCondition?: string;
  thermalImageUrl?: string;
  anomalyCount: number;
  anomalies: AnomalySnapshot[];
  
  // Engineer inputs
  inspectorName?: string;
  transformerStatus?: TransformerStatus;
  voltageReading?: number;
  currentReading?: number;
  loadReading?: number;
  temperatureReading?: number;
  recommendedAction?: string;
  additionalRemarks?: string;
  maintenanceDate?: string;
  
  // Metadata
  status: RecordStatus;
  version: number;
  createdBy?: string;
  updatedBy?: string;
  createdAt: string;
  updatedAt?: string;
  finalizedAt?: string;
}

export interface CreateMaintenanceRecordRequest {
  inspectionId: string;
  inspectorName?: string;
  transformerStatus?: TransformerStatus;
  voltageReading?: number;
  currentReading?: number;
  loadReading?: number;
  temperatureReading?: number;
  recommendedAction?: string;
  additionalRemarks?: string;
  maintenanceDate?: string;
  createdBy?: string;
}

export async function createMaintenanceRecord(
  data: CreateMaintenanceRecordRequest
): Promise<MaintenanceRecord> {
  return api('/api/maintenance-records', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
}

export async function updateMaintenanceRecord(
  id: string,
  data: Partial<CreateMaintenanceRecordRequest>
): Promise<MaintenanceRecord> {
  return api(`/api/maintenance-records/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
}

export async function finalizeRecord(
  id: string,
  finalizedBy: string
): Promise<MaintenanceRecord> {
  return api(`/api/maintenance-records/${id}/finalize?finalizedBy=${finalizedBy}`, {
    method: 'POST'
  });
}

export async function getMaintenanceRecord(id: string): Promise<MaintenanceRecord> {
  return api(`/api/maintenance-records/${id}`);
}

export async function getRecordsForTransformer(
  transformerId: string,
  page = 0,
  size = 10
): Promise<{ content: MaintenanceRecord[]; totalPages: number; totalElements: number }> {
  return api(`/api/maintenance-records/transformer/${transformerId}?page=${page}&size=${size}`);
}

export async function getRecordsByDateRange(
  transformerId: string,
  startDate: string,
  endDate: string,
  page = 0,
  size = 10
): Promise<{ content: MaintenanceRecord[]; totalPages: number; totalElements: number }> {
  return api(
    `/api/maintenance-records/transformer/${transformerId}/date-range?` +
    `startDate=${startDate}&endDate=${endDate}&page=${page}&size=${size}`
  );
}

export async function deleteMaintenanceRecord(id: string): Promise<void> {
  return api(`/api/maintenance-records/${id}`, { method: 'DELETE' });
}
```

### Step 2: Create Maintenance Record Form Component

**File**: `frontend/src/pages/MaintenanceRecordForm.tsx`

```typescript
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getInspection, type Inspection } from '../api/inspections';
import { getAnnotations, type Annotation } from '../api/annotations';
import { 
  createMaintenanceRecord, 
  updateMaintenanceRecord,
  finalizeRecord,
  type CreateMaintenanceRecordRequest,
  type TransformerStatus 
} from '../api/maintenance-records';

export default function MaintenanceRecordForm() {
  const { inspectionId } = useParams();
  const navigate = useNavigate();

  const [inspection, setInspection] = useState<Inspection | null>(null);
  const [annotations, setAnnotations] = useState<Annotation[]>([]);
  const [loading, setLoading] = useState(true);

  // Form state
  const [inspectorName, setInspectorName] = useState('');
  const [transformerStatus, setTransformerStatus] = useState<TransformerStatus>('OK');
  const [voltageReading, setVoltageReading] = useState('');
  const [currentReading, setCurrentReading] = useState('');
  const [loadReading, setLoadReading] = useState('');
  const [temperatureReading, setTemperatureReading] = useState('');
  const [recommendedAction, setRecommendedAction] = useState('');
  const [additionalRemarks, setAdditionalRemarks] = useState('');
  const [maintenanceDate, setMaintenanceDate] = useState('');

  useEffect(() => {
    if (!inspectionId) return;
    
    Promise.all([
      getInspection(inspectionId),
      getAnnotations(inspectionId, 0, 1000)
    ])
      .then(([inspData, annData]) => {
        setInspection(inspData);
        setAnnotations(annData.content.filter(a => a.isActive));
        setLoading(false);
      })
      .catch(err => {
        alert('Error loading inspection: ' + err.message);
        setLoading(false);
      });
  }, [inspectionId]);

  const handleSaveDraft = async () => {
    if (!inspectionId) return;

    const data: CreateMaintenanceRecordRequest = {
      inspectionId,
      inspectorName: inspectorName || undefined,
      transformerStatus,
      voltageReading: voltageReading ? parseFloat(voltageReading) : undefined,
      currentReading: currentReading ? parseFloat(currentReading) : undefined,
      loadReading: loadReading ? parseFloat(loadReading) : undefined,
      temperatureReading: temperatureReading ? parseFloat(temperatureReading) : undefined,
      recommendedAction: recommendedAction || undefined,
      additionalRemarks: additionalRemarks || undefined,
      maintenanceDate: maintenanceDate || undefined,
      createdBy: 'current-user' // Replace with actual user
    };

    try {
      const record = await createMaintenanceRecord(data);
      alert('Maintenance record saved as draft');
      navigate(`/maintenance-records/${record.id}`);
    } catch (err: any) {
      alert('Error saving record: ' + err.message);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (!inspection) return <div>Inspection not found</div>;

  return (
    <div style={{ padding: '24px', maxWidth: '1200px', margin: '0 auto' }}>
      <h1>Maintenance Record Form</h1>
      
      {/* System-Generated Section (Read-Only) */}
      <section style={{ marginBottom: '32px', padding: '20px', background: '#f9fafb', borderRadius: '8px' }}>
        <h2 style={{ marginBottom: '16px' }}>Inspection Details (Auto-Generated)</h2>
        
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
          <div>
            <strong>Transformer Code:</strong> {inspection.transformerCode}
          </div>
          <div>
            <strong>Inspection Number:</strong> {inspection.inspectionNumber}
          </div>
          <div>
            <strong>Inspection Date:</strong> {new Date(inspection.inspectedAt!).toLocaleDateString()}
          </div>
          <div>
            <strong>Weather:</strong> {inspection.weatherCondition || 'N/A'}
          </div>
          <div>
            <strong>Total Anomalies:</strong> {annotations.length}
          </div>
        </div>

        {/* Thermal Image */}
        {inspection.inspectionImageUrl && (
          <div style={{ marginTop: '16px' }}>
            <strong>Thermal Image with Annotations:</strong>
            <img 
              src={inspection.inspectionImageUrl} 
              alt="Thermal" 
              style={{ width: '100%', maxWidth: '600px', marginTop: '8px', border: '1px solid #ddd' }}
            />
          </div>
        )}

        {/* Anomaly List */}
        <div style={{ marginTop: '16px' }}>
          <strong>Detected Anomalies:</strong>
          <table style={{ width: '100%', marginTop: '8px', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ background: '#e5e7eb' }}>
                <th style={{ padding: '8px', textAlign: 'left' }}>Box #</th>
                <th style={{ padding: '8px', textAlign: 'left' }}>Type</th>
                <th style={{ padding: '8px', textAlign: 'left' }}>Confidence</th>
                <th style={{ padding: '8px', textAlign: 'left' }}>Source</th>
                <th style={{ padding: '8px', textAlign: 'left' }}>Coordinates</th>
              </tr>
            </thead>
            <tbody>
              {annotations.map(ann => (
                <tr key={ann.id} style={{ borderBottom: '1px solid #ddd' }}>
                  <td style={{ padding: '8px' }}>{ann.boxNumber}</td>
                  <td style={{ padding: '8px' }}>{ann.className || 'Unknown'}</td>
                  <td style={{ padding: '8px' }}>{ann.confidence?.toFixed(2) || 'N/A'}</td>
                  <td style={{ padding: '8px' }}>{ann.source}</td>
                  <td style={{ padding: '8px' }}>
                    ({ann.bboxX1}, {ann.bboxY1}) - ({ann.bboxX2}, {ann.bboxY2})
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* Editable Section */}
      <section style={{ marginBottom: '32px' }}>
        <h2 style={{ marginBottom: '16px' }}>Engineer Input (Editable)</h2>
        
        <div style={{ display: 'grid', gap: '16px' }}>
          {/* Inspector Name */}
          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
              Inspector Name
            </label>
            <input
              type="text"
              value={inspectorName}
              onChange={(e) => setInspectorName(e.target.value)}
              style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
            />
          </div>

          {/* Transformer Status */}
          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
              Transformer Status *
            </label>
            <select
              value={transformerStatus}
              onChange={(e) => setTransformerStatus(e.target.value as TransformerStatus)}
              style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
            >
              <option value="OK">OK</option>
              <option value="NEEDS_MAINTENANCE">Needs Maintenance</option>
              <option value="URGENT_ATTENTION">Urgent Attention</option>
            </select>
          </div>

          {/* Electrical Readings */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: '16px' }}>
            <div>
              <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                Voltage (V)
              </label>
              <input
                type="number"
                step="0.01"
                value={voltageReading}
                onChange={(e) => setVoltageReading(e.target.value)}
                style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                Current (A)
              </label>
              <input
                type="number"
                step="0.01"
                value={currentReading}
                onChange={(e) => setCurrentReading(e.target.value)}
                style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                Load (kVA)
              </label>
              <input
                type="number"
                step="0.01"
                value={loadReading}
                onChange={(e) => setLoadReading(e.target.value)}
                style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
              />
            </div>
            <div>
              <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
                Temperature (°C)
              </label>
              <input
                type="number"
                step="0.1"
                value={temperatureReading}
                onChange={(e) => setTemperatureReading(e.target.value)}
                style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
              />
            </div>
          </div>

          {/* Maintenance Date */}
          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
              Maintenance Date
            </label>
            <input
              type="date"
              value={maintenanceDate}
              onChange={(e) => setMaintenanceDate(e.target.value)}
              style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
            />
          </div>

          {/* Recommended Action */}
          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
              Recommended Action
            </label>
            <textarea
              value={recommendedAction}
              onChange={(e) => setRecommendedAction(e.target.value)}
              rows={4}
              placeholder="Describe the recommended corrective actions..."
              style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
            />
          </div>

          {/* Additional Remarks */}
          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}>
              Additional Remarks
            </label>
            <textarea
              value={additionalRemarks}
              onChange={(e) => setAdditionalRemarks(e.target.value)}
              rows={4}
              placeholder="Any additional observations or notes..."
              style={{ width: '100%', padding: '8px', border: '1px solid #d1d5db', borderRadius: '4px' }}
            />
          </div>
        </div>
      </section>

      {/* Actions */}
      <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
        <button
          onClick={() => navigate(-1)}
          style={{ padding: '10px 20px', border: '1px solid #d1d5db', borderRadius: '4px', background: 'white' }}
        >
          Cancel
        </button>
        <button
          onClick={handleSaveDraft}
          style={{ padding: '10px 20px', border: 'none', borderRadius: '4px', background: '#3b82f6', color: 'white' }}
        >
          Save as Draft
        </button>
      </div>
    </div>
  );
}
```

### Step 3: Create Record History View

**File**: `frontend/src/pages/MaintenanceRecordHistory.tsx`

```typescript
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getRecordsForTransformer, type MaintenanceRecord } from '../api/maintenance-records';

export default function MaintenanceRecordHistory() {
  const { transformerId } = useParams();
  const navigate = useNavigate();

  const [records, setRecords] = useState<MaintenanceRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);

  useEffect(() => {
    if (!transformerId) return;

    setLoading(true);
    getRecordsForTransformer(transformerId, page, 10)
      .then(data => {
        setRecords(data.content);
        setTotalPages(data.totalPages);
        setLoading(false);
      })
      .catch(err => {
        alert('Error loading records: ' + err.message);
        setLoading(false);
      });
  }, [transformerId, page]);

  if (loading) return <div>Loading...</div>;

  return (
    <div style={{ padding: '24px', maxWidth: '1400px', margin: '0 auto' }}>
      <h1>Maintenance Record History</h1>

      <table style={{ width: '100%', marginTop: '24px', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ background: '#f3f4f6', borderBottom: '2px solid #d1d5db' }}>
            <th style={{ padding: '12px', textAlign: 'left' }}>Record #</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Transformer</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Inspection Date</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Status</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Anomalies</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Inspector</th>
            <th style={{ padding: '12px', textAlign: 'left' }}>Actions</th>
          </tr>
        </thead>
        <tbody>
          {records.map(record => (
            <tr key={record.id} style={{ borderBottom: '1px solid #e5e7eb' }}>
              <td style={{ padding: '12px' }}>{record.recordNumber}</td>
              <td style={{ padding: '12px' }}>{record.transformerCode}</td>
              <td style={{ padding: '12px' }}>
                {new Date(record.inspectionDate).toLocaleDateString()}
              </td>
              <td style={{ padding: '12px' }}>
                <span style={{
                  padding: '4px 8px',
                  borderRadius: '4px',
                  background: record.transformerStatus === 'OK' ? '#d1fae5' : 
                              record.transformerStatus === 'URGENT_ATTENTION' ? '#fee2e2' : '#fef3c7',
                  color: record.transformerStatus === 'OK' ? '#065f46' :
                         record.transformerStatus === 'URGENT_ATTENTION' ? '#991b1b' : '#92400e'
                }}>
                  {record.transformerStatus?.replace('_', ' ')}
                </span>
              </td>
              <td style={{ padding: '12px' }}>{record.anomalyCount}</td>
              <td style={{ padding: '12px' }}>{record.inspectorName || '-'}</td>
              <td style={{ padding: '12px' }}>
                <button
                  onClick={() => navigate(`/maintenance-records/${record.id}`)}
                  style={{ padding: '6px 12px', border: '1px solid #d1d5db', borderRadius: '4px', background: 'white' }}
                >
                  View
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Pagination */}
      <div style={{ marginTop: '24px', display: 'flex', justifyContent: 'center', gap: '8px' }}>
        <button
          onClick={() => setPage(p => Math.max(0, p - 1))}
          disabled={page === 0}
          style={{ padding: '8px 16px', border: '1px solid #d1d5db', borderRadius: '4px' }}
        >
          Previous
        </button>
        <span style={{ padding: '8px 16px' }}>
          Page {page + 1} of {totalPages}
        </span>
        <button
          onClick={() => setPage(p => Math.min(totalPages - 1, p + 1))}
          disabled={page >= totalPages - 1}
          style={{ padding: '8px 16px', border: '1px solid #d1d5db', borderRadius: '4px' }}
        >
          Next
        </button>
      </div>
    </div>
  );
}
```

### Step 4: Add Routes

**File**: `frontend/src/App.tsx` (add these routes)

```typescript
<Route path="/inspections/:inspectionId/maintenance-record" element={<MaintenanceRecordForm />} />
<Route path="/maintenance-records/:id" element={<MaintenanceRecordView />} />
<Route path="/transformers/:transformerId/maintenance-history" element={<MaintenanceRecordHistory />} />
```

---

## PDF Generation

### Option 1: Server-Side PDF (Recommended)

**Add dependency to `build.gradle`**:
```gradle
implementation 'com.itextpdf:itext7-core:7.2.5'
```

**File**: `backend/src/main/java/com/acme/backend/service/PdfGenerationService.java`

```java
package com.acme.backend.service;

import com.acme.backend.domain.MaintenanceRecord;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;

@Service
public class PdfGenerationService {

    public byte[] generatePdf(MaintenanceRecord record) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        try {
            PdfWriter writer = new PdfWriter(baos);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            // Title
            document.add(new Paragraph("Maintenance Record")
                .setFontSize(20)
                .setBold());
            
            document.add(new Paragraph("Record Number: " + record.getRecordNumber()));
            document.add(new Paragraph("Transformer: " + record.getTransformer().getCode()));
            
            // Add more content...

            document.close();
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate PDF", e);
        }

        return baos.toByteArray();
    }
}
```

### Option 2: Client-Side PDF

**Add dependency to `frontend/package.json`**:
```json
"dependencies": {
  "jspdf": "^2.5.1",
  "html2canvas": "^1.4.1"
}
```

```typescript
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

const exportToPdf = async () => {
  const element = document.getElementById('maintenance-record-content');
  const canvas = await html2canvas(element!);
  const imgData = canvas.toDataURL('image/png');
  
  const pdf = new jsPDF();
  pdf.addImage(imgData, 'PNG', 10, 10, 190, 0);
  pdf.save(`maintenance-record-${record.recordNumber}.pdf`);
};
```

---

## Implementation Timeline

### Week 1: Database & Backend Foundation
- **Day 1-2**: Create database tables, run migrations
- **Day 3-4**: Create domain entities and repositories
- **Day 5**: Create service layer and business logic

### Week 2: Backend API & Frontend Foundation
- **Day 1-2**: Create REST controllers and test with Postman
- **Day 3-4**: Create TypeScript types and API clients
- **Day 5**: Build basic form component

### Week 3: UI & Integration
- **Day 1-2**: Complete maintenance record form with all fields
- **Day 3**: Build record history view
- **Day 4**: Integrate with existing inspection flow
- **Day 5**: Add routing and navigation

### Week 4: PDF & Polish
- **Day 1-2**: Implement PDF generation (server or client)
- **Day 3**: Add print-friendly CSS
- **Day 4**: Testing and bug fixes
- **Day 5**: Documentation and deployment

**Total Estimated Time**: 4 weeks (80-100 hours)

---

## Testing Checklist

### Backend Tests
- [ ] Create maintenance record from inspection
- [ ] Update draft record
- [ ] Finalize record (lock editing)
- [ ] Cannot edit finalized record
- [ ] Get records for transformer
- [ ] Filter by date range
- [ ] Soft delete record
- [ ] Record number generation is unique
- [ ] Anomaly snapshot is correct
- [ ] Versioning works correctly

### Frontend Tests
- [ ] Form loads inspection data correctly
- [ ] All input fields are editable
- [ ] Validation works (required fields)
- [ ] Save draft creates record
- [ ] Record history displays correctly
- [ ] Pagination works
- [ ] PDF export works
- [ ] Print view is clean
- [ ] Navigation flows correctly

### Integration Tests
- [ ] End-to-end: Inspection → Record → PDF
- [ ] Multiple records for same transformer
- [ ] Record history filtering
- [ ] Edit and re-save draft
- [ ] Finalize prevents further edits

---

## Summary

Phase 4 adds **digital maintenance record generation** to complete the TransX platform workflow:

1. **Database**: 2 new tables (`maintenance_records`, `maintenance_record_anomalies`)
2. **Backend**: 2 entities, 1 repository, 1 service, 1 controller
3. **Frontend**: 3 new pages (Form, View, History)
4. **PDF**: Server-side (iText) or client-side (jsPDF)

**Key Features**:
- ✅ Auto-populate from inspection data
- ✅ Editable engineer input fields
- ✅ Anomaly snapshot for traceability
- ✅ Version control and finalization
- ✅ Record history with filtering
- ✅ PDF export for audits

This completes all 4 phases of the EN3350 Software Design Competition!



# Phase 4 Implementation Approach

## Overview
Phase 4 introduces a **Digital Maintenance Record System** to the **TransX platform**.  
After transformer inspection and anomaly detection (Phases 1–3), engineers can now generate, edit, finalize, and archive official maintenance records with AI-validated data, engineering input, and audit-friendly PDF export.

---

## Step-wise Guide

### 1. Database Schema Setup
#### Create Two New Tables
- **maintenancerecords**  
  Stores maintenance record metadata, engineer inputs, inspection references, and versioning.

- **maintenancerecordanomalies**  
  Records a snapshot of anomaly data when a maintenance record is created.

#### Update Existing Tables
- Add summary columns:
  - Record count
  - Has record flag  
  For quick stats and linkage in `transformers` and `inspections`.

---

### 2. Backend Entity Modeling
#### Define Domain Entities
- `MaintenanceRecord`  
- `MaintenanceRecordAnomaly`  
  Include both system-generated and engineer-editable fields.

#### Establish Relationships
- Link maintenance records to transformers and inspections.  
- Associate anomaly snapshots for traceability.

#### Add Status & Versioning
- Support `draft` and `finalized` statuses.  
- Implement version control to lock finalized records.

---

### 3. Backend Repository & Service Layer
#### Repository Creation
- Implement CRUD repositories for all main entities.  
- Enable custom queries for:
  - Filtering by date
  - Transformer ID
  - Record status

#### Service Layer
- Business logic for:
  - Creating, updating, finalizing, retrieving, and soft-deleting records  
  - Generating anomaly snapshots  
  - Managing version increments

---

### 4. Backend API Layer
#### REST Controller Design
Expose endpoints for:
- Record creation  
- Editing and finalization  
- Retrieval by ID, transformer, or date range  
- Soft deletion

#### Validation & Security
- Validate engineer input fields.  
- Enforce restrictions on finalized records.  
- Link records using unique inspection and transformer references.

---

### 5. Frontend Implementation
#### Form Page
- Responsive form with:
  - Auto-filled system data from inspection  
  - AI anomaly data display  
  - Editable fields for engineer input

#### Record History View
- Listing page with:
  - Filtering by transformer and date  
  - Pagination  
  - Summaries: status, anomaly count, inspector, actions

#### Record View Page
- Detailed record view:
  - Read-only system fields  
  - Editable engineer fields (if draft)

#### Navigation Enhancements
- Add new routes for:
  - Maintenance form  
  - Record view  
  - History page

---

### 6. PDF Export Integration
#### PDF Generation
- Integrate server-side or client-side PDF export.  
- Include:
  - Full record data  
  - Inspection info  
  - Anomaly list  
  - Engineer input  
  - Record status and version  
For compliance and audits.

---

### 7. Testing and QA Checklist
#### Backend Testing
- Verify:
  - Record creation from inspection  
  - Correct anomaly snapshot generation  
  - Unique record numbers and versioning  
  - Filtering, soft delete, and finalized record protection

#### Frontend Testing
- Validate:
  - Form data filling and error handling  
  - Data persistence  
  - Record viewing, filtering, and PDF export  
  - Smooth navigation and consistent UI workflow

---

### 8. Deployment and Documentation
#### Deploy New Features
- Run database migrations  
- Verify entity and API availability  
- Update documentation for all new and modified endpoints

#### User Guide
- Provide step-by-step instructions for:
  - Filling  
  - Saving  
  - Finalizing  
  - Exporting maintenance records

---

## Implementation Milestones

| Week | Task Focus |
|------|-------------|
| Week 1 | Database & backend entities |
| Week 2 | API & frontend foundation |
| Week 3 | UI integration, history, and record view |
| Week 4 | PDF export & final polish |

---

## Key Features Covered
- Database schema setup and anomaly snapshot for traceability  
- Editable and system-generated fields in records  
- Secure status handling (`draft`/`finalized`) and version control  
- Full audit trail and historical records filtering  
- Clean PDF export for compliance and reporting

---

## End Result
Phase 4 completes the **full digital transformer workflow** — from anomaly detection to **robust, audit-friendly maintenance records** within the TransX platform.