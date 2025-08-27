-- =====================================================
-- Migration Script: Add Inspection Support
-- Database: en3350_db
-- Date: August 27, 2025
-- =====================================================

USE en3350_db;

-- Step 1: Update thermal_images table type enum to include INSPECTION
ALTER TABLE thermal_images MODIFY COLUMN type ENUM('BASELINE', 'MAINTENANCE', 'INSPECTION') NOT NULL;

-- Step 2: Create inspections table
CREATE TABLE inspections (
    id binary(16) NOT NULL,
    inspection_no varchar(255) NOT NULL,
    transformer_id binary(16) NOT NULL,
    branch varchar(255) NOT NULL,
    inspection_date date NOT NULL,
    inspection_time time NOT NULL,
    maintenance_date date DEFAULT NULL,
    maintenance_time time DEFAULT NULL,
    status enum('IN_PROGRESS','PENDING','COMPLETED') NOT NULL DEFAULT 'IN_PROGRESS',
    inspected_by varchar(255) NOT NULL,
    notes varchar(2048) DEFAULT NULL,
    created_at datetime(6) DEFAULT NULL,
    updated_at datetime(6) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY UK_inspection_no (inspection_no),
    KEY FK_inspection_transformer (transformer_id),
    CONSTRAINT FK_inspection_transformer FOREIGN KEY (transformer_id) REFERENCES transformers (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 3: Add inspection_id column to thermal_images table
ALTER TABLE thermal_images ADD COLUMN inspection_id binary(16) DEFAULT NULL;

-- Step 4: Add foreign key constraint for inspection_id
ALTER TABLE thermal_images ADD CONSTRAINT FK_thermal_image_inspection 
FOREIGN KEY (inspection_id) REFERENCES inspections (id) ON DELETE SET NULL;

-- Step 5: Verify the changes
DESCRIBE thermal_images;
DESCRIBE inspections;

-- Show success message
SELECT 'Migration completed successfully! You can now upload INSPECTION type images.' as Status;
