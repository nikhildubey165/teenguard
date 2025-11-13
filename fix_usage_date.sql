-- Fix usage date from yesterday to today
-- This fixes the timezone issue where data was saved with UTC date

-- Check current data
SELECT app_name, usage_minutes, usage_date, updated_at 
FROM app_usage 
WHERE usage_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY);

-- Update yesterday's data to today
UPDATE app_usage 
SET usage_date = CURDATE() 
WHERE usage_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY);

-- Verify the fix
SELECT app_name, usage_minutes, usage_date, updated_at 
FROM app_usage 
WHERE usage_date = CURDATE();
