-- TransX Users table for authentication
-- Named 'transx_users' to avoid conflict with existing 'users' table
CREATE TABLE IF NOT EXISTS transx_users (
    id BINARY(16) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NULL,  -- NULL for Google OAuth users
    avatar VARCHAR(500) NULL,
    role ENUM('ADMIN', 'INSPECTOR', 'VIEWER') NOT NULL DEFAULT 'INSPECTOR',
    provider ENUM('EMAIL', 'GOOGLE') NOT NULL DEFAULT 'EMAIL',
    google_id VARCHAR(255) NULL UNIQUE,
    theme_preference ENUM('LIGHT', 'DARK', 'SYSTEM') NOT NULL DEFAULT 'SYSTEM',
    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    language_preference VARCHAR(10) NOT NULL DEFAULT 'en',
    timezone_preference VARCHAR(50) NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_transx_users_email (email),
    INDEX idx_transx_users_google_id (google_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Activity log table for tracking user actions
CREATE TABLE IF NOT EXISTS transx_user_activity_log (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NULL,
    entity_id BINARY(16) NULL,
    details JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_activity_user (user_id),
    INDEX idx_activity_action (action),
    INDEX idx_activity_created (created_at),
    CONSTRAINT fk_transx_activity_user FOREIGN KEY (user_id) REFERENCES transx_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert a default admin user (password: Admin123!)
-- Password hash is bcrypt for 'Admin123!'
INSERT IGNORE INTO transx_users (id, name, email, password, role, provider) 
VALUES (
    UNHEX(REPLACE(UUID(), '-', '')),
    'Admin User',
    'admin@transx.com',
    '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG',
    'ADMIN',
    'EMAIL'
);
