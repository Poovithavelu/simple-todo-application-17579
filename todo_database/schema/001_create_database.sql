-- PUBLIC_INTERFACE
-- This migration ensures the target database exists.
-- It creates the database 'myapp' if it does not already exist and sets a sane default charset/collation.

-- Note: The actual database name can be controlled by environment variables in runtime scripts.
-- This script uses 'myapp' to match the container's default configuration.
CREATE DATABASE IF NOT EXISTS myapp
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
