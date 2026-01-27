#!/bin/bash
set -e

setup_node_version() {
    case "$NODE_VERSION" in
        22|24)
            local node_bin="/opt/node/${NODE_VERSION}/bin"
            ln -sf "${node_bin}/node" /usr/local/bin/node
            ln -sf "${node_bin}/npm" /usr/local/bin/npm
            ln -sf "${node_bin}/npx" /usr/local/bin/npx
            ln -sf "${node_bin}/corepack" /usr/local/bin/corepack
            ;;
        *)
            echo "ERROR: Invalid NODE_VERSION '$NODE_VERSION'. Supported: 22, 24" >&2
            exit 1
            ;;
    esac
}

apply_timeouts() {
    export PHP_MAX_EXECUTION_TIME="$REQUEST_TIMEOUT"
    export CADDY_READ_TIMEOUT="$((REQUEST_TIMEOUT + 5))s"
    export CADDY_WRITE_TIMEOUT="$((REQUEST_TIMEOUT + 10))s"
}

resolve_frankenphp_mode() {
    local mode="${FRANKENPHP_MODE:-classic}"

    if [ "$mode" = "worker" ] && [ ! -f "$FRANKENPHP_WORKER" ]; then
        echo "WARNING: Worker mode requested but $FRANKENPHP_WORKER not found. Running in classic mode."
        mode="classic"
    fi

    export FRANKENPHP_MODE="$mode"
}

apply_frankenphp_mode_defaults() {
    local mode="${FRANKENPHP_MODE:-classic}"

    if [ -z "${PHP_XDEBUG_START_WITH_REQUEST:-}" ]; then
        if [ "$mode" = "worker" ]; then
            export PHP_XDEBUG_START_WITH_REQUEST="trigger"
        else
            export PHP_XDEBUG_START_WITH_REQUEST="yes"
        fi
    fi

    if [ -z "${PHP_XDEBUG_START_UPON_ERROR:-}" ]; then
        if [ "$mode" = "worker" ]; then
            export PHP_XDEBUG_START_UPON_ERROR="default"
        else
            export PHP_XDEBUG_START_UPON_ERROR="yes"
        fi
    fi
}

apply_php_env_defaults() {
    local env="${PHP_ENV:-production}"

    case "$env" in
        production|development) ;;
        *)
            echo "WARNING: Unknown PHP_ENV '$env'. Falling back to production."
            env="production"
            ;;
    esac

    export PHP_ENV="$env"

    if [ -z "${PHP_DISPLAY_ERRORS:-}" ]; then
        if [ "$env" = "development" ]; then
            export PHP_DISPLAY_ERRORS="On"
        else
            export PHP_DISPLAY_ERRORS="Off"
        fi
    fi

    if [ -z "${PHP_DISPLAY_STARTUP_ERRORS:-}" ]; then
        if [ "$env" = "development" ]; then
            export PHP_DISPLAY_STARTUP_ERRORS="On"
        else
            export PHP_DISPLAY_STARTUP_ERRORS="Off"
        fi
    fi

    if [ -z "${PHP_ERROR_REPORTING:-}" ]; then
        if [ "$env" = "development" ]; then
            export PHP_ERROR_REPORTING="E_ALL"
        else
            export PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED"
        fi
    fi

    if [ -z "${PHP_XDEBUG_MODE:-}" ]; then
        if [ "$env" = "development" ]; then
            export PHP_XDEBUG_MODE="debug,develop"
        else
            export PHP_XDEBUG_MODE="off"
        fi
    fi

    if [ -z "${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-}" ]; then
        if [ "$env" = "development" ]; then
            export PHP_OPCACHE_VALIDATE_TIMESTAMPS="1"
        else
            export PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"
        fi
    fi

    if [ -z "${FRANKENPHP_WORKER_WATCH:-}" ]; then
        if [ "$env" = "development" ]; then
            export FRANKENPHP_WORKER_WATCH="/opt/project/**/*.php,/opt/project/.env*"
        else
            export FRANKENPHP_WORKER_WATCH=""
        fi
    fi
}

