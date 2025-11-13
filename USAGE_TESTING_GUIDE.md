# Usage Testing Guide

## Overview
I've added functionality to easily test the app usage tracking and blocking system. You can now modify the "Used Today" values and test the blocking functionality.

## What I Added

### 1. Test Endpoint (Backend)
- Added `/usage/test-set-usage` endpoint to manually set usage values
- Located in: `server/routes/usage.js`

### 2. Test Buttons (Frontend)
- Added test buttons to each app card in the App Limits page
- Three buttons per app (if it has a limit):
  - **Test: 1min** - Sets usage to 1 minute
  - **Test: Block** - Sets usage to the daily limit (blocks the app)
  - **Reset** - Resets usage back to 0

### 3. SQL Script
- Created `add_test_usage.sql` for manual database testing

## How to Test

### Method 1: Using Test Buttons (Recommended)
1. **Start the application**:
   ```bash
   # In server directory
   npm start
   
   # In client directory (separate terminal)
   npm start
   ```

2. **Navigate to App Limits page** as a teenager user

3. **For any app with a limit set**:
   - Click **"Test: 1min"** to set usage to 1 minute
   - The display should update to show "1 / 2 minutes" (or whatever your limit is)
   - Click **"Test: Block"** to set usage equal to the limit
   - The app should become blocked and show "🚫 BLOCKED - Available at midnight"
   - Try clicking the blocked app - it should show an alert and NOT open
   - Click **"Reset"** to clear usage back to 0

### Method 2: Using SQL Script
1. **Run the SQL script**:
   ```sql
   -- Connect to your database and run:
   source add_test_usage.sql
   ```

2. **Adjust the teenager_id** in the script to match your user ID

### Method 3: Using API Directly
```javascript
// Set usage to 1 minute
fetch('/api/usage/test-set-usage', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    app_name: 'youtube',
    usage_minutes: 1
  })
});
```

## Expected Behavior

### When Usage < Limit
- App shows current usage (e.g., "1 / 2 minutes")
- Progress bar shows percentage used
- App is clickable and opens normally
- Shows "Click to open →"

### When Usage = Limit
- App shows "🚫 BLOCKED - Available at midnight"
- App card becomes grayed out (opacity: 0.7)
- Cursor shows "not-allowed" when hovering
- Clicking shows alert: "Daily time limit reached!"
- App does NOT open

### Blocking Alert Details
The alert shows:
- Current usage vs limit
- Time until midnight reset
- Explanation that usage resets at 12:00 AM

## Verification Steps

1. ✅ **Set usage to 1 minute** - Should show partial usage
2. ✅ **Set usage to limit** - Should block the app completely  
3. ✅ **Try to open blocked app** - Should show alert and not open
4. ✅ **Reset usage** - Should unblock the app
5. ✅ **Check progress bar** - Should update correctly
6. ✅ **Check percentage** - Should calculate correctly

## Troubleshooting

### If test buttons don't appear:
- Make sure the app has a limit set (ask parent to set one)
- Check browser console for errors
- Refresh the page

### If usage doesn't update:
- Check network tab for API errors
- Look at server console logs
- Try the manual refresh button

### If blocking doesn't work:
- Verify the limit is actually set in the database
- Check that app names match exactly (case-sensitive)
- Look for JavaScript errors in browser console

## Notes

- Usage resets automatically at midnight
- Test buttons only appear for apps with limits set
- The blocking logic is implemented in both frontend and backend for security
- All changes are immediately saved to the database
