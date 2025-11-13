# 🎯 Custom Apps Feature - Setup & Usage Guide

## Overview
Teenagers can now add and edit their own custom apps in the "Available Apps & Limits" section, in addition to the predefined apps.

## 🔧 Setup Instructions

### If You're Setting Up Fresh:

The `custom_apps` table is **already included** in the main `schema.sql` file. Just follow the normal setup:

```bash
# Import the main schema (includes custom_apps table)
mysql -u root -p < server/database/schema.sql
```

### If You Already Have the Database:

You have two options:

**Option 1: Add the table manually**
```bash
mysql -u root -p parent_teen_db
```
Then run:
```sql
CREATE TABLE IF NOT EXISTS custom_apps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  icon VARCHAR(50) DEFAULT '📱',
  category VARCHAR(100) DEFAULT 'Other',
  url VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_teen_app (teenager_id, app_name)
);
```

**Option 2: Re-import the entire schema** (safer for updates)
```bash
# Backup first if you have data!
mysql -u root -p parent_teen_db < server/database/schema.sql
```

### Restart the Server

After updating the database, restart your server:

```bash
# If server is running, stop it (Ctrl+C)
# Then restart it
npm run dev
```

## 📱 Features Added

### For Teenagers:

1. **Add Custom Apps**
   - Click "+ Add Custom App" button
   - Fill in the form:
     - App Name (required)
     - Icon (emoji, optional - defaults to 📱)
     - Category (dropdown selection)
     - Website URL (required)
   - Submit to add the app

2. **Edit Custom Apps**
   - Click the ✏️ edit icon on any custom app card
   - Modify app details (name, icon, category, URL)
   - Save changes or cancel
   - Only custom apps can be edited (predefined apps cannot)

3. **View Custom Apps**
   - Custom apps appear alongside predefined apps
   - Custom apps have a purple "Custom" badge
   - All functionality (usage tracking, limits, blocking) works the same

### For Parents:

- Parents can set time limits on custom apps just like predefined apps
- Custom apps appear in usage reports
- Custom apps can be blocked like any other app

## 🎨 Visual Indicators

- **Custom Badge**: Purple gradient badge shows which apps are custom
- **Edit Button**: Pencil icon appears on custom apps for editing
- **Form Card**: Beautiful form for adding/editing apps
- **Categories**: Pre-defined categories for organization

## 🗄️ Database Schema

The migration creates a new table:

```sql
CREATE TABLE custom_apps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  icon VARCHAR(50) DEFAULT '📱',
  category VARCHAR(100) DEFAULT 'Other',
  url VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_teen_app (teenager_id, app_name)
);
```

## 🔐 Security

- Only teenagers can add/delete their own custom apps
- Each teenager's custom apps are isolated
- URL validation ensures valid website addresses
- Duplicate app names are prevented per teenager

## 🚀 API Endpoints

### Get Custom Apps
- **GET** `/api/custom-apps`
- Returns all custom apps for the logged-in teenager

### Add Custom App
- **POST** `/api/custom-apps`
- Body: `{ app_name, icon, category, url }`
- Creates a new custom app

### Delete Custom App
- **DELETE** `/api/custom-apps/:id`
- Deletes a custom app by ID

## 📝 Usage Examples

### Example 1: Adding Duolingo
```
App Name: Duolingo
Icon: 🦉
Category: Education
URL: https://www.duolingo.com
```

### Example 2: Adding Khan Academy
```
App Name: Khan Academy
Icon: 📚
Category: Education
URL: https://www.khanacademy.org
```

### Example 3: Adding Chess.com
```
App Name: Chess.com
Icon: ♟️
Category: Gaming
URL: https://www.chess.com
```

## 🐛 Troubleshooting

### "Error adding custom app"
- Check if app name already exists
- Verify URL is valid (must start with http:// or https://)
- Check internet connection

### Custom apps not showing
- Verify database migration ran successfully
- Restart the server
- Check browser console for errors
- Refresh the page

### Can't delete custom app
- Make sure you're logged in as a teenager
- Only your own custom apps can be deleted
- Check if app is being used in any limits

## 🎯 Next Steps

After setup, teenagers can:
1. Navigate to "Available Apps & Limits"
2. Click "+ Add Custom App"
3. Add their favorite educational or approved apps
4. Parents can then set limits on these custom apps
5. Usage is tracked automatically

Enjoy the new custom apps feature! 🎉
