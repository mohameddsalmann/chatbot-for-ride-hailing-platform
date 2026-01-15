-- ============================================
-- SMARTLINE CHATBOT V3.4 DATABASE MIGRATION
-- Issue Reporting, Manipulation Detection, Strike System
-- ============================================

-- ============================================
-- ISSUE REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS issue_reports (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    trip_id VARCHAR(100),
    captain_id VARCHAR(100),
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50) NOT NULL,
    description TEXT,
    status ENUM('PENDING', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REJECTED') DEFAULT 'PENDING',
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    resolution TEXT,
    resolved_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_trip_id (trip_id),
    INDEX idx_captain_id (captain_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at)
);

-- ============================================
-- EMERGENCY ALERTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS emergency_alerts (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    trip_id VARCHAR(100),
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    status ENUM('PENDING', 'ACKNOWLEDGED', 'RESOLVED') DEFAULT 'PENDING',
    priority ENUM('HIGH', 'CRITICAL') DEFAULT 'CRITICAL',
    acknowledged_by VARCHAR(100),
    acknowledged_at TIMESTAMP NULL,
    resolved_at TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status_priority (status, priority),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- ============================================
-- MANIPULATION REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS manipulation_reports (
    id VARCHAR(50) PRIMARY KEY,
    trip_id VARCHAR(100),
    captain_id VARCHAR(100) NOT NULL,
    rider_id VARCHAR(100) NOT NULL,
    
    -- Report details
    report_type ENUM('cancel_request', 'cash_request', 'rebook_request', 'other') DEFAULT 'other',
    description TEXT,
    
    -- Evidence
    evidence_id VARCHAR(50),
    evidence_type ENUM('image', 'audio', 'text'),
    
    -- AI Validation
    ai_confidence DECIMAL(5,2) DEFAULT 0,
    keywords_detected JSON,
    ocr_text TEXT,
    transcription TEXT,
    
    -- Status
    status ENUM('PENDING', 'VALIDATED', 'STRIKE_APPLIED', 'REJECTED', 'LOGGED_LOW_CONFIDENCE') DEFAULT 'PENDING',
    strike_id VARCHAR(50),
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validated_at TIMESTAMP NULL,
    resolved_at TIMESTAMP NULL,
    
    -- Indexes
    INDEX idx_captain (captain_id),
    INDEX idx_rider (rider_id),
    INDEX idx_trip (trip_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
);

-- ============================================
-- EVIDENCE FILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS evidence_files (
    id VARCHAR(50) PRIMARY KEY,
    trip_id VARCHAR(100),
    user_id VARCHAR(100) NOT NULL,
    report_id VARCHAR(50),
    
    -- File info
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size INT,
    
    -- Validation
    ai_confidence DECIMAL(5,2),
    validation_result JSON,
    
    -- Timestamps
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validated_at TIMESTAMP NULL,
    
    INDEX idx_trip (trip_id),
    INDEX idx_user (user_id),
    INDEX idx_report (report_id)
);

-- ============================================
-- CAPTAIN STRIKES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS captain_strikes (
    id VARCHAR(50) PRIMARY KEY,
    captain_id VARCHAR(100) NOT NULL,
    report_id VARCHAR(50),
    
    -- Strike details
    level INT NOT NULL DEFAULT 0,
    action ENUM('WARNING', 'EARNINGS_HOLD', 'SUSPENSION', 'PERMANENT_BAN') NOT NULL,
    reason VARCHAR(255),
    
    -- AI data
    confidence DECIMAL(5,2),
    keywords_detected JSON,
    
    -- Status & timing
    status ENUM('ACTIVE', 'EXPIRED', 'APPEALED', 'OVERTURNED') DEFAULT 'ACTIVE',
    expires_at TIMESTAMP NULL,
    
    -- Appeal info
    appeal_reason TEXT,
    appeal_date TIMESTAMP NULL,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_captain (captain_id),
    INDEX idx_status (status),
    INDEX idx_level (level),
    INDEX idx_expires (expires_at)
);

-- ============================================
-- STRIKE APPEALS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS strike_appeals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    strike_id VARCHAR(50) NOT NULL,
    captain_id VARCHAR(100) NOT NULL,
    reason TEXT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    reviewer_id VARCHAR(100),
    review_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    
    INDEX idx_strike (strike_id),
    INDEX idx_captain (captain_id),
    INDEX idx_status (status)
);

-- ============================================
-- BAN REVIEW QUEUE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS ban_review_queue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    captain_id VARCHAR(100) NOT NULL UNIQUE,
    status ENUM('PENDING', 'REVIEWED', 'APPROVED', 'OVERTURNED') DEFAULT 'PENDING',
    reviewer_id VARCHAR(100),
    review_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    
    INDEX idx_captain (captain_id),
    INDEX idx_status (status)
);

-- ============================================
-- SUSPICIOUS ACTIVITY LOG TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS suspicious_activity_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user (user_id),
    INDEX idx_type (activity_type),
    INDEX idx_created (created_at)
);

-- ============================================
-- NOTIFICATIONS TABLE (if not exists)
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    message TEXT,
    data JSON,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    INDEX idx_user (user_id),
    INDEX idx_type (type),
    INDEX idx_read (is_read),
    INDEX idx_created (created_at)
);

-- ============================================
-- ADD COLUMNS TO DRIVERS TABLE
-- (Run these separately if columns don't exist)
-- ============================================

-- Add earnings hold columns
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS earnings_hold BOOLEAN DEFAULT FALSE;
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS hold_expires_at TIMESTAMP NULL;

-- Add suspension columns
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT FALSE;
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS suspension_expires_at TIMESTAMP NULL;

-- Add ban columns
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT FALSE;
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS banned_at TIMESTAMP NULL;
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS ban_reason VARCHAR(255);

-- Add language preference
-- ALTER TABLE drivers ADD COLUMN IF NOT EXISTS preferred_language VARCHAR(10) DEFAULT 'ar';

-- ============================================
-- PROMO CODES TABLE (for promo feature)
-- ============================================
CREATE TABLE IF NOT EXISTS promo_codes (
    id VARCHAR(50) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_amount DECIMAL(10,2) NOT NULL,
    discount_type ENUM('fixed', 'percentage') DEFAULT 'fixed',
    max_discount DECIMAL(10,2),
    min_order_amount DECIMAL(10,2),
    usage_limit INT,
    usage_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    expiry_date TIMESTAMP NULL,
    allow_multiple_use BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_code (code),
    INDEX idx_active (is_active),
    INDEX idx_expiry (expiry_date)
);

-- ============================================
-- PROMO CODE USAGE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS promo_code_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promo_code_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    trip_id VARCHAR(100),
    discount_applied DECIMAL(10,2),
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_promo (promo_code_id),
    INDEX idx_user (user_id),
    UNIQUE KEY unique_promo_user (promo_code_id, user_id)
);

-- ============================================
-- COMPLAINTS TABLE (enhanced)
-- ============================================
CREATE TABLE IF NOT EXISTS complaints (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    trip_id VARCHAR(100),
    type VARCHAR(50) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in_progress', 'resolved', 'closed') DEFAULT 'pending',
    resolution TEXT,
    resolved_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    
    INDEX idx_user (user_id),
    INDEX idx_trip (trip_id),
    INDEX idx_status (status)
);

-- ============================================
-- END OF MIGRATION
-- ============================================

