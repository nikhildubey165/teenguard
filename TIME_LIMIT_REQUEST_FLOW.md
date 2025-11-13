# ⏰ Time Limit Request Feature - Complete Flow

## 📋 Feature Overview

This feature allows teenagers to request additional time when they reach their app time limit, and parents can approve or reject these requests.

## 🔄 Complete User Flow

### Step 1: Parent Sets Screen-Time Limit
**Location:** Parent Dashboard → App Limits

1. Parent logs in
2. Navigates to "App Limits" tab
3. Selects teenager
4. Sets time limit for an app (e.g., YouTube: 60 minutes/day)
5. Limit is saved in `app_limits` table

**Database:**
```sql
INSERT INTO app_limits (parent_id, teenager_id, app_name, daily_limit_minutes)
VALUES (1, 2, 'Youtube', 60);
```

---

### Step 2: Teen Uses the App
**Location:** Teen Dashboard → My Apps & Limits

1. Teen logs in
2. Clicks on app (e.g., Youtube)
3. App opens in new window
4. **Time tracking starts:**
   - Display shows "Time Used: X minutes"
   - Display shows "Time Remaining: Y minutes"
   - Usage saved every 60 seconds to `app_usage` table
   - Countdown updates in real-time

**Database:**
```sql
-- Usage tracked and updated
INSERT INTO app_usage (teenager_id, app_name, usage_minutes, usage_date)
VALUES (2, 'Youtube', 30, '2025-11-09')
ON DUPLICATE KEY UPDATE usage_minutes = 30;
```

---

### Step 3: Time Expires - App Blocks Access
**Location:** AppLauncher Component

**What Happens:**
1. When usage reaches limit (60 minutes):
   - Timer detects: `totalUsed >= daily_limit_minutes`
   - `handleTimeLimitReached()` is called
2. **Automatic Actions:**
   - ✅ Saves remaining usage to database
   - ✅ Stops all tracking intervals
   - ✅ **Closes app window forcefully**
   - ✅ Shows blocked screen with ⏰ icon
3. **Message Displayed:**
   ```
   ⏰ Time Limit Reached
   Time limit reached! You've used your daily limit for Youtube.
   The app has been closed automatically.
   ```

**Code Flow:**
```javascript
// AppLauncher.js - Line 164-168
if (limit && totalUsed >= limit.daily_limit_minutes) {
  console.log('Time limit reached! Closing app...');
  clearInterval(intervalRef.current);
  handleTimeLimitReached();
  return;
}
```

---

### Step 4: Teen Sends Request to Increase Time
**Location:** Blocked Screen → Request Form

**UI Flow:**
1. Blocked screen shows two buttons:
   - **"📝 Request More Time"** ← Teen clicks this
   - "Go Back"
2. Request form appears with:
   - Current limit display: "Current limit: 60 minutes"
   - Input: "Requested Time Limit (minutes)" (must be > 60)
   - Textarea: "Reason (optional)"
   - Buttons: "Send Request" / "Cancel"

**Example Request:**
```
Requested Time Limit: 120 minutes
Reason: Need to finish my school project video editing
```

3. Teen clicks "Send Request"
4. **API Call:**
   ```javascript
   POST /api/time-limit-requests
   {
     app_name: "Youtube",
     requested_limit: 120,
     reason: "Need to finish my school project video editing"
   }
   ```

**Database:**
```sql
INSERT INTO time_limit_requests 
(teenager_id, parent_id, app_name, current_limit, requested_limit, reason, status)
VALUES (2, 1, 'Youtube', 60, 120, 'Need to finish my school project video editing', 'pending');
```

5. Success message: "Request sent to parent successfully!"
6. Teen is returned to dashboard

---

### Step 5: Parent Receives Notification
**Location:** Parent Dashboard → ⏰ Limit Requests Tab

**What Parent Sees:**

