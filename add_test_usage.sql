-- Add test usage data for YouTube app to test blocking functionality
-- This will set the usage to 1 minute out of 2 minutes limit

-- First, check if there's a teenager user (assuming ID 1 or 2)
-- You may need to adjust the teenager_id based on your actual user ID

-- Get today's date in YYYY-MM-DD format
SET @today = CURDATE();

-- Add 1 minute of usage for YouTube (adjust teenager_id as needed)
-- Replace '1' with the actual teenager user ID from your users table
INSERT INTO app_usage (teenager_id, app_name, usage_minutes, usage_date) 
VALUES (1, 'youtube', 1, @today)
ON DUPLICATE KEY UPDATE 
  usage_minutes = 1,
  updated_at = NOW();

-- Verify the data was inserted
SELECT 
  au.teenager_id,
  au.app_name,
  au.usage_minutes,
  au.usage_date,
  al.daily_limit_minutes
FROM app_usage au
LEFT JOIN app_limits al ON au.teenager_id = al.teenager_id AND au.app_name = al.app_name
WHERE au.app_name = 'youtube' AND au.usage_date = @today;

-- To test blocking, uncomment the following line to set usage to 2 minutes (equal to limit):
-- UPDATE app_usage SET usage_minutes = 2 WHERE app_name = 'youtube' AND usage_date = @today;

-- To reset usage back to 0, uncomment the following line:
-- DELETE FROM app_usage WHERE app_name = 'youtube' AND usage_date = @today;
