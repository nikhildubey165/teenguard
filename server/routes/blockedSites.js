const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get blocked sites
router.get('/', authenticateToken, async (req, res) => {
  try {
    let sites;
    
    if (req.user.role === 'parent') {
      [sites] = await pool.execute(`
        SELECT bs.*, u.name as teenager_name
        FROM blocked_sites bs
        JOIN users u ON bs.teenager_id = u.id
        WHERE bs.parent_id = ?
        ORDER BY bs.created_at DESC
      `, [req.user.userId]);
    } else {
      [sites] = await pool.execute(`
        SELECT * FROM blocked_sites
        WHERE teenager_id = ?
        ORDER BY created_at DESC
      `, [req.user.userId]);
    }

    res.json({ sites });
  } catch (error) {
    console.error('Get blocked sites error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create blocked site (parent only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can block sites' });
    }

    const { teenager_id, site_url } = req.body;

    if (!teenager_id || !site_url) {
      return res.status(400).json({ error: 'Teenager ID and site URL are required' });
    }

    // Check if site already blocked
    const [existing] = await pool.execute(
      'SELECT * FROM blocked_sites WHERE teenager_id = ? AND site_url = ?',
      [teenager_id, site_url]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Site is already blocked' });
    }

    const [result] = await pool.execute(
      `INSERT INTO blocked_sites (parent_id, teenager_id, site_url)
       VALUES (?, ?, ?)`,
      [req.user.userId, teenager_id, site_url]
    );

    res.status(201).json({ message: 'Site blocked successfully' });
  } catch (error) {
    console.error('Create blocked site error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete blocked site (parent only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can unblock sites' });
    }

    const { id } = req.params;

    const [sites] = await pool.execute(
      'SELECT * FROM blocked_sites WHERE id = ? AND parent_id = ?',
      [id, req.user.userId]
    );

    if (sites.length === 0) {
      return res.status(404).json({ error: 'Blocked site not found' });
    }

    await pool.execute('DELETE FROM blocked_sites WHERE id = ?', [id]);

    res.json({ message: 'Site unblocked successfully' });
  } catch (error) {
    console.error('Delete blocked site error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

