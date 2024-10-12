#!/bin/bash
set -e

# Function to modify postgresql.conf
modify_postgresql_conf() {
    echo "Modifying postgresql.conf with required parameters"

    # Set wal_level to 'logical'
    sed -i "s/^#\?wal_level = .*/wal_level = 'logical'/" "${PGDATA}/postgresql.conf"

    # Set shared_preload_libraries to include pglogical
    sed -i "s/^#\?shared_preload_libraries = .*/shared_preload_libraries = 'pglogical'/" "${PGDATA}/postgresql.conf"

    # Set wal_sender_timeout to 0
    sed -i "s/^#\?wal_sender_timeout = .*/wal_sender_timeout = 0/" "${PGDATA}/postgresql.conf"

    # Set max_replication_slots
    sed -i "s/^#\?max_replication_slots = .*/max_replication_slots = ${MAX_REPLICATION_SLOTS:-10}/" "${PGDATA}/postgresql.conf"

    # Set max_wal_senders
    sed -i "s/^#\?max_wal_senders = .*/max_wal_senders = ${MAX_WAL_SENDERS:-12}/" "${PGDATA}/postgresql.conf"

    # Set max_worker_processes
    sed -i "s/^#\?max_worker_processes = .*/max_worker_processes = ${MAX_WORKER_PROCESSES:-10}/" "${PGDATA}/postgresql.conf"

    echo "Parameters have been set in postgresql.conf"
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

echo "Configuration complete. PostgreSQL will start with the required parameters set."
