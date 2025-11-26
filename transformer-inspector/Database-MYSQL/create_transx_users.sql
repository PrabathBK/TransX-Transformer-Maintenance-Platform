-- Create transx_users table for authentication
-- Run this script in your MySQL database (en3350_db)

CREATE TABLE IF NOT EXISTS transx_users (
    id BINARY(16) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    avatar VARCHAR(500),
    role ENUM('ADMIN', 'INSPECTOR', 'VIEWER') NOT NULL DEFAULT 'INSPECTOR',
    provider ENUM('EMAIL', 'GOOGLE') NOT NULL DEFAULT 'EMAIL',
    google_id VARCHAR(255),
    theme_preference ENUM('LIGHT', 'DARK', 'SYSTEM') DEFAULT 'SYSTEM',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    email_notifications_enabled BOOLEAN DEFAULT TRUE,
    language_preference VARCHAR(10) DEFAULT 'en',
    timezone_preference VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_google_id (google_id)
);

-- Note: New users will be created when they sign up through the app
-- Passwords are stored as BCrypt hashes, not plaintext
