# Fix: Today's Usage Showing Old/Test Data

## 🔍 **Problem**
The "Today's Usage" section is showing 14 minutes for YouTube even though you haven't used the app today.

## 🎯 **Root Cause**
Old test data exists in the database from when you ran `add_test_usage.sql`. This test data has today's date but was created earlier, so it's showing up in your "Today's Usage" report.

## ✅ **Solution Options**

### **Option 1: Clean Up Test Data (Recommended)**

Run the cleanup script to remove old test data:

1. **Open your MySQL client** (MySQL Workbench, phpMyAdmin, or command line)
2. **Connect to your database**
3. **Run the cleanup script**: `cleanup_old_usage_data.sql`

The script will:
- Show you what data exists for today
- Identify old test data
- Provide commands to delete it (uncomment to run)

### **Option 2: Delete Today's Usage Data**

If you want to start fresh for today:

```sql
-- Delete ALL usage data for today
DELETE FROM app_usage WHERE usage_date = CURDATE();
```

### **Option 3: Delete Specific App Data**

If you only want to remove YouTube test data:

```sql
-- Delete only YouTube test data for today
DELETE FROM app_usage WHERE app_name IN ('youtube', 'YouTube') AND usage_date = CURDATE();
```

## 🔧 **Step-by-Step Fix**

### **Step 1: Check Current Data**
```sql
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
```

### **Step 2: Identify the Problem**
Look for:
- Apps you haven't used today
- Usage data with old `created_at` timestamps
- Test data from `add_test_usage.sql`

### **Step 3: Clean Up**
Run one of the DELETE commands above based on what you found.

### **Step 4: Verify**
Refresh your usage report and check that:
- Only actual usage appears
- Test data is gone
- Today's Usage shows 0 if you haven't used any apps

## 🚀 **Prevention**

To prevent this in the future:

1. **Don't use production dates for test data**
   - Use past dates for testing
   - Or use a separate test database

2. **Clean up after testing**
   - Always delete test data after running tests
   - Document what test data you add

3. **Use better test data**
   - Use obvious test app names like "TEST_APP"
   - Use past dates that won't interfere with today's data

## 📝 **Quick Fix Command**

If you just want to remove all today's usage and start fresh:

```sql
DELETE FROM app_usage WHERE usage_date = CURDATE();
```

Then refresh your usage report page.

## ✅ **Expected Result**

After cleanup:
- Today's Usage should show 0 minutes (or only actual usage)
- No test data should appear
- Only apps you actually use today will show up

## 🔍 **Debugging**

If the issue persists after cleanup:

1. **Check the server logs** when you refresh the report
2. **Look for the query** that fetches today's usage
3. **Verify the date format** matches between client and server
4. **Check timezone settings** on your server

The server logs will show:
```
[MY-REPORT] QUERYING FOR TODAY'S USAGE
Server time: 2025-11-12T...
Today's date (for query): 2025-11-12
```

Make sure this date matches your actual current date.
