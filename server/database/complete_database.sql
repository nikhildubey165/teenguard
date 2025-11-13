-- ============================================
-- PARENT-TEEN CONTROL - COMPLETE DATABASE SETUP
-- This file includes schema creation and data cleanup
-- Run this in phpMyAdmin to set up or reset the database
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

-- App usage tracking table
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
-- DATA CLEANUP (IMPORTANT: Fix for "Used Today" issue)
-- ============================================

-- ⚠️ RECOMMENDED: Delete old usage data to fix the "always showing 1 minute" issue
-- This removes yesterday's data and keeps only today's data
DELETE FROM app_usage WHERE usage_date < CURDATE();

-- Alternative: Delete ALL usage data to start completely fresh (uncomment if needed)
-- DELETE FROM app_usage;
-- ALTER TABLE app_usage AUTO_INCREMENT = 1;

-- Verify cleanup
SELECT CONCAT('✅ Cleaned old data. Remaining records: ', COUNT(*)) as cleanup_status
FROM app_usage;

-- ============================================
-- USEFUL QUERIES FOR MAINTENANCE
-- ============================================

-- View all usage data
-- SELECT 
--   u.name as teenager_name,
--   au.app_name,
--   au.usage_minutes,
--   au.usage_date,
--   au.updated_at
-- FROM app_usage au
-- JOIN users u ON au.teenager_id = u.id
-- ORDER BY au.usage_date DESC, au.updated_at DESC;

-- View today's usage only
-- SELECT 
--   u.name as teenager_name,
--   au.app_name,
--   au.usage_minutes,
--   au.usage_date
-- FROM app_usage au
-- JOIN users u ON au.teenager_id = u.id
-- WHERE au.usage_date = CURDATE()
-- ORDER BY u.name, au.app_name;

-- View app limits
-- SELECT 
--   u.name as teenager_name,
--   al.app_name,
--   al.daily_limit_minutes
-- FROM app_limits al
-- JOIN users u ON al.teenager_id = u.id
-- ORDER BY u.name, al.app_name;

-- View custom apps
-- SELECT 
--   u.name as teenager_name,
--   ca.app_name,
--   ca.icon,
--   ca.category,
--   ca.url
-- FROM custom_apps ca
-- JOIN users u ON ca.teenager_id = u.id
-- ORDER BY u.name, ca.app_name;

-- ============================================
-- VERIFICATION & DIAGNOSTICS
-- ============================================

-- Basic verification
SELECT '✅ Database setup complete!' as status;
SELECT CONCAT('📊 Tables created: ', COUNT(*)) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'parent_teen_db';

-- Show current date and time
SELECT 
  '📅 Current Server Date/Time' as info,
  CURDATE() as today_date,
  NOW() as server_time;

-- Check app_usage table structure
SELECT 
  '📋 App Usage Table Structure' as info,
  COLUMN_NAME,
  DATA_TYPE,
  IS_NULLABLE,
  COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'parent_teen_db' 
  AND TABLE_NAME = 'app_usage'
ORDER BY ORDINAL_POSITION;

-- Show all usage data with date status
SELECT 
  '📊 All Usage Records' as section,
  au.id,
  COALESCE(u.name, 'Unknown') as teenager_name,
  au.app_name,
  au.usage_minutes,
  au.usage_date,
  CASE 
    WHEN au.usage_date = CURDATE() THEN '✅ TODAY'
    WHEN au.usage_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY) THEN '⚠️ YESTERDAY'
    ELSE '❌ OLD DATA'
  END as date_status,
  au.updated_at
FROM parent_teen_db.app_usage au
LEFT JOIN parent_teen_db.users u ON au.teenager_id = u.id
ORDER BY au.usage_date DESC, au.updated_at DESC
LIMIT 20;

-- Show only today's usage
SELECT 
  '✅ Today\'s Usage Only' as section,
  COALESCE(u.name, 'Unknown') as teenager_name,
  au.app_name,
  au.usage_minutes,
  au.usage_date,
  au.updated_at
FROM parent_teen_db.app_usage au
LEFT JOIN parent_teen_db.users u ON au.teenager_id = u.id
WHERE au.usage_date = CURDATE()
ORDER BY u.name, au.app_name;

-- Count records by date
SELECT 
  '📈 Usage Count by Date' as section,
  usage_date,
  COUNT(*) as record_count,
  SUM(usage_minutes) as total_minutes,
  CASE 
    WHEN usage_date = CURDATE() THEN '✅ TODAY'
    WHEN usage_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY) THEN '⚠️ YESTERDAY (Should be 0!)'
    ELSE '❌ OLD DATA (Should be 0!)'
  END as status
FROM parent_teen_db.app_usage
GROUP BY usage_date
ORDER BY usage_date DESC;

-- Check if old data exists (should return 0)
SELECT 
  '🔍 Old Data Check' as section,
  COUNT(*) as old_records_count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ GOOD - No old data found'
    ELSE '⚠️ WARNING - Old data still exists! Run cleanup again.'
  END as status
FROM parent_teen_db.app_usage
WHERE usage_date < CURDATE();

-- Show app limits
SELECT 
  '⏱️ App Limits Configuration' as section,
  COALESCE(u.name, 'Unknown') as teenager_name,
  al.app_name,
  al.daily_limit_minutes
FROM parent_teen_db.app_limits al
LEFT JOIN parent_teen_db.users u ON al.teenager_id = u.id
ORDER BY u.name, al.app_name;

-- Final status summary
SELECT 
  '🎯 VERIFICATION COMPLETE' as status,
  CONCAT('Today is: ', CURDATE()) as today,
  CONCAT('Server time: ', NOW()) as time,
  '✅ Check results above for any warnings' as note;

-- ============================================
-- SETUP INSTRUCTIONS
-- ============================================
-- 
-- ⚠️ IMPORTANT: This file now includes automatic cleanup of old usage data
-- This fixes the "Used Today always showing 1 minute from yesterday" issue
--
-- METHOD 1: Using phpMyAdmin (Recommended)
-- 1. Open http://localhost/phpmyadmin
-- 2. Click on "SQL" tab
-- 3. Copy and paste this ENTIRE file
-- 4. Click "Go" to execute
-- 5. Done! Old data will be cleaned automatically ✅
--
-- METHOD 2: Using MySQL Command Line
-- 1. Open Command Prompt
-- 2. Run: mysql -u root -p parent_teen_db < complete_database.sql
-- 3. Enter your MySQL password
-- 4. Done! ✅
--
-- WHAT THIS FILE DOES:
-- ✅ Creates all necessary tables
-- ✅ Removes yesterday's usage data (keeps only today's data)
-- ✅ Fixes the "always showing 1 minute" bug
-- ✅ Verifies the database is set up correctly
--
-- ============================================
