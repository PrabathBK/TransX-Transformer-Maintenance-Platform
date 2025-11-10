-- ===================================================================
-- Phase 4: Maintenance Record Generation System
-- Migration Script for TransX Platform
-- Created: November 10, 2025
-- ===================================================================

USE en3350_db;

-- ===================================================================
-- Table: maintenance_records
-- Purpose: Store digital maintenance record forms with system-generated
--          and engineer-editable fields
-- ===================================================================

DROP TABLE IF EXISTS `maintenance_record_anomalies`;
DROP TABLE IF EXISTS `maintenance_records`;

CREATE TABLE `maintenance_records` (
    `id` BINARY(16) NOT NULL,
    `record_number` VARCHAR(50) NOT NULL UNIQUE,
    
    -- Foreign keys
    `transformer_id` BINARY(16) NOT NULL,
    `inspection_id` BINARY(16) NOT NULL,
    
    -- ========== SYSTEM-GENERATED FIELDS (from inspection) ==========
    `inspection_date` TIMESTAMP NULL,
    `weather_condition` VARCHAR(20) NULL,
    `thermal_image_url` VARCHAR(500) NULL,
    `anomaly_count` INT DEFAULT 0,
    
    -- ========== TAB 1: MAINTENANCE RECORD FIELDS ==========
    -- Start Time / Completion Time
    `start_time` TIME NULL,
    `completion_time` TIME NULL,
    `supervised_by` VARCHAR(100) NULL,
    
    -- Gang Composition
    `gang_tech_1` VARCHAR(100) NULL COMMENT 'Technician I',
    `gang_tech_2` VARCHAR(100) NULL COMMENT 'Technician II', 
    `gang_tech_3` VARCHAR(100) NULL COMMENT 'Technician III',
    `gang_helpers` VARCHAR(200) NULL COMMENT 'Helpers (comma-separated)',
    
    -- Inspection Details
    `inspected_by` VARCHAR(100) NULL,
    `inspected_date` DATE NULL,
    `rectified_by` VARCHAR(100) NULL,
    `rectified_date` DATE NULL,
    `re_inspected_by` VARCHAR(100) NULL,
    `re_inspected_date` DATE NULL,
    `css_inspector` VARCHAR(100) NULL,
    `css_date` DATE NULL,
    
    -- Remarks
    `all_spotted_spots_corrected` TINYINT(1) DEFAULT 0,
    `css_inspector_2` VARCHAR(100) NULL,
    `css_date_2` DATE NULL,
    
    -- ========== TAB 2: WORK-DATA SHEET FIELDS ==========
    -- Branch / Transformer Info
    `branch` VARCHAR(100) NULL,
    `transformer_no` VARCHAR(50) NULL,
    `pole_no` VARCHAR(50) NULL,
    
    -- Location Details
    `location_details` VARCHAR(500) NULL,
    
    -- Date of Inspection
    `date_of_inspection` DATE NULL,
    `inspection_time` TIME NULL,
    
    -- Base Line Imaging Numbers
    `baseline_right` VARCHAR(50) NULL,
    `baseline_left` VARCHAR(50) NULL,
    `baseline_front` VARCHAR(50) NULL,
    
    -- Load Growth
    `load_growth_kva` DECIMAL(10, 2) NULL,
    `current_month_date` DATE NULL,
    `current_month_kva` DECIMAL(10, 2) NULL,
    
    -- Base Line Condition
    `baseline_condition` ENUM('SUNNY', 'CLOUDY', 'RAINY') NULL,
    
    -- Transformer Type
    `transformer_type` ENUM('BULK', 'DISTRIBUTION', 'POLE_MOUNTED') NULL,
    
    -- Meter Details
    `meter_serial` VARCHAR(100) NULL,
    `meter_maker_ct_ratio` VARCHAR(100) NULL,
    `meter_make` VARCHAR(100) NULL,
    
    -- Work Content (Multi-select checkboxes stored as JSON)
    `work_content` JSON NULL COMMENT 'Stores selected work items as {"Mo": true, "C": false, ...}',
    
    -- After Inspection Report checkboxes
    `after_inspection_ok` TINYINT(1) DEFAULT 0,
    `after_inspection_not_ok` TINYINT(1) DEFAULT 0,
    `after_inspection_rf_nos` VARCHAR(200) NULL,
    `after_inspection_notes` TEXT NULL,
    
    -- Inspection Voltage and Current Readings
    -- First Inspection
    `first_inspection_v_x` DECIMAL(10, 2) NULL,
    `first_inspection_v_y` DECIMAL(10, 2) NULL,
    `first_inspection_v_z` DECIMAL(10, 2) NULL,
    `first_inspection_i_r` DECIMAL(10, 2) NULL,
    `first_inspection_i_y` DECIMAL(10, 2) NULL,
    `first_inspection_i_b` DECIMAL(10, 2) NULL,
    
    -- Second Inspection
    `second_inspection_v_x` DECIMAL(10, 2) NULL,
    `second_inspection_v_y` DECIMAL(10, 2) NULL,
    `second_inspection_v_z` DECIMAL(10, 2) NULL,
    `second_inspection_i_r` DECIMAL(10, 2) NULL,
    `second_inspection_i_y` DECIMAL(10, 2) NULL,
    `second_inspection_i_b` DECIMAL(10, 2) NULL,
    
    -- ========== METADATA FIELDS ==========
    `status` ENUM('DRAFT', 'FINALIZED') DEFAULT 'DRAFT',
    `version` INT DEFAULT 1,
    `created_by` VARCHAR(100) NULL,
    `updated_by` VARCHAR(100) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `finalized_at` TIMESTAMP NULL,
    `is_deleted` TINYINT(1) DEFAULT 0,
    
    -- Constraints
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_record_number` (`record_number`),
    KEY `idx_transformer_id` (`transformer_id`),
    KEY `idx_inspection_id` (`inspection_id`),
    KEY `idx_status` (`status`),
    KEY `idx_date_of_inspection` (`date_of_inspection`),
    KEY `idx_created_at` (`created_at`),
    
    CONSTRAINT `fk_maintenance_transformer` 
        FOREIGN KEY (`transformer_id`) REFERENCES `transformers`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_maintenance_inspection` 
        FOREIGN KEY (`inspection_id`) REFERENCES `inspections`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Digital maintenance records with inspection data and engineer inputs';

-- ===================================================================
-- Table: maintenance_record_anomalies
-- Purpose: Snapshot of anomalies at the time record was created
--          (immutable historical record)
-- ===================================================================

CREATE TABLE `maintenance_record_anomalies` (
    `id` BINARY(16) NOT NULL,
    `maintenance_record_id` BINARY(16) NOT NULL,
    
    -- Snapshot data from annotations table
    `box_number` INT NULL,
    `class_id` INT NULL,
    `class_name` VARCHAR(50) NULL,
    `confidence` DECIMAL(5,3) NULL,
    `bbox_x1` INT NOT NULL,
    `bbox_y1` INT NOT NULL,
    `bbox_x2` INT NOT NULL,
    `bbox_y2` INT NOT NULL,
    `source` ENUM('ai', 'human') NOT NULL,
    `action_type` VARCHAR(50) NULL,
    `created_by` VARCHAR(100) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    PRIMARY KEY (`id`),
    KEY `idx_maintenance_record_id` (`maintenance_record_id`),
    KEY `idx_box_number` (`maintenance_record_id`, `box_number`),
    
    CONSTRAINT `fk_mra_maintenance_record` 
        FOREIGN KEY (`maintenance_record_id`) 
        REFERENCES `maintenance_records`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Historical snapshot of anomalies for each maintenance record';

-- ===================================================================
-- Optional: Update existing tables to add summary columns
-- ===================================================================

-- Add maintenance_record_count to transformers (for quick stats)
ALTER TABLE `transformers` 
ADD COLUMN `maintenance_record_count` INT DEFAULT 0 
COMMENT 'Cached count of maintenance records for this transformer';

-- Add has_maintenance_record flag to inspections
ALTER TABLE `inspections` 
ADD COLUMN `has_maintenance_record` TINYINT(1) DEFAULT 0
COMMENT 'Flag indicating if maintenance record exists for this inspection';

-- ===================================================================
-- Indexes for performance optimization
-- ===================================================================

-- Composite indexes for common queries
CREATE INDEX `idx_transformer_date` ON `maintenance_records`(`transformer_id`, `date_of_inspection`);
CREATE INDEX `idx_transformer_status` ON `maintenance_records`(`transformer_id`, `status`);
CREATE INDEX `idx_finalized_records` ON `maintenance_records`(`status`, `finalized_at`);

-- ===================================================================
-- Sample Data (Optional - for testing)
-- ===================================================================

-- Insert sample maintenance record (commented out - uncomment for testing)
/*
INSERT INTO `maintenance_records` (
    `id`, `record_number`, `transformer_id`, `inspection_id`,
    `branch`, `transformer_no`, `pole_no`,
    `inspected_by`, `inspected_date`,
    `baseline_condition`, `transformer_type`,
    `status`, `created_by`, `created_at`
) VALUES (
    UNHEX(REPLACE(UUID(), '-', '')),
    'MR-TX-001-0001',
    (SELECT id FROM transformers WHERE code = 'TX-001' LIMIT 1),
    (SELECT id FROM inspections WHERE inspection_number = 'INS-001' LIMIT 1),
    'Nugegoda',
    'TX-001',
    'EN-122-A',
    'A-110',
    '2023-05-21',
    'SUNNY',
    'BULK',
    'DRAFT',
    'system',
    NOW()
);
*/

-- ===================================================================
-- Migration Complete
-- ===================================================================

SELECT 'Phase 4 tables created successfully!' as Status;
SELECT COUNT(*) as maintenance_records_count FROM maintenance_records;
SELECT COUNT(*) as maintenance_record_anomalies_count FROM maintenance_record_anomalies;
