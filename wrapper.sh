#!/bin/bash

# Exit as soon as any command fails
set -e

# Make sure there is a PGDATA variable available
if [ -z "$PGDATA" ]; then
  echo "Missing PGDATA variable"
  exit 1
fi

# Set up needed variables
SSL_DIR="/var/lib/postgresql/data/certs"
INIT_SSL_SCRIPT="/docker-entrypoint-initdb.d/init-ssl.sh"
POSTGRES_CONF_FILE="$PGDATA/postgresql.conf"

# Regenerate if the certificate is not a x509v3 certificate
if [ -f "$SSL_DIR/server.crt" ] && ! openssl x509 -noout -text -in "$SSL_DIR/server.crt" | grep -q "DNS:localhost"; then
  echo "Did not find a x509v3 certificate, regenerating certificates..."
  bash "$INIT_SSL_SCRIPT"
fi

# Regenerate if the certificate has expired or will expire
# 2592000 seconds = 30 days
if [ -f "$SSL_DIR/server.crt" ] && ! openssl x509 -checkend 2592000 -noout -in "$SSL_DIR/server.crt"; then
  echo "Certificate has or will expire soon, regenerating certificates..."
  bash "$INIT_SSL_SCRIPT"
fi

# Generate a certificate if the database was initialized but is missing a certificate
# Useful when going from the base postgres image to this SSL image
if [ -f "$POSTGRES_CONF_FILE" ] && [ ! -f "$SSL_DIR/server.crt" ]; then
  echo "Database initialized without certificate, generating certificates..."
  bash "$INIT_SSL_SCRIPT"
fi

# **Add this section to run config-wal.sh**
# Wait until postgresql.conf is created
while [ ! -f "${PGDATA}/postgresql.conf" ]; do
    echo "Waiting for postgresql.conf to be created..."
    sleep 1
done

# Execute the configuration script to modify postgresql.conf
echo "Executing config-wal.sh to set required PostgreSQL parameters..."
bash /docker-entrypoint-initdb.d/config-wal.sh

# Unset PGHOST to force psql to use Unix socket path (specific to Railway)
unset PGHOST

# Unset PGPORT to prevent issues with empty values
unset PGPORT

# Call the entrypoint script and redirect output if LOG_TO_STDOUT is true
if [[ "$LOG_TO_STDOUT" == "true" ]]; then
    exec /usr/local/bin/docker-entrypoint.sh "$@" 2>&1
else
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi
