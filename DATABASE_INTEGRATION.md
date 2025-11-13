# ✅ Database Integration Complete

## Single Database Setup

Everything is now integrated into **ONE database**: `parent_teen_db`

## What Changed?

✅ The `custom_apps` table has been **added to the main schema.sql**  
✅ No separate migration file needed  
✅ One database, one import command  

## Setup Instructions

### Fresh Installation:
Just import the main schema file:
```bash
mysql -u root -p < server/database/schema.sql
```

This creates:
- Database: `parent_teen_db`
- All tables including:
  - users
  - tasks
  - app_limits
  - app_usage
  - blocked_sites
  - custom_apps ← **NEW**
  - and all other tables

### Existing Installation:
If you already have the database running, you need to add the `custom_apps` table:

```bash
mysql -u root -p parent_teen_db
```

Then run this SQL:
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

## Configuration

Your `.env` file should have:
```env
DB_NAME=parent_teen_db
```

## Files You Can Ignore

- ❌ `server/database/migration_custom_apps.sql` - No longer needed (integrated into schema.sql)

## Verify Setup

After importing, verify all tables exist:
```bash
mysql -u root -p parent_teen_db -e "SHOW TABLES;"
```

You should see:
```
+---------------------------+
| Tables_in_parent_teen_db  |
+---------------------------+
| app_limits                |
| app_usage                 |
| blocked_sites             |
| custom_apps               | ← Should see this
| parents                   |
| tasks                     |
| teenagers                 |
| time_requests             |
| users                     |
| website_usage             |
+---------------------------+
```

## Summary

🎉 **You now have ONE unified database with ALL features!**

No need to manage multiple database files or migrations. Everything is in `schema.sql`.