process_php_conf_templates() {
    local conf_dir="$PHP_INI_DIR/conf.d"

    for tpl in "$conf_dir"/*.tpl; do
        if [ -f "$tpl" ]; then
            local ini="${tpl%.tpl}"
            envsubst < "$tpl" > "$ini"
            rm -f "$tpl"
        fi
    done
}

setup_ssh() {
    local ssh_dir="/root/.ssh"

    # Skip if no SSH configuration present
    if [ -z "${SSH_AUTH_SOCK:-}" ] && [ ! -f "/run/secrets/ssh_key" ]; then
        return 0
    fi

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    setup_ssh_known_hosts "$ssh_dir"

    # Use agent forwarding if available, otherwise load from secret
    if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK}" ] && ssh-add -l >/dev/null 2>&1; then
        echo "SSH: Using forwarded agent ($(ssh-add -l 2>/dev/null | wc -l | xargs) keys)"
    elif [ -f "/run/secrets/ssh_key" ]; then
        setup_ssh_from_docker_secret
    fi
}

setup_ssh_known_hosts() {
    local ssh_dir="$1"
    local known_hosts="$ssh_dir/known_hosts"

    # Prefer mounted known_hosts
    if [ -f "/run/secrets/ssh_known_hosts" ]; then
        cp /run/secrets/ssh_known_hosts "$known_hosts"
        chmod 644 "$known_hosts"
        echo "SSH: Using mounted known_hosts"
        return 0
    fi

    # Fallback: ssh-keyscan for common hosts
    if [ -n "${SSH_KNOWN_HOSTS:-}" ]; then
        local IFS=','
        for host in $SSH_KNOWN_HOSTS; do
            host=$(echo "$host" | xargs)
            [ -n "$host" ] && ssh-keyscan -H "$host" >> "$known_hosts" 2>/dev/null
        done
        chmod 644 "$known_hosts"
    fi
}

setup_ssh_from_docker_secret() {
    local socket_path="/tmp/ssh-agent.sock"
    rm -f "$socket_path"
    ssh-agent -a "$socket_path" >/dev/null
    export SSH_AUTH_SOCK="$socket_path"

    local passphrase="${SSH_KEY_PASSPHRASE:-}"

    if [ -n "$passphrase" ]; then
        local askpass="/tmp/ssh_askpass_$$"
        printf '#!/bin/sh\necho "%s"\n' "$passphrase" > "$askpass"
        chmod 700 "$askpass"

        SSH_ASKPASS="$askpass" SSH_ASKPASS_REQUIRE=force \
            ssh-add /run/secrets/ssh_key </dev/null 2>/dev/null

        rm -f "$askpass"
    else
        ssh-add /run/secrets/ssh_key 2>/dev/null
    fi

    echo "SSH: Agent started with $(ssh-add -l 2>/dev/null | wc -l | xargs) key(s)"
}

setup_worker_mode() {
    [ "${FRANKENPHP_MODE:-classic}" = "worker" ] || return 0

    local worker_filename="${FRANKENPHP_WORKER##*/}"
    local watch_config=""
    if [ -n "$FRANKENPHP_WORKER_WATCH" ]; then
        local IFS=','
        for pattern in $FRANKENPHP_WORKER_WATCH; do
            # Trim leading/trailing whitespace
            pattern=$(echo "$pattern" | xargs)
            if [ -n "$pattern" ]; then
                [ -n "$watch_config" ] && watch_config+=$'\n'"        "
                watch_config+="watch \"$pattern\""
            fi
        done
    fi

    export FRANKENPHP_WORKER_CONFIG="worker {
        file \"$FRANKENPHP_WORKER\"
        $watch_config
    }"

    export PHP_SERVER_CONFIG="index $worker_filename
        try_files {path} $worker_filename
        resolve_root_symlink"
}

main() {
    setup_node_version
    apply_timeouts
    resolve_frankenphp_mode
    apply_php_env_defaults
    apply_frankenphp_mode_defaults
    process_php_conf_templates
    setup_ssh
    setup_worker_mode

    # If a command is passed and it's not a frankenphp flag, run it directly (e.g. composer install)
    if [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; then
        exec "$@"
    fi

    exec frankenphp run "$@"
}

main "$@"
