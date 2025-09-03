#!/bin/bash
# PUBLIC_INTERFACE
# Apply MySQL schema files in order for the todo database.
# This script reads connection details from the container defaults.
# Environment variables (if set) override default values.
# Required vars (if overriding):
#   MYSQL_USER, MYSQL_PASSWORD, MYSQL_DB, MYSQL_PORT, MYSQL_HOST

set -euo pipefail

MYSQL_USER="${MYSQL_USER:-appuser}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-dbuser123}"
MYSQL_DB="${MYSQL_DB:-myapp}"
MYSQL_PORT="${MYSQL_PORT:-5000}"
MYSQL_HOST="${MYSQL_HOST:-localhost}"

echo "Applying schema to MySQL database:"
echo "  Host: ${MYSQL_HOST}"
echo "  Port: ${MYSQL_PORT}"
echo "  DB:   ${MYSQL_DB}"
echo "  User: ${MYSQL_USER}"

# Apply database creation first using root if available, fallback to app user.
apply_sql() {
  local file="$1"
  echo "-> Applying ${file}"
  if mysql -u root -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -e "SELECT 1" >/dev/null 2>&1; then
    mysql -u root -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" < "${file}"
  else
    mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" < "${file}"
  fi
}

# Ensure database exists
apply_sql "schema/001_create_database.sql"

# Apply remaining migrations within the database context
for f in schema/002_create_todos_table.sql; do
  apply_sql "${f}"
done

echo "✓ Schema applied successfully."
