-- ============================================
-- DATABASE RESET SCRIPT
-- This will clean up old usage data and ensure fresh start
-- ============================================

USE parent_teen_db;

-- Step 1: Delete ALL old usage data
-- This removes all historical usage records
DELETE FROM app_usage;

-- Step 2: Reset auto-increment counter
ALTER TABLE app_usage AUTO_INCREMENT = 1;

-- Step 3: Verify the table is empty
SELECT COUNT(*) as total_records FROM app_usage;

-- Step 4: Check current structure (should show 0 records)
SELECT * FROM app_usage;

-- Step 5: Verify other tables are intact
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_limits FROM app_limits;
SELECT COUNT(*) as total_custom_apps FROM custom_apps;

-- ============================================
-- OPTIONAL: If you want to keep limits but reset usage
-- ============================================

-- View current app limits (these will be preserved)
SELECT 
    al.id,
    u.username,
    al.app_name,
    al.daily_limit_minutes,
    al.created_at
FROM app_limits al
JOIN users u ON al.teenager_id = u.id
ORDER BY u.username, al.app_name;

-- View custom apps (these will be preserved)
SELECT 
    ca.id,
    u.username,
    ca.app_name,
    ca.icon,
    ca.category,
    ca.url,
    ca.created_at
FROM custom_apps ca
JOIN users u ON ca.user_id = u.id
ORDER BY u.username, ca.app_name;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check today's date in database
SELECT CURDATE() as today_date, NOW() as current_timestamp;

-- After running this script, all usage should be 0
-- When you use an app, it will create new records with today's date

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '✅ Database cleaned successfully! All usage data removed.' as status;
SELECT '📊 App limits and custom apps are preserved.' as info;
SELECT '🎯 Usage tracking will start fresh from 0 minutes.' as next_step;
