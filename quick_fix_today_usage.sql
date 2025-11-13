-- QUICK FIX: Remove today's usage data to start fresh
-- Run this if you haven't used any apps today and want to clear the incorrect data

-- Show what will be deleted
SELECT 
  'Data to be deleted:' as info,
  teenager_id,
  app_name,
  usage_minutes,
  usage_date,
  created_at
FROM app_usage
WHERE usage_date = CURDATE();

-- Delete all usage data for today
-- This will remove the test YouTube data showing 14 minutes
DELETE FROM app_usage WHERE usage_date = CURDATE();

-- Verify deletion
SELECT 
  'Remaining data for today:' as info,
  COUNT(*) as count
FROM app_usage
WHERE usage_date = CURDATE();

-- If count is 0, the cleanup was successful
-- Now refresh your usage report page and Today's Usage should show 0
