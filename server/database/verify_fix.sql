-- ============================================
-- VERIFICATION SCRIPT
-- Run this to check if the fix is working
-- ============================================

USE parent_teen_db;

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
  IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'parent_teen_db' 
  AND TABLE_NAME = 'app_usage'
ORDER BY ORDINAL_POSITION;

-- Show all usage data with dates
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
    WHEN COUNT(*) = 0 THEN '✅ GOOD - No old data'
    ELSE '⚠️ WARNING - Old data still exists!'
  END as status
FROM parent_teen_db.app_usage
WHERE usage_date < CURDATE();

-- Show app limits
SELECT 
  '⏱️ App Limits' as section,
  COALESCE(u.name, 'Unknown') as teenager_name,
  al.app_name,
  al.daily_limit_minutes
FROM parent_teen_db.app_limits al
LEFT JOIN parent_teen_db.users u ON al.teenager_id = u.id
ORDER BY u.name, al.app_name;

-- Final status
SELECT 
  '🎯 VERIFICATION COMPLETE' as status,
  CONCAT('Today is: ', CURDATE()) as today,
  CONCAT('Server time: ', NOW()) as time;
