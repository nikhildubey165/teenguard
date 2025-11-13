@echo off
echo ============================================
echo Parent-Teen Work Manager
echo Database Setup Script
echo ============================================
echo.

REM Check if MySQL is in PATH
where mysql >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: MySQL is not found in PATH
    echo Please install MySQL or add it to your system PATH
    echo.
    echo Common MySQL paths:
    echo   C:\Program Files\MySQL\MySQL Server 8.0\bin
    echo   C:\xampp\mysql\bin
    pause
    exit /b 1
)

echo MySQL found!
echo.

REM Prompt for MySQL credentials
set /p MYSQL_USER="Enter MySQL username (default: root): "
if "%MYSQL_USER%"=="" set MYSQL_USER=root

echo.
echo Connecting to MySQL as %MYSQL_USER%...
echo You will be prompted for your MySQL password.
echo.

REM Run the initialization script
mysql -u %MYSQL_USER% -p < init_database.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo SUCCESS! Database setup completed!
    echo ============================================
    echo.
    echo Database: parent_teen_db
    echo Tables created: 13
    echo.
    echo Next steps:
    echo 1. Update your .env file with database credentials
    echo 2. Start the backend server: npm start
    echo 3. Start the frontend: npm start (in client folder^)
    echo.
) else (
    echo.
    echo ============================================
    echo ERROR: Database setup failed!
    echo ============================================
    echo.
    echo Please check:
    echo 1. MySQL server is running
    echo 2. Username and password are correct
    echo 3. You have permission to create databases
    echo.
)

pause
