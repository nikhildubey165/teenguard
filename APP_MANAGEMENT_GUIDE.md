# 🎯 App Management Guide

## Overview
Teenagers can **add and edit** custom apps in the "Available Apps & Limits" section.

## 🚀 Features

### **Custom Apps Management**
- ✅ **Add** custom apps
- ✅ **Edit** custom apps (name, icon, category, URL)

## 📋 Setup Instructions

The custom apps feature is already included in the main schema. No additional setup needed!

### Restart Server (if needed)

```bash
# Stop the server if running (Ctrl+C)
# Then restart
npm run dev
```

## 🎨 User Interface

### Header Button
- **"+ Add Custom App"** - Opens form to add new custom app

### App Cards

Custom apps have an action button:
- **✏️ Edit** - Edit app details (name, icon, category, URL)

## 📖 How to Use

### Adding a Custom App
1. Click **"+ Add Custom App"**
2. Fill in the form:
   - App Name (required)
   - Icon (emoji)
   - Category (dropdown)
   - Website URL (required)
3. Click **"Add App"**

### Editing a Custom App
1. Click the **✏️ Edit** button on a custom app card
2. The form opens with current app details
3. Make your changes
4. Click **"Update App"**
5. Or click **"Cancel"** to discard changes

## 🔧 API Endpoints

### Custom Apps

#### Get Custom Apps
```
GET /api/custom-apps
```

#### Add Custom App
```
POST /api/custom-apps
Body: { app_name, icon, category, url }
```

#### Update Custom App
```
PUT /api/custom-apps/:id
Body: { app_name, icon, category, url }
```


## 🗄️ Database Tables

### custom_apps
Stores custom apps added by teenagers
```sql
- id: Primary key
- teenager_id: Foreign key to users
- app_name: Name of the app
- icon: Emoji icon
- category: App category
- url: Website URL
- created_at: Timestamp
```

## 🎯 Use Cases

### Example 1: Add Study App
```
1. Click "+ Add Custom App"
2. Enter:
   - Name: "Khan Academy"
   - Icon: 📚
   - Category: Education
   - URL: https://www.khanacademy.org
3. Click "Add App"
```

### Example 2: Edit Custom App
```
1. Find your custom app
2. Click ✏️ Edit button
3. Change URL or icon
4. Click "Update App"
```

## 🔐 Security & Permissions

- ✅ Only teenagers can manage their own apps
- ✅ Custom apps are isolated per teenager
- ✅ Parents can still set limits on any app
- ✅ Usage tracking continues for all apps
- ✅ URL validation prevents invalid links

## 💡 Pro Tips

1. **Edit custom apps** if URLs change or to update icons
2. **Use descriptive names** for custom apps
3. **Custom apps work with all features** - limits, usage tracking, blocking

## 🐛 Troubleshooting

### Can't edit app
- Only custom apps can be edited
- Predefined apps cannot be modified

### "App with this name already exists"
- Choose a different name
- Or edit the existing app instead

### Edit form shows wrong data
- Click Cancel and try again
- Refresh the page

## 📊 Features Summary

| Feature | Custom Apps | Predefined Apps |
|---------|-------------|-----------------|
| Add | ✅ Yes | ❌ No |
| Edit | ✅ Yes | ❌ No |
| Usage Tracking | ✅ Yes | ✅ Yes |
| Time Limits | ✅ Yes | ✅ Yes |
| Blocking | ✅ Yes | ✅ Yes |

## 🎉 Summary

You can now manage custom apps:
- **Add** apps you want
- **Edit** apps you've added

All while maintaining full usage tracking and parental controls! 🎯
