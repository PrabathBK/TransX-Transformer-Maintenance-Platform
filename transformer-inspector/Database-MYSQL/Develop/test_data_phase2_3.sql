-- ============================================
-- Test Data for Phase 2 & 3
-- TransX Transformer Maintenance Platform
-- ============================================

USE en3350_db;

-- ============================================
-- Check and show current structure
-- ============================================
DESCRIBE inspections;

-- ============================================
-- Insert Test Inspections
-- ============================================

-- Get a transformer ID to use (assuming transformers exist from Phase 1)
SET @transformer_id = (SELECT id FROM transformers LIMIT 1);

-- Get a thermal image ID to use as baseline (if any exist)
SET @baseline_image_id = (SELECT id FROM thermal_images WHERE type = 'BASELINE' LIMIT 1);

-- Insert sample inspection 1 (simplified - only required fields)
INSERT INTO inspections (
    id, 
    inspection_number, 
    transformer_id, 
    status, 
    created_at
) VALUES (
    UNHEX(REPLACE(UUID(), '-', '')),
    'INS-001',
    @transformer_id,
    'PENDING',
    NOW()
),
(
    UNHEX(REPLACE(UUID(), '-', '')),
    'INS-002',
    @transformer_id,
    'IN_PROGRESS',
    NOW()
),
(
    UNHEX(REPLACE(UUID(), '-', '')),
    'INS-003',
    @transformer_id,
    'COMPLETED',
    DATE_SUB(NOW(), INTERVAL 7 DAY)
);

-- ============================================
-- Verify Insertions
-- ============================================

SELECT 
    i.inspection_number,
    i.status,
    t.code AS transformer_code,
    i.branch,
    i.weather_condition,
    i.inspected_by,
    i.created_at
FROM inspections i
JOIN transformers t ON i.transformer_id = t.id
ORDER BY i.created_at DESC;

-- ============================================
-- End of Test Data Script
-- ============================================
