#!/bin/bash
set -e

# Function to modify postgresql.conf
modify_postgresql_conf() {
    echo "Modifying postgresql.conf to set wal_level to logical"
    sed -i "s/^#wal_level = .*/wal_level = logical/" "${PGDATA}/postgresql.conf"
    echo "wal_level has been set to logical in postgresql.conf"
}

# Check if PGDATA is set
if [ -z "${PGDATA}" ]; then
    echo "Error: PGDATA environment variable is not set."
    exit 1
fi

# Wait until postgresql.conf is created
while [ ! -f "${PGDATA}/postgresql.conf" ]; do
    echo "Waiting for postgresql.conf to be created..."
    sleep 1
done

# Modify postgresql.conf
modify_postgresql_conf

echo "Configuration complete. PostgreSQL will start with wal_level set to logical."
