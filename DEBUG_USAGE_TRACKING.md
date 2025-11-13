# Debug Guide: Usage Tracking Issue

## Problem
"Used Today" shows 0 minutes even after using an app.

## Changes Made

### Frontend (AppLimits.js)
- ✅ Added detailed logging with `===` prefix
- ✅ Immediate + delayed refresh when app closes
- ✅ Auto-refresh every 10 seconds
- ✅ Logs show: data fetching, filtering, and usage lookup

### Backend (usage.js)
- ✅ Added logging with `[USAGE]` prefix
- ✅ Logs show: what's being saved, old vs new values, retrieval results

## How to Test

### Step 1: Start the Application
```bash
# Terminal 1 - Backend (watch for [USAGE] logs)
cd server
npm start

# Terminal 2 - Frontend
cd client
npm start
```

### Step 2: Open Browser Console
1. Open browser (Chrome/Edge)
2. Press F12 to open Developer Tools
3. Go to Console tab
4. Clear console (Ctrl+L)

### Step 3: Test Usage Tracking
1. Login as teenager
2. Go to "My Apps & Limits"
3. Click on an app (e.g., Youtube)
4. Wait for at least 60 seconds (1 minute)
5. Close the app window
6. Wait 3 seconds

### Step 4: Check Logs

#### Backend Terminal Should Show:
```
[USAGE] Saving usage for Youtube: 1 minutes on 2025-11-09
[USAGE] Creating new record for Youtube: 1 minutes
[USAGE] Successfully saved usage for Youtube
```

#### Frontend Console Should Show:
```
=== Fetching usage for date: 2025-11-09
=== Raw usage data received: [{app_name: "Youtube", usage_date: "2025-11-09", usage_minutes: 1}]
=== Checking Youtube: usageDate=2025-11-09, today=2025-11-09, matches=true
=== Filtered today's usage data: [{app_name: "Youtube", usage_minutes: 1}]
=== getTodayUsage for Youtube: found=true, minutes=1, todayUsage length=1
```

## Common Issues & Solutions

### Issue 1: No backend logs
**Problem:** Backend not receiving save requests
**Solution:** Check AppLauncher.js is calling saveUsage()

### Issue 2: Backend shows 0 minutes
**Problem:** AppLauncher calculating time incorrectly
**Solution:** Check sessionStartTime and elapsed calculation

### Issue 3: Data saved but not retrieved
**Problem:** Date format mismatch
**Check:** Backend saves as YYYY-MM-DD, frontend filters same format

### Issue 4: App name mismatch
**Problem:** "Youtube" vs "youtube" (case sensitive)
**Solution:** Ensure exact match between custom_apps.app_name and app_usage.app_name

### Issue 5: Data retrieved but filtered out
**Problem:** Date comparison failing
**Check:** Console logs show "matches=false"

## Quick Database Check

If you want to check the database directly:

```sql
-- Check what's in the database
SELECT * FROM app_usage 
WHERE usage_date = CURDATE() 
ORDER BY created_at DESC;

-- Check teenager's usage
SELECT 
  au.app_name, 
  au.usage_date, 
  au.usage_minutes,
  u.name as teenager_name
FROM app_usage au
JOIN users u ON au.teenager_id = u.id
WHERE au.usage_date = CURDATE();
```

## Expected Behavior

1. **While using app:**
   - Time Used counter increases every second
   - Every 60 seconds, backend receives save request
   - Backend logs show cumulative total

2. **When closing app:**
   - Final save with remaining time
   - Frontend refreshes immediately
   - "Used Today" updates within 3 seconds

3. **Auto-refresh:**
   - Every 10 seconds, frontend fetches latest data
   - Console shows "Auto-refreshing usage data..."

## Next Steps

1. Run the test steps above
2. Copy ALL console logs (both frontend and backend)
3. Check if data is in database
4. Share logs to identify exact issue

## Files Modified

- `client/src/components/Teen/AppLimits.js` - Enhanced logging & refresh
- `client/src/components/Teen/AppLauncher.js` - Fixed time tracking
- `server/routes/usage.js` - Added logging
