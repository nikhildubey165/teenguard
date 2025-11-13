const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all custom apps from all teenagers (parent only)
router.get('/all', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can view all custom apps' });
    }

    // Get all custom apps from all teenagers
    const [customApps] = await pool.execute(
      `SELECT ca.*, u.name as teenager_name 
       FROM custom_apps ca
       JOIN users u ON ca.teenager_id = u.id
       WHERE u.role = 'teenager'
       ORDER BY ca.created_at DESC`
    );

    res.json({ apps: customApps });
  } catch (error) {
    console.error('Get all custom apps error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get custom apps for a specific teenager (parent only)
router.get('/teenager/:teenagerId', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can view teenager apps' });
    }

    const { teenagerId } = req.params;

    // Verify the teenager exists
    const [teenager] = await pool.execute(
      'SELECT * FROM users WHERE id = ? AND role = ?',
      [teenagerId, 'teenager']
    );

    if (teenager.length === 0) {
      return res.status(404).json({ error: 'Teenager not found' });
    }

    // Get custom apps for this teenager
    const [customApps] = await pool.execute(
      'SELECT * FROM custom_apps WHERE teenager_id = ? ORDER BY created_at DESC',
      [teenagerId]
    );

    res.json({ apps: customApps });
  } catch (error) {
    console.error('Get teenager apps error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get custom apps for a teenager
router.get('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can view custom apps' });
    }

    const [customApps] = await pool.execute(
      'SELECT * FROM custom_apps WHERE teenager_id = ? ORDER BY created_at DESC',
      [req.user.userId]
    );

    res.json({ apps: customApps });
  } catch (error) {
    console.error('Get custom apps error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Add a custom app (teenager only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can add custom apps' });
    }

    const { app_name, icon, category, url } = req.body;

    if (!app_name || !url) {
      return res.status(400).json({ error: 'App name and URL are required' });
    }

    // Validate URL format
    try {
      new URL(url);
    } catch (e) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    // Check if app already exists for this teenager
    const [existing] = await pool.execute(
      'SELECT * FROM custom_apps WHERE teenager_id = ? AND app_name = ?',
      [req.user.userId, app_name]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'App with this name already exists' });
    }

    const [result] = await pool.execute(
      `INSERT INTO custom_apps (teenager_id, app_name, icon, category, url)
       VALUES (?, ?, ?, ?, ?)`,
      [req.user.userId, app_name, icon || '📱', category || 'Other', url]
    );

    res.status(201).json({ 
      message: 'Custom app added successfully',
      app: {
        id: result.insertId,
        app_name,
        icon: icon || '📱',
        category: category || 'Other',
        url
      }
    });
  } catch (error) {
    console.error('Add custom app error:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'App with this name already exists' });
    }
    res.status(500).json({ error: 'Server error' });
  }
});

// Update a custom app (teenager only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can update custom apps' });
    }

    const { id } = req.params;
    const { app_name, icon, category, url } = req.body;

    if (!app_name || !url) {
      return res.status(400).json({ error: 'App name and URL are required' });
    }

    // Validate URL format
    try {
      new URL(url);
    } catch (e) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    // Check if the app belongs to this teenager
    const [apps] = await pool.execute(
      'SELECT * FROM custom_apps WHERE id = ? AND teenager_id = ?',
      [id, req.user.userId]
    );

    if (apps.length === 0) {
      return res.status(404).json({ error: 'Custom app not found' });
    }

    // Check if new app name conflicts with another app (excluding current one)
    const [existing] = await pool.execute(
      'SELECT * FROM custom_apps WHERE teenager_id = ? AND app_name = ? AND id != ?',
      [req.user.userId, app_name, id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'App with this name already exists' });
    }

    await pool.execute(
      'UPDATE custom_apps SET app_name = ?, icon = ?, category = ?, url = ? WHERE id = ?',
      [app_name, icon || '📱', category || 'Other', url, id]
    );

    res.json({ 
      message: 'Custom app updated successfully',
      app: {
        id,
        app_name,
        icon: icon || '📱',
        category: category || 'Other',
        url
      }
    });
  } catch (error) {
    console.error('Update custom app error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete a custom app (teenager only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can delete custom apps' });
    }

    const { id } = req.params;

    // Check if the app belongs to this teenager
    const [apps] = await pool.execute(
      'SELECT * FROM custom_apps WHERE id = ? AND teenager_id = ?',
      [id, req.user.userId]
    );

    if (apps.length === 0) {
      return res.status(404).json({ error: 'Custom app not found' });
    }

    await pool.execute('DELETE FROM custom_apps WHERE id = ?', [id]);

    res.json({ message: 'Custom app deleted successfully' });
  } catch (error) {
    console.error('Delete custom app error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get hidden apps for teenager
router.get('/hidden', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can view hidden apps' });
    }

    const [hiddenApps] = await pool.execute(
      'SELECT app_name FROM hidden_apps WHERE teenager_id = ?',
      [req.user.userId]
    );

    res.json({ hiddenApps: hiddenApps.map(row => row.app_name) });
  } catch (error) {
    console.error('Get hidden apps error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Hide a predefined app (teenager only)
router.post('/hide', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can hide apps' });
    }

    const { app_name } = req.body;

    if (!app_name) {
      return res.status(400).json({ error: 'App name is required' });
    }

    // Check if already hidden
    const [existing] = await pool.execute(
      'SELECT * FROM hidden_apps WHERE teenager_id = ? AND app_name = ?',
      [req.user.userId, app_name]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'App is already hidden' });
    }

    await pool.execute(
      'INSERT INTO hidden_apps (teenager_id, app_name) VALUES (?, ?)',
      [req.user.userId, app_name]
    );

    res.json({ message: 'App hidden successfully' });
  } catch (error) {
    console.error('Hide app error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Unhide/show a predefined app (teenager only)
router.delete('/hide/:appName', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can unhide apps' });
    }

    const { appName } = req.params;

    await pool.execute(
      'DELETE FROM hidden_apps WHERE teenager_id = ? AND app_name = ?',
      [req.user.userId, appName]
    );

    res.json({ message: 'App shown successfully' });
  } catch (error) {
    console.error('Unhide app error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
