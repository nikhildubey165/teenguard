-- Migration: Add time_limit_requests table
-- Date: 2025-11-09
-- Description: Allow teenagers to request time limit increases from parents

CREATE TABLE IF NOT EXISTS time_limit_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  parent_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  current_limit INT NOT NULL,
  requested_limit INT NOT NULL,
  reason TEXT,
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE
);
