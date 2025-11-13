-- Check for bad app names in the database
SELECT * FROM app_usage WHERE LENGTH(app_name) < 3 OR app_name = 'y';

-- Delete bad app usage data (single letter app names)
-- DELETE FROM app_usage WHERE LENGTH(app_name) < 3;

-- Check all app usage for today
SELECT 
    teenager_id,
    app_name,
    usage_minutes,
    usage_date,
    created_at,
    updated_at
FROM app_usage 
WHERE usage_date = CURDATE()
ORDER BY teenager_id, app_name;

-- If you want to delete just the 'y' entry:
-- DELETE FROM app_usage WHERE app_name = 'y';
