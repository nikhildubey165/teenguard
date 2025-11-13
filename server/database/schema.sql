-- Create database
CREATE DATABASE IF NOT EXISTS parent_teen_db;
USE parent_teen_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('parent', 'teenager') NOT NULL,
  parent_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Parents table
CREATE TABLE IF NOT EXISTS parents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Teenagers table
CREATE TABLE IF NOT EXISTS teenagers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  teenager_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  due_date DATETIME NOT NULL,
  estimated_time INT,
  status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Time requests table
CREATE TABLE IF NOT EXISTS time_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  teenager_id INT NOT NULL,
  additional_time INT NOT NULL,
  reason TEXT,
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE
);

-- App limits table
CREATE TABLE IF NOT EXISTS app_limits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  daily_limit_minutes INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_app_limit (teenager_id, app_name)
);

-- Blocked sites table
CREATE TABLE IF NOT EXISTS blocked_sites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  teenager_id INT NOT NULL,
  site_url VARCHAR(500) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE
);

-- App usage tracking table
CREATE TABLE IF NOT EXISTS app_usage (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  usage_minutes INT NOT NULL DEFAULT 0,
  usage_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_daily_usage (teenager_id, app_name, usage_date)
);

-- Website usage tracking table
CREATE TABLE IF NOT EXISTS website_usage (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  site_url VARCHAR(500) NOT NULL,
  visit_count INT NOT NULL DEFAULT 0,
  usage_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_daily_website_usage (teenager_id, site_url, usage_date)
);

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

-- Time limit increase requests table
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

-- Hidden apps table (predefined apps hidden by teenagers)
CREATE TABLE IF NOT EXISTS hidden_apps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teenager_id INT NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teenager_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_hidden_app (teenager_id, app_name)
);

