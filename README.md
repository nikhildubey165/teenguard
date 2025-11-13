# Parent-Teen Work Management System

A comprehensive web application for parents to manage their teenagers' tasks, time extensions, app limits, and blocked websites.

## Features

### For Parents:
- **Task Management**: Create and assign tasks to teenagers with due dates and estimated time
- **Time Extension Requests**: View and approve/reject time extension requests from teenagers
- **App Time Limits**: Set daily time limits for specific apps (e.g., Instagram, TikTok, YouTube)
- **Blocked Websites**: Block specific websites for teenagers
- **Dashboard**: View all tasks, requests, and settings in one place

### For Teenagers:
- **View Tasks**: See all assigned tasks with status and due dates
- **Task Management**: Mark tasks as in-progress or completed
- **Request Time Extensions**: Request additional time for tasks with reasons
- **View Limits**: See app time limits and blocked websites set by parents

## Tech Stack

- **Frontend**: React 18, React Router, Axios
- **Backend**: Node.js, Express.js
- **Database**: MySQL
- **Authentication**: JWT (JSON Web Tokens)

## Prerequisites

- Node.js (v14 or higher)
- MySQL (v5.7 or higher)
- npm or yarn

## Installation

1. **Clone the repository** (if applicable) or navigate to the project directory

2. **Install dependencies**:
   ```bash
   npm run install-all
   ```

3. **Set up the database**:
   - Create a MySQL database
   - Update the `.env` file with your database credentials (see `.env.example`)
   - Run the schema file to create tables:
     ```bash
     mysql -u root -p < server/database/schema.sql
     ```
     Or import it using your MySQL client

4. **Configure environment variables**:
   - Copy `.env.example` to `.env`
   - Update the database credentials and JWT secret:
     ```
     DB_HOST=localhost
     DB_USER=root
     DB_PASSWORD=your_password
     DB_NAME=parent_teen_db
     JWT_SECRET=your-secret-key-change-this
     PORT=5000
     ```

## Running the Application

1. **Start both server and client** (recommended for development):
   ```bash
   npm run dev
   ```

2. **Or start them separately**:
   ```bash
   # Terminal 1 - Start backend server
   npm run server

   # Terminal 2 - Start frontend client
   npm run client
   ```

3. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000

## Database Schema

The application uses the following main tables:
- `users` - Stores parent and teenager accounts
- `parents` - Parent-specific data
- `teenagers` - Teenager-specific data
- `tasks` - Task assignments
- `time_requests` - Time extension requests
- `app_limits` - App time limits
- `blocked_sites` - Blocked websites

## Usage

1. **Register Accounts**:
   - Register as a Parent account
   - Register as a Teenager account (or have parent create it)

2. **Parent Workflow**:
   - Login as parent
   - Go to Tasks tab to create and assign tasks
   - Go to Time Requests tab to approve/reject requests
   - Go to App Limits tab to set app time limits
   - Go to Blocked Sites tab to block websites

3. **Teenager Workflow**:
   - Login as teenager
   - View assigned tasks in My Tasks tab
   - Update task status (Start Task, Mark Complete)
   - Request time extensions if needed
   - View app limits and blocked sites

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Tasks
- `GET /api/tasks` - Get all tasks (filtered by role)
- `POST /api/tasks` - Create task (parent only)
- `PATCH /api/tasks/:id/status` - Update task status
- `GET /api/tasks/teenagers` - Get list of teenagers (parent only)

### Time Requests
- `GET /api/time-requests` - Get all time requests
- `POST /api/time-requests` - Create time request (teenager only)
- `PATCH /api/time-requests/:id/status` - Approve/reject request (parent only)

### App Limits
- `GET /api/app-limits` - Get all app limits
- `POST /api/app-limits` - Create/update app limit (parent only)
- `DELETE /api/app-limits/:id` - Delete app limit (parent only)

### Blocked Sites
- `GET /api/blocked-sites` - Get all blocked sites
- `POST /api/blocked-sites` - Block a site (parent only)
- `DELETE /api/blocked-sites/:id` - Unblock a site (parent only)

## Security Notes

- Change the `JWT_SECRET` in production to a strong random string
- Use environment variables for sensitive data
- Implement HTTPS in production
- Consider adding rate limiting for API endpoints
- Add input validation and sanitization

## Future Enhancements

- Email notifications for task assignments and request approvals
- Real-time updates using WebSockets
- Mobile app version
- Activity tracking and reports
- Parent-teenager messaging system
- Task categories and priorities
- Recurring tasks

## License

ISC

## Support

For issues or questions, please create an issue in the repository.

