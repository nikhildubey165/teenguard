-- Check current usage data
SELECT 
    app_name,
    usage_minutes,
    usage_date,
    DATE(usage_date) as date_only,
    CURDATE() as today,
    CASE 
        WHEN DATE(usage_date) = CURDATE() THEN 'TODAY ✅'
        ELSE 'OLD DATA ❌'
    END as status,
    created_at,
    updated_at
FROM app_usage
ORDER BY updated_at DESC
LIMIT 10;

-- Check if date matches
SELECT 
    COUNT(*) as records_today,
    SUM(usage_minutes) as total_minutes_today
FROM app_usage
WHERE DATE(usage_date) = CURDATE();

-- Check all dates
SELECT 
    DATE(usage_date) as date,
    COUNT(*) as records,
    SUM(usage_minutes) as total_minutes
FROM app_usage
GROUP BY DATE(usage_date)
ORDER BY date DESC;
