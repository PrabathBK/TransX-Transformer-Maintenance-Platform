-- ====================================================================
-- TransX Inspection History System Database Schema
-- ====================================================================

-- Add new columns to existing annotations table for numbering
ALTER TABLE annotations 
ADD COLUMN box_number INT DEFAULT NULL AFTER class_name,
ADD COLUMN current_inspector VARCHAR(255) DEFAULT NULL AFTER created_by,
ADD INDEX idx_box_number (inspection_id, box_number);

-- Create inspection_history table for detailed tracking
CREATE TABLE inspection_history (
    id BINARY(16) NOT NULL PRIMARY KEY,
    inspection_id BINARY(16) NOT NULL,
    box_number INT DEFAULT NULL,
    action_type ENUM(
        'INSPECTION_CREATED',
        'INSPECTOR_CHANGED', 
        'AI_DETECTION_RUN',
        'BOX_CREATED',
        'BOX_EDITED',
        'BOX_MOVED',
        'BOX_RESIZED',
        'BOX_APPROVED',
        'BOX_REJECTED',
        'BOX_DELETED',
        'CLASS_CHANGED',
        'CONFIDENCE_UPDATED',
        'STATUS_CHANGED',
        'INSPECTION_COMPLETED'
    ) NOT NULL,
    action_description VARCHAR(1000) DEFAULT NULL,
    user_name VARCHAR(255) NOT NULL,
    previous_data JSON DEFAULT NULL,
    new_data JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    INDEX idx_inspection_history_inspection_id (inspection_id),
    INDEX idx_inspection_history_box_number (inspection_id, box_number),
    INDEX idx_inspection_history_created_at (created_at),
    INDEX idx_inspection_history_user (user_name),
    INDEX idx_inspection_history_action_type (action_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update inspections table to support enhanced status tracking
ALTER TABLE inspections 
ADD COLUMN current_inspector VARCHAR(255) DEFAULT NULL AFTER inspected_by,
ADD COLUMN completed_at TIMESTAMP NULL DEFAULT NULL AFTER maintenance_date,
ADD COLUMN completed_by VARCHAR(255) DEFAULT NULL AFTER completed_at;

-- Update status enum to include more granular states
ALTER TABLE inspections 
MODIFY COLUMN status ENUM(
    'DRAFT',
    'IN_PROGRESS', 
    'UNDER_REVIEW',
    'COMPLETED',
    'CANCELLED'
) DEFAULT 'DRAFT';

-- Create box_numbering_sequence table to track next box number per inspection
CREATE TABLE box_numbering_sequence (
    inspection_id BINARY(16) NOT NULL PRIMARY KEY,
    next_box_number INT NOT NULL DEFAULT 1,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create inspection_access_log for tracking who accessed what when
CREATE TABLE inspection_access_log (
    id BINARY(16) NOT NULL PRIMARY KEY,
    inspection_id BINARY(16) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    access_type ENUM('VIEW', 'EDIT', 'CREATE') NOT NULL,
    session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_end TIMESTAMP NULL DEFAULT NULL,
    user_agent VARCHAR(500) DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    INDEX idx_access_log_inspection_id (inspection_id),
    INDEX idx_access_log_user (user_name),
    INDEX idx_access_log_session_start (session_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Initial Data Migration
-- ====================================================================

-- Assign box numbers to existing annotations
SET @row_number = 0;
SET @prev_inspection_id = '';

UPDATE annotations a
JOIN (
    SELECT 
        id,
        inspection_id,
        @row_number := CASE 
            WHEN @prev_inspection_id = HEX(inspection_id) THEN @row_number + 1
            ELSE 1
        END AS box_number,
        @prev_inspection_id := HEX(inspection_id)
    FROM annotations
    WHERE is_active = 1
    ORDER BY inspection_id, created_at
) numbered ON a.id = numbered.id
SET a.box_number = numbered.box_number;

-- Initialize box numbering sequences for existing inspections
INSERT INTO box_numbering_sequence (inspection_id, next_box_number)
SELECT 
    inspection_id,
    COALESCE(MAX(box_number), 0) + 1
FROM annotations
WHERE is_active = 1
GROUP BY inspection_id;

-- ====================================================================
-- Helper Views for Easy Querying
-- ====================================================================

-- View for inspection history with human-readable data
CREATE VIEW inspection_history_view AS
SELECT 
    h.id,
    h.inspection_id,
    HEX(h.inspection_id) as inspection_id_hex,
    i.inspection_number,
    h.box_number,
    h.action_type,
    h.action_description,
    h.user_name,
    h.previous_data,
    h.new_data,
    h.created_at,
    i.status as inspection_status,
    i.current_inspector
FROM inspection_history h
JOIN inspections i ON h.inspection_id = i.id
ORDER BY h.created_at DESC;

-- View for current box status per inspection
CREATE VIEW inspection_boxes_current AS
SELECT 
    a.inspection_id,
    HEX(a.inspection_id) as inspection_id_hex,
    i.inspection_number,
    a.box_number,
    a.class_name,
    a.class_id,
    a.confidence,
    a.source,
    a.action_type,
    a.created_by,
    a.current_inspector,
    a.created_at,
    a.bbox_x1,
    a.bbox_y1,
    a.bbox_x2,
    a.bbox_y2,
    i.status as inspection_status,
    i.current_inspector as inspection_current_inspector
FROM annotations a
JOIN inspections i ON a.inspection_id = i.id
WHERE a.is_active = 1
ORDER BY a.inspection_id, a.box_number;

-- ====================================================================
-- Triggers for Automatic History Tracking
-- ====================================================================

DELIMITER $$

-- Trigger to log annotation changes
CREATE TRIGGER trg_annotation_history_insert 
    AFTER INSERT ON annotations
    FOR EACH ROW
BEGIN
    INSERT INTO inspection_history (
        id, inspection_id, box_number, action_type, action_description,
        user_name, new_data, created_at
    ) VALUES (
        UNHEX(REPLACE(UUID(), '-', '')),
        NEW.inspection_id,
        NEW.box_number,
        CASE 
            WHEN NEW.source = 'ai' THEN 'AI_DETECTION_RUN'
            ELSE 'BOX_CREATED'
        END,
        CONCAT(
            CASE WHEN NEW.source = 'ai' THEN 'AI detected ' ELSE 'User created ' END,
            'box #', COALESCE(NEW.box_number, 'unnumbered'), 
            ' - ', COALESCE(NEW.class_name, 'unknown class'),
            ' (confidence: ', COALESCE(NEW.confidence, 0), ')'
        ),
        COALESCE(NEW.current_inspector, NEW.created_by, 'system'),
        JSON_OBJECT(
            'box_number', NEW.box_number,
            'class_name', NEW.class_name,
            'class_id', NEW.class_id,
            'confidence', NEW.confidence,
            'bbox', JSON_OBJECT('x1', NEW.bbox_x1, 'y1', NEW.bbox_y1, 'x2', NEW.bbox_x2, 'y2', NEW.bbox_y2),
            'source', NEW.source,
            'action_type', NEW.action_type
        ),
        NOW()
    );
END$$

-- Trigger to log annotation updates
CREATE TRIGGER trg_annotation_history_update 
    AFTER UPDATE ON annotations
    FOR EACH ROW
BEGIN
    DECLARE action_desc VARCHAR(1000);
    DECLARE hist_action_type VARCHAR(50);
    
    -- Determine action type based on what changed
    SET hist_action_type = 'BOX_EDITED';
    SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' modified');
    
    IF OLD.action_type != NEW.action_type THEN
        CASE NEW.action_type
            WHEN 'approved' THEN 
                SET hist_action_type = 'BOX_APPROVED';
                SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' approved');
            WHEN 'rejected' THEN 
                SET hist_action_type = 'BOX_REJECTED';
                SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' rejected');
            WHEN 'deleted' THEN 
                SET hist_action_type = 'BOX_DELETED';
                SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' deleted');
        END CASE;
    ELSEIF OLD.class_name != NEW.class_name OR OLD.class_id != NEW.class_id THEN
        SET hist_action_type = 'CLASS_CHANGED';
        SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' class changed from ', 
                               COALESCE(OLD.class_name, 'unknown'), ' to ', COALESCE(NEW.class_name, 'unknown'));
    ELSEIF OLD.bbox_x1 != NEW.bbox_x1 OR OLD.bbox_y1 != NEW.bbox_y1 OR 
           OLD.bbox_x2 != NEW.bbox_x2 OR OLD.bbox_y2 != NEW.bbox_y2 THEN
        IF ABS(OLD.bbox_x2 - OLD.bbox_x1) != ABS(NEW.bbox_x2 - NEW.bbox_x1) OR 
           ABS(OLD.bbox_y2 - OLD.bbox_y1) != ABS(NEW.bbox_y2 - NEW.bbox_y1) THEN
            SET hist_action_type = 'BOX_RESIZED';
            SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' resized');
        ELSE
            SET hist_action_type = 'BOX_MOVED';
            SET action_desc = CONCAT('Box #', COALESCE(NEW.box_number, 'unnumbered'), ' moved');
        END IF;
    END IF;
    
    INSERT INTO inspection_history (
        id, inspection_id, box_number, action_type, action_description,
        user_name, previous_data, new_data, created_at
    ) VALUES (
        UNHEX(REPLACE(UUID(), '-', '')),
        NEW.inspection_id,
        NEW.box_number,
        hist_action_type,
        action_desc,
        COALESCE(NEW.current_inspector, NEW.modified_by, NEW.created_by, 'system'),
        JSON_OBJECT(
            'box_number', OLD.box_number,
            'class_name', OLD.class_name,
            'class_id', OLD.class_id,
            'confidence', OLD.confidence,
            'bbox', JSON_OBJECT('x1', OLD.bbox_x1, 'y1', OLD.bbox_y1, 'x2', OLD.bbox_x2, 'y2', OLD.bbox_y2),
            'action_type', OLD.action_type
        ),
        JSON_OBJECT(
            'box_number', NEW.box_number,
            'class_name', NEW.class_name,
            'class_id', NEW.class_id,
            'confidence', NEW.confidence,
            'bbox', JSON_OBJECT('x1', NEW.bbox_x1, 'y1', NEW.bbox_y1, 'x2', NEW.bbox_x2, 'y2', NEW.bbox_y2),
            'action_type', NEW.action_type
        ),
        NOW()
    );