**Request Card:**
```
┌─────────────────────────────────────────┐
│ Youtube                    ⏳ Pending   │
│ 👤 Teen Name                            │
├─────────────────────────────────────────┤
│ Current Limit:      60 minutes          │
│ Requested Limit:    120 minutes         │
│ Increase:           +60 minutes         │
├─────────────────────────────────────────┤
│ Reason:                                 │
│ Need to finish my school project        │
│ video editing                           │
├─────────────────────────────────────────┤
│ 📅 Nov 9, 2025 2:30 PM                  │
├─────────────────────────────────────────┤
│  ✅ Approve      ❌ Reject              │
└─────────────────────────────────────────┘
```

**Filter Tabs Available:**
- **Pending** (default) - Shows new requests
- Approved - Shows approved requests
- Rejected - Shows rejected requests
- All - Shows everything

---

### Step 6: Parent Reviews and Decides
**Location:** Same - ⏰ Limit Requests Tab

**Option A: Parent Approves ✅**

1. Parent clicks "✅ Approve"
2. Confirmation: "Are you sure you want to approve this request?"
3. Parent confirms
4. **API Call:**
   ```javascript
   PUT /api/time-limit-requests/123
   { status: 'approved' }
   ```

5. **Backend Actions:**
   ```javascript
   // 1. Update request status
   UPDATE time_limit_requests 
   SET status = 'approved', updated_at = NOW() 
   WHERE id = 123;
   
   // 2. Update app limit automatically
   UPDATE app_limits 
   SET daily_limit_minutes = 120 
   WHERE teenager_id = 2 AND app_name = 'Youtube';
   ```

6. Success message: "Request approved successfully!"
7. Request card updates to show "✅ Approved" badge

**Option B: Parent Rejects ❌**

1. Parent clicks "❌ Reject"
2. Confirmation: "Are you sure you want to reject this request?"
3. Parent confirms
4. **API Call:**
   ```javascript
   PUT /api/time-limit-requests/123
   { status: 'rejected' }
   ```

5. **Backend Actions:**
   ```javascript
   // Only update request status
   UPDATE time_limit_requests 
   SET status = 'rejected', updated_at = NOW() 
   WHERE id = 123;
   
   // App limit remains unchanged at 60 minutes
   ```

6. Message: "Request rejected."
7. Request card updates to show "❌ Rejected" badge

---

### Step 7A: If Approved - Teen Gets Extra Time
**Location:** Teen Dashboard → My Apps & Limits

**What Happens:**
1. Teen refreshes or navigates to "My Apps & Limits"
2. **App card now shows:**
   ```
   Youtube
   Daily Limit: 120 minutes  ← Updated!
   Used Today: 60 minutes
   [Progress bar at 50%]
   ```

3. Teen clicks on Youtube
4. **Access Check:**
   ```javascript
   // AppLimits.js - handleAppClick
   const limit = getAppLimit('Youtube'); // Returns 120
   const todayMinutes = getTodayUsage('Youtube'); // Returns 60
   
   if (todayMinutes >= limit.daily_limit_minutes) {
     // 60 < 120 = false, so NOT blocked
     alert('Time limit reached');
   } else {
     // Opens app successfully!
     setSelectedApp(app);
   }
   ```

5. **App opens successfully!**
6. Teen can use for additional 60 minutes (120 - 60 = 60 remaining)
7. Time tracking continues from where it left off

---

### Step 7B: If Rejected - App Remains Blocked
**Location:** Teen Dashboard → My Apps & Limits

**What Happens:**
1. Teen refreshes or navigates to "My Apps & Limits"
2. **App card still shows:**
   ```
   Youtube
   Daily Limit: 60 minutes  ← Unchanged
   Used Today: 60 minutes
   [Progress bar at 100% - RED]
   Daily limit reached!
   ```

3. Teen clicks on Youtube
4. **Access Check:**
   ```javascript
   const limit = getAppLimit('Youtube'); // Returns 60
   const todayMinutes = getTodayUsage('Youtube'); // Returns 60
   
   if (todayMinutes >= limit.daily_limit_minutes) {
     // 60 >= 60 = true, BLOCKED!
     alert('Daily time limit (60 minutes) has been reached for Youtube.');
     return; // App does not open
   }
   ```

