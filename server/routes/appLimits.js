const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const predefinedApps = require('../utils/predefinedApps');

const router = express.Router();

// Get predefined apps
router.get('/predefined', authenticateToken, async (req, res) => {
  try {
    res.json({ apps: predefinedApps });
  } catch (error) {
    console.error('Get predefined apps error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get app limits
router.get('/', authenticateToken, async (req, res) => {
  try {
    let limits;
    
    if (req.user.role === 'parent') {
      [limits] = await pool.execute(`
        SELECT al.*, u.name as teenager_name
        FROM app_limits al
        JOIN users u ON al.teenager_id = u.id
        WHERE al.parent_id = ?
        ORDER BY al.created_at DESC
      `, [req.user.userId]);
    } else {
      [limits] = await pool.execute(`
        SELECT * FROM app_limits
        WHERE teenager_id = ?
        ORDER BY created_at DESC
      `, [req.user.userId]);
    }

    res.json({ limits });
  } catch (error) {
    console.error('Get app limits error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create/Update app limit (parent only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can set app limits' });
    }

    const { teenager_id, app_name, daily_limit_minutes } = req.body;

    if (!teenager_id || !app_name || !daily_limit_minutes) {
      return res.status(400).json({ error: 'Teenager ID, app name, and daily limit are required' });
    }

    // Check if limit already exists
    const [existing] = await pool.execute(
      'SELECT * FROM app_limits WHERE teenager_id = ? AND app_name = ?',
      [teenager_id, app_name]
    );

    if (existing.length > 0) {
      // Update existing limit
      await pool.execute(
        'UPDATE app_limits SET daily_limit_minutes = ? WHERE id = ?',
        [daily_limit_minutes, existing[0].id]
      );
      res.json({ message: 'App limit updated successfully' });
    } else {
      // Create new limit
      const [result] = await pool.execute(
        `INSERT INTO app_limits (parent_id, teenager_id, app_name, daily_limit_minutes)
         VALUES (?, ?, ?, ?)`,
        [req.user.userId, teenager_id, app_name, daily_limit_minutes]
      );
      res.status(201).json({ message: 'App limit created successfully' });
    }
  } catch (error) {
    console.error('Create app limit error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete app limit (parent only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can delete app limits' });
    }

    const { id } = req.params;

    const [limits] = await pool.execute(
      'SELECT * FROM app_limits WHERE id = ? AND parent_id = ?',
      [id, req.user.userId]
    );

    if (limits.length === 0) {
      return res.status(404).json({ error: 'App limit not found' });
    }

    await pool.execute('DELETE FROM app_limits WHERE id = ?', [id]);

    res.json({ message: 'App limit deleted successfully' });
  } catch (error) {
    console.error('Delete app limit error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

