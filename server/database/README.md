# Database Setup Guide

## Quick Start - Single File Setup

### Option 1: Using MySQL Command Line

```bash
# Navigate to the database folder
cd server/database

# Run the complete initialization script
mysql -u root -p < init_database.sql
```

### Option 2: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Go to **File** → **Open SQL Script**
4. Select `init_database.sql`
5. Click the **Execute** button (⚡ icon)

### Option 3: Using phpMyAdmin

1. Open phpMyAdmin
2. Click on **Import** tab
3. Click **Choose File** and select `init_database.sql`
4. Click **Go** at the bottom

### Option 4: Using Command Line (Windows)

```powershell
# From the project root
cd server\database

# Run the script (replace 'root' with your MySQL username)
Get-Content init_database.sql | mysql -u root -p
```

## Database Structure

The `init_database.sql` file creates the complete database with all tables:

### Core Tables
- **users** - Parent and teenager accounts (with parent_id linking)
- **parents** - Additional parent data
- **teenagers** - Additional teenager data

### Task Management
- **tasks** - Tasks assigned by parents
- **time_requests** - Requests for additional time on tasks

### App Management
- **app_limits** - Time limits set by parents
- **custom_apps** - Apps added by teenagers
- **hidden_apps** - Apps hidden by teenagers

### Usage Tracking
- **app_usage** - Daily app usage tracking
- **website_usage** - Website visit tracking

### Parental Controls
- **blocked_sites** - Sites blocked by parents
- **time_limit_requests** - Requests to increase app time limits

## Verification

After running the script, verify the setup:

```sql
-- Check database exists
SHOW DATABASES LIKE 'parent_teen_db';

-- Use the database
USE parent_teen_db;

-- List all tables
SHOW TABLES;

-- Should show 13 tables:
-- 1. users
-- 2. parents
-- 3. teenagers
-- 4. tasks
-- 5. time_requests
-- 6. app_limits
-- 7. custom_apps
-- 8. hidden_apps
-- 9. app_usage
-- 10. website_usage
-- 11. blocked_sites
-- 12. time_limit_requests
```

## Environment Configuration

Make sure your `.env` file has the correct database credentials:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=parent_teen_db
PORT=5000
JWT_SECRET=your_jwt_secret_key
```

## Troubleshooting

### Error: "Access denied for user"
- Check your MySQL username and password
- Make sure MySQL server is running

### Error: "Database already exists"
- The script uses `CREATE DATABASE IF NOT EXISTS`, so this is safe
- It will use the existing database

### Error: "Table already exists"
- The script uses `CREATE TABLE IF NOT EXISTS`, so this is safe
- Existing tables won't be modified

### Need to Reset Database?

```sql
-- Drop the entire database and start fresh
DROP DATABASE IF EXISTS parent_teen_db;

-- Then run init_database.sql again
```

## Migration Files

Individual migration files are also available in this folder:
- `migration_custom_apps.sql` - Custom apps feature
- `migration_time_limit_requests.sql` - Time limit requests feature

These are included in `init_database.sql`, so you don't need to run them separately for a fresh install.

## Next Steps

After database setup:
1. Start the backend server: `npm start` (from server folder)
2. Start the frontend: `npm start` (from client folder)
3. Register a parent account
4. Register a teenager account (linked to parent)
5. Start using the application!
