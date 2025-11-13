-- Clean up old/test usage data that's showing incorrectly in Today's Usage
-- This script will help identify and remove stale data

-- Step 1: Check what data exists for today
SELECT 
  'Current Today Usage' as check_type,
  teenager_id,
  app_name,
  usage_minutes,
  usage_date,
  created_at,
  updated_at
FROM app_usage
WHERE usage_date = CURDATE()
ORDER BY updated_at DESC;

-- Step 2: Check for old test data (YouTube with lowercase)
SELECT 
  'Old Test Data' as check_type,
  teenager_id,
  app_name,
  usage_minutes,
  usage_date,
  created_at,
  updated_at
FROM app_usage
WHERE app_name = 'youtube' OR app_name = 'YouTube'
ORDER BY usage_date DESC;

-- Step 3: DELETE old test data (UNCOMMENT TO RUN)
-- This will remove the test YouTube data that was added
-- DELETE FROM app_usage WHERE app_name = 'youtube' AND usage_date = CURDATE();

-- Step 4: DELETE ALL today's usage data if you want a fresh start (UNCOMMENT TO RUN)
-- WARNING: This will delete ALL usage data for today
-- DELETE FROM app_usage WHERE usage_date = CURDATE();

-- Step 5: Verify cleanup
-- SELECT 
--   teenager_id,
--   app_name,
--   usage_minutes,
--   usage_date
-- FROM app_usage
-- WHERE usage_date = CURDATE();
