-- =============================================
-- SaaS Login System - Database Setup
-- =============================================

-- Drop database if exists and create fresh
DROP DATABASE IF EXISTS saas_auth_system;
CREATE DATABASE saas_auth_system;
USE saas_auth_system;

-- =============================================
-- Table: users
-- Stores user account information
-- =============================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    plan_start DATE NOT NULL,
    plan_end DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- Table: password_resets
-- Stores password reset tokens
-- =============================================
CREATE TABLE password_resets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_token (token),
    INDEX idx_email (email),
    INDEX idx_expires (expires_at),
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- Insert Test Data (Optional)
-- =============================================
-- Test User: Password is 'password123'
INSERT INTO users (full_name, email, password_hash, plan_start, plan_end, status) 
VALUES (
    'Test User', 
    'test@example.com', 
    '$2a$10$KPvPOXhHvwkJ7/rOyVLJ5.rJk5Z.8F6Tr5H0b2H8yJb6vK4h8TkEi',
    CURDATE(), 
    DATE_ADD(CURDATE(), INTERVAL 30 DAY),
    'ACTIVE'
);

-- =============================================
-- Verification Queries
-- =============================================
SELECT 'Database setup complete!' AS Status;
SELECT COUNT(*) as user_count FROM users;
SELECT * FROM users;

-- =============================================
-- Cleanup old reset tokens (Run periodically)
-- =============================================
-- DELETE FROM password_resets WHERE expires_at < NOW();
