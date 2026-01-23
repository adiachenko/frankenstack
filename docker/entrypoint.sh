#!/bin/bash
set -e

# Configure Node.js version symlinks
setup_node_version() {
    case "$NODE_VERSION" in
        22|24)
            local node_bin="/opt/node/${NODE_VERSION}/bin"
            ln -sf "${node_bin}/node" /usr/local/bin/node
            ln -sf "${node_bin}/npm" /usr/local/bin/npm
            ln -sf "${node_bin}/npx" /usr/local/bin/npx
            ln -sf "${node_bin}/corepack" /usr/local/bin/corepack
            echo "Node.js $(node --version) active"
            ;;
        *)
            echo "ERROR: Invalid NODE_VERSION '$NODE_VERSION'. Supported: 22, 24" >&2
            exit 1
            ;;
    esac
}

# Export timeout-related environment variables
setup_timeouts() {
    export PHP_MAX_EXECUTION_TIME="$REQUEST_TIMEOUT"
    export CADDY_READ_TIMEOUT="$((REQUEST_TIMEOUT + 5))s"
    export CADDY_WRITE_TIMEOUT="$((REQUEST_TIMEOUT + 10))s"
}

# Process PHP configuration templates
process_templates() {
    local conf_dir="$PHP_INI_DIR/conf.d"

    for tpl in "$conf_dir"/*.tpl; do
        if [ -f "$tpl" ]; then
            local ini="${tpl%.tpl}"
            envsubst < "$tpl" > "$ini"
            rm -f "$tpl"
        fi
    done
}

# Configure worker mode if enabled
setup_worker_mode() {
    [ "$FRANKENPHP_MODE" = "worker" ] || return 0

    local worker_script="/app/public/frankenphp-worker.php"
    if [ ! -f "$worker_script" ]; then
        echo "WARNING: Worker mode requested but $worker_script not found. Running in classic mode."
        return 0
    fi

    local watch_config=""
    if [ -n "$FRANKENPHP_WORKER_WATCH" ]; then
        local IFS=','
        for pattern in $FRANKENPHP_WORKER_WATCH; do
            # Trim leading/trailing whitespace
            pattern=$(echo "$pattern" | xargs)
            [ -n "$pattern" ] && watch_config="${watch_config}watch \"$pattern\"
        "
        done
        echo "FrankenPHP file watching enabled: $FRANKENPHP_WORKER_WATCH"
    fi

    export FRANKENPHP_WORKER_CONFIG="worker {
        file \"$worker_script\"
        $watch_config
    }"

    export PHP_SERVER_CONFIG="index frankenphp-worker.php
        try_files {path} frankenphp-worker.php
        resolve_root_symlink"

    echo "FrankenPHP worker mode enabled with: $worker_script"
}

# Main entrypoint logic
main() {
    setup_node_version
    setup_timeouts
    process_templates
    setup_worker_mode

    # If a command is passed and it's not a frankenphp flag, run it directly
    # e.g. docker compose run --rm app composer install
    if [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; then
        exec "$@"
    fi

    # Execute FrankenPHP
    exec frankenphp run "$@"
}

main "$@"
