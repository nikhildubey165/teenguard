# Complete Fix: Usage Tracking Issues

## 🔍 **Two Problems Identified**

### **Problem 1: Old Test Data Showing 14 Minutes**
- YouTube showing 14 minutes even though you haven't used it today
- This is from the test data added by `add_test_usage.sql`
- The test data has today's date but was created earlier

### **Problem 2: Timer Not Running for Other Apps**
- When you open other apps, the timer doesn't start
- The code is working correctly, but you need to wait for the window to load
- Timer starts after 2 seconds (line 84-89 in AppLauncher.js)

## ✅ **Solution**

### **Fix 1: Clean Up Test Data**

**Option A: Delete ALL today's usage (Fresh Start)**
```sql
-- This will remove all usage data for today
DELETE FROM app_usage WHERE usage_date = CURDATE();
```

**Option B: Delete Only YouTube Test Data**
```sql
-- This will remove only YouTube data for today
DELETE FROM app_usage 
WHERE app_name IN ('youtube', 'YouTube') 
AND usage_date = CURDATE();
```

**Option C: Check First, Then Delete**
```sql
-- Step 1: See what data exists
SELECT 
  teenager_id,
  app_name,
  usage_minutes,
  usage_date,
  created_at,
  updated_at
FROM app_usage
WHERE usage_date = CURDATE()
ORDER BY updated_at DESC;

-- Step 2: Delete the test data (after verifying above)
DELETE FROM app_usage WHERE usage_date = CURDATE();
```

### **Fix 2: Understanding Timer Behavior**

The timer **IS working correctly**. Here's what happens:

1. **Window Opens** → You see "App window opened, waiting for load..."
2. **2 Second Wait** → System waits for window to fully load
3. **Timer Starts** → You see "Window confirmed open, starting timer..."
4. **Every 1 Second** → Timer updates: "Time display: 0 → 1 → 2..."
5. **Every 30 Seconds** → Auto-save: "Auto-save: Saving X minute(s)"

**What to Check:**
- Open browser console (F12) when you launch an app
- Look for these messages:
  ```
  [Window] App window opened, waiting for load...
  [Window] Window confirmed open, starting timer...
  [Timer] Time display: 0 → 1 (elapsed: 60s)
  ```

**If you don't see these messages:**
- The app window might be blocked by popup blocker
- The window might have closed immediately
- Check browser console for errors

## 🔧 **Step-by-Step Fix Process**

### **Step 1: Clean Database**
1. Open MySQL Workbench or your database client
2. Connect to your database
3. Run one of the DELETE commands above
4. Verify with: `SELECT * FROM app_usage WHERE usage_date = CURDATE();`

### **Step 2: Test Timer**
1. **Refresh your app page** (Ctrl+F5 to clear cache)
2. **Open browser console** (F12 → Console tab)
3. **Click on any app** to launch it
4. **Watch the console** for timer messages
5. **Wait at least 60 seconds** to see the first minute count
6. **Check the display** - it should show "Time Used Today: 1m"

### **Step 3: Verify Usage Tracking**
1. **Use an app for 2-3 minutes**
2. **Close the app window**
3. **Go to Usage Report**
4. **Check if the usage appears**

## 🎯 **Expected Console Output (When Working)**

```
[AppLauncher] Starting with 0 minutes already used today for Instagram
[Window] App window opened, waiting for load...
[Window] Window confirmed open, starting timer...
[Timer] Time display: 0 → 1 (elapsed: 60s)
[Auto-save] Saving 1 minute(s) for Instagram (session: 1 min)
[saveUsagePeriodically] Instagram: adding 1 minute(s)
✅ [saveUsagePeriodically] Successfully saved 1 minute(s) for "Instagram"
[Timer] Time display: 1 → 2 (elapsed: 120s)
🛑 [Window Check] App window closed by user - STOPPING TIMER IMMEDIATELY
[Final Save] Instagram: session=2min (120s), already saved=1min, adding=1min
✅ [Final Save] Successfully saved 1 minute(s) for "Instagram"
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: Timer Shows But Doesn't Count**
**Cause:** Window closed immediately or popup blocked
**Solution:** 
- Allow popups for your site
- Check if app window actually opened
- Look for error messages in console

### **Issue 2: Timer Counts But Doesn't Save**
**Cause:** API error or network issue
**Solution:**
- Check network tab in browser console
- Look for failed POST requests to `/usage/app`
- Check server logs for errors

### **Issue 3: Usage Saves But Doesn't Show in Report**
**Cause:** Date mismatch or caching
**Solution:**
- Clear browser cache (Ctrl+Shift+Delete)
- Check server logs for date being used
- Verify timezone settings

### **Issue 4: Multiple Apps Show Old Data**
**Cause:** Multiple test records in database
**Solution:**
- Use Option A to delete ALL today's data
- Start fresh with actual usage

## 📝 **Quick Reference Commands**

### **Check Today's Usage**
```sql
SELECT * FROM app_usage WHERE usage_date = CURDATE();
```

### **Delete Today's Usage**
```sql
DELETE FROM app_usage WHERE usage_date = CURDATE();
```

### **Check Specific App**
```sql
SELECT * FROM app_usage 
WHERE app_name = 'YouTube' 
AND usage_date = CURDATE();
```

### **See All Usage for Your User**
```sql
SELECT * FROM app_usage 
WHERE teenager_id = 2 
ORDER BY usage_date DESC, updated_at DESC 
LIMIT 10;
```

## ✅ **After Fix Checklist**

- [ ] Database cleaned (no test data)
- [ ] Browser cache cleared
- [ ] Console shows timer messages
- [ ] Timer counts up correctly
- [ ] Usage saves every 30 seconds
- [ ] Final save works when closing app
- [ ] Usage appears in report
- [ ] Today's Usage shows correct data

## 🔍 **Debugging Tips**

If issues persist:

1. **Check Server Logs**
   - Look for `[USAGE]` messages
   - Verify dates match
   - Check for SQL errors

2. **Check Browser Console**
   - Look for `[Timer]` messages
   - Check for `[Auto-save]` messages
   - Look for network errors

3. **Check Database Directly**
   - Run SELECT queries to see actual data
   - Verify dates are in correct format
   - Check teenager_id matches your user

4. **Check Timezone**
   - Server and client should use same timezone
   - CURDATE() should match today's date
   - Check `usage_date` format in database

## 🚀 **Prevention**

To avoid this in the future:

1. **Don't use CURDATE() for test data**
   - Use past dates: `DATE_SUB(CURDATE(), INTERVAL 7 DAY)`
   - Or use obvious test dates: `'2020-01-01'`

2. **Use a test database**
   - Keep production data separate
   - Test in a safe environment

3. **Clean up after testing**
   - Always delete test data
   - Document what you added

4. **Use better test app names**
   - Use "TEST_APP" instead of real app names
   - Makes it obvious what's test data
