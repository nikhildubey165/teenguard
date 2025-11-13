# 🔍 Diagnose: "Used Today" Not Displaying

## 🎯 Quick Diagnosis Steps

### Step 1: Open Browser Console

1. Press **F12** to open DevTools
2. Go to **Console** tab
3. Click the **🔄 Refresh** button in your app
4. Look for these logs:

```
=== Fetching usage for date: 2025-11-09
=== Raw usage data received: [...]
=== Filtered today's usage data: [...]
=== getTodayUsage called for: "y"
=== Available usage data: [...]
```

### Step 2: Check What You See

Look for this specific log:
```
=== getTodayUsage called for: "y"
=== Available usage data: [{app_name: "y", usage_minutes: 2}]
```

**If you see this:** ✅ Data is there, display issue
**If you don't see this:** ❌ Data not being fetched

### Step 3: Check App Name Mismatch

Look for this warning:
```
⚠️ No usage found for "y". Available apps: ["youtube", "Y", "y "]
```

This means the app name doesn't match exactly!

## 🐛 Common Issues

### Issue 1: App Name Mismatch

**Symptom:** Console shows:
```
⚠️ No usage found for "y". Available apps: ["youtube"]
```

**Cause:** The app name in the database is "youtube" but the app card shows "y"

**Fix:** The names must match EXACTLY (case-sensitive, no extra spaces)

**Solution:**
```sql
-- Check what's in the database
SELECT DISTINCT app_name FROM app_usage WHERE usage_date = CURDATE();

-- If it shows "youtube" but your app is called "y", update it:
UPDATE app_usage SET app_name = 'y' WHERE app_name = 'youtube';
```

### Issue 2: Date Mismatch

**Symptom:** Console shows:
```
=== Checking y: usageDate=2025-11-08, today=2025-11-09, matches=false
```

**Cause:** The usage was saved with yesterday's date

**Fix:** Check your system date/time

**Solution:**
```sql
-- Check dates in database
SELECT app_name, usage_date, usage_minutes FROM app_usage ORDER BY usage_date DESC LIMIT 10;

-- If dates are wrong, update to today:
UPDATE app_usage SET usage_date = CURDATE() WHERE app_name = 'y';
```

### Issue 3: No Data in Database

**Symptom:** Console shows:
```
=== Raw usage data received: []
=== Filtered today's usage data: []
```

**Cause:** Usage wasn't saved to database

**Fix:** Check if `AppLauncher` is saving data

**Solution:**
1. Check server console for `[USAGE] Saving usage...`
2. If not there, the `saveUsage()` function isn't being called
3. Check `AppLauncher.js` cleanup function

### Issue 4: State Not Updating

**Symptom:** Console shows data but display doesn't update

**Cause:** React state not re-rendering

**Fix:** Force re-render by clicking refresh multiple times

**Solution:**
```javascript
// In AppLimits.js, the state should update:
setTodayUsage(todayData); // This should trigger re-render
```

## 🔧 Step-by-Step Fix

### Fix 1: Check Database

```sql
-- 1. Check what's saved
SELECT * FROM app_usage WHERE usage_date = CURDATE();

-- Expected output:
-- | id | teenager_id | app_name | usage_minutes | usage_date |
-- | 1  | 2           | y        | 2             | 2025-11-09 |

-- 2. If app_name is different, note it down
-- Example: If it shows "youtube" instead of "y"
```

### Fix 2: Check App Name in Frontend

```javascript
// In browser console, type:
console.log('App name:', 'y');

// Then check what's in usage:
// Look for the log: === All app names in usage: ["..."]
```

### Fix 3: Match the Names

**Option A: Update Database to Match Frontend**
```sql
UPDATE app_usage SET app_name = 'y' WHERE app_name = 'youtube';
```

**Option B: Update Frontend to Match Database**
Edit the custom app name to match what's in the database.

### Fix 4: Clear and Refresh

1. Click **🔄 Refresh** button
2. Wait for "⏳ Refreshing..." to finish
3. Check if "Used Today" updates

## 📊 What to Look For

### Successful Log Pattern:

