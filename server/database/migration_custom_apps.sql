-- Migration to add custom_apps table
USE teen_db;

-- Custom apps table (apps added by teenagers)
CREATE TABLE IF NOT EXISTS custom_apps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  icon VARCHAR(50) DEFAULT '📱',
  category VARCHAR(100) DEFAULT 'Other',
  url VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_teen_app (teenager_id, app_name)
);
