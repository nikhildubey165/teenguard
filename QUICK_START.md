# 🚀 Quick Start Guide

## Step-by-Step Instructions to Run the Application

### Prerequisites
- ✅ Node.js installed (v14 or higher)
- ✅ MySQL installed and running
- ✅ npm or yarn package manager

---

## Step 1: Install Dependencies

Open terminal/command prompt in the project folder and run:

```bash
npm run install-all
```

This installs dependencies for both backend and frontend.

---

## Step 2: Set Up MySQL Database

### Option A: Using Command Line
```bash
mysql -u root -p
```

Then in MySQL, run:
```sql
source server/database/schema.sql
```

### Option B: Using MySQL Workbench
1. Open MySQL Workbench
2. Connect to your MySQL server
3. Go to **File → Open SQL Script**
4. Select `server/database/schema.sql`
5. Click **Run** (or press F5)

### Option C: Using phpMyAdmin
1. Open phpMyAdmin in your browser
2. Click on **Import** tab
3. Choose file: `server/database/schema.sql`
4. Click **Go**

---

## Step 3: Create .env File

Create a file named `.env` in the **root directory** (same level as `package.json`) with this content:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=parent_teen_db
JWT_SECRET=my-super-secret-jwt-key-12345
PORT=5000
```

**⚠️ Important:**
- Replace `your_mysql_password` with your actual MySQL root password
- Change `JWT_SECRET` to any random string (for security)

---

## Step 4: Start the Application

### Easy Way (Recommended):
Run both server and client together:

```bash
npm run dev
```

This starts:
- ✅ Backend server on **http://localhost:5000**
- ✅ Frontend client on **http://localhost:3000**

### Alternative Way (Separate Terminals):

**Terminal 1 - Start Backend:**
```bash
npm run server
```

**Terminal 2 - Start Frontend:**
```bash
npm run client
```

---

## Step 5: Open in Browser

Open your web browser and go to:

**http://localhost:3000**

---

## Step 6: Create Accounts

### Create Parent Account:
1. Click **"Register"**
2. Fill in:
   - Name: `John Parent`
   - Email: `parent@example.com`
   - Password: `password123`
   - Role: **Parent**
3. Click **"Register"**

### Create Teenager Account:
1. Click **"Register"** (or logout first)
2. Fill in:
   - Name: `Jane Teen`
   - Email: `teen@example.com`
   - Password: `password123`
   - Role: **Teenager**
3. Click **"Register"**

---

## ✅ You're All Set!

Now you can:
- **As Parent**: Create tasks, set app limits, block sites, view reports
- **As Teenager**: View tasks, request time extensions, see app limits, view usage reports

---

## 🐛 Troubleshooting

### "Cannot connect to database"
- ✅ Check MySQL is running
- ✅ Verify `.env` file has correct password
- ✅ Make sure database `parent_teen_db` exists

### "Port 5000 already in use"
- Change `PORT=5000` to `PORT=5001` in `.env` file

### "Port 3000 already in use"
- React will automatically try port 3001, 3002, etc.

### "Module not found"
- Run `npm run install-all` again
- Or delete `node_modules` folders and reinstall

### "Cannot find .env file"
- Make sure `.env` is in the root directory (not in `client` or `server`)
- Check the file is named exactly `.env` (not `.env.txt`)

---

## 📝 Quick Commands Reference

```bash
# Install all dependencies
npm run install-all

# Start both server and client
npm run dev

# Start only backend server
npm run server

# Start only frontend client
npm run client
```

---

## 🎯 What's Next?

1. **Login as Parent** → Set app limits for teenager
2. **Login as Teenager** → View your app limits and usage
3. **Create tasks** → Assign work to teenager
4. **View Reports** → See usage statistics

Enjoy using the Parent-Teen Work Management System! 🎉

