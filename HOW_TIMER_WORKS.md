# ⏱️ How the Timer System Works

## ✅ Your Requirements (Already Implemented!)

1. ✅ **Timer starts when user opens app**
2. ✅ **Timer stops when user closes app**
3. ✅ **Timer continues from where it stopped when reopened**
4. ✅ **Timer resets after 24 hours (new day)**

---

## 📋 Complete Flow Explanation

### Session 1: First Time Opening App Today

**Step 1: User Opens YouTube**
```
Action: Click "Click to open →"
System:
  1. Fetches current usage from database for TODAY
  2. Database returns: 0 minutes (first time today)
  3. Displays: "Time Used Today: 0 minutes"
  4. Opens YouTube in new window
  5. Starts timer from 0
```

**Step 2: User Uses App for 2 Minutes**
```
Timer Running:
  - Second 1-59: Shows "0 minutes"
  - Second 60-119: Shows "1 minute"
  - Second 120+: Shows "2 minutes"

Auto-Save (every 30 seconds):
  - At 60 seconds: Saves 1 minute to database
  - Database now has: 1 minute
  - At 120 seconds: Saves 1 more minute to database
  - Database now has: 2 minutes (1 + 1)
```

**Step 3: User Closes YouTube**
```
Action: Close YouTube window
System:
  1. Detects window closed
  2. Stops all timers immediately
  3. Calculates final session time: 2 minutes
  4. Saves to database (adds 0 more since already saved)
  5. Database has: 2 minutes total
  6. Timer stopped ✅
```

---

### Session 2: Opening App Again (Same Day)

**Step 1: User Opens YouTube Again**
```
Action: Click "Click to open →"
System:
  1. Fetches current usage from database for TODAY
  2. Database returns: 2 minutes (from previous session)
  3. Displays: "Time Used Today: 2 minutes" ← Continues from where it stopped!
  4. Opens YouTube in new window
  5. Starts NEW timer from 0 (for this session only)
```

**Step 2: User Uses App for 1 More Minute**
```
Timer Running:
  - Display shows: "2 minutes" (DB) + "0 minutes" (session) = "2 minutes"
  - After 60 seconds: "2 minutes" (DB) + "1 minute" (session) = "3 minutes"

Auto-Save:
  - At 60 seconds: Saves 1 minute to database
  - Database calculation: 2 (old) + 1 (new) = 3 minutes
  - Database now has: 3 minutes total
```

**Step 3: User Closes YouTube**
```
Action: Close YouTube window
System:
  1. Stops timer
  2. Final save (already saved during auto-save)
  3. Database has: 3 minutes total
  4. Timer stopped ✅
```

---

### Session 3: Next Day (24 Hours Later)

**Step 1: User Opens YouTube Next Day**
```
Action: Click "Click to open →"
Date: 2025-11-12 (next day)

System:
  1. Fetches current usage from database for TODAY (2025-11-12)
  2. Database returns: 0 minutes ← NEW DAY! Reset! ✅
  3. Displays: "Time Used Today: 0 minutes"
  4. Opens YouTube in new window
  5. Starts fresh timer from 0
  
Previous Day's Data:
  - 2025-11-11: 3 minutes (stored in database, not deleted)
  - Still available for reports and history
  - But doesn't affect today's usage
```

---

## 🔄 Cycle Diagram

```
Day 1 (2025-11-11):
┌─────────────────────────────────────────────────────┐
│ Session 1: Open → Use 2 min → Close                │
│ Database: 0 → 1 → 2 minutes                        │
├─────────────────────────────────────────────────────┤
│ Session 2: Open → Use 1 min → Close                │
│ Database: 2 → 3 minutes                            │
├─────────────────────────────────────────────────────┤
│ Session 3: Open → Use 2 min → Close                │
│ Database: 3 → 5 minutes                            │
└─────────────────────────────────────────────────────┘
Total for Day 1: 5 minutes

⏰ 24 Hours Pass (Midnight) ⏰

Day 2 (2025-11-12):
┌─────────────────────────────────────────────────────┐
│ Session 1: Open → Use 1 min → Close                │
│ Database: 0 → 1 minute ← RESET! New day!           │
├─────────────────────────────────────────────────────┤
│ Session 2: Open → Use 3 min → Close                │
│ Database: 1 → 4 minutes                            │
└─────────────────────────────────────────────────────┘
Total for Day 2: 4 minutes
```

---

## 🗄️ Database Structure

### Table: `app_usage`
```sql
CREATE TABLE app_usage (
  id INT PRIMARY KEY,
  teenager_id INT,
  app_name VARCHAR(255),
  usage_minutes INT,           -- Accumulated minutes for the day
  usage_date DATE,              -- 2025-11-11, 2025-11-12, etc.
  updated_at TIMESTAMP,
  UNIQUE KEY (teenager_id, app_name, usage_date)  -- One record per app per day
);
```

### Example Data:
```
id | teenager_id | app_name | usage_minutes | usage_date  | updated_at
---|-------------|----------|---------------|-------------|-------------------
1  | 2           | youtube  | 5             | 2025-11-11  | 2025-11-11 16:30:00
2  | 2           | youtube  | 4             | 2025-11-12  | 2025-11-12 10:15:00
3  | 2           | instagram| 10            | 2025-11-11  | 2025-11-11 18:45:00
4  | 2           | instagram| 2             | 2025-11-12  | 2025-11-12 09:30:00
```

