# Use Postgres 16 as the base image
FROM postgres:16

# Install OpenSSL, sudo, and pglogical extension dependencies
RUN apt-get update && apt-get install -y openssl sudo postgresql-16-pglogical

# Allow the postgres user to execute certain commands as root without a password
RUN echo "postgres ALL=(root) NOPASSWD: /usr/bin/mkdir, /bin/chown, /usr/bin/openssl" > /etc/sudoers.d/postgres

# Add init scripts while setting permissions
COPY --chmod=755 init-ssl.sh /docker-entrypoint-initdb.d/init-ssl.sh
COPY --chmod=755 wrapper.sh /usr/local/bin/wrapper.sh

# Create a configuration script to set required PostgreSQL parameters
COPY --chmod=755 config-wal.sh /docker-entrypoint-initdb.d/config-wal.sh

# Copy the configuration script to the root directory
COPY --chmod=755 config-wal.sh /config-wal.sh

# Set the ENTRYPOINT to your wrapper script
ENTRYPOINT ["wrapper.sh"]

# Provide default command arguments
CMD ["postgres", "--port=5432"]
