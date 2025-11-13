# Debug App Blocking Issue

## The Problem
Your YouTube app shows:
- Daily Limit: 1 minute
- Used Today: 0 / 1 minutes  
- But when you click "Click to open →", it's not working as expected

## Steps to Debug

### Step 1: Check Browser Console
1. **Open your app** in the browser
2. **Press F12** to open Developer Tools
3. **Go to Console tab**
4. **Click on the YouTube app**
5. **Look for these debug messages:**

```
🔍 DEBUG: App clicked: {name: "youtube", url: "...", ...}
🔍 DEBUG: App URL: https://www.youtube.com
🔍 DEBUG: App name: youtube
🔍 DEBUG: App limit found: {daily_limit_minutes: 1, ...}
🔍 DEBUG: Checking limit for youtube: used 0/1 minutes
✅ DEBUG: Opening app - all checks passed
```

### Step 2: Possible Issues & Solutions

#### Issue A: No URL
**If you see:**
```
❌ DEBUG: No URL found for app
```
**Solution:** 
1. Click **EDIT** button on YouTube app
2. Add URL: `https://www.youtube.com`
3. Click **Update App**

#### Issue B: App Opens But No Time Tracking
**If app opens but time doesn't increase:**
1. **Check server console** for tracking logs
2. **Look for these messages:**
```
[AppLauncher] Starting with 0 minutes already used today for youtube
[Auto-save] Saving 1 minute(s) for youtube (session: 1 min)
```

#### Issue C: Blocking Not Working
**If app opens even when limit reached:**
1. **Use the app for 1+ minutes**
2. **Close the app window**
3. **Refresh the App Limits page**
4. **Try clicking YouTube again**
5. **Should now show blocking alert**

### Step 3: Manual Test
1. **Use YouTube for 1 minute**
2. **Close YouTube window**
3. **Wait 10 seconds**
4. **Click refresh button** (🔄 Refresh Usage)
5. **Check if it shows "1 / 1 minutes"**
6. **Click YouTube again** - should be blocked

### Step 4: Check Database (If Still Not Working)
Run this SQL to manually set usage:
```sql
-- Replace 'X' with your actual teenager user ID
INSERT INTO app_usage (teenager_id, app_name, usage_minutes, usage_date) 
VALUES (X, 'youtube', 1, CURDATE())
ON DUPLICATE KEY UPDATE 
  usage_minutes = 1,
  updated_at = NOW();
```

## Expected Behavior

### When Usage = 0 minutes:
- Shows "Used Today: 0 / 1 minutes"
- Shows "Click to open →"
- App should open when clicked

### When Usage = 1 minute (limit reached):
- Shows "Used Today: 1 / 1 minutes" 
- Shows "🚫 BLOCKED - Available at midnight"
- Alert when clicked: "Daily time limit reached!"
- App should NOT open

## Common Causes

1. **Missing URL** - App needs https://www.youtube.com
2. **Name mismatch** - Limit set for "YouTube" but app named "youtube"
3. **Time tracking not working** - Server/database issue
4. **Cache issue** - Need to refresh usage data

## Quick Fix Commands

### Add URL to YouTube app:
1. Click EDIT on YouTube
2. Set URL: `https://www.youtube.com`
3. Click Update

### Force refresh usage:
1. Click "🔄 Refresh Usage" button
2. Wait 2 seconds
3. Check if numbers update

### Reset usage to test blocking:
```sql
UPDATE app_usage 
SET usage_minutes = 1 
WHERE app_name = 'youtube' 
AND usage_date = CURDATE();
```

## What to Look For

✅ **Working correctly:**
- App opens in new window/tab
- Time tracking shows in console
- Usage increases after using app
- Blocking works when limit reached

❌ **Not working:**
- Alert "This app does not have a website URL"
- App opens but time never increases
- Can still open app after reaching limit
- No debug messages in console

Follow these steps and let me know what debug messages you see!
