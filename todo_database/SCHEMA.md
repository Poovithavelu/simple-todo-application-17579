# Todo Database Schema (MySQL)

This container stores persistent data for the simple todo application.

## Database

- Name: `myapp` (default; override with environment variables when applying schema)
- Charset/Collation: `utf8mb4 / utf8mb4_unicode_ci`

## Table: todos

Columns:
- id: INT UNSIGNED, AUTO_INCREMENT, PRIMARY KEY
- description: TEXT, NOT NULL
- completed: TINYINT(1), NOT NULL, DEFAULT 0 (false)
- start_time: DATETIME, NULL

Constraints/Indexes:
- Uniqueness on description: Implemented via a virtual generated column `description_crc` that contains the first 255 characters of `description`, with a UNIQUE key.
  - Note: MySQL cannot index TEXT without a prefix; this approach ensures uniqueness for the first 255 characters. If you need absolute uniqueness for arbitrarily long text, switch to a separate hash column (e.g., SHA2 hash) with a UNIQUE constraint.

## Files

- schema/001_create_database.sql — Creates the database if not exists.
- schema/002_create_todos_table.sql — Creates the `todos` table with required columns and constraints.
- apply_schema.sh — Helper script to apply the schema locally using MySQL CLI.

## Applying the Schema

Ensure MySQL is running. The `startup.sh` in this container starts MySQL on port 5000 with default credentials.

Then run:
```bash
cd simple-todo-application-17579/todo_database
bash apply_schema.sh
```

Override defaults with env vars if needed:
```bash
MYSQL_HOST=localhost MYSQL_PORT=5000 MYSQL_DB=myapp MYSQL_USER=appuser MYSQL_PASSWORD=dbuser123 bash apply_schema.sh
```

## Notes

- The `completed` column uses TINYINT(1) for boolean semantics.
- `start_time` is nullable to allow todos that are not scheduled yet.
- For stricter uniqueness on full description text beyond 255 characters, prefer adding a persisted hash column:

```sql
ALTER TABLE todos
  ADD COLUMN description_sha CHAR(64) AS (SHA2(description, 256)) PERSISTENT,
  ADD UNIQUE KEY uq_todos_description_sha (description_sha);
```
