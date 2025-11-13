# New Features - App Management & Reporting System

## 🎮 Predefined Apps

The application now includes **18 predefined apps** that parents can set limits for:

### Social Media Apps
- 📷 Instagram
- 👥 Facebook
- 👻 Snapchat
- 🐦 Twitter
- 🤖 Reddit
- 📌 Pinterest

### Entertainment Apps
- 📺 YouTube
- 🎬 Netflix
- 🎵 Spotify
- 🎵 TikTok

### Gaming Apps
- 🎮 Games (General)
- 🎮 Twitch
- 🎮 Roblox
- ⛏️ Minecraft
- 🎯 Fortnite
- 🔫 Call of Duty

### Communication Apps
- 💬 WhatsApp
- 💬 Discord

## ✨ New Features

### 1. Enhanced App Limits (Parent Dashboard)
- **Predefined Apps Dropdown**: Parents can now select from a list of popular apps instead of typing
- **App Icons**: Visual icons for each app make it easier to identify
- **Default Limits**: Each app has a suggested default time limit
- **App Categories**: Apps are organized by category (Social Media, Gaming, Entertainment, etc.)

### 2. All Apps View (Teen Dashboard)
- **Complete App Gallery**: Teenagers can see all available apps in a beautiful grid layout
- **Visual Indicators**: 
  - Green border = App has a limit set
  - Gray border = No limit set
- **App Information**: Each app card shows:
  - App icon
  - App name
  - Category
  - Daily limit (if set)

### 3. Usage Reports (Parent Dashboard)
Parents can now view comprehensive usage reports:

#### Features:
- **Filter by Teenager**: View reports for specific teenagers or all teenagers
- **Time Period Selection**: Choose last 7, 14, or 30 days
- **Summary Cards**: Quick overview showing:
  - Total usage per app
  - Average daily usage
  - Number of days used
- **Detailed Table**: Complete breakdown showing:
  - Date
  - App name
  - Usage minutes
  - Daily limit
  - Status (Within Limit / Over Limit / No Limit)
  - Which teenager
- **Over Limit Highlighting**: Rows highlighted in red when limits are exceeded

### 4. My Usage Report (Teen Dashboard)
Teenagers can view their own usage statistics:

#### Features:
- **Today's Usage**: 
  - Visual progress bars showing usage vs. limit
  - Color-coded (green = within limit, red = over limit)
  - Shows remaining time for each app
- **Summary Statistics**:
  - Total usage per app over selected period
  - Average daily usage
  - Days used
  - Daily limits
- **Daily Breakdown**: Detailed list of all usage entries
- **Time Period Selection**: View last 7, 14, or 30 days

## 📊 Database Updates

### New Tables:
1. **app_usage**: Tracks daily app usage for each teenager
   - Records usage minutes per app per day
   - Automatically updates existing records

2. **website_usage**: Tracks website visits (for future use)
   - Records visit counts per website per day

## 🔌 New API Endpoints

### Usage Tracking
- `POST /api/usage/app` - Track app usage (teenager only)
- `GET /api/usage/app` - Get app usage history (teenager only)

### Reports
- `GET /api/usage/report` - Get usage report (parent only)
  - Query params: `teenager_id` (optional), `days` (default: 7)
- `GET /api/usage/my-report` - Get own usage report (teenager only)
  - Query params: `days` (default: 7)

### Predefined Apps
- `GET /api/app-limits/predefined` - Get list of predefined apps

## 🎨 UI Enhancements

### Visual Improvements:
- **App Icons**: Large, colorful emoji icons for each app
- **Progress Bars**: Visual representation of usage vs. limits
- **Color Coding**: 
  - Green = Within limit / Has limit
  - Red = Over limit / Warning
  - Gray = No limit / Neutral
- **Card Layouts**: Modern card-based design for better organization
- **Responsive Grids**: Apps displayed in responsive grid layouts
- **Hover Effects**: Interactive cards with hover animations

### New Components:
1. **Parent/Reports.js** - Comprehensive reporting dashboard for parents
2. **Teen/UsageReport.js** - Personal usage report for teenagers
3. Enhanced **Parent/AppLimits.js** - With predefined apps dropdown
4. Enhanced **Teen/AppLimits.js** - Complete app gallery view

## 📱 How to Use

### For Parents:
1. **Set App Limits**:
   - Go to "App Limits" tab
   - Click "+ New Limit"
   - Select teenager
   - Choose app from dropdown (with icons!)
   - Set daily limit (defaults suggested)
   - Save

2. **View Reports**:
   - Go to "Reports" tab
   - Select teenager (or "All Teenagers")
   - Choose time period (7/14/30 days)
   - View summary cards and detailed table
   - Identify apps where limits are exceeded

### For Teenagers:
1. **View All Apps**:
   - Go to "App Limits" tab
   - See all available apps in grid
   - Green border = limit set
   - Gray border = no limit

2. **View Usage Report**:
   - Go to "My Report" tab
   - See today's usage with progress bars
   - View summary statistics
   - Check daily breakdown
   - Select time period (7/14/30 days)

## 🔮 Future Enhancements

The system is now ready for:
- Real-time usage tracking (when integrated with device monitoring)
- Automatic limit enforcement
- Notifications when limits are exceeded
- Weekly/monthly summary emails
- Usage trends and analytics
- Parent-teenager usage comparisons

## 🚀 Technical Notes

- All usage data is stored daily (one record per app per day per teenager)
- Reports aggregate data efficiently using SQL GROUP BY
- The system supports multiple teenagers per parent
- Usage tracking is designed to be called periodically (e.g., every minute) from a device monitoring app
- The API is ready for integration with device monitoring solutions