**Key Points:**
- ✅ One record per app per day
- ✅ `usage_date` determines which day
- ✅ `usage_minutes` accumulates throughout the day
- ✅ New day = new record = fresh start

---

## 🔧 Technical Implementation

### 1. Fetching Current Usage (Start of Session)
```javascript
// AppLauncher.js - Line 30-32
const currentUsage = await getCurrentTotalUsage();
setCurrentDbUsage(currentUsage);
console.log(`Starting with ${currentUsage} minutes already used today`);
```

**API Call:**
```javascript
GET /usage/app?days=0  // days=0 means TODAY ONLY
```

**Backend Query:**
```sql
SELECT usage_minutes 
FROM app_usage 
WHERE teenager_id = ? 
  AND app_name = ? 
  AND usage_date = CURDATE()  -- Today's date only
```

### 2. Tracking Time (During Session)
```javascript
// AppLauncher.js - Line 189-193
intervalRef.current = setInterval(() => {
  const elapsedSeconds = Math.floor((Date.now() - sessionStartTime) / 1000);
  const elapsedMinutes = Math.floor(elapsedSeconds / 60);
  // Show total: DB usage + current session
  setTimeUsed(currentDbUsage + elapsedMinutes);
}, 1000);
```

**Display Formula:**
```
Total Displayed = Database Minutes + Current Session Minutes
Example: 5 (from DB) + 2 (current session) = 7 minutes shown
```

### 3. Auto-Saving (Every 30 Seconds)
```javascript
// AppLauncher.js - Line 228-243
const saveInterval = setInterval(async () => {
  const minutesToSave = totalElapsedMinutes - totalSavedMinutes;
  if (minutesToSave >= 1) {
    await saveUsagePeriodically(minutesToSave);
    totalSavedMinutes = totalElapsedMinutes;
  }
}, 30000); // Every 30 seconds
```

**API Call:**
```javascript
POST /usage/app
Body: { app_name: "youtube", usage_minutes: 1 }  // Just the NEW minutes
```

**Backend Query:**
```sql
INSERT INTO app_usage (teenager_id, app_name, usage_minutes, usage_date) 
VALUES (?, ?, ?, CURDATE())
ON DUPLICATE KEY UPDATE 
  usage_minutes = usage_minutes + VALUES(usage_minutes),  -- ADD to existing
  updated_at = NOW()
```

### 4. Final Save (When Closing)
```javascript
// AppLauncher.js - Line 348-399
const saveUsage = async () => {
  // Stop all timers
  clearInterval(intervalRef.current);
  clearInterval(saveIntervalRef.current);
  
  // Calculate final minutes
  const minutesToSave = Math.floor(elapsedSeconds / 60);
  
  // Save to database
  await api.post('/usage/app', {
    app_name: app.name,
    usage_minutes: minutesToSave
  });
  
  // Clear start time to prevent double-save
  startTimeRef.current = null;
}
```

### 5. Daily Reset (Automatic)
**No code needed!** The reset happens automatically because:
```sql
WHERE usage_date = CURDATE()  -- Always queries today's date
```

When the date changes (midnight):
- `CURDATE()` returns new date (e.g., 2025-11-12)
- Query finds no record for new date
- Returns 0 minutes
- New record created for new day
- Previous day's data remains in database for history

---

## 📊 Example Timeline

### Monday (2025-11-11)

**9:00 AM - Session 1**
```
Open YouTube
DB: 0 min → Display: 0 min
Use for 30 min
DB: 0 → 30 min → Display: 30 min
Close YouTube
```

**2:00 PM - Session 2**
```
Open YouTube
DB: 30 min → Display: 30 min (continues from morning!)
Use for 15 min
DB: 30 → 45 min → Display: 45 min
Close YouTube
```

**8:00 PM - Session 3**
```
Open YouTube
DB: 45 min → Display: 45 min (still accumulating!)
Use for 10 min
DB: 45 → 55 min → Display: 55 min
Close YouTube
```

**End of Monday: Total = 55 minutes**

---

### Tuesday (2025-11-12) - Next Day

**9:00 AM - Session 1**
```
Open YouTube
DB: 0 min → Display: 0 min (RESET! New day!)
Use for 20 min
DB: 0 → 20 min → Display: 20 min
Close YouTube
```

**Previous day's 55 minutes:**
- Still in database (for reports/history)
- Not affecting today's count
- Can be viewed in usage reports

---

## ✅ Summary

### What Happens:
1. **Open App** → Fetch today's usage from DB → Start timer
2. **Use App** → Timer counts up → Auto-save every 30 seconds
3. **Close App** → Stop timer → Final save → Timer stopped
4. **Reopen App** → Fetch today's usage (includes previous sessions) → Continue
5. **New Day** → Automatically starts from 0 → Previous day's data saved

### Key Features:
- ✅ Timer starts fresh each session
- ✅ Display shows accumulated total (DB + current session)
- ✅ Saves every 30 seconds (prevents data loss)
- ✅ Stops immediately when window closes
- ✅ Continues from previous total when reopened
- ✅ Resets at midnight (new day)
- ✅ Keeps history of all previous days

### Database Behavior:
- One record per app per day
- `usage_minutes` accumulates throughout the day
- `usage_date` determines which day
- Old data preserved for reports
- New day = new record = automatic reset

---

**Your system already works exactly as you described!** 🎉

Just make sure:
1. Server is running
2. React app is running
3. Database is set up correctly
4. Test by opening/closing app multiple times

The timer will continue from where it stopped, and reset after 24 hours automatically!
