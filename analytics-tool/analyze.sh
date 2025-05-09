#!/bin/bash

# analyze.sh
# Enhanced node analysis tool for collecting logs, RPC metrics, and system metrics

# Default values
DAYS=7
LOG_DIR="/var/log/kaia"
OUTPUT_DIR="./output"
BIN_PATH="/usr/bin/ken"
BLOCK_HEIGHT=100
RPC_ENDPOINT="/var/kend/data/kaia.ipc"  # Default to IPC socket
MONITOR_PORT=61006
METRICS_INTERVAL=5  # seconds
OS=$(uname)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help message
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --days N               Number of days to analyze (default: 3)"
    echo "  --log-dir DIR          Log directory (default: /var/log/kaia)"
    echo "  --output-dir DIR       Output directory (default: ./output)"
    echo "  --rpc-endpoint PATH    RPC endpoint (default: /var/run/kaia/kaia.ipc)"
    echo "  --interval N           Metrics collection interval in seconds (default: 5)"
    echo "  --monitor-port N       Monitor port (default: 61006)"
    echo "  --duration N           Monitoring duration in seconds (default: 300)"
    echo "  --logs-only            Only collect logs"
    echo "  --monitor-metrics-only Only collect monitor metrics"
    echo "  --system-metrics-only  Only collect system metrics"
    echo "  --network-only         Only collect network metrics"
    echo "  --gov-data-only        Only collect gov data"
    echo "  --consensus-only       Only collect consensus data"
    echo "  --compress-output      Compress the output directory to zip file"
    echo "  --help                 Show this help message"
    exit 1
}

# Enhanced requirements check
check_requirements() {
    local required_commands="nc jq awk sed date zip netstat top ps df"
    local missing_commands=()

    for cmd in $required_commands; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -ne 0 ]; then
        echo -e "${RED}Error: Required commands not found: ${missing_commands[*]}${NC}"
        echo "Please install the missing commands and try again."
        exit 1
    fi
}

# Function to make RPC calls
make_rpc_call() {
    local method=$1
    local params=$2
    local request="{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":[$params],\"id\":1}"
    local response=$(curl -s -X POST -H "Content-Type: application/json" --data "$request" "$RPC_ENDPOINT")

    echo "$response"
}

make_ipc_call() {
    local method=$1
    local params=$2
    local request="$method($params)"
    if [ "$params" == "" ]; then
        request="$method"
    fi
    local response=$($BIN_PATH --exec "console.log(JSON.stringify($request))" attach $RPC_ENDPOINT | head -n 1)

    echo $response
}

