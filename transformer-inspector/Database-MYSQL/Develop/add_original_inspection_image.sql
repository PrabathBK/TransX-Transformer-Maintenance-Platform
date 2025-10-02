-- Migration to add original_inspection_image_id column to inspections table
-- This allows tracking of the original image for editing annotations separately from the display image

ALTER TABLE inspections 
ADD COLUMN original_inspection_image_id BINARY(16),
ADD CONSTRAINT fk_inspection_original_image 
    FOREIGN KEY (original_inspection_image_id) 
    REFERENCES thermal_images(id) 
    ON DELETE SET NULL;

-- Create index for performance
CREATE INDEX idx_inspections_original_inspection_image_id 
ON inspections (original_inspection_image_id);

-- Update existing inspections to set original image same as current inspection image
UPDATE inspections 
SET original_inspection_image_id = inspection_image_id 
WHERE inspection_image_id IS NOT NULL;