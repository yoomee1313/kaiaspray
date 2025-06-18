#!/bin/bash

pushd .
trap 'popd' EXIT

HOMEDIR="$(dirname "$0")"
cd $HOMEDIR

delete_explorer_data() {
    rm -rf explorer/services/blockscout-db-data explorer/services/dets explorer/services/logs explorer/services/redis-data explorer/services/stats-db-data
}

#RPC_PORT=$(sed -n 's/^RPC_PORT=\([0-9]*\)$/\1/p' ${1}${2}/conf/k${1}d.conf)
#RPC_URL=http://localhost:$RPC_PORT
#WS_PORT=$(sed -n 's/^WS_PORT=\([0-9]*\)$/\1/p' ${1}${2}/conf/k${1}d.conf)
#WS_URL=ws://localhost:$WS_PORT
#echo $WS_URL $RPC_URL

# --gcmode archive --state.block-interval 1

case "$1" in
    delete)
        echo "Deleting explorer database..."
        delete_explorer_data
        ;;
    *)
        echo "Usage: $0 {delete}"
        exit 1
        ;;
esac

