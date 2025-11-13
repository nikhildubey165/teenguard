const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Helper function to get local date in YYYY-MM-DD format
const getLocalDate = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

// Track app usage (teenager only)
router.post('/app', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can track usage' });
    }

    let { app_name, usage_minutes } = req.body;

    if (!app_name || usage_minutes === undefined) {
      return res.status(400).json({ error: 'App name and usage minutes are required' });
    }

    // Trim app name to remove leading/trailing spaces
    app_name = app_name.trim();

    // Validate app name - must be at least 2 characters
    if (app_name.length < 2) {
      console.error(`[USAGE] Invalid app name rejected: "${app_name}" (too short)`);
      return res.status(400).json({ error: 'App name must be at least 2 characters long' });
    }

    const today = getLocalDate();
    const timestamp = new Date().toISOString();
    
    console.log(`[USAGE ${timestamp}] Teen ${req.user.userId} - Saving usage for "${app_name}": ${usage_minutes} minutes on ${today}`);

    // Use INSERT ... ON DUPLICATE KEY UPDATE for atomic operation
    // This prevents race conditions when multiple saves happen simultaneously
    // IMPORTANT: We ADD to existing usage, not replace it
    const [result] = await pool.execute(
      `INSERT INTO app_usage (teenager_id, app_name, usage_minutes, usage_date) 
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
         usage_minutes = usage_minutes + VALUES(usage_minutes),
         updated_at = NOW()`,
      [req.user.userId, app_name, usage_minutes, today]
    );
    
    console.log(`[USAGE ${timestamp}] Query executed - affectedRows: ${result.affectedRows}`);

    if (result.affectedRows === 1) {
      console.log(`[USAGE ${timestamp}] ✅ Created new record for "${app_name}": ${usage_minutes} minutes`);
    } else if (result.affectedRows === 2) {
      console.log(`[USAGE ${timestamp}] ✅ Updated existing record for "${app_name}": ${usage_minutes} minutes`);
    }

    // Verify the save by reading back
    const [verify] = await pool.execute(
      'SELECT usage_minutes FROM app_usage WHERE teenager_id = ? AND app_name = ? AND usage_date = ?',
      [req.user.userId, app_name, today]
    );
    
    if (verify.length > 0) {
      console.log(`[USAGE ${timestamp}] ✅ Verified: "${app_name}" now has ${verify[0].usage_minutes} minutes in DB`);
    }

    res.json({ 
      message: 'Usage tracked successfully',
      saved_minutes: verify.length > 0 ? verify[0].usage_minutes : usage_minutes
    });
  } catch (error) {
    console.error('Track app usage error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get app usage for teenager
router.get('/app', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can view their usage' });
    }

    const { days = 7 } = req.query;
    const daysInt = parseInt(days);
    const today = getLocalDate(); // Use the same date format as when saving
    
    let query, params;
    
    if (daysInt === 0) {
      // Get only today's data - exact match
      console.log(`[USAGE] Fetching TODAY ONLY usage for teenager ${req.user.userId} on ${today}`);
      query = `SELECT app_name, usage_date, usage_minutes 
               FROM app_usage 
               WHERE teenager_id = ? AND usage_date = ?
               ORDER BY app_name`;
      params = [req.user.userId, today];
    } else {
      // Get data from (today - days) onwards
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - daysInt);
      const startDateStr = startDate.toISOString().split('T')[0];
      
      console.log(`[USAGE] Fetching usage for teenager ${req.user.userId} from ${startDateStr} to ${today} (${days} days)`);
      query = `SELECT app_name, usage_date, usage_minutes 
               FROM app_usage 
               WHERE teenager_id = ? AND usage_date >= ?
               ORDER BY usage_date DESC, app_name`;
      params = [req.user.userId, startDateStr];
    }

    const [usage] = await pool.execute(query, params);

    console.log(`[USAGE] Found ${usage.length} usage records:`, usage.map(u => `${u.app_name}: ${u.usage_minutes}min on ${u.usage_date}`));
    res.json({ usage });
  } catch (error) {
    console.error('Get app usage error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get usage report for parent (all teenagers)
router.get('/report', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can view reports' });
    }

    const { teenager_id, days = 7 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    let query = `
      SELECT 
        au.app_name,
        au.usage_date,
        au.usage_minutes,
        al.daily_limit_minutes,
        u.name as teenager_name,
        u.id as teenager_id
      FROM app_usage au
      JOIN users u ON au.teenager_id = u.id
      LEFT JOIN app_limits al ON au.teenager_id = al.teenager_id AND au.app_name = al.app_name
      WHERE u.role = 'teenager' AND au.usage_date >= ?
    `;
    let params = [startDate.toISOString().split('T')[0]];

    if (teenager_id) {
      query += ' AND au.teenager_id = ?';
      params.push(teenager_id);
    }

    query += ' ORDER BY au.usage_date DESC, au.app_name';

    const [usage] = await pool.execute(query, params);

    // Get summary statistics
    const [summary] = await pool.execute(
      `SELECT 
        au.app_name,
        SUM(au.usage_minutes) as total_minutes,
        AVG(au.usage_minutes) as avg_minutes,
        COUNT(DISTINCT au.usage_date) as days_used,
        u.name as teenager_name
      FROM app_usage au
      JOIN users u ON au.teenager_id = u.id
      WHERE u.role = 'teenager' AND au.usage_date >= ?
      ${teenager_id ? 'AND au.teenager_id = ?' : ''}
      GROUP BY au.app_name, u.id, u.name
      ORDER BY total_minutes DESC`,
      teenager_id ? [startDate.toISOString().split('T')[0], teenager_id] : [startDate.toISOString().split('T')[0]]
    );

    // Get total screen time
    const [totalScreenTime] = await pool.execute(
      `SELECT SUM(au.usage_minutes) as total_screen_time
       FROM app_usage au
       JOIN users u ON au.teenager_id = u.id
       WHERE u.role = 'teenager' AND au.usage_date >= ?
       ${teenager_id ? 'AND au.teenager_id = ?' : ''}`,
      teenager_id ? [startDate.toISOString().split('T')[0], teenager_id] : [startDate.toISOString().split('T')[0]]
    );

    // Get tasks statistics
    const [tasksStats] = await pool.execute(
      `SELECT 
        COUNT(*) as total_tasks,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_tasks
       FROM tasks
       WHERE parent_id = ?
       ${teenager_id ? 'AND teenager_id = ?' : ''}`,
      teenager_id ? [req.user.userId, teenager_id] : [req.user.userId]
    );

    // Get category-wise time comparison (using custom_apps for categories)
    const [categoryTime] = await pool.execute(
      `SELECT 
        COALESCE(ca.category, 'Other') as category,
        SUM(au.usage_minutes) as total_minutes,
        COUNT(DISTINCT au.app_name) as app_count
       FROM app_usage au
       JOIN users u ON au.teenager_id = u.id
       LEFT JOIN custom_apps ca ON au.app_name = ca.app_name AND au.teenager_id = ca.teenager_id
       WHERE u.role = 'teenager' AND au.usage_date >= ?
       ${teenager_id ? 'AND au.teenager_id = ?' : ''}
       GROUP BY COALESCE(ca.category, 'Other')
       ORDER BY total_minutes DESC`,
      teenager_id ? [startDate.toISOString().split('T')[0], teenager_id] : [startDate.toISOString().split('T')[0]]
    );

    // Get blocked sites
    const [blockedSites] = await pool.execute(
      `SELECT 
        bs.id,
        bs.site_url,
        bs.created_at,
        u.name as teenager_name,
        u.id as teenager_id
       FROM blocked_sites bs
       JOIN users u ON bs.teenager_id = u.id
       WHERE bs.parent_id = ?
       ${teenager_id ? 'AND bs.teenager_id = ?' : ''}
       ORDER BY bs.created_at DESC`,
      teenager_id ? [req.user.userId, teenager_id] : [req.user.userId]
    );

    res.json({ 
      usage, 
      summary,
      totalScreenTime: totalScreenTime[0]?.total_screen_time || 0,
      tasksStats: tasksStats[0] || { total_tasks: 0, completed_tasks: 0, in_progress_tasks: 0, pending_tasks: 0 },
      categoryTime,
      blockedSites
    });
  } catch (error) {
    console.error('Get usage report error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get teenager's own report
router.get('/my-report', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can view their report' });
    }

    const { days = 7 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));
    const requestTime = new Date().toISOString();

    console.log(`[MY-REPORT ${requestTime}] Teen ${req.user.userId} requesting report for ${days} days`);

    // Get daily usage
    const [dailyUsage] = await pool.execute(
      `SELECT 
        app_name,
        usage_date,
        usage_minutes
      FROM app_usage
      WHERE teenager_id = ? AND usage_date >= ?
      ORDER BY usage_date DESC`,
      [req.user.userId, startDate.toISOString().split('T')[0]]
    );

    // Get summary by app
    const [summary] = await pool.execute(
      `SELECT 
        au.app_name,
        SUM(au.usage_minutes) as total_minutes,
        AVG(au.usage_minutes) as avg_minutes,
        COUNT(DISTINCT au.usage_date) as days_used,
        al.daily_limit_minutes
      FROM app_usage au
      LEFT JOIN app_limits al ON au.teenager_id = al.teenager_id AND au.app_name = al.app_name
      WHERE au.teenager_id = ? AND au.usage_date >= ?
      GROUP BY au.app_name, al.daily_limit_minutes
      ORDER BY total_minutes DESC`,
      [req.user.userId, startDate.toISOString().split('T')[0]]
    );

    // Get today's usage with explicit date
    const today = getLocalDate();
    console.log(`\n========================================`);
    console.log(`[MY-REPORT ${requestTime}] QUERYING FOR TODAY'S USAGE`);
    console.log(`Server time: ${new Date().toISOString()}`);
    console.log(`Today's date (for query): ${today}`);
    console.log(`User ID: ${req.user.userId}`);
    console.log(`========================================\n`);
    
    // First, check ALL usage data for this user
    const [allUsage] = await pool.execute(
      `SELECT app_name, usage_date, usage_minutes, created_at, updated_at 
       FROM app_usage 
       WHERE teenager_id = ? 
       ORDER BY usage_date DESC, updated_at DESC 
       LIMIT 10`,
      [req.user.userId]
    );
    console.log(`[MY-REPORT] ALL recent usage records (${allUsage.length}):`, 
      allUsage.map(u => `  ${u.app_name}: ${u.usage_minutes}min on ${u.usage_date} (created: ${u.created_at})`).join('\n'));
    
    // Now get today's usage
    const [todayUsage] = await pool.execute(
      `SELECT 
        au.app_name,
        au.usage_minutes,
        au.usage_date,
        al.daily_limit_minutes,
        au.updated_at
      FROM app_usage au
      LEFT JOIN app_limits al ON au.teenager_id = al.teenager_id AND au.app_name = al.app_name
      WHERE au.teenager_id = ? AND au.usage_date = ?`,
      [req.user.userId, today]
    );

    console.log(`\n[MY-REPORT] TODAY's usage (${todayUsage.length} records matching date ${today}):`);
    if (todayUsage.length === 0) {
      console.log(`  ⚠️ NO RECORDS FOUND FOR TODAY!`);
      console.log(`  This means either:`);
      console.log(`    1. No usage has been recorded today`);
      console.log(`    2. The usage_date in database doesn't match today's date`);
    } else {
      todayUsage.forEach(u => {
        console.log(`  ✅ ${u.app_name}: ${u.usage_minutes}min (date in DB: ${u.usage_date}, updated: ${u.updated_at})`);
      });
    }

    // Get tasks statistics for this teenager
    const [tasksStats] = await pool.execute(
      `SELECT 
        COUNT(*) as total_tasks,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_tasks
       FROM tasks
       WHERE teenager_id = ?`,
      [req.user.userId]
    );

    // Get blocked sites for this teenager
    const [blockedSites] = await pool.execute(
      `SELECT 
        bs.id,
        bs.site_url,
        bs.created_at
       FROM blocked_sites bs
       WHERE bs.teenager_id = ?
       ORDER BY bs.created_at DESC`,
      [req.user.userId]
    );

    // Set cache control headers to prevent caching
    res.set({
      'Cache-Control': 'no-store, no-cache, must-revalidate, private',
      'Pragma': 'no-cache',
      'Expires': '0'
    });

    res.json({ 
      dailyUsage, 
      summary, 
      todayUsage,
      tasksStats: tasksStats[0] || { total_tasks: 0, completed_tasks: 0, in_progress_tasks: 0, pending_tasks: 0 },
      blockedSites
    });
  } catch (error) {
    console.error('Get my report error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});


module.exports = router;

