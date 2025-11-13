const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get time requests
router.get('/', authenticateToken, async (req, res) => {
  try {
    let requests;
    
    if (req.user.role === 'parent') {
      [requests] = await pool.execute(`
        SELECT tr.*, t.title as task_title, u.name as teenager_name
        FROM time_requests tr
        JOIN tasks t ON tr.task_id = t.id
        JOIN users u ON tr.teenager_id = u.id
        WHERE t.parent_id = ?
        ORDER BY tr.created_at DESC
      `, [req.user.userId]);
    } else {
      [requests] = await pool.execute(`
        SELECT tr.*, t.title as task_title
        FROM time_requests tr
        JOIN tasks t ON tr.task_id = t.id
        WHERE tr.teenager_id = ?
        ORDER BY tr.created_at DESC
      `, [req.user.userId]);
    }

    res.json({ requests });
  } catch (error) {
    console.error('Get time requests error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create time request (teenager only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'teenager') {
      return res.status(403).json({ error: 'Only teenagers can request time extensions' });
    }

    const { task_id, additional_time, reason } = req.body;

    if (!task_id || !additional_time) {
      return res.status(400).json({ error: 'Task ID and additional time are required' });
    }

    // Check if task exists and belongs to teenager
    const [tasks] = await pool.execute(
      'SELECT * FROM tasks WHERE id = ? AND teenager_id = ?',
      [task_id, req.user.userId]
    );

    if (tasks.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    // Check if there's already a pending request
    const [existing] = await pool.execute(
      'SELECT * FROM time_requests WHERE task_id = ? AND status = "pending"',
      [task_id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'A pending request already exists for this task' });
    }

    const [result] = await pool.execute(
      `INSERT INTO time_requests (task_id, teenager_id, additional_time, reason, status)
       VALUES (?, ?, ?, ?, 'pending')`,
      [task_id, req.user.userId, additional_time, reason || null]
    );

    const [newRequest] = await pool.execute(
      'SELECT * FROM time_requests WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({ message: 'Time request created successfully', request: newRequest[0] });
  } catch (error) {
    console.error('Create time request error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Approve/Reject time request (parent only)
router.patch('/:id/status', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can approve/reject requests' });
    }

    const { id } = req.params;
    const { status } = req.body;

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    // Check if request exists and belongs to parent's task
    const [requests] = await pool.execute(`
      SELECT tr.*, t.parent_id
      FROM time_requests tr
      JOIN tasks t ON tr.task_id = t.id
      WHERE tr.id = ?
    `, [id]);

    if (requests.length === 0) {
      return res.status(404).json({ error: 'Request not found' });
    }

    const request = requests[0];

    if (request.parent_id !== req.user.userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    await pool.execute(
      'UPDATE time_requests SET status = ? WHERE id = ?',
      [status, id]
    );

    // If approved, update task due date
    if (status === 'approved') {
      await pool.execute(`
        UPDATE tasks
        SET due_date = DATE_ADD(due_date, INTERVAL ? MINUTE)
        WHERE id = ?
      `, [request.additional_time, request.task_id]);
    }

    res.json({ message: `Time request ${status} successfully` });
  } catch (error) {
    console.error('Update time request error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

