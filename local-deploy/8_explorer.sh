#!/bin/bash

pushd .
trap 'popd' EXIT

HOMEDIR="$(dirname "$0")"
cd $HOMEDIR

docker_compose() {
	if docker compose version >/dev/null 2>&1; then
		docker compose -f explorer/docker-compose.yml "$@"
	else
		docker-compose -f explorer/docker-compose.yml "$@"
	fi
}

delete_explorer_data() {
    rm -rf explorer/services/blockscout-db-data explorer/services/dets explorer/services/logs explorer/services/redis-data explorer/services/stats-db-data
}

start_explorer() {
    set -e
    RPC_PORT=$(sed -n 's/^RPC_PORT=\([0-9]*\)$/\1/p' ${1}${2}/conf/k${1}d.conf)
    RPC_URL=http://host.docker.internal:$RPC_PORT
    WS_PORT=$(sed -n 's/^WS_PORT=\([0-9]*\)$/\1/p' ${1}${2}/conf/k${1}d.conf)
    WS_URL=ws://host.docker.internal:$WS_PORT
    CHAIN_ID=$(sed -n 's/^NETWORK_ID=\([0-9]*\)$/\1/p' ${1}${2}/conf/k${1}d.conf)
    echo $RPC_URL $WS_URL $CHAIN_ID

    RPC_URL=$RPC_URL WS_URL=$WS_URL CHAIN_ID=$CHAIN_ID docker_compose up -d
    set +e
}

# --gcmode archive --state.block-interval 1

case "$1" in
    delete)
        echo "Deleting explorer database..."
        docker_compose down
        delete_explorer_data
        ;;
    start)
        shift
        start_explorer "$@"
        ;;
    stop)
        docker_compose stop
        ;;
    *)
        echo "Usage: $0 {start|stop|delete}"
        exit 1
        ;;
esac

