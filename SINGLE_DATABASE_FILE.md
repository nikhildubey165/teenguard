# 🗄️ Single Database File - Complete Setup

## ✅ Your Single Database File

**File:** `server/database/init_database.sql`

This ONE file contains **EVERYTHING** you need:
- ✅ Creates database: `parent_teen_db`
- ✅ Creates all 13 tables
- ✅ Includes `parent_id` field for teenager-parent linking
- ✅ Includes `time_limit_requests` table
- ✅ All indexes for performance
- ✅ All foreign keys and relationships

## 🚀 How to Run (Choose One Method)

### Method 1: Windows Batch Script (Easiest)
```bash
# Double-click this file:
server\database\setup_database.bat
```

### Method 2: MySQL Command Line
```bash
cd server\database
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
4. Click Execute (⚡ icon)

### Method 5: phpMyAdmin
1. Open phpMyAdmin
2. Click Import tab
3. Choose `init_database.sql`
4. Click Go

## 📋 What Gets Created

### Database:
- `parent_teen_db`

### 13 Tables:

**Core System:**
1. `users` - All accounts (with `parent_id` for teenagers)
2. `parents` - Parent-specific data
3. `teenagers` - Teenager-specific data

**Task Management:**
4. `tasks` - Assigned tasks
5. `time_requests` - Task time extension requests

**App Control:**
6. `app_limits` - Time limits for apps
7. `custom_apps` - User-added apps
8. `hidden_apps` - Hidden apps
9. `time_limit_requests` - App time limit increase requests

**Tracking:**
10. `app_usage` - Daily app usage
11. `website_usage` - Website visits

**Parental Controls:**
12. `blocked_sites` - Blocked websites

## ✅ Verification

After running the file, verify it worked:

```sql
-- Connect to MySQL
mysql -u root -p

-- Check database exists
SHOW DATABASES LIKE 'parent_teen_db';

-- Use database
USE parent_teen_db;

-- List all tables (should show 13)
SHOW TABLES;

-- Check users table has parent_id
DESCRIBE users;
-- Should show: id, name, email, password, role, parent_id, created_at

-- Check time_limit_requests table exists
DESCRIBE time_limit_requests;
```

## 📊 Table Structure

```
users
├── id (PRIMARY KEY)
├── name
├── email (UNIQUE)
├── password
├── role (parent/teenager)
├── parent_id (links teenagers to parents) ← IMPORTANT!
└── created_at

time_limit_requests
├── id (PRIMARY KEY)
├── teenager_id (FOREIGN KEY → users.id)
├── parent_id (FOREIGN KEY → users.id)
├── app_name
├── current_limit
├── requested_limit
├── reason
├── status (pending/approved/rejected)
├── created_at
└── updated_at
```

## 🔧 Environment Setup

After database setup, update your `.env` file:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=parent_teen_db
PORT=5000
JWT_SECRET=your_secret_key_here
```

## 🎯 Next Steps

1. ✅ Run `init_database.sql` (done!)
2. ✅ Update `.env` file
3. ✅ Start backend: `cd server && npm start`
4. ✅ Start frontend: `cd client && npm start`
5. ✅ Register accounts:
   - Register a **parent** first
   - Register a **teenager** (select the parent)
6. ✅ Start using the app!

## 🐛 Troubleshooting

### "Database already exists"
- Safe to ignore - script uses `IF NOT EXISTS`
- Or drop and recreate:
  ```sql
  DROP DATABASE IF EXISTS parent_teen_db;
  ```
  Then run `init_database.sql` again

### "Table already exists"
- Safe to ignore - script uses `IF NOT EXISTS`
- Existing tables won't be modified

### "MySQL not found"
- Install MySQL or add to PATH
- Common paths:
  - `C:\Program Files\MySQL\MySQL Server 8.0\bin`
  - `C:\xampp\mysql\bin`

### "Access denied"
- Check MySQL username/password
- Make sure MySQL server is running

## 📝 File Contents Summary

The `init_database.sql` file includes:

```sql
-- 1. Create database
CREATE DATABASE IF NOT EXISTS parent_teen_db;
USE parent_teen_db;

-- 2. Create users table (with parent_id)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('parent', 'teenager') NOT NULL,
  parent_id INT DEFAULT NULL,  -- ← Links teenagers to parents
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Create all other tables...
-- (parents, teenagers, tasks, time_requests, app_limits, 
--  custom_apps, hidden_apps, app_usage, website_usage, 
--  blocked_sites, time_limit_requests)
```

## ✨ Features Included

This database supports:
- ✅ User authentication (parents & teenagers)
- ✅ Parent-teenager linking via `parent_id`
- ✅ Task management
- ✅ Task time extension requests
- ✅ App time limits
- ✅ App time limit increase requests (NEW!)
- ✅ Custom apps
- ✅ Usage tracking
- ✅ Blocked sites
- ✅ Reports and analytics

## 🎉 You're All Set!

**One file. One command. Complete database.**

```bash
mysql -u root -p < server/database/init_database.sql
```

That's it! Your entire database is ready to use. 🚀

---

## 📂 File Location

```
ucd/
└── server/
    └── database/
        ├── init_database.sql          ⭐ THIS IS THE ONE!
        ├── setup_database.bat         (Windows quick setup)
        ├── schema.sql                 (same content, alternative)
        ├── README.md                  (detailed docs)
        └── fix_existing_teenagers.sql (for fixing old accounts)
```

**Use:** `init_database.sql` - It has everything!
