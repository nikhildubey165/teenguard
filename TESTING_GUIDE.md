# 🧪 Testing Guide - Time Limit Request Feature

## Prerequisites

1. ✅ Database setup complete (`init_database.sql` executed)
2. ✅ Backend server running (`npm start` in server folder)
3. ✅ Frontend running (`npm start` in client folder)
4. ✅ Two accounts created:
   - Parent account
   - Teenager account (linked to parent)

---

## 🎬 Step-by-Step Test Scenario

### Setup Phase

#### 1. Create Test Accounts

**Parent Account:**
```
Name: Test Parent
Email: parent@test.com
Password: password123
Role: Parent
```

**Teenager Account:**
```
Name: Test Teen
Email: teen@test.com
Password: password123
Role: Teenager
Parent: Test Parent (select from dropdown)
```

#### 2. Add a Custom App (as Teenager)

1. Login as teenager
2. Go to "My Apps & Limits"
3. Click "+ Add App"
4. Fill in:
   ```
   App Name: Youtube
   Icon: 📺
   Category: Entertainment
   URL: https://www.youtube.com
   ```
5. Click "✅ Add App"

---

### Test Phase

#### Test 1: Parent Sets Time Limit (5 minutes)

1. **Login as Parent**
2. Go to **"App Limits"** tab
3. Click **"+ Set New Limit"**
4. Fill in:
   ```
   Teenager: Test Teen
   App: Youtube
   Daily Limit: 5 minutes  ← Short for testing!
   ```
5. Click **"Set Limit"**

**Expected Result:**
- ✅ Success message appears
- ✅ Limit appears in the list
- ✅ Database check:
  ```sql
  SELECT * FROM app_limits WHERE app_name = 'Youtube';
  -- Should show: daily_limit_minutes = 5
  ```

---

#### Test 2: Teen Uses App Until Time Expires (5 minutes)

1. **Login as Teenager**
2. Go to **"My Apps & Limits"**
3. **Verify app card shows:**
   ```
   Youtube 📺
   Daily Limit: 5 minutes
   Used Today: 0 minutes
   ```
4. **Click on Youtube card**
5. **App opens in new window**
6. **Verify launcher shows:**
   ```
   Time Remaining: 5m
   Time Used: 0m
   ```
7. **Wait and watch:**
   - Every second: "Time Used" increases
   - Every 60 seconds: Usage saves (check console logs)
   - After 5 minutes: App should close automatically

**Expected Result at 5 minutes:**
- ✅ App window closes automatically
- ✅ Blocked screen appears
- ✅ Shows: "⏰ Time Limit Reached"
- ✅ Message: "Time limit reached! You've used your daily limit for Youtube."
- ✅ Two buttons visible:
  - "📝 Request More Time"
  - "Go Back"

**Console Logs to Watch:**
```
Auto-saving 1 minute(s) of usage for Youtube
[USAGE] Saving usage for Youtube: 1 minutes on 2025-11-09
Time limit reached! Closing app...
handleTimeLimitReached called
App window closed
```

---

#### Test 3: Teen Sends Request for More Time (2 minutes)

1. **On blocked screen, click "📝 Request More Time"**
2. **Request form appears**
3. **Fill in:**
   ```
   Current limit: 5 minutes (shown)
   Requested Time Limit: 15 minutes
   Reason: Need to finish watching educational video for homework
   ```
4. **Click "Send Request"**

**Expected Result:**
- ✅ Success alert: "Request sent to parent successfully!"
- ✅ Returns to dashboard
- ✅ Database check:
  ```sql
  SELECT * FROM time_limit_requests WHERE app_name = 'Youtube';
  -- Should show new request with status = 'pending'
  ```

**Backend Console Log:**
```
[REQUEST] Teenager 2 requested 15 minutes for Youtube
```

---

#### Test 4: Parent Reviews Request (1 minute)

1. **Login as Parent**
2. Go to **"⏰ Limit Requests"** tab
3. **Verify "Pending" tab is active**
4. **See request card:**
   ```
   ┌─────────────────────────────────┐
   │ Youtube          ⏳ Pending    │
   │ 👤 Test Teen                    │
   ├─────────────────────────────────┤
   │ Current Limit:    5 minutes     │
   │ Requested Limit:  15 minutes    │
   │ Increase:         +10 minutes   │
   ├─────────────────────────────────┤
   │ Reason:                         │
   │ Need to finish watching...      │
   ├─────────────────────────────────┤
   │ 📅 Nov 9, 2025 2:30 PM          │
   ├─────────────────────────────────┤
   │  ✅ Approve    ❌ Reject        │
   └─────────────────────────────────┘
   ```

**Expected Result:**
- ✅ Request card displays all information correctly
- ✅ Status badge shows "⏳ Pending"
- ✅ Increase calculation correct (+10 minutes)

---

#### Test 5A: Parent Approves Request (1 minute)

1. **Click "✅ Approve"**
2. **Confirm the dialog**

**Expected Result:**
- ✅ Success message: "Request approved successfully!"
- ✅ Card updates to show "✅ Approved" badge
- ✅ Card moves to "Approved" tab
- ✅ Database checks:
  ```sql
  -- Request status updated
  SELECT status FROM time_limit_requests WHERE app_name = 'Youtube';
  -- Should show: status = 'approved'
  
  -- App limit automatically updated
  SELECT daily_limit_minutes FROM app_limits WHERE app_name = 'Youtube';
  -- Should show: daily_limit_minutes = 15 (was 5)
  ```

