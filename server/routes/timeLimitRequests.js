const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Create a time limit increase request (teenager only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can create requests' });
    }

    const { app_name, requested_limit, reason } = req.body;

    if (!app_name || !requested_limit) {
      return res.status(400).json({ error: 'App name and requested limit are required' });
    }

    // Get parent_id and current limit
    const [teenager] = await pool.execute(
      'SELECT parent_id FROM users WHERE id = ?',
      [req.user.userId]
    );

    if (teenager.length === 0 || !teenager[0].parent_id) {
      return res.status(400).json({ error: 'No parent associated with this account' });
    }

    const parent_id = teenager[0].parent_id;

    // Get current limit
    const [limits] = await pool.execute(
      'SELECT daily_limit_minutes FROM app_limits WHERE teenager_id = ? AND app_name = ?',
      [req.user.userId, app_name]
    );

    const current_limit = limits.length > 0 ? limits[0].daily_limit_minutes : 0;

    // Check if there's already a pending request for this app
    const [existingRequests] = await pool.execute(
      'SELECT id FROM time_limit_requests WHERE teenager_id = ? AND app_name = ? AND status = ?',
      [req.user.userId, app_name, 'pending']
    );

    if (existingRequests.length > 0) {
      return res.status(400).json({ error: 'You already have a pending request for this app' });
    }

    // Create the request
    await pool.execute(
      `INSERT INTO time_limit_requests 
       (teenager_id, parent_id, app_name, current_limit, requested_limit, reason, status) 
       VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
      [req.user.userId, parent_id, app_name, current_limit, requested_limit, reason || null]
    );

    console.log(`[REQUEST] Teenager ${req.user.userId} requested ${requested_limit} minutes for ${app_name}`);
    res.json({ message: 'Request sent to parent successfully' });
  } catch (error) {
    console.error('Create time limit request error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all requests for a teenager
router.get('/my-requests', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can view their requests' });
    }

    const [requests] = await pool.execute(
      `SELECT 
        id, app_name, current_limit, requested_limit, reason, status, created_at, updated_at
       FROM time_limit_requests
       WHERE teenager_id = ?
       ORDER BY created_at DESC`,
      [req.user.userId]
    );

    res.json({ requests });
  } catch (error) {
    console.error('Get teenager requests error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all pending requests for a parent
router.get('/parent-requests', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can view requests' });
    }

    const { status = 'pending' } = req.query;

    let query = `
      SELECT 
        tlr.id,
        tlr.app_name,
        tlr.current_limit,
        tlr.requested_limit,
        tlr.reason,
        tlr.status,
        tlr.created_at,
        tlr.updated_at,
        u.name as teenager_name,
        u.id as teenager_id
      FROM time_limit_requests tlr
      JOIN users u ON tlr.teenager_id = u.id
      WHERE tlr.parent_id = ?
    `;

    const params = [req.user.userId];

    if (status && status !== 'all') {
      query += ' AND tlr.status = ?';
      params.push(status);
    }

    query += ' ORDER BY tlr.created_at DESC';

    const [requests] = await pool.execute(query, params);

    res.json({ requests });
  } catch (error) {
    console.error('Get parent requests error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Approve or reject a request (parent only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can approve/reject requests' });
    }

    const { id } = req.params;
    const { status } = req.body;

    if (!status || !['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'Status must be either approved or rejected' });
    }

    // Get the request
    const [requests] = await pool.execute(
      'SELECT * FROM time_limit_requests WHERE id = ? AND parent_id = ?',
      [id, req.user.userId]
    );

    if (requests.length === 0) {
      return res.status(404).json({ error: 'Request not found' });
    }

    const request = requests[0];

    if (request.status !== 'pending') {
      return res.status(400).json({ error: 'This request has already been processed' });
    }

    // Update request status
    await pool.execute(
      'UPDATE time_limit_requests SET status = ?, updated_at = NOW() WHERE id = ?',
      [status, id]
    );

    // If approved, update the app limit
    if (status === 'approved') {
      // Check if limit exists
      const [existingLimits] = await pool.execute(
        'SELECT id FROM app_limits WHERE teenager_id = ? AND app_name = ?',
        [request.teenager_id, request.app_name]
      );

      if (existingLimits.length > 0) {
        // Update existing limit
        await pool.execute(
          'UPDATE app_limits SET daily_limit_minutes = ? WHERE id = ?',
          [request.requested_limit, existingLimits[0].id]
        );
      } else {
        // Create new limit
        await pool.execute(
          'INSERT INTO app_limits (parent_id, teenager_id, app_name, daily_limit_minutes) VALUES (?, ?, ?, ?)',
          [req.user.userId, request.teenager_id, request.app_name, request.requested_limit]
        );
      }

      console.log(`[REQUEST] Parent approved: ${request.app_name} limit increased to ${request.requested_limit} minutes`);
    } else {
      console.log(`[REQUEST] Parent rejected: ${request.app_name} limit increase request`);
    }

    res.json({ message: `Request ${status} successfully` });
  } catch (error) {
    console.error('Update request error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete a request (teenager can delete their own pending requests)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (req.user.role === 'teenager') {
      // Teenager can only delete their own pending requests
      const [result] = await pool.execute(
        'DELETE FROM time_limit_requests WHERE id = ? AND teenager_id = ? AND status = ?',
        [id, req.user.userId, 'pending']
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Request not found or cannot be deleted' });
      }
    } else if (req.user.role === 'parent') {
      // Parent can delete any request
      const [result] = await pool.execute(
        'DELETE FROM time_limit_requests WHERE id = ? AND parent_id = ?',
        [id, req.user.userId]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Request not found' });
      }
    } else {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    res.json({ message: 'Request deleted successfully' });
  } catch (error) {
    console.error('Delete request error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
