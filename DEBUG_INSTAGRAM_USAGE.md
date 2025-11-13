# Debug Instagram Usage Issue

## 🔍 **Possible Causes:**

### **1. Case Sensitivity Issue**
- App name might be saved as "instagram" instead of "Instagram"
- Database queries are case-sensitive

### **2. App Name Mismatch**
- Predefined app name: "Instagram"
- Saved usage name: might be different

### **3. Date/Time Issues**
- Usage saved with wrong date
- Timezone issues

## 🔧 **Debug Steps:**

### **Step 1: Check Console Logs**
When you use Instagram, look for these console messages:
```
[saveUsagePeriodically] Instagram: adding 1 minute(s)
[getCurrentTotalUsage] Instagram has X minutes for today
```

### **Step 2: Check Database Directly**
Open browser console and run:
```javascript
// Check all usage records
fetch('/api/usage/app?days=30', {
  headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
})
.then(r => r.json())
.then(data => {
  console.log('All usage records:', data.usage);
  const instagram = data.usage.filter(u => u.app_name.toLowerCase().includes('instagram'));
  console.log('Instagram records:', instagram);
});
```

### **Step 3: Check Report Data**
```javascript
// Check report data
fetch('/api/usage/my-report?days=7', {
  headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
})
.then(r => r.json())
.then(data => {
  console.log('Report data:', data);
  const instagram = data.summary.find(s => s.app_name.toLowerCase().includes('instagram'));
  console.log('Instagram in report:', instagram);
});
```

## 🎯 **Expected Behavior:**

### **When Using Instagram:**
1. **Timer starts**: Shows "Time Used Today: 0m → 1m → 2m..."
2. **Auto-save logs**: "[saveUsagePeriodically] Instagram: adding 1 minute(s)"
3. **Database save**: Usage recorded with app_name = "Instagram"
4. **Report shows**: Instagram appears in usage report

### **If Not Working:**
- Timer might not be starting
- Usage might not be saving
- App name might be wrong
- Date might be wrong

## 🔧 **Quick Fix Attempts:**

### **Fix 1: Force Save Test**
Add this to AppLauncher for testing:
```javascript
// Test save for Instagram
const testSave = async () => {
  await api.post('/usage/app', {
    app_name: 'Instagram',
    usage_minutes: 1
  });
  console.log('Test save completed for Instagram');
};
```

### **Fix 2: Check App Name**
In AppLauncher, add logging:
```javascript
console.log('App object:', app);
console.log('App name being saved:', app.name);
```

### **Fix 3: Database Query Fix**
If case sensitivity is the issue, update backend query to be case-insensitive:
```sql
WHERE LOWER(au.app_name) = LOWER(?)
```

## 🚀 **Next Steps:**
1. Use Instagram for 2+ minutes
2. Check console logs for save messages
3. Check usage report to see if data appears
4. If still not working, run debug queries above