# Enhanced log collection with pattern matching
collect_logs() {
    local output_dir="$OUTPUT_DIR/logs"
    
    echo -e "${GREEN}Collecting logs from the past $DAYS days...${NC}"
    
    # Create logs directory
    mkdir -p "$output_dir"
    
    # Find and copy log files
    for node_type in "cn" "pn" "en"; do
        local LOG_FILE="$LOG_DIR/k${node_type}d.out"

        if [ -f "$LOG_FILE" ]; then
            TODAY_SHORT=$(tail -n 10 $LOG_FILE | grep -oE '[0-9]{2}/[0-9]{2}' | tail -n 1)
            if [ -z "$TODAY_SHORT" ]; then
                echo "Could not extract date from log."
                exit 1
            fi

            TIMESTAMP=$(date -j -f "%Y/%m/%d" "$(date +%Y)/$TODAY_SHORT" "+%s")
            CUTOFF=$(date -j -r $((TIMESTAMP - DAYS * 86400)) +%m/%d)

            echo "DAYS: $DAYS"
            echo "TODAY: $TODAY_SHORT"
            echo "CUTOFF: $CUTOFF"
            
            awk -v cutoff="$CUTOFF" '
            function date_ge(a, b) {
                split(a, aa, "/")
                split(b, bb, "/")
                return (aa[1] aa[2]) >= (bb[1] bb[2])
            }
            {
                if (match($0, /\[[0-9]{2}\/[0-9]{2},/)) {
                    log_date = substr($0, RSTART + 1, 5)
                    if (date_ge(log_date, cutoff)) {
                        print
                    }
                }
            }
            ' "$LOG_FILE" > "$OUTPUT_DIR/logs/k${node_type}d.out"
            
            echo -e "${GREEN}Copied k${node_type}d.out to $output_dir${NC}"
        fi
    done

    echo -e "${GREEN}Log collection completed. Logs saved to $output_dir${NC}"
}

# Enhanced RPC metrics collection
collect_monitor_metrics() {
    echo -e "${GREEN}Collecting monitor metrics...${NC}"
    mkdir -p "$OUTPUT_DIR/monitor"

    # Get node info
    curl -s http://localhost:$MONITOR_PORT/metrics > "$OUTPUT_DIR/monitor/monitor_metrics"
}

# Modified consensus data collection
collect_consensus_data() {
    local output_file="$OUTPUT_DIR/consensus_data/$BLOCK_HEIGHT.log"
    echo -e "${GREEN}Collecting consensus data...${NC}"
    mkdir -p "$OUTPUT_DIR"/consensus_data

    {
        local block_hex="0x$(printf '%x' "$BLOCK_HEIGHT")"

        echo "=== basic info ==="
        echo "block number: ""$BLOCK_HEIGHT"
        echo "chainId:" `make_ipc_call "kaia.chainId" ""`
        echo "rewardBase:" `make_ipc_call "kaia.rewardbase" ""`
        echo ""

        # Get current proposer
        echo "=== kaia.getBlockWithConsensusInfo ==="
        make_ipc_call "kaia.getBlockWithConsensusInfo" "$block_hex" | jq "."
        echo ""

        echo "=== istanbul.getValidators ==="
        make_ipc_call "istanbul.getValidators" "$block_hex" | jq "."
        echo ""

        echo "=== istanbul.getDemotedValidators ==="
        make_ipc_call "istanbul.getDemotedValidators" "$block_hex" | jq "."
        echo ""

        echo "=== kaia.getCouncil ==="
        make_ipc_call "kaia.getCouncil" "$block_hex" | jq "."
        echo ""

        echo "=== kaia.getCommittee ==="
        make_ipc_call "kaia.getCommittee" "$block_hex" | jq "."
        echo ""

        echo "=== governance.getStakingInfo ==="
        make_ipc_call "governance.getStakingInfo" "$block_hex" | jq "."
        echo ""
        
        echo "=== kaia.getRewards ==="
        make_ipc_call "kaia.getRewards" "$block_hex" | jq "."
        echo ""

    } > "$output_file"

    echo -e "${GREEN}Consensus data collected. Results saved to $output_file${NC}"
}

# Modified network metrics collection
collect_network_data() {
    local output_file="$OUTPUT_DIR/network_data/network_data.log"
    echo -e "${GREEN}Collecting network data...${NC}"
    mkdir -p "$OUTPUT_DIR"/network_data

    {
        echo "=== basic info ==="
        echo "block number:" `make_ipc_call "kaia.blockNumber" ""`
        echo "chainId:" `make_ipc_call "kaia.chainId" ""`
        echo "nodeAddress:" `make_ipc_call "kaia.nodeAddress" ""`
        echo "peerCount:" `make_ipc_call "net.peerCountByType" " "`
        echo ""

        # Get node info
        echo "=== admin_nodeInfo ==="
        make_ipc_call "admin.nodeInfo" "" | jq "."
        echo ""

        # Get peers
        echo "=== admin_peers ==="
        make_ipc_call "admin.peers" "" | jq "."
        echo ""
    } > "$output_file"

    echo -e "${GREEN}Network metrics collected. Results saved to $output_file${NC}"
}

collect_gov_data() {
    local output_file="$OUTPUT_DIR/gov_data/$BLOCK_HEIGHT.log"
    echo -e "${GREEN}Collecting gov data...${NC}"
    mkdir -p "$OUTPUT_DIR"/gov_data

    local block_hex="0x$(printf '%x' "$BLOCK_HEIGHT")"
    local response=$(make_rpc_call "kaia_getBlockByNumber" "\"$block_hex\", true")

    if [ -z "$response" ] ||[ "$response" == "null" ]; then
        echo -e "${RED}Error: Response not found at height $BLOCK_HEIGHT${NC}"
        return 1
    fi
    {
        echo "=== basic info ==="
        echo "block number: ""$BLOCK_HEIGHT"
        echo "chainId:" `make_rpc_call "kaia_chainId" "" | jq ".result"`
        echo ""

        echo "=== voteData, governanceData, extraData ==="
        # 1. Decode the vote data
        local vote_data=$(echo "$response" | jq -r '.result.voteData')
        echo "votedata:""$vote_data"
        if [ "$vote_data" != "null" ] || [ "$vote_data" != "0x" ]; then
            $BIN_PATH util decode-vote "$vote_data"
        fi
        echo ""
        # 2. Decode the gov data
        local gov_data=$(echo "$response" | jq -r '.result.governanceData')
        echo "governancedata:""$gov_data"
        if [ "$gov_data" != "null" ] || [ "$gov_data" != "0x" ]; then
            $BIN_PATH util decode-gov "$gov_data"
        fi
        echo ""
        # 3. Decode the extra data
        local temp_file=$(mktemp)
        echo "$response" | jq '.result' > "$temp_file"
        echo "decoded extra data:"
        $BIN_PATH util decode-extra "$temp_file"
        echo ""

        echo "=== kaia.getChainConfig ==="
        make_rpc_call "kaia_getChainConfig" "\"$block_hex\"" | jq '.result'
        echo ""

        echo "=== kaia.getParams ==="
        make_rpc_call "kaia_getParams" "\"$block_hex\"" | jq '.result'
        echo ""

    } > "$output_file"
}

# Enhanced system metrics collection
collect_system_metrics() {
    mkdir -p "$OUTPUT_DIR"/system_metrics
    local output_file="$OUTPUT_DIR/system_metrics/system_metrics.txt"

    # Collect detailed system metrics
    {
        echo "=== System Metrics Report ==="
        echo "Generated at: $(date)"
        echo ""

        echo "=== CPU Information ==="
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sysctl -n machdep.cpu.brand_string
        else
            # Linux
            cat /proc/cpuinfo | grep "model name" | head -1
        fi
        echo ""


        echo "=== System Information ==="
        echo "** Memory Size:"
        sysctl -n hw.memsize | awk '{printf "  %.2f GB\n", $1 / 1024 / 1024 / 1024}'

        echo "** CPU Cores:"
        echo "  Logical Cores: $(sysctl -n hw.logicalcpu)"
        echo "  Physical Cores: $(sysctl -n hw.physicalcpu)"
        echo ""

        echo "=== Top Result ==="
        top -l 1 -s 0 -o rsize | head -n 20
        echo ""

        echo "=== Disk Usage ==="
        df -h
        echo ""

        echo "=== Process Information ==="
        ps aux | grep -i kaia | grep -v grep
        echo ""

        echo "=== Killed System Logs ==="
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            log show --predicate 'eventMessage CONTAINS[c] "killed"' --info --last 1d
        else
            # Linux
            dmesg | grep -i 'killed process'
        fi
        echo ""

    } > "$output_file"

    echo -e "${GREEN}System metrics collected. Results saved to $output_file and $json_output_file${NC}"
}

# Enhanced archive creation with compression
create_archive() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local archive_name="analysis_${timestamp}.zip"
    
    echo -e "${GREEN}Creating archive...${NC}"
    
    # Check if output directory exists
    if [ ! -d "$OUTPUT_DIR" ]; then
        echo -e "${RED}Error: Output directory $OUTPUT_DIR does not exist${NC}"
        return 1
    fi
    
    # Create zip archive
    if command -v zip >/dev/null 2>&1; then
        zip -r "$archive_name" "$OUTPUT_DIR" >/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Archive created successfully: $archive_name${NC}"
        else
            echo -e "${RED}Error: Failed to create archive${NC}"
            return 1
        fi
    else
        echo -e "${RED}Error: 'zip' command not found. Please install zip utility.${NC}"
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --days)
            DAYS="$2"
            shift 2
            ;;
        --log-dir)
            LOG_DIR="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --rpc-endpoint)
            RPC_ENDPOINT="$2"
            shift 2
            ;;
        --interval)
            METRICS_INTERVAL="$2"
            shift 2
            ;;
        --monitor-port)
            MONITOR_PORT="$2"
            shift 2
            ;;
        --block-height)
            BLOCK_HEIGHT="$2"
            shift 2
            ;;
        --bin-path)
            BIN_PATH="$2"
            shift 2
            ;;
        --logs-only)
            LOGS_ONLY=true
            shift
            ;;
        --monitor-metrics-only)
            MONITOR_METRICS_ONLY=true
            shift
            ;;
        --system-metrics-only)
            SYSTEM_METRICS_ONLY=true
            shift
            ;;
        --network-only)
            NETWORK_ONLY=true
            shift
            ;;
        --gov-data-only)
            GOV_DATA_ONLY=true
            shift
            ;;
        --consensus-only)
            CONSENSUS_ONLY=true
            shift
            ;;
        --compress-output)
            COMPRESS_OUTPUT=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Main execution with error handling
main() {
    # Check requirements first
    check_requirements

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    # Trap errors
    trap 'echo -e "${RED}An error occurred. Cleaning up...${NC}"; exit 1' ERR

    if [ "$NETWORK_ONLY" = true ]; then
        collect_network_data
    elif [ "$CONSENSUS_ONLY" = true ]; then
        collect_consensus_data
    elif [ "$GOV_DATA_ONLY" = true ]; then
        collect_gov_data
    elif [ "$COMPRESS_OUTPUT" = true ]; then
        create_archive
    else
        echo -e "${GREEN}Starting common analysis...${NC}"
        collect_logs
        collect_monitor_metrics
        collect_system_metrics
        echo -e "${GREEN}Common analysis completed successfully!${NC}"
    fi
}

# Execute main with error handling
main "$@"