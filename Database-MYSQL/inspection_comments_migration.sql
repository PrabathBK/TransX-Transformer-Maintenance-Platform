-- Add comments table for inspection comments
CREATE TABLE inspection_comments (
    id BINARY(16) NOT NULL PRIMARY KEY,
    inspection_id BINARY(16) NOT NULL,
    comment_text TEXT NOT NULL,
    author VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    INDEX idx_inspection_comments_inspection_id (inspection_id),
    INDEX idx_inspection_comments_created_at (created_at)
);