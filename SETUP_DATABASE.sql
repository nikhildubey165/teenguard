-- ============================================
-- PARENT-TEEN CONTROL - DATABASE SETUP
-- Fixed version for correct usage tracking
-- ============================================

-- Create and use database
CREATE DATABASE IF NOT EXISTS parent_teen_db;
USE parent_teen_db;

-- ============================================
-- TABLE CREATION
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('parent', 'teenager') NOT NULL,
  parent_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_role (role),
  INDEX idx_parent_id (parent_id)
);

-- Parents table
CREATE TABLE IF NOT EXISTS parents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Teenagers table
CREATE TABLE IF NOT EXISTS teenagers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  teenager_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  due_date DATETIME NOT NULL,
  estimated_time INT,
  status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_teenager_status (teenager_id, status),
  INDEX idx_due_date (due_date)
);

-- Time requests table
CREATE TABLE IF NOT EXISTS time_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  teenager_id INT NOT NULL,
  additional_time INT NOT NULL,
  reason TEXT,
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_status (status)
);

-- App limits table
CREATE TABLE IF NOT EXISTS app_limits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  daily_limit_minutes INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_app_limit (teenager_id, app_name),
  INDEX idx_teenager_app (teenager_id, app_name)
);

-- Blocked sites table
CREATE TABLE IF NOT EXISTS blocked_sites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  teenager_id INT NOT NULL,
  site_url VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_teenager_id (teenager_id)
);

-- ⭐ App usage tracking table (MAIN TABLE FOR USAGE TRACKING)
CREATE TABLE IF NOT EXISTS app_usage (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  usage_minutes INT NOT NULL DEFAULT 0,
  usage_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_daily_usage (teenager_id, app_name, usage_date),
  INDEX idx_teenager_date (teenager_id, usage_date),
  INDEX idx_usage_date (usage_date)
);

-- Website usage tracking table
CREATE TABLE IF NOT EXISTS website_usage (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  site_url VARCHAR(500) NOT NULL,
  visit_count INT NOT NULL DEFAULT 0,
  usage_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_daily_website_usage (teenager_id, site_url, usage_date),
  INDEX idx_teenager_date (teenager_id, usage_date)
);

-- Custom apps table
CREATE TABLE IF NOT EXISTS custom_apps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  icon VARCHAR(50) DEFAULT '📱',
  category VARCHAR(100) DEFAULT 'Other',
  url VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_teen_app (teenager_id, app_name),
  INDEX idx_teenager_id (teenager_id)
);

-- Time limit increase requests table
CREATE TABLE IF NOT EXISTS time_limit_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  parent_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  current_limit INT NOT NULL,
  requested_limit INT NOT NULL,
  reason TEXT,
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_parent_status (parent_id, status),
  INDEX idx_teenager_status (teenager_id, status)
);

-- Hidden apps table
CREATE TABLE IF NOT EXISTS hidden_apps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_hidden_app (teenager_id, app_name),
  INDEX idx_teenager_id (teenager_id)
);

-- ============================================
-- CLEAN OLD USAGE DATA (OPTIONAL)
-- ============================================

-- Option 1: Delete ONLY yesterday's data (keeps today's data)
-- DELETE FROM app_usage WHERE usage_date < CURDATE();

-- Option 2: Delete ALL usage data to start completely fresh
-- DELETE FROM app_usage;
-- ALTER TABLE app_usage AUTO_INCREMENT = 1;

-- ============================================
-- USEFUL QUERIES TO CHECK YOUR DATA
-- ============================================

-- Check today's usage
SELECT 
  u.name as teenager_name,
  au.app_name,
  au.usage_minutes,
  au.usage_date,
  au.updated_at
FROM app_usage au
JOIN users u ON au.teenager_id = u.id
WHERE au.usage_date = CURDATE()
ORDER BY u.name, au.app_name;

-- Check all recent usage (last 7 days)
SELECT 
  u.name as teenager_name,
  au.app_name,
  au.usage_minutes,
  au.usage_date,
  au.updated_at
FROM app_usage au
JOIN users u ON au.teenager_id = u.id
WHERE au.usage_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY au.usage_date DESC, u.name, au.app_name;

-- Check app limits
SELECT 
  u.name as teenager_name,
  al.app_name,
  al.daily_limit_minutes
FROM app_limits al
JOIN users u ON al.teenager_id = u.id
ORDER BY u.name, al.app_name;

-- ============================================
-- VERIFICATION
-- ============================================

SELECT '✅ Database setup complete!' as status;
SELECT CONCAT('📊 Total tables: ', COUNT(*)) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'parent_teen_db';
SELECT CURDATE() as today_date, NOW() as server_time;

-- ============================================
-- SETUP INSTRUCTIONS
-- ============================================
-- 
-- METHOD 1: Using phpMyAdmin (Easiest)
-- 1. Open http://localhost/phpmyadmin in your browser
-- 2. Click on "SQL" tab at the top
-- 3. Copy this ENTIRE file content
-- 4. Paste it in the SQL text area
-- 5. Click "Go" button
-- 6. Done! ✅
--
-- METHOD 2: Using MySQL Command Line
-- 1. Open Command Prompt
-- 2. Navigate to this file's location
-- 3. Run: mysql -u root -p < SETUP_DATABASE.sql
-- 4. Enter your MySQL password
-- 5. Done! ✅
--
-- TO CLEAN OLD DATA:
-- - Uncomment one of the DELETE lines in "CLEAN OLD USAGE DATA" section
-- - Run the script again
--
-- ============================================
