# 🧪 Testing Steps - Usage Tracking Fix

## ⚠️ CRITICAL: Did you restart the server?

The code changes won't work until you restart the Node.js server!

### Restart Server Now:
1. Go to the terminal running your server
2. Press `Ctrl + C` to stop it
3. Run: `npm start`
4. Wait for "Server running on port 5000" message

---

## 📋 Step-by-Step Test

### Step 1: Verify Server is Running
Check terminal - you should see:
```
Server running on port 5000
Connected to MySQL database
```

### Step 2: Clear Browser Cache
- Press `Ctrl + Shift + R` in your browser
- Or press `F12` → Application → Clear storage → Clear site data

### Step 3: Open YouTube
1. Go to "My Apps & Limits" page
2. Click **"Click to open →"** on YouTube card
3. A new window should open with YouTube

### Step 4: Watch the Terminal
You should see logs like:
```
[AppLauncher] Starting with 0 minutes already used today for youtube
[getCurrentTotalUsage] youtube has 0 minutes for today (2025-11-11)
```

### Step 5: Wait 1 Minute
Keep the YouTube window open for at least 1 minute (60 seconds)

### Step 6: Check Auto-Save (after 30 seconds)
Terminal should show:
```
[Auto-save] Saving 1 minute(s) for youtube (session: 1 min)
[saveUsagePeriodically] youtube: adding 1 minute(s)
[USAGE] Teen X - Saving usage for "youtube": 1 minutes on 2025-11-11
[USAGE] Query executed - affectedRows: 1
✅ Created new record for "youtube": 1 minutes
✅ Verified: "youtube" now has 1 minutes in DB
```

### Step 7: Close YouTube Window
Close the YouTube window after 1-2 minutes

### Step 8: Check Final Save
Terminal should show:
```
[Final Save] youtube: session=1min (60s), adding=1min
[USAGE] Teen X - Saving usage for "youtube": 1 minutes on 2025-11-11
[USAGE] Query executed - affectedRows: 2  ← IMPORTANT: Should be 2!
✅ Updated existing record for "youtube": 1 minutes
✅ Verified: "youtube" now has 2 minutes in DB  ← Total should increase!
```

### Step 9: Refresh App Limits Page
1. Go back to "My Apps & Limits" page
2. Press `F5` to refresh
3. Should show: **"Used Today: 2 minutes"** ✅

### Step 10: Test Accumulation
1. Click "Click to open →" again
2. Wait another minute
3. Close the window
4. Refresh the page
5. Should show: **"Used Today: 3 minutes"** ✅

---

## 🔍 Troubleshooting

### Problem: Still showing 0 minutes

**Check 1: Did you restart the server?**
```bash
# Stop server (Ctrl+C)
cd c:\Users\Gourav\Desktop\ucd\server
npm start
```

**Check 2: Are there any errors in terminal?**
Look for red error messages

**Check 3: Is the browser cache cleared?**
Press `Ctrl + Shift + Delete` → Clear everything

**Check 4: Check browser console (F12)**
Look for any red errors in the Console tab

### Problem: Terminal shows errors

**Error: "Cannot find module"**
```bash
cd c:\Users\Gourav\Desktop\ucd\server
npm install
npm start
```

**Error: "Port already in use"**
```bash
# Kill the old process
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F
npm start
```

### Problem: affectedRows is always 1

This means the UPDATE isn't working. Check:
1. Is the database cleanup script run?
2. Is the server restarted?
3. Are you logged in as a teenager (not parent)?

---

## 🎯 What to Share if Still Not Working

If it's still not working, share these:

### 1. Terminal Output
Copy the last 20-30 lines from the server terminal

### 2. Browser Console
Press F12 → Console tab → Copy any errors

### 3. Database Check
Run this in phpMyAdmin:
```sql
SELECT * FROM app_usage WHERE usage_date = CURDATE();
```
Share the results

### 4. Server Status
```bash
# Check if server is running
netstat -ano | findstr :5000
```

---

## ✅ Expected Final Result

After all tests:
- ✅ App Limits page shows correct "Used Today" minutes
- ✅ Minutes accumulate across sessions (1, 2, 3, 4...)
- ✅ Terminal shows `affectedRows: 2` for updates
- ✅ Database has one record per app with increasing minutes

---

**Start with Step 1 (Restart Server) and follow each step carefully!** 🚀
