# ⏰ Proactive Time Extension Request Feature

## 📋 Overview

This feature allows teenagers to **proactively request** time limit extensions for apps **before** they reach their limit, in addition to the reactive request option when blocked.

## 🆕 What's New

### Two Ways to Request Time Extensions:

1. **Proactive Request** (NEW!) - From "My Apps & Limits" page
   - Teen can request extension anytime
   - Select app from dropdown
   - Enter additional time needed
   - Provide optional reason
   
2. **Reactive Request** (Existing) - When blocked
   - Appears when time limit reached
   - Request form in blocked screen
   - Enter new total limit

## 🎯 User Flow - Proactive Request

### Step 1: Teen Opens Request Form

**Location:** Teen Dashboard → My Apps & Limits

1. Teen logs in
2. Navigates to "My Apps & Limits"
3. Clicks **"⏰ Request Time Extension"** button (top right)
4. Request form appears

### Step 2: Teen Fills Request Form

**Form Fields:**

```
┌─────────────────────────────────────┐
│  Request Time Extension             │
├─────────────────────────────────────┤
│  App *                              │
│  [Select app ▼]                     │
│  - Youtube (Current: 60 min)        │
│  - Instagram (Current: 30 min)      │
│  - Twitter (Current: 45 min)        │
├─────────────────────────────────────┤
│  Additional Time (minutes) *        │
│  [30                            ]   │
├─────────────────────────────────────┤
│  Reason (optional)                  │
│  [Need to finish school project ]   │
│  [video editing                 ]   │
│  [                              ]   │
├─────────────────────────────────────┤
│  [Submit Request]  [Cancel]         │
└─────────────────────────────────────┘
```

**Example:**
- **App:** Youtube (Current: 60 min)
- **Additional Time:** 30 minutes
- **Reason:** Need to finish school project video editing

**Calculation:**
- Current Limit: 60 minutes
- Additional Time: 30 minutes
- **Requested Limit: 90 minutes** (60 + 30)

### Step 3: Request Submitted

1. Teen clicks "Submit Request"
2. **API Call:**
   ```javascript
   POST /api/time-limit-requests
   {
     app_name: "Youtube",
     requested_limit: 90,  // 60 + 30
     reason: "Need to finish school project video editing"
   }
   ```
3. Success message: "Request sent to parent successfully!"
4. Form closes
5. Teen can continue using apps normally

### Step 4: Parent Reviews Request

**Location:** Parent Dashboard → ⏰ Limit Requests

Parent sees the request card:

```
┌─────────────────────────────────────┐
│ Youtube              ⏳ Pending     │
│ 👤 Teen Name                        │
├─────────────────────────────────────┤
│ Current Limit:    60 minutes        │
│ Requested Limit:  90 minutes        │
│ Increase:         +30 minutes       │
├─────────────────────────────────────┤
│ Reason:                             │
│ Need to finish school project       │
│ video editing                       │
├─────────────────────────────────────┤
│ 📅 Nov 9, 2025 2:45 PM              │
├─────────────────────────────────────┤
│  ✅ Approve      ❌ Reject          │
└─────────────────────────────────────┘
```

### Step 5: Parent Approves/Rejects

**If Approved:**
- Limit updates: 60 → 90 minutes
- Teen gets +30 minutes immediately
- Can use app for additional time

**If Rejected:**
- Limit stays: 60 minutes
- Teen continues with original limit
- No changes to app access

## 🔄 Comparison: Proactive vs Reactive

### Proactive Request (NEW)

**When:** Anytime before limit is reached

**Location:** My Apps & Limits page

**Form Fields:**
- App (dropdown)
- Additional Time (minutes)
- Reason (optional)

**Advantages:**
- ✅ Plan ahead
- ✅ Request before running out
- ✅ No interruption to work
- ✅ Can see all apps with limits

**Use Case:**
> "I have 60 minutes for Youtube, but I know I'll need 90 minutes for my project. Let me request 30 more minutes now."

### Reactive Request (Existing)

**When:** After limit is reached and app is blocked

**Location:** Blocked screen

**Form Fields:**
- Requested Time Limit (total minutes)
- Reason (optional)

**Advantages:**
- ✅ Request when actually needed
- ✅ Know exact usage before requesting
- ✅ Immediate context for parent

**Use Case:**
> "I've used all 60 minutes, but I need to finish this video. Let me request 90 minutes total."

## 🎨 UI Components

### Button Location

**Teen Dashboard → My Apps & Limits**

```
┌────────────────────────────────────────────────┐
│  My Apps & Limits                              │
│  Add your apps and click to open them          │
│                                                 │
│              [⏰ Request Time Extension]  [+ Add App] │
└────────────────────────────────────────────────┘
```

### Request Form Design

**Styling:**
- Gradient background (blue-purple)
- Bordered with primary color
- Elevated shadow
- Smooth animations
- Focus states on inputs

**Validation:**
- App selection required
- Additional time must be > 0
- Reason is optional
- Shows current limit in dropdown

