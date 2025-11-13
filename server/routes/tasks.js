const express = require('express');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all tasks (parent sees all, teenager sees only their tasks)
router.get('/', authenticateToken, async (req, res) => {
  try {
    let tasks;
    
    if (req.user.role === 'parent') {
      [tasks] = await pool.execute(`
        SELECT t.*, u.name as teenager_name, u.email as teenager_email
        FROM tasks t
        LEFT JOIN users u ON t.teenager_id = u.id
        ORDER BY t.created_at DESC
      `);
    } else {
      [tasks] = await pool.execute(`
        SELECT t.*, u.name as parent_name
        FROM tasks t
        LEFT JOIN users u ON t.parent_id = u.id
        WHERE t.teenager_id = ?
        ORDER BY t.created_at DESC
      `, [req.user.userId]);
    }

    res.json({ tasks });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create task (parent only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can create tasks' });
    }

    const { teenager_id, title, description, due_date, estimated_time } = req.body;

    if (!teenager_id || !title || !due_date) {
      return res.status(400).json({ error: 'Teenager ID, title, and due date are required' });
    }

    const [result] = await pool.execute(
      `INSERT INTO tasks (parent_id, teenager_id, title, description, due_date, estimated_time, status)
       VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
      [req.user.userId, teenager_id, title, description, due_date, estimated_time || null]
    );

    const [newTask] = await pool.execute(
      'SELECT * FROM tasks WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({ message: 'Task created successfully', task: newTask[0] });
  } catch (error) {
    console.error('Create task error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update task status (teenager can mark as completed)
router.patch('/:id/status', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['pending', 'in_progress', 'completed'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    // Check if task exists and user has permission
    const [tasks] = await pool.execute(
      'SELECT * FROM tasks WHERE id = ?',
      [id]
    );

    if (tasks.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const task = tasks[0];

    if (req.user.role === 'teenager' && task.teenager_id !== req.user.userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    if (req.user.role === 'parent' && task.parent_id !== req.user.userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    await pool.execute(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id]
    );

    res.json({ message: 'Task status updated successfully' });
  } catch (error) {
    console.error('Update task error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get teenagers list (for parent to assign tasks)
router.get('/teenagers', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'parent') {
      return res.status(403).json({ error: 'Only parents can view teenagers' });
    }

    const [teenagers] = await pool.execute(`
      SELECT u.id, u.name, u.email
      FROM users u
      WHERE u.role = 'teenager'
    `);

    res.json({ teenagers });
  } catch (error) {
    console.error('Get teenagers error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

