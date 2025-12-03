#!/bin/bash
# wait-for-postgres.sh: Wait for PostgreSQL to be ready

set -e

# Get connection details from environment variables (with defaults)
host="${DB_HOST:-localhost}"
port="${DB_PORT:-5432}"

echo "Waiting for PostgreSQL to be ready on ${host}:${port}..."

# First, wait for the port to be open (using timeout if available)
if command -v timeout >/dev/null 2>&1; then
    timeout 60 bash -c "until nc -z ${host} ${port}; do sleep 1; done"
elif command -v nc >/dev/null 2>&1; then
    until nc -z "${host}" "${port}"; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 1
    done
else
    # Fallback: use bash TCP connection check
    until (timeout 1 bash -c "cat < /dev/null > /dev/tcp/${host}/${port}") 2>/dev/null; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 1
    done
fi

echo "PostgreSQL is up and ready on ${host}:${port}!"

