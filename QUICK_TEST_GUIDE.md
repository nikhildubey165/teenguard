# 🧪 Quick Test Guide - Verify Timer Behavior

## ✅ What You Want to Test

1. Timer starts when opening app
2. Timer stops when closing app
3. Timer continues from where it stopped
4. Timer resets after 24 hours

---

## 🚀 Quick Test (5 Minutes)

### Test 1: First Session
```
1. Open YouTube app
   Expected: "Time Used Today: 0 minutes"

2. Wait 1 minute (60 seconds)
   Expected: "Time Used Today: 1 minute"

3. Close YouTube window
   Expected: Timer stops, usage saved

4. Refresh "My Apps & Limits" page
   Expected: "Used Today: 1 minutes"
```

### Test 2: Second Session (Continuation)
```
1. Open YouTube app again
   Expected: "Time Used Today: 1 minute" ← Continues from before!

2. Wait 1 more minute
   Expected: "Time Used Today: 2 minutes" ← Accumulated!

3. Close YouTube window
   Expected: Timer stops, usage saved

4. Refresh "My Apps & Limits" page
   Expected: "Used Today: 2 minutes"
```

### Test 3: Third Session (Verify Accumulation)
```
1. Open YouTube app again
   Expected: "Time Used Today: 2 minutes" ← Still continuing!

2. Wait 1 more minute
   Expected: "Time Used Today: 3 minutes" ← Still accumulating!

3. Close YouTube window
   Expected: Timer stops

4. Check database:
   SELECT * FROM app_usage WHERE usage_date = CURDATE();
   Expected: One record with 3 minutes
```

---

## 📊 Expected Console Output

### Opening App (First Time Today):
```
[AppLauncher] Starting with 0 minutes already used today for youtube
[getCurrentTotalUsage] youtube has 0 minutes for today (2025-11-11)
```

### Opening App (Second Time Today):
```
[AppLauncher] Starting with 1 minutes already used today for youtube
[getCurrentTotalUsage] youtube has 1 minutes for today (2025-11-11)
```

### Opening App (Third Time Today):
```
[AppLauncher] Starting with 2 minutes already used today for youtube
[getCurrentTotalUsage] youtube has 2 minutes for today (2025-11-11)
```

### Auto-Save (Every 30 seconds):
```
[Auto-save] Saving 1 minute(s) for youtube (session: 1 min)
[saveUsagePeriodically] youtube: adding 1 minute(s)
[USAGE] Teen 2 - Saving usage for "youtube": 1 minutes on 2025-11-11
✅ Updated existing record for "youtube": 1 minutes
✅ Verified: "youtube" now has 2 minutes in DB  ← Total increases!
```

### Closing App:
```
[Window Check] App window closed by user
[Final Save] Stopping all tracking intervals...
[Final Save] youtube: session=1min (65s), adding=1min
✅ [Final Save] Successfully saved 1 minute(s) for youtube
[Final Save] Cleanup complete - tracking stopped
```

---

## 🗄️ Database Check

### After Each Session:
```sql
SELECT 
  app_name,
  usage_minutes,
  usage_date,
  updated_at
FROM app_usage
WHERE usage_date = CURDATE()
ORDER BY updated_at DESC;
```

### Expected Results:

**After Session 1:**
```
app_name | usage_minutes | usage_date  | updated_at
---------|---------------|-------------|-------------------
youtube  | 1             | 2025-11-11  | 2025-11-11 09:01:00
```

**After Session 2:**
```
app_name | usage_minutes | usage_date  | updated_at
---------|---------------|-------------|-------------------
youtube  | 2             | 2025-11-11  | 2025-11-11 09:15:00
         ↑ Increased!                   ↑ Updated!
```

**After Session 3:**
```
app_name | usage_minutes | usage_date  | updated_at
---------|---------------|-------------|-------------------
youtube  | 3             | 2025-11-11  | 2025-11-11 09:30:00
         ↑ Increased again!             ↑ Updated again!
```

