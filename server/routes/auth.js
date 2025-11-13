const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role, parent_id } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    if (!['parent', 'teenager'].includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }

    // If teenager, parent_id is required
    if (role === 'teenager' && !parent_id) {
      return res.status(400).json({ error: 'Parent ID is required for teenager accounts' });
    }

    // Check if user exists
    const [existing] = await pool.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user with parent_id if teenager
    let result;
    if (role === 'teenager') {
      [result] = await pool.execute(
        'INSERT INTO users (name, email, password, role, parent_id) VALUES (?, ?, ?, ?, ?)',
        [name, email, hashedPassword, role, parent_id]
      );
    } else {
      [result] = await pool.execute(
        'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
        [name, email, hashedPassword, role]
      );
    }

    const userId = result.insertId;

    // If parent, create parent record
    if (role === 'parent') {
      await pool.execute(
        'INSERT INTO parents (user_id) VALUES (?)',
        [userId]
      );
    }

    // If teenager, create teenager record
    if (role === 'teenager') {
      await pool.execute(
        'INSERT INTO teenagers (user_id) VALUES (?)',
        [userId]
      );
    }

    const token = jwt.sign(
      { userId, email, role },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: { id: userId, name, email, role }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const [users] = await pool.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: { id: user.id, name: user.name, email: user.email, role: user.role }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get current user
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT id, name, email, role FROM users WHERE id = ?',
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: users[0] });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all parents (for teenager registration)
router.get('/parents', async (req, res) => {
  try {
    const [parents] = await pool.execute(
      'SELECT id, name, email FROM users WHERE role = ?',
      ['parent']
    );

    res.json({ parents });
  } catch (error) {
    console.error('Get parents error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

