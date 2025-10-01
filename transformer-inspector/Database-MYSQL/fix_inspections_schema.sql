-- ============================================
-- Fix Inspections Table Schema Conflicts
-- TransX Transformer Maintenance Platform
-- ============================================

USE en3350_db;

-- ============================================
-- Option 1: Drop and recreate (if no important data)
-- ============================================

-- First, disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing table with conflicts
DROP TABLE IF EXISTS annotation_history;
DROP TABLE IF EXISTS annotations;
DROP TABLE IF EXISTS inspections;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Recreate with clean schema
CREATE TABLE IF NOT EXISTS inspections (
    id BINARY(16) PRIMARY KEY,
    inspection_number VARCHAR(50) UNIQUE NOT NULL,
    transformer_id BINARY(16) NOT NULL,
    baseline_image_id BINARY(16),
    inspection_image_id BINARY(16),
    
    -- Metadata
    branch VARCHAR(100),
    weather_condition ENUM('SUNNY', 'CLOUDY', 'RAINY'),
    status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    notes TEXT,
    
    -- Tracking
    inspected_by VARCHAR(100),
    inspected_at TIMESTAMP NULL,
    maintenance_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (transformer_id) REFERENCES transformers(id) ON DELETE CASCADE,
    FOREIGN KEY (baseline_image_id) REFERENCES thermal_images(id) ON DELETE SET NULL,
    FOREIGN KEY (inspection_image_id) REFERENCES thermal_images(id) ON DELETE SET NULL,
    
    -- Indexes for performance
    INDEX idx_inspection_number (inspection_number),
    INDEX idx_transformer_id (transformer_id),
    INDEX idx_status (status),
    INDEX idx_inspected_at (inspected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recreate annotations table
CREATE TABLE IF NOT EXISTS annotations (
    id BINARY(16) PRIMARY KEY,
    inspection_id BINARY(16) NOT NULL,
    version INT DEFAULT 1,
    
    -- Bounding box coordinates (pixel values)
    bbox_x1 INT NOT NULL,
    bbox_y1 INT NOT NULL,
    bbox_x2 INT NOT NULL,
    bbox_y2 INT NOT NULL,
    
    -- Classification based on rules.txt
    class_id INT,
    class_name VARCHAR(50),
    confidence DECIMAL(5,3),
    
    -- Metadata for Phase 3 tracking
    source ENUM('ai', 'human') NOT NULL,
    action_type ENUM('created', 'edited', 'deleted', 'approved', 'rejected') DEFAULT 'created',
    
    -- User tracking
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(100),
    modified_at TIMESTAMP NULL,
    
    -- Version control for Phase 3 undo/redo
    parent_annotation_id BINARY(16),
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Optional fields
    comments TEXT,
    
    -- Foreign Keys
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_annotation_id) REFERENCES annotations(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_inspection_id (inspection_id),
    INDEX idx_inspection_active (inspection_id, is_active),
    INDEX idx_source (source),
    INDEX idx_version (inspection_id, version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recreate annotation_history table
CREATE TABLE IF NOT EXISTS annotation_history (
    id BINARY(16) PRIMARY KEY,
    annotation_id BINARY(16) NOT NULL,
    inspection_id BINARY(16) NOT NULL,
    
    -- Action tracking
    action_type VARCHAR(50),
    snapshot_data JSON,
    
    -- User tracking
    user_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (annotation_id) REFERENCES annotations(id) ON DELETE CASCADE,
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_annotation_id (annotation_id),
    INDEX idx_inspection_id (inspection_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Verify schema
-- ============================================
DESCRIBE inspections;

-- ============================================
-- End of Clean Migration Script
-- ============================================