END$$

-- Trigger to log inspection status changes
CREATE TRIGGER trg_inspection_history_update 
    AFTER UPDATE ON inspections
    FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO inspection_history (
            id, inspection_id, action_type, action_description,
            user_name, previous_data, new_data, created_at
        ) VALUES (
            UNHEX(REPLACE(UUID(), '-', '')),
            NEW.id,
            'STATUS_CHANGED',
            CONCAT('Inspection status changed from ', OLD.status, ' to ', NEW.status),
            COALESCE(NEW.current_inspector, NEW.inspected_by, 'system'),
            JSON_OBJECT('status', OLD.status, 'current_inspector', OLD.current_inspector),
            JSON_OBJECT('status', NEW.status, 'current_inspector', NEW.current_inspector),
            NOW()
        );
    END IF;
    
    IF OLD.current_inspector != NEW.current_inspector THEN
        INSERT INTO inspection_history (
            id, inspection_id, action_type, action_description,
            user_name, previous_data, new_data, created_at
        ) VALUES (
            UNHEX(REPLACE(UUID(), '-', '')),
            NEW.id,
            'INSPECTOR_CHANGED',
            CONCAT('Inspector changed from ', COALESCE(OLD.current_inspector, 'none'), 
                   ' to ', COALESCE(NEW.current_inspector, 'none')),
            COALESCE(NEW.current_inspector, 'system'),
            JSON_OBJECT('current_inspector', OLD.current_inspector),
            JSON_OBJECT('current_inspector', NEW.current_inspector),
            NOW()
        );
    END IF;
END$$

DELIMITER ;

-- ====================================================================
-- Sample Queries for Testing
-- ====================================================================

-- Get complete history for an inspection
-- SELECT * FROM inspection_history_view WHERE inspection_id_hex = 'YOUR_INSPECTION_ID' ORDER BY created_at;

-- Get current boxes for an inspection
-- SELECT * FROM inspection_boxes_current WHERE inspection_id_hex = 'YOUR_INSPECTION_ID' ORDER BY box_number;

-- Get next box number for an inspection
-- SELECT next_box_number FROM box_numbering_sequence WHERE inspection_id = UNHEX(REPLACE('YOUR_INSPECTION_ID', '-', ''));