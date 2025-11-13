# 🗄️ Database Setup - Single File Installation

## ✅ What's Been Created

I've created a **single, comprehensive database file** that sets up everything you need:

### Main File: `server/database/init_database.sql`
- ✅ Creates database: `parent_teen_db`
- ✅ Creates all 13 tables with proper relationships
- ✅ Includes indexes for better performance
- ✅ Includes the new `parent_id` field in users table
- ✅ Includes time_limit_requests table
- ✅ Ready to run - no additional files needed!

## 🚀 Quick Setup (Choose One Method)

### Method 1: Windows Batch Script (Easiest)
```bash
# Double-click this file:
server/database/setup_database.bat

# Or run from command line:
cd server/database
setup_database.bat
```

### Method 2: MySQL Command Line
```bash
cd server/database
mysql -u root -p < init_database.sql
```

### Method 3: PowerShell
```powershell
cd server\database
Get-Content init_database.sql | mysql -u root -p
```

### Method 4: MySQL Workbench
1. Open MySQL Workbench
2. File → Open SQL Script
3. Select `init_database.sql`
4. Click Execute (⚡)

### Method 5: phpMyAdmin
1. Open phpMyAdmin
2. Import tab
3. Choose `init_database.sql`
4. Click Go

## 📋 What Gets Created

### 13 Tables:

**Core System:**
1. `users` - All user accounts (parents & teenagers)
   - **NEW:** `parent_id` field to link teenagers to parents
2. `parents` - Parent-specific data
3. `teenagers` - Teenager-specific data

**Task Management:**
4. `tasks` - Assigned tasks
5. `time_requests` - Task time extension requests

**App Control:**
6. `app_limits` - Time limits for apps
7. `custom_apps` - User-added apps
8. `hidden_apps` - Hidden apps
9. `time_limit_requests` - **NEW:** Requests to increase app time limits

**Tracking:**
10. `app_usage` - Daily app usage
11. `website_usage` - Website visits

**Parental Controls:**
12. `blocked_sites` - Blocked websites

## ✅ Verification

After running the script, verify it worked:

```sql
-- Connect to MySQL
mysql -u root -p

-- Check database
SHOW DATABASES LIKE 'parent_teen_db';

-- Use database
USE parent_teen_db;

-- List all tables (should show 13)
SHOW TABLES;

-- Check users table structure
DESCRIBE users;
-- Should include: id, name, email, password, role, parent_id, created_at

-- Check time_limit_requests table
DESCRIBE time_limit_requests;
-- Should include: id, teenager_id, parent_id, app_name, current_limit, requested_limit, reason, status, created_at, updated_at
```

## 🔧 Environment Setup

Update your `.env` file in the server folder:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=parent_teen_db
PORT=5000
JWT_SECRET=your_secret_key_here
```

## 📁 Files Created

```
server/database/
├── init_database.sql          ⭐ Main file - Run this!
├── setup_database.bat         🪟 Windows quick setup
├── README.md                  📖 Detailed documentation
├── schema.sql                 📝 Updated with parent_id
├── migration_custom_apps.sql  (included in init_database.sql)
└── migration_time_limit_requests.sql (included in init_database.sql)
```

## 🎯 Next Steps

1. **Run the database setup** (choose any method above)
2. **Verify tables were created** (see verification section)
3. **Update .env file** with your MySQL credentials
4. **Start the backend:**
   ```bash
   cd server
   npm start
   ```
5. **Start the frontend:**
   ```bash
   cd client
   npm start
   ```
6. **Register accounts:**
   - Create a parent account
   - Create a teenager account (will be linked to parent)

## 🐛 Troubleshooting

### "MySQL not found"
- Install MySQL or add to PATH
- Common paths:
  - `C:\Program Files\MySQL\MySQL Server 8.0\bin`
  - `C:\xampp\mysql\bin`

### "Access denied"
- Check username/password
- Make sure MySQL server is running

### "Database already exists"
- Safe to ignore - script uses `IF NOT EXISTS`
- Or drop and recreate:
  ```sql
  DROP DATABASE IF EXISTS parent_teen_db;
  ```
  Then run `init_database.sql` again

### Need to Reset?
```sql
-- Drop everything and start fresh
DROP DATABASE IF EXISTS parent_teen_db;

-- Then run init_database.sql again
```

## ✨ Features Included

The database now supports:
- ✅ User authentication (parents & teenagers)
- ✅ Task management
- ✅ App time limits
- ✅ Custom apps
- ✅ Usage tracking
- ✅ Blocked sites
- ✅ **Time limit increase requests** (NEW!)
- ✅ Parent-teenager linking via `parent_id`

## 🎉 You're All Set!

Once the database is set up, your application will have:
- Complete user management
- Task tracking system
- App monitoring and limits
- Usage analytics
- Parental controls
- Time limit request system

Happy coding! 🚀