**Backend Console Log:**
```
[REQUEST] Parent approved: Youtube limit increased to 15 minutes
```

---

#### Test 6: Teen Gets Extra Time and Continues (2 minutes)

1. **Login as Teenager**
2. Go to **"My Apps & Limits"**
3. **Verify app card now shows:**
   ```
   Youtube 📺
   Daily Limit: 15 minutes  ← Updated!
   Used Today: 5 minutes
   [Progress bar at 33%]
   ```
4. **Click on Youtube card**
5. **App should open successfully!**
6. **Verify launcher shows:**
   ```
   Time Remaining: 10m  (15 - 5 = 10)
   Time Used: 0m  (new session)
   ```
7. **Use for a few more minutes**
8. **Verify time tracking continues normally**

**Expected Result:**
- ✅ App opens without blocking
- ✅ Can use for additional 10 minutes
- ✅ Time tracking works correctly
- ✅ Usage accumulates (5 + new usage)

---

#### Test 5B: Alternative - Parent Rejects Request (1 minute)

**If you want to test rejection instead:**

1. **Click "❌ Reject"**
2. **Confirm the dialog**

**Expected Result:**
- ✅ Message: "Request rejected."
- ✅ Card updates to show "❌ Rejected" badge
- ✅ Card moves to "Rejected" tab
- ✅ Database checks:
  ```sql
  -- Request status updated
  SELECT status FROM time_limit_requests WHERE app_name = 'Youtube';
  -- Should show: status = 'rejected'
  
  -- App limit UNCHANGED
  SELECT daily_limit_minutes FROM app_limits WHERE app_name = 'Youtube';
  -- Should show: daily_limit_minutes = 5 (still 5!)
  ```

**Backend Console Log:**
```
[REQUEST] Parent rejected: Youtube limit increase request
```

---

#### Test 7: Teen Remains Blocked After Rejection (1 minute)

1. **Login as Teenager**
2. Go to **"My Apps & Limits"**
3. **Verify app card shows:**
   ```
   Youtube 📺
   Daily Limit: 5 minutes  ← Unchanged
   Used Today: 5 minutes
   [Progress bar at 100% - RED]
   Daily limit reached!
   ```
4. **Click on Youtube card**

**Expected Result:**
- ✅ Alert appears: "Daily time limit (5 minutes) has been reached for Youtube."
- ✅ App does NOT open
- ✅ Remains blocked until next day

---

## 🔍 Additional Tests

### Test 8: Multiple Requests
- Teen can send multiple requests for different apps
- Parent sees all requests
- Each request is independent

### Test 9: Filter Tabs
- "Pending" shows only pending requests
- "Approved" shows only approved requests
- "Rejected" shows only rejected requests
- "All" shows everything

### Test 10: Delete Request
- Parent can delete processed requests
- Teen can delete their own pending requests

### Test 11: Next Day Reset
- Change system date to next day
- Usage resets to 0
- Teen can use app again (original limit applies)

---

## 🐛 Troubleshooting

### Issue: App doesn't close at time limit
**Check:**
- Browser console for errors
- Backend logs for time tracking
- Database: `SELECT * FROM app_usage WHERE app_name = 'Youtube';`

### Issue: Request not appearing for parent
**Check:**
- Database: `SELECT * FROM time_limit_requests;`
- Parent is logged in correctly
- Refresh the page

### Issue: Approval doesn't update limit
**Check:**
- Backend console for errors
- Database: `SELECT * FROM app_limits WHERE app_name = 'Youtube';`
- API response in Network tab

### Issue: Teen still blocked after approval
**Check:**
- Refresh the page
- Check database limit was actually updated
- Clear browser cache

---

## ✅ Success Checklist

After completing all tests, you should have:

- [x] Parent can set time limits
- [x] Teen can use app with time tracking
- [x] App blocks automatically at limit
- [x] Teen can request more time
- [x] Parent receives and sees request
- [x] Approval increases limit automatically
- [x] Teen can continue using app after approval
- [x] Rejection keeps app blocked
- [x] All data persists correctly
- [x] UI updates reflect changes

---

## 📊 Database Verification Queries

```sql
-- Check all limits
SELECT u.name, al.app_name, al.daily_limit_minutes
FROM app_limits al
JOIN users u ON al.teenager_id = u.id;

-- Check today's usage
SELECT u.name, au.app_name, au.usage_minutes, au.usage_date
FROM app_usage au
JOIN users u ON au.teenager_id = u.id
WHERE au.usage_date = CURDATE();

-- Check all requests
SELECT 
  t.name as teenager,
  p.name as parent,
  tlr.app_name,
  tlr.current_limit,
  tlr.requested_limit,
  tlr.status,
  tlr.created_at
FROM time_limit_requests tlr
JOIN users t ON tlr.teenager_id = t.id
JOIN users p ON tlr.parent_id = p.id
ORDER BY tlr.created_at DESC;
```

---

## 🎉 Test Complete!

If all tests pass, your Time Limit Request feature is working perfectly! 🚀
