#!/bin/bash

source "./0.variables.sh"

# Set default values if not set
DOCKER_IMAGE=${DOCKER_IMAGE:-"kaiachain/kaia:latest"}
NUM_CNS=${NUM_CNS:-1}
CHAIN_ID=${CHAIN_ID:-203}
NETWORK_ID=${NETWORK_ID:-203}

if [ 1 -ne $NUM_CNS ]; then
  echo "Currently, it only works for 1 CN configuration."
  exit
fi

# Download kaia docker image.
docker pull $DOCKER_IMAGE

# Create cache directory in the script directory
CURR_PWD=`pwd`
OUTPUT_DIR=/homi-output
case "$(uname -sr)" in
   CYGWIN*|MINGW*|MINGW32*|MSYS*)
      CURR_PWD=`pwd -W`
      OUTPUT_DIR=${CURR_PWD}/homi-outputa
     ;;
esac

# Generate docker-compose.yml for docker-compose.
docker run --rm \
  -v "${CURR_PWD}:/homi-output" \
  "${DOCKER_IMAGE}" \
  homi setup \
  -o "${OUTPUT_DIR}" \
  --docker-image-id "${DOCKER_IMAGE}" \
  --cn-num "${NUM_CNS}" \
  --chainID "${CHAIN_ID}" \
  --network-id "${NETWORK_ID}" \
  docker

# add eth namespace in docker-compose.yml
sed -i -e "s/RPC_API=\"db,klay,/RPC_API=\"db,eth,kaia,/" docker-compose.yml

# Create datasources.yml
cat > datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: DS_KLAYTN
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    version: 1
EOF

cat > dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: 'file'
    disableDeletion: false
    editable: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# Replace DS_KLAYTN in JSON files
sed -i -e 's/"\${DS_KLAYTN}"/"DS_KLAYTN"/g' Klaytn*.json

# Add grafana datasource volume mount to docker-compose.yml
sed -i -e 's/hostname: grafana/hostname: grafana\
    volumes:\
      - ".\/datasources.yml:\/etc\/grafana\/provisioning\/datasources\/datasources.yml"\
      - ".\/dashboard.yml:\/etc\/grafana\/provisioning\/dashboards\/dashboard.yml"\
      - ".\/Klaytn_txpool.json:\/var\/lib\/grafana\/dashboards\/Klaytn_txpool.json"\
      - ".\/Klaytn.json:\/var\/lib\/grafana\/dashboards\/Klaytn.json"/' docker-compose.yml

# Update private key if necessary
if [ ! -z $PRIVATE_KEY ]; then
  echo "replacing private key."
	sed -i -e "s/\(.*nodekeyhex \)\(.*\)\(\".*\)/\1$PRIVATE_KEY\3/" docker-compose.yml
	sed -i -e "s/\(.*REWARDBASE=\)\(.*'\)/\1$ADDRESS'/" docker-compose.yml

  # Add the account to the node wallet.
  PK=`grep "nodekeyhex" docker-compose.yml | sed "s/.*nodekeyhex \(.*\)\".*/\1/"`
  REWARDBASE=`grep "REWARDBASE" docker-compose.yml | sed "s/.*REWARDBASE=\(.*\)\'.*/\1/" | sed "s/\('\s>>.*\)//"`

  ./add_import_key.sh docker-compose.yml $PK $REWARDBASE
fi

echo "Execution done"
