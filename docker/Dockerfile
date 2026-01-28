# check=skip=SecretsUsedInArgOrEnv
FROM dunglas/frankenphp:1.11.1-php8.4.17-trixie

LABEL org.opencontainers.image.source=https://github.com/adiachenko/frankenstack

# Node.js version build args (used_below)
ARG NODE_22_VERSION=22.22.0
ARG NODE_24_VERSION=24.13.0

# MySQL version build arg (used_below)
ARG MYSQL_VERSION=8.4.8

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    git \
    unzip \
    openssh-client \
    sqlite3 \
    vim-tiny \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/vim.tiny /usr/bin/vim

# Install PHP extensions
RUN install-php-extensions \
    bcmath \
    bz2 \
    exif \
    ffi \
    ftp \
    gd \
    gmp \
    igbinary \
    imagick \
    intl \
    ldap \
    lz4 \
    memcached \
    mongodb \
    pcntl \
    pcov \
    pdo_mysql \
    pdo_pgsql \
    redis \
    sockets \
    uv \
    xdebug \
    zip

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Remove default opcache config (we provide our own)
RUN rm -f "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"

# Pre-install latest 2 LTS versions of Node.js
RUN set -eux; \
    # Map Docker architecture to Node.js architecture
    case "$(dpkg --print-architecture)" in \
        amd64) ARCH='x64' ;; \
        arm64) ARCH='arm64' ;; \
        *) echo "Unsupported architecture"; exit 1 ;; \
    esac; \
    # Install Node 22
    mkdir -p /opt/node/22; \
    curl -fsSL "https://nodejs.org/dist/v${NODE_22_VERSION}/node-v${NODE_22_VERSION}-linux-${ARCH}.tar.xz" \
        | tar -xJ --strip-components=1 -C /opt/node/22; \
    # Install Node 24
    mkdir -p /opt/node/24; \
    curl -fsSL "https://nodejs.org/dist/v${NODE_24_VERSION}/node-v${NODE_24_VERSION}-linux-${ARCH}.tar.xz" \
        | tar -xJ --strip-components=1 -C /opt/node/24; \
    # Create default symlinks (Node 24)
    ln -s /opt/node/24/bin/node /usr/local/bin/node; \
    ln -s /opt/node/24/bin/npm /usr/local/bin/npm; \
    ln -s /opt/node/24/bin/npx /usr/local/bin/npx; \
    ln -s /opt/node/24/bin/corepack /usr/local/bin/corepack; \
    # Verify installation
    node --version; \
    npm --version

# Install MySQL 8.4 client (generic glibc2.28 binaries for both amd64 and arm64)
RUN set -eux; \
    # Install runtime dependency for MySQL client
    apt-get update && apt-get install -y --no-install-recommends libncurses6 \
        && rm -rf /var/lib/apt/lists/*; \
    # Map Debian arch to MySQL arch naming
    case "$(dpkg --print-architecture)" in \
        amd64) MYSQL_ARCH='x86_64' ;; \
        arm64) MYSQL_ARCH='aarch64' ;; \
        *) echo "Unsupported architecture"; exit 1 ;; \
    esac; \
    # Download tarball to temp location
    curl -fsSL "https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-${MYSQL_VERSION}-linux-glibc2.28-${MYSQL_ARCH}.tar.xz" \
        -o /tmp/mysql.tar.xz; \
    # Extract only client binaries
    mkdir -p /tmp/mysql; \
    tar -xJf /tmp/mysql.tar.xz -C /tmp/mysql --strip-components=1 \
        --wildcards '*/bin/mysql' '*/bin/mysqldump' '*/bin/mysqladmin' \
        '*/bin/mysqlcheck' '*/bin/mysqlimport' '*/bin/mysqlshow'; \
    mv /tmp/mysql/bin/* /usr/local/bin/; \
    # Cleanup
    rm -rf /tmp/mysql /tmp/mysql.tar.xz; \
    # Verify installation
    mysql --version

# Install PostgreSQL 18 client (via PGDG apt repository for multi-arch support)
RUN set -eux; \
    # Install temporary dependencies for adding repository
    apt-get update && apt-get install -y --no-install-recommends gnupg; \
    # Add PGDG repository key and source
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt trixie-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list; \
    # Install PostgreSQL client
    apt-get update && apt-get install -y --no-install-recommends postgresql-client-18; \
    # Cleanup: remove repository artifacts and temporary dependencies
    rm -f /usr/share/keyrings/pgdg.gpg /etc/apt/sources.list.d/pgdg.list; \
    apt-get purge -y --auto-remove gnupg; \
    rm -rf /var/lib/apt/lists/*; \
    # Verify installation
    psql --version

COPY php/*.tpl $PHP_INI_DIR/conf.d/
COPY caddy/Caddyfile /etc/frankenphp/Caddyfile

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set default environment variables (see entrypoint.sh for defaults dependent on PHP_ENV)
ENV NODE_VERSION=24 \
    PHP_ENV=production \
    FRANKENPHP_MODE=classic \
    FRANKENPHP_WORKER=/opt/project/public/frankenphp-worker.php \
    FRANKENPHP_MAX_REQUESTS= \
    REQUEST_TIMEOUT=60 \
    SERVER_NAME=:80 \
    PHP_MEMORY_LIMIT=256M \
    PHP_POST_MAX_SIZE=8M \
    PHP_UPLOAD_MAX_SIZE=2M \
    PHP_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=20000 \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER=16 \
    PHP_XDEBUG_CLIENT_HOST=host.docker.internal \
    PHP_XDEBUG_CLIENT_PORT=9003 \
    COMPOSER_MEMORY_LIMIT=-1 \
    SSH_KNOWN_HOSTS="github.com,gitlab.com,bitbucket.org" \
    # Default socket path for SSH agent (used when loading keys from secrets)
    SSH_AUTH_SOCK="/tmp/ssh-agent.sock"

WORKDIR /opt/project

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--config", "/etc/frankenphp/Caddyfile"]