## 💻 Technical Implementation

### Frontend Changes

**File:** `client/src/components/Teen/AppLimits.js`

**New State:**
```javascript
const [showRequestForm, setShowRequestForm] = useState(false);
const [requestFormData, setRequestFormData] = useState({
  selectedApp: '',
  additionalTime: '',
  reason: ''
});
```

**New Functions:**
```javascript
handleOpenRequestForm()    // Opens the form
handleCloseRequestForm()   // Closes and resets form
handleSubmitRequest()      // Submits request to API
```

**New UI:**
- "⏰ Request Time Extension" button
- Request form with app dropdown
- Additional time input
- Reason textarea

### CSS Styling

**File:** `client/src/components/Parent/Dashboard.css`

**New Classes:**
```css
.header-buttons          // Container for header buttons
.btn-request            // Request button styling
.request-form-card      // Form card styling
```

**Features:**
- Gradient button with hover effect
- Elevated form card
- Focus states for inputs
- Responsive design

### Backend API

**Endpoint:** `POST /api/time-limit-requests`

**Request Body:**
```json
{
  "app_name": "Youtube",
  "requested_limit": 90,
  "reason": "Need to finish school project"
}
```

**Backend Logic:**
1. Gets teenager's parent_id from users table
2. Gets current limit from app_limits table
3. Creates request in time_limit_requests table
4. Returns success response

**No changes needed** - existing API supports both request types!

## ✅ Testing Guide

### Test 1: Open Request Form

1. Login as teenager
2. Go to "My Apps & Limits"
3. Click "⏰ Request Time Extension"
4. **Expected:** Form appears with gradient background

### Test 2: View Apps in Dropdown

1. Open request form
2. Click on "App" dropdown
3. **Expected:** See all apps with limits
4. **Format:** "Youtube (Current: 60 min)"

### Test 3: Submit Request

1. Select app: Youtube
2. Enter additional time: 30
3. Enter reason: "School project"
4. Click "Submit Request"
5. **Expected:** 
   - Success message
   - Form closes
   - Request saved to database

### Test 4: Verify Database

```sql
SELECT * FROM time_limit_requests 
WHERE app_name = 'Youtube' 
ORDER BY created_at DESC 
LIMIT 1;

-- Should show:
-- current_limit: 60
-- requested_limit: 90 (60 + 30)
-- reason: "School project"
-- status: pending
```

### Test 5: Parent Sees Request

1. Login as parent
2. Go to "⏰ Limit Requests"
3. **Expected:** See request with +30 minutes increase

### Test 6: Approve Request

1. Click "✅ Approve"
2. **Expected:**
   - Limit updates to 90 minutes
   - Teen can use app for 90 minutes total

### Test 7: Multiple Requests

1. Teen can submit multiple requests
2. For different apps
3. All appear in parent dashboard
4. Each can be approved/rejected independently

## 🎯 Validation Rules

### Form Validation

1. **App Selection:**
   - Required field
   - Must select from dropdown
   - Only shows apps with limits

2. **Additional Time:**
   - Required field
   - Must be > 0
   - Must be a number
   - No maximum (parent decides)

3. **Reason:**
   - Optional field
   - Free text
   - Helps parent understand need

### Business Logic

1. **Current Limit Check:**
   - System finds current limit
   - Calculates: requested = current + additional
   - Sends calculated value to backend

2. **Duplicate Requests:**
   - Teen can send multiple requests
   - For same app
   - Parent sees all pending requests

3. **No Limit Set:**
   - If app has no limit, won't appear in dropdown
   - Teen must ask parent to set limit first

## 📊 User Benefits

### For Teenagers:

✅ **Plan Ahead:** Request time before running out
✅ **No Interruption:** Don't wait until blocked
✅ **Better Communication:** Explain need in advance
✅ **See All Options:** Dropdown shows all apps with limits
✅ **Flexible:** Can request any amount of additional time

### For Parents:

✅ **Proactive Requests:** See needs before they're urgent
✅ **Better Context:** Teen explains why they need more time
✅ **Same Interface:** All requests in one place
✅ **Easy Approval:** One-click approve/reject
✅ **Automatic Updates:** Limits update automatically

## 🚀 Feature Complete!

Both request methods are now available:

1. **Proactive Request** - From My Apps & Limits page ✅
2. **Reactive Request** - From blocked screen ✅

Teenagers can choose the best method for their situation!

## 📝 Summary

**What Changed:**
- ✅ Added "⏰ Request Time Extension" button
- ✅ Created request form with app dropdown
- ✅ Added additional time input field
- ✅ Integrated with existing API
- ✅ Styled with gradient theme
- ✅ Full validation and error handling

**What Stayed the Same:**
- ✅ Backend API (no changes needed)
- ✅ Parent dashboard (works with both types)
- ✅ Approval/rejection flow
- ✅ Database structure

**Result:**
Teenagers now have **two convenient ways** to request time extensions, making the system more flexible and user-friendly! 🎉
