-- ============================================
-- Fix Existing Teenager Accounts
-- ============================================
-- This script helps link existing teenager accounts to their parents
-- Run this if you have teenagers without parent_id

USE parent_teen_db;

-- View all users and their parent associations
SELECT 
  id,
  name,
  email,
  role,
  parent_id,
  CASE 
    WHEN role = 'teenager' AND parent_id IS NULL THEN '⚠️ NEEDS PARENT'
    WHEN role = 'teenager' AND parent_id IS NOT NULL THEN '✅ HAS PARENT'
    WHEN role = 'parent' THEN '👤 PARENT'
  END as status
FROM users
ORDER BY role, id;

-- ============================================
-- OPTION 1: Link specific teenager to parent
-- ============================================
-- Replace the IDs with actual values from your database

-- Example: Link teenager with ID 2 to parent with ID 1
-- UPDATE users SET parent_id = 1 WHERE id = 2 AND role = 'teenager';

-- ============================================
-- OPTION 2: Interactive linking (run one at a time)
-- ============================================

-- Step 1: View all parents
SELECT id, name, email FROM users WHERE role = 'parent';

-- Step 2: View all teenagers without parents
SELECT id, name, email FROM users WHERE role = 'teenager' AND parent_id IS NULL;

-- Step 3: Link teenager to parent (replace IDs)
-- UPDATE users 
-- SET parent_id = <PARENT_ID> 
-- WHERE id = <TEENAGER_ID> AND role = 'teenager';

-- ============================================
-- OPTION 3: Auto-link if only one parent exists
-- ============================================
-- WARNING: Only use this if you have exactly ONE parent and want to link ALL teenagers to them

-- Check how many parents exist
SELECT COUNT(*) as parent_count FROM users WHERE role = 'parent';

-- If only 1 parent exists, uncomment and run this:
-- UPDATE users 
-- SET parent_id = (SELECT id FROM users WHERE role = 'parent' LIMIT 1)
-- WHERE role = 'teenager' AND parent_id IS NULL;

-- ============================================
-- VERIFICATION
-- ============================================
-- After updating, verify all teenagers have parents

SELECT 
  t.id as teenager_id,
  t.name as teenager_name,
  t.email as teenager_email,
  p.id as parent_id,
  p.name as parent_name,
  p.email as parent_email
FROM users t
LEFT JOIN users p ON t.parent_id = p.id
WHERE t.role = 'teenager'
ORDER BY t.id;

-- Check for any teenagers still without parents
SELECT 
  id,
  name,
  email,
  '⚠️ NO PARENT ASSIGNED' as warning
FROM users 
WHERE role = 'teenager' AND parent_id IS NULL;

-- ============================================
-- EXAMPLE USAGE
-- ============================================

-- Scenario: You have these users:
-- Parent: ID=1, Name="John Parent", Email="parent@test.com"
-- Teenager: ID=2, Name="Jane Teen", Email="teen@test.com"

-- To link them:
-- UPDATE users SET parent_id = 1 WHERE id = 2 AND role = 'teenager';

-- Verify:
-- SELECT * FROM users WHERE id = 2;
-- Should show: parent_id = 1
