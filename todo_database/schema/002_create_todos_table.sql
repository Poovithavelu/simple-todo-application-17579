-- PUBLIC_INTERFACE
-- This migration creates the 'todos' table in the 'myapp' database.
-- Table fields:
--  - id: INT, auto-increment, primary key
--  - description: TEXT, required, unique (to ensure unique todo items)
--  - completed: TINYINT(1) (boolean), defaults to 0 (false)
--  - start_time: DATETIME, nullable
-- Indexes:
--  - UNIQUE index on description to ensure uniqueness

USE myapp;

CREATE TABLE IF NOT EXISTS todos (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  description TEXT NOT NULL COMMENT 'Todo description',
  completed TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Completion status (0 = false, 1 = true)',
  start_time DATETIME NULL COMMENT 'Start time of the todo',
  PRIMARY KEY (id),
  -- MySQL cannot create a UNIQUE index directly on TEXT; use a generated column to support uniqueness.
  -- We create a virtual generated column with a prefix length to enforce uniqueness up to 255 chars.
  -- If longer descriptions are required to be unique beyond 255, consider using a hash column.
  description_crc CHAR(255) AS (SUBSTRING(description, 1, 255)) VIRTUAL,
  UNIQUE KEY uq_todos_description (description_crc)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT='Stores user todo items';