```
=== Fetching usage for date: 2025-11-09
=== Raw usage data received: [{app_name: "y", usage_date: "2025-11-09", usage_minutes: 2}]
=== Checking y: usageDate=2025-11-09, today=2025-11-09, matches=true
=== Filtered today's usage data: [{app_name: "y", usage_minutes: 2}]
=== Setting todayUsage state with: [{app_name: "y", usage_minutes: 2}]
=== getTodayUsage called for: "y"
=== Available usage data: [{app_name: "y", usage_minutes: 2}]
=== All app names in usage: ["y"]
=== getTodayUsage for "y": found=true, minutes=2, todayUsage length=1
```

**Result:** ✅ "Used Today: 2 minutes" should display

### Failed Log Pattern:

```
=== Fetching usage for date: 2025-11-09
=== Raw usage data received: [{app_name: "youtube", usage_date: "2025-11-09", usage_minutes: 2}]
=== Checking youtube: usageDate=2025-11-09, today=2025-11-09, matches=true
=== Filtered today's usage data: [{app_name: "youtube", usage_minutes: 2}]
=== getTodayUsage called for: "y"
=== Available usage data: [{app_name: "youtube", usage_minutes: 2}]
=== All app names in usage: ["youtube"]
⚠️ No usage found for "y". Available apps: ["youtube"]
=== getTodayUsage for "y": found=false, minutes=0, todayUsage length=1
```

**Result:** ❌ "Used Today: 0 minutes" (NAME MISMATCH!)

## 🎯 Quick SQL Fixes

### Check Current Data:
```sql
USE parent_teen_db;

-- See all usage
SELECT * FROM app_usage WHERE usage_date = CURDATE();

-- See all custom apps
SELECT * FROM custom_apps;

-- See all app limits
SELECT * FROM app_limits;
```

### Fix Name Mismatch:
```sql
-- If usage shows "youtube" but app is "y":
UPDATE app_usage SET app_name = 'y' WHERE app_name = 'youtube' AND usage_date = CURDATE();

-- If limit shows "youtube" but app is "y":
UPDATE app_limits SET app_name = 'y' WHERE app_name = 'youtube';

-- If custom app shows "youtube" but should be "y":
UPDATE custom_apps SET app_name = 'y' WHERE app_name = 'youtube';
```

### Fix Date Issue:
```sql
-- Update to today's date
UPDATE app_usage SET usage_date = CURDATE() WHERE app_name = 'y';
```

### Verify Fix:
```sql
-- All three should show the same app name
SELECT app_name FROM app_usage WHERE usage_date = CURDATE();
SELECT app_name FROM app_limits;
SELECT app_name FROM custom_apps;

-- All should return "y" (or whatever your app is called)
```

## ✅ Verification Checklist

After fixing, verify:

- [ ] Database has usage record with correct app name
- [ ] Database has usage record with today's date
- [ ] Console shows: `matches=true` for your app
- [ ] Console shows: `found=true` when getting usage
- [ ] "Used Today" displays correct minutes
- [ ] Progress bar fills to correct percentage
- [ ] No warning about "No usage found"

## 🚀 Most Likely Solution

Based on your screenshot showing app name "y":

```sql
-- Run this in your MySQL:
USE parent_teen_db;

-- Check what name is actually saved:
SELECT app_name, usage_minutes, usage_date FROM app_usage WHERE usage_date = CURDATE();

-- If it shows something other than "y", update it:
UPDATE app_usage SET app_name = 'y' WHERE usage_date = CURDATE();
UPDATE app_limits SET app_name = 'y' WHERE app_name != 'y';
UPDATE custom_apps SET app_name = 'y' WHERE app_name != 'y';

-- Then refresh the page and click 🔄 Refresh
```

## 💡 Prevention

To prevent this in the future:

1. **Use consistent names** - Don't change app names after creating them
2. **Check console logs** - Always check for warnings
3. **Use the refresh button** - Click 🔄 after using an app
4. **Verify database** - Occasionally check that names match

## 📞 Still Not Working?

If it's still not working, share these logs:

1. **Browser Console Logs** (after clicking 🔄 Refresh)
2. **SQL Query Result:**
   ```sql
   SELECT * FROM app_usage WHERE usage_date = CURDATE();
   ```
3. **SQL Query Result:**
   ```sql
   SELECT * FROM custom_apps;
   ```

This will help identify the exact issue!
