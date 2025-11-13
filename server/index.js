const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const authRoutes = require('./routes/auth');
const taskRoutes = require('./routes/tasks');
const timeRequestRoutes = require('./routes/timeRequests');
const appLimitRoutes = require('./routes/appLimits');
const blockedSiteRoutes = require('./routes/blockedSites');
const usageRoutes = require('./routes/usage');
const customAppsRoutes = require('./routes/customApps');
const timeLimitRequestRoutes = require('./routes/timeLimitRequests');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/time-requests', timeRequestRoutes);
app.use('/api/app-limits', appLimitRoutes);
app.use('/api/blocked-sites', blockedSiteRoutes);
app.use('/api/usage', usageRoutes);
app.use('/api/custom-apps', customAppsRoutes);
app.use('/api/time-limit-requests', timeLimitRequestRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Parent-Teen Work Manager API' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

