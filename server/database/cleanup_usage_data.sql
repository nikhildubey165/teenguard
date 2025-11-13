-- ============================================
-- CLEANUP SCRIPT - Fix Incorrect Usage Data
-- ============================================
-- Run this to clean up old/incorrect data before testing the fix
-- ============================================

USE parent_teen_db;

-- 1. Show current data (before cleanup)
SELECT 
  '📊 BEFORE CLEANUP' as section,
  au.id,
  u.name as teenager,
  au.app_name,
  au.usage_minutes,
  au.usage_date,
  au.updated_at
FROM app_usage au
LEFT JOIN users u ON au.teenager_id = u.id
ORDER BY au.usage_date DESC, au.updated_at DESC;

-- 2. Delete ALL usage data to start fresh
DELETE FROM app_usage;

-- 3. Reset auto-increment
ALTER TABLE app_usage AUTO_INCREMENT = 1;

-- 4. Verify cleanup
SELECT 
  '✅ AFTER CLEANUP' as section,
  COUNT(*) as total_records,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ All data cleaned - Ready for testing!'
    ELSE '⚠️ Some data remains'
  END as status
FROM app_usage;

SELECT '🎯 Cleanup complete! Now restart your server and test the app.' as message;
