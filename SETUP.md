# Setup Guide

## Quick Start

### 1. Install Dependencies
```bash
npm run install-all
```

### 2. Database Setup

#### Option A: Using MySQL Command Line
```bash
mysql -u root -p
```
Then run:
```sql
source server/database/schema.sql
```

#### Option B: Using MySQL Workbench or phpMyAdmin
1. Open MySQL Workbench or phpMyAdmin
2. Create a new database named `parent_teen_db`
3. Import the file `server/database/schema.sql`

**Note:** The schema includes all tables including the new `custom_apps` table for teenagers to add their own apps.

### 3. Environment Configuration

Create a `.env` file in the root directory with the following content:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=parent_teen_db
JWT_SECRET=your-secret-key-change-this-to-random-string
PORT=5000
```

**Important**: Replace `your_mysql_password` with your actual MySQL root password, and change `JWT_SECRET` to a random string for security.

### 4. Start the Application

#### Development Mode (Both Server and Client)
```bash
npm run dev
```

This will start:
- Backend server on http://localhost:5000
- Frontend client on http://localhost:3000

#### Or Start Separately

**Terminal 1 - Backend:**
```bash
npm run server
```

**Terminal 2 - Frontend:**
```bash
npm run client
```

### 5. Access the Application

Open your browser and navigate to: http://localhost:3000

## Creating Test Accounts

1. **Register a Parent Account:**
   - Click "Register"
   - Fill in name, email, password
   - Select "Parent" as role
   - Submit

2. **Register a Teenager Account:**
   - Click "Register" (or logout first)
   - Fill in name, email, password
   - Select "Teenager" as role
   - Submit

## Troubleshooting

### Database Connection Error
- Verify MySQL is running
- Check `.env` file has correct database credentials
- Ensure database `parent_teen_db` exists
- Verify all tables were created (check with `SHOW TABLES;` in MySQL)

### Port Already in Use
- Change `PORT` in `.env` file
- Or stop the process using the port

### Module Not Found
- Run `npm run install-all` again
- Delete `node_modules` and `package-lock.json`, then reinstall

### CORS Errors
- Ensure backend is running on port 5000
- Check that frontend proxy is set correctly in `client/package.json`

## Production Deployment

1. Build the React app:
   ```bash
   cd client
   npm run build
   ```

2. Set production environment variables
3. Use a process manager like PM2 for Node.js
4. Configure reverse proxy (nginx/Apache)
5. Use HTTPS
6. Change JWT_SECRET to a strong random string