5. **Alert shown:** "Daily time limit (60 minutes) has been reached for Youtube."
6. App does not open
7. **Next allowed slot:** Tomorrow (new day, usage resets to 0)

---

## 🗂️ Database Tables Involved

### 1. app_limits
```sql
| id | parent_id | teenager_id | app_name | daily_limit_minutes |
|----|-----------|-------------|----------|---------------------|
| 1  | 1         | 2           | Youtube  | 60 → 120 (if approved) |
```

### 2. app_usage
```sql
| id | teenager_id | app_name | usage_minutes | usage_date |
|----|-------------|----------|---------------|------------|
| 1  | 2           | Youtube  | 60            | 2025-11-09 |
```

### 3. time_limit_requests
```sql
| id | teenager_id | parent_id | app_name | current_limit | requested_limit | reason | status |
|----|-------------|-----------|----------|---------------|-----------------|--------|--------|
| 1  | 2           | 1         | Youtube  | 60            | 120             | ...    | pending → approved/rejected |
```

---

## 🔧 Technical Implementation

### Frontend Components

**Teen Side:**
- `AppLauncher.js` - Time tracking, blocking, request form
- `AppLimits.js` - App list, usage display, access control

**Parent Side:**
- `TimeLimitRequests.js` - Request management interface
- `Dashboard.js` - Navigation tab

### Backend Routes

```javascript
// Time Limit Requests API
POST   /api/time-limit-requests          // Teen creates request
GET    /api/time-limit-requests/my-requests  // Teen views their requests
GET    /api/time-limit-requests/parent-requests  // Parent views requests
PUT    /api/time-limit-requests/:id      // Parent approves/rejects
DELETE /api/time-limit-requests/:id      // Delete request
```

### Key Functions

**AppLauncher.js:**
- `checkTimeLimit()` - Checks if limit exists
- `startTimeTracking()` - Tracks usage every second
- `handleTimeLimitReached()` - Blocks app when limit reached
- `handleRequestTimeIncrease()` - Submits request to parent

**AppLimits.js:**
- `handleAppClick()` - Checks limit before opening app
- `getTodayUsage()` - Gets current usage
- `getAppLimit()` - Gets current limit

**TimeLimitRequests.js:**
- `handleApprove()` - Approves request and updates limit
- `handleReject()` - Rejects request
- `fetchRequests()` - Loads requests with filters

---

## ✅ Testing Checklist

### Test 1: Set Limit
- [ ] Parent can set app limit
- [ ] Limit appears in database
- [ ] Teen sees limit in app card

### Test 2: Use App
- [ ] Teen can open app
- [ ] Time tracking works
- [ ] Usage saves to database
- [ ] Display updates in real-time

### Test 3: Reach Limit
- [ ] App closes automatically at limit
- [ ] Blocked screen appears
- [ ] Correct message shown
- [ ] "Request More Time" button visible

### Test 4: Send Request
- [ ] Request form appears
- [ ] Can enter requested limit
- [ ] Can enter reason
- [ ] Request saves to database
- [ ] Success message shown

### Test 5: Parent Review
- [ ] Request appears in parent dashboard
- [ ] All details shown correctly
- [ ] Can filter by status
- [ ] Approve/Reject buttons work

### Test 6: Approve Flow
- [ ] Approval updates request status
- [ ] App limit updates automatically
- [ ] Teen can open app again
- [ ] Additional time is available

### Test 7: Reject Flow
- [ ] Rejection updates request status
- [ ] App limit stays unchanged
- [ ] Teen still cannot open app
- [ ] Blocked until next day

---

## 🎯 Success Criteria

✅ **Feature is working if:**
1. App blocks access when time limit reached
2. Teen can send request from blocked screen
3. Parent sees request in dashboard
4. Approval automatically increases limit
5. Teen can immediately use app after approval
6. Rejection keeps app blocked
7. All data persists in database

---

## 🚀 Ready to Test!

All components are implemented and ready. Follow the testing checklist to verify the complete flow!