**Key Points:**
- ✅ Only ONE record per app per day
- ✅ `usage_minutes` increases with each session
- ✅ `updated_at` changes with each save
- ✅ `usage_date` stays the same (today)

---

## 🔄 Test Daily Reset (Tomorrow)

### Option 1: Wait Until Tomorrow
```
1. Wait until midnight (or next day)
2. Open YouTube app
   Expected: "Time Used Today: 0 minutes" ← RESET!
3. Previous day's data still in database:
   SELECT * FROM app_usage WHERE usage_date = '2025-11-11';
   Expected: Shows yesterday's 3 minutes
```

### Option 2: Simulate Next Day (For Testing)
```sql
-- Change today's record to yesterday
UPDATE app_usage 
SET usage_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
WHERE usage_date = CURDATE();

-- Now test:
1. Open YouTube app
   Expected: "Time Used Today: 0 minutes" ← Fresh start!
2. Database will create new record for today
```

---

## ✅ Success Criteria

### Session Continuation:
- [ ] Session 1: Shows 0 → 1 minute
- [ ] Session 2: Shows 1 → 2 minutes (continued!)
- [ ] Session 3: Shows 2 → 3 minutes (still continuing!)

### Timer Behavior:
- [ ] Timer starts when opening app
- [ ] Timer stops when closing app
- [ ] No background tracking after close
- [ ] Display shows accumulated total

### Database:
- [ ] Only one record per app per day
- [ ] Minutes accumulate correctly
- [ ] Updated timestamp changes with each save

### Daily Reset:
- [ ] New day starts at 0 minutes
- [ ] Previous day's data preserved
- [ ] Can view history in reports

---

## 🐛 Troubleshooting

### Issue: Timer doesn't continue (always starts at 0)
**Cause:** Not fetching current usage from database
**Check:** Console should show "Starting with X minutes already used today"
**Fix:** Make sure `getCurrentTotalUsage()` is called on initialization

### Issue: Minutes not accumulating in database
**Cause:** Backend replacing instead of adding
**Check:** Server logs should show `affectedRows: 2` for updates
**Fix:** Verify line 38 in `usage.js` has the `+` sign:
```javascript
usage_minutes = usage_minutes + VALUES(usage_minutes),
```

### Issue: Timer keeps running after close
**Cause:** Intervals not cleared
**Check:** Console should show "Cleanup complete - tracking stopped"
**Fix:** Restart React app to apply latest code

### Issue: Shows yesterday's data
**Cause:** Date filtering issue
**Check:** API calls should use `days=0`
**Fix:** Verify all API calls use `params: { days: 0 }`

---

## 📝 Quick Checklist

Before testing:
- [ ] Server is running (`npm start` in server folder)
- [ ] React app is running (`npm start` in client folder)
- [ ] Database is set up (tables exist)
- [ ] Old data cleaned (run cleanup script if needed)
- [ ] Browser cache cleared (Ctrl+Shift+R)

During testing:
- [ ] Watch browser console (F12)
- [ ] Watch server terminal
- [ ] Check database after each session
- [ ] Verify timer stops when closing

After testing:
- [ ] All sessions accumulated correctly
- [ ] Database has one record with correct total
- [ ] Timer stopped properly
- [ ] No errors in console

---

## 🎯 Expected Final Result

After 3 sessions of 1 minute each:

**Frontend Display:**
```
My Apps & Limits
└── YouTube
    └── Used Today: 3 minutes ✅
```

**Database:**
```sql
SELECT * FROM app_usage WHERE usage_date = CURDATE();

Result:
app_name: youtube
usage_minutes: 3
usage_date: 2025-11-11
```

**Console Logs:**
```
Session 1: Started with 0, ended with 1 ✅
Session 2: Started with 1, ended with 2 ✅
Session 3: Started with 2, ended with 3 ✅
```

---

**Your system is already built to work this way!**

Just test it following the steps above to verify everything is working correctly. 🚀
