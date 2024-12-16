#!/bin/bash
### This is a deployment script for mezo validator stack
### For now it's created for debian-based systems and amd64 architecture (x86_64)
### Script handles:
### 1. Installing required packages using apt package manager
### 2. Building and installing mezod binary from the source
### 3. Installing connect sidecar
### 4. Deploying mezo validator stack as systemd services

set -eo pipefail

update_system() {
    apt update -y &&  apt upgrade -y
}

install_tools() {
    apt install ufw jq curl -y
}

open_ports() {
    ufw --force enable
    ufw allow 26660,26656,26657,1317,9090,8545,8546,6065/tcp
    # allow ssh connections:
    ufw allow 22/tcp
}

download_binary() {
    url="$1"
    verbose="$2"

    [[ "$verbose" == "verbose" ]] && echo "Downloading mezod package to temporary dir"

    if [ -z "$url" ]; then
        echo "Error: URL is empty. Exiting."
        exit 1
    fi

    [[ "$verbose" == "verbose" ]] && echo "Download URL: $url"

    if [[ "$verbose" == "verbose" ]]; then
        curl --verbose --silent --location \
            --output ./tmp/mezod-${MEZOD_ARCH}.tar.gz $url
    else
        curl --silent --location \
            --output ./tmp/mezod-${MEZOD_ARCH}.tar.gz $url
    fi

    if [ $? -ne 0 ]; then
        echo "Error: curl command failed during download."
        exit 1
    fi

    if [ ! -f ./tmp/mezod-${MEZOD_ARCH}.tar.gz ]; then
        echo "Error: Downloaded file does not exist."
        exit 1
    fi
 
}

unpack_binary() {
    if [[ "$1" == "" ]]; then
        echo "No argument provided, exiting"
    fi
    destination=$1
    [[ "$2" == "verbose" ]] && echo "Unpacking the binary build ${MEZOD_VERSION}"
    tar -xvf ./tmp/mezod-${MEZOD_ARCH}.tar.gz -C "${destination}" >/dev/null
}

install_mezo() {
    mkdir -p ${MEZOD_DESTINATION}
    mkdir -p ./tmp

    download_binary ${MEZOD_DOWNLOAD_LINK} "verbose"
    unpack_binary ${MEZOD_DESTINATION}

    chown root:root ${MEZO_EXEC}
    chmod +x ${MEZO_EXEC}

    echo "Mezo binary installed with path: ${MEZO_EXEC}"
}

install_skip() {
    # Empty version defaults to latest
    if [[ -z "${CONNECT_VERSION}" ]]; then
      CONNECT_VERSION="2.1.2"
    fi

    # Empty download script link defaults to official connect sidecar install script
    if [[ -z "${CONNECT_DOWNLOAD_SCRIPT}" ]]; then
      CONNECT_DOWNLOAD_SCRIPT="./install-connect.sh"
    fi

    if [[ -f "${CONNECT_DOWNLOAD_SCRIPT}"  ]]; then
      cat ${CONNECT_DOWNLOAD_SCRIPT} | CONNECT_SIDECAR_VERSION=${CONNECT_VERSION} bash
    else
      curl -ksSL ${CONNECT_DOWNLOAD_SCRIPT} | CONNECT_SIDECAR_VERSION=${CONNECT_VERSION} bash
    fi

    CONNECT_TMP=$(which connect)
    CONNECT_VERSION=$(${CONNECT_TMP} version)
    
    CONNECT_EXEC_PATH=$MEZOD_HOME/bin/skip-${CONNECT_VERSION}
    CONNECT_EXEC=$CONNECT_EXEC_PATH/connect

    mkdir -p $CONNECT_EXEC_PATH

    mv $CONNECT_TMP $CONNECT_EXEC_PATH
    rm -rf $CONNECT_TMP

    echo "Skip binary installed with path: ${CONNECT_EXEC_PATH}"
}

prepare_keyring() {
   test -f "${MEZOD_HOME}/keyring-file/keyhash" && {
    echo "Keyring already prepared!"
    return
  }

  echo "Prepare keyring..."
  (echo "${MEZOD_KEYRING_MNEMONIC}"; echo "${MEZOD_KEYRING_PASSWORD}"; echo "${MEZOD_KEYRING_PASSWORD}") \
    | ${MEZO_EXEC} keys add \
      "${MEZOD_KEYRING_NAME}" \
      --home="${MEZOD_HOME}" \
      --keyring-backend="file" \
      --recover
  echo "Keyring prepared!"
}

init_mezo_config() {

    prepare_keyring
    
    echo "Initialize configuration..."
    echo "$MEZOD_KEYRING_MNEMONIC" | ${MEZO_EXEC} \
        init \
        "${MEZOD_MONIKER}" \
        --chain-id="${MEZOD_CHAIN_ID}" \
        --home="${MEZOD_HOME}" \
        --keyring-backend="file" \
        --overwrite \
        --recover
    echo "Configuration initialized!"
}

configure_mezo() {
    
    client_config_file="${MEZOD_HOME}/config/client.toml"
    app_config_file="${MEZOD_HOME}/config/app.toml"
    config_file="${MEZOD_HOME}/config/config.toml"

    echo "Backup original configuration..."
    echo "Backup ${client_config_file} to ${client_config_file}.bak"
    test -f "${client_config_file}.bak" ||  cat "$client_config_file" | tee "${client_config_file}.bak" > /dev/null
    echo "Backup ${app_config_file} to ${app_config_file}.bak"
    test -f "${app_config_file}.bak" ||  cat "$app_config_file" | tee "${app_config_file}.bak" > /dev/null
    echo "Backup ${config_file} to ${config_file}.bak"
    test -f "${config_file}.bak" ||  cat "$config_file" | tee "${config_file}.bak" > /dev/null

    echo "Customize configuration..."

    ${MEZO_EXEC} toml set \
        ${client_config_file} \
        -v chain-id="${MEZOD_CHAIN_ID}" \
        -v keyring-backend="file" \
        -v node="tcp://0.0.0.0:26657"

    ${MEZO_EXEC} toml set \
        ${config_file} \
        -v moniker="${MEZOD_MONIKER}" \
        -v p2p.laddr="tcp://0.0.0.0:${MEZOD_PORT_P2P}" \
        -v rpc.laddr="tcp://0.0.0.0:26657" \
        -v instrumentation.prometheus=true \
        -v instrumentation.prometheus_listen_addr="0.0.0.0:26660" \
        -v p2p.external_address="${MEZOD_PUBLIC_IP}:${MEZOD_PORT_P2P}" \
        -v consensus.timeout_propose="30s" \
        -v consensus.timeout_propose_delta="5s" \
        -v consensus.timeout_prevote="10s" \
        -v consensus.timeout_prevote_delta="5s" \
        -v consensus.timeout_precommit="5s" \
        -v consensus.timeout_precommit_delta="5s" \
        -v consensus.timeout_commit="150s" \
        -v rpc.timeout_broadcast_tx_commit="150s"

    ${MEZO_EXEC} toml set \
        ${app_config_file} \
        -v ethereum-sidecar.client.server-address="0.0.0.0:7500" \
        -v api.enable=true \
        -v api.address="tcp://0.0.0.0:1317" \
        -v grpc.enable=true \
        -v grpc.address="0.0.0.0:9090" \
        -v grpc-web.enable=true \
        -v json-rpc.enable=true \
        -v json-rpc.address="0.0.0.0:8545" \
        -v json-rpc.api="eth,txpool,personal,net,debug,web3" \
        -v json-rpc.ws-address="0.0.0.0:8546" \
        -v json-rpc.metrics-address="0.0.0.0:6065" \
        -v "pruning=nothing"

}

init_genval() {
    test -f "${MEZOD_HOME}"/config/genval/genval-*.json && {
        echo "Genval already exists!"
        return
    }

    echo "Prepare genval..."
    echo "${MEZOD_KEYRING_PASSWORD}" \
        | ${MEZO_EXEC} genesis genval \
        "${MEZOD_KEYRING_NAME}" \
        --keyring-backend="file" \
        --chain-id="${MEZOD_CHAIN_ID}" \
        --home="${MEZOD_HOME}" \
        --ip="${MEZOD_PUBLIC_IP}"


    echo "Genval prepared!"
}

setup_systemd_skip(){
    echo "
[Unit]
Description=Connect Sidecar Service
After=network.target

[Service]
Restart=no
ExecStartPre=/bin/echo "Starting connect-sidecar systemd initialization..."
ExecStart=${CONNECT_EXEC} --log-disable-file-rotation --port=${CONNECT_SIDECAR_PORT} --market-map-endpoint=\"127.0.0.1:9090\"
StandardOutput=journal
StandardError=journal
User=root

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/connect-sidecar.service

}

setup_systemd_sidecar(){
    echo "
[Unit]
Description=Ethereum Sidecar Service
After=network.target

[Service]
Restart=no
ExecStartPre=/bin/echo "Starting ethereum-sidecar systemd initialization..."
ExecStart=${MEZO_EXEC} ethereum-sidecar --log_format=${MEZOD_LOG_FORMAT} --ethereum-sidecar.server.ethereum-node-address=${MEZOD_ETHEREUM_SIDECAR_SERVER_ETHEREUM_NODE_ADDRESS}
StandardOutput=journal
StandardError=journal
User=root

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/ethereum-sidecar.service

}

setup_systemd_mezo(){
    echo "
[Unit]
Description=Mezo Service
After=network.target

[Service]
Restart=no
ExecStartPre=/bin/echo "Starting mezod systemd initialization..."
ExecStart=${MEZO_EXEC} start --home=${MEZOD_HOME} --metrics
StandardOutput=journal
StandardError=journal
User=root

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/mezo.service

}

systemd_restart() {
    echo "Reloading systemd daemon"
    systemctl daemon-reload
    echo "Starting systemd services"
    systemctl start mezo
    systemctl start ethereum-sidecar
    systemctl start connect-sidecar
}

cleanup() {
    echo "Stopping mezo.service"
    systemctl stop mezo.service || echo 'mezo stopped'
    echo "Stopping ethereum-sidecar.service"
    systemctl stop ethereum-sidecar.service || echo 'ethereum sidecar stopped'
    echo "Stopping connect-sidecar.service"
    systemctl stop connect-sidecar.service || echo 'skip sidecar stopped'

    echo "Disabling systemd unit mezo.service"
    systemctl disable mezo.service || echo 'mezo sidecar already disabled'
    echo "Disabling systemd unit ethereum-sidecar.service"
    systemctl disable ethereum-sidecar.service || echo 'ethereum already disabled'
    echo "Disabling systemd unit connect-sidecar.service"
    systemctl disable connect-sidecar.service || echo 'skip sidecar already disabled'

    echo "Removing systemd file /etc/systemd/system/mezo.service"
    rm -f /etc/systemd/system/mezo.service
    echo "Removing systemd file /etc/systemd/system/ethereum-sidecar.service"
    rm -f /etc/systemd/system/ethereum-sidecar.service
    echo "Removing systemd file /etc/systemd/system/connect-sidecar.service"
    rm -f /etc/systemd/system/connect-sidecar.service

    echo "Reloading systemd daemon"
    systemctl daemon-reload

    rm -rf ${MEZOD_HOME}
}

backup() {
    if [ ! -d "$MEZOD_HOME" ]; then
        echo "Error: Directory $MEZOD_HOME does not exist."
        exit 1
    fi
    
    BACKUP_DIRNAME=$(dirname "$MEZOD_HOME")
    BACKUP_FOLDER=$(basename "$MEZOD_HOME")

    echo "Trying to create directory for backups"
    mkdir -p "$MEZOD_HOME-backups"

    echo "Creating a backup of $MEZOD_HOME to $MEZOD_HOME-backups/mezo_backup_$(date +%Y%m%d).tar.gz"
    tar -czvf "$MEZOD_HOME-backups/mezo_backup_$(date +%Y%m%d).tar.gz" -C "$BACKUP_DIRNAME" "$BACKUP_FOLDER"
}

usage() {
    echo -e "This is a Mezo Validator Kit Native installation script."
    echo -e "Script handles installation of the validator software as native binaries managed by systemd services.\n"
    echo -e "Steps executed during installation:"
    echo -e "1. Update system (apt package manager)"
    echo -e "2. Install tools required for script (ufw jq curl)"
    echo -e "3. Open firewall ports (ufw)"
    echo -e "4. Install mezo binary"
    echo -e "5. Install connect-sidecar binary"
    echo -e "6. Configure Mezo - keyring, configuration files"
    echo -e "7. Setup systemd services for Mezo"
    echo -e "8. Send an submitApplication transaction through mezod binary (TODO)\n"

    echo -e "Usage: $0\n\n" \
    "\t[stop <opt>]\n\t\tstop chosen mezo service (opts: mezo | ethereum-sidecar | connect-sidecar)\n\n" \
    "\t[start <opt>]\n\t\tstart chosen mezo service (opts: mezo | ethereum-sidecar | connect-sidecar)\n\n" \
    "\t[restart <opt>]\n\t\trestart chosen mezo service (opts: mezo | ethereum-sidecar | connect-sidecar)\n\n" \
    "\t[logs <opt>]\n\t\tshow logs for  chosen mezo service (opts: mezo|ethereum-sidecar|connect-sidecar )\n\n" \
    "\t[health]\n\t\tcheck health of mezo systemd services\n\n" \
    "\t[export-private-key]\n\t\texport validator private key (needed for hardhat setup)\n\n" \
    "\t[mnemonic]\n\t\tgenerate keyring mnemonic (this is required to run validator kit!)\n\n" \
    "\t[-b/--backup]\n\t\tbackup mezo home dir to ${MEZOD_HOME}-backups\n\n" \
    "\t[-c/--cleanup]\n\t\tclean up the installation\n\t\tWARNING: this option removes whole Mezo directory (${MEZOD_HOME}) INCLUDING PRIVATE KEYS\n\n" \
    "\t[-s/--show-variables]\n\t\toutput variables read from env files\n\n" \
    "\t[-v/--validator-info]\n\t\tshow validator info\n\n" \
    "\t[-e/--envfile <arg>]\n\t\tset file with environment variables for setup script\n\n" \
    "\t[-h/--help]\n\t\tshow this prompt\n" 
}

healthcheck() {
    systemctl status --no-pager mezo || echo "issues with mezo"
    systemctl status --no-pager ethereum-sidecar || echo "issues with ethereum sidecar"
    systemctl status --no-pager connect-sidecar || echo "issues with connect sidecar"
}

show_variables() {
    ### Application ###
    echo "MEZOD_CHAIN_ID $MEZOD_CHAIN_ID"
    echo "MEZOD_HOME $MEZOD_HOME"
    echo "MEZOD_MONIKER $MEZOD_MONIKER"

    ### Keyring ###
    echo "MEZOD_KEYRING_NAME $MEZOD_KEYRING_NAME"
    echo "MEZOD_KEYRING_DIR $MEZOD_KEYRING_DIR"
    echo "MEZOD_KEYRING_PASSWORD $MEZOD_KEYRING_PASSWORD"

    ### Other ###
    echo "MEZOD_ETHEREUM_SIDECAR_CLIENT_SERVER_ADDRESS $MEZOD_ETHEREUM_SIDECAR_CLIENT_SERVER_ADDRESS"
    echo "MEZOD_ETHEREUM_SIDECAR_SERVER_ETHEREUM_NODE_ADDRESS $MEZOD_ETHEREUM_SIDECAR_SERVER_ETHEREUM_NODE_ADDRESS"
    echo "MEZOD_LOG_FORMAT $MEZOD_LOG_FORMAT"
    echo "MEZOD_KEY_NAME $MEZOD_KEY_NAME"
    echo "MEZOD_LOGLEVEL $MEZOD_LOGLEVEL"

    echo "CONNECT_SIDECAR_PORT $CONNECT_SIDECAR_PORT"

    ### Setup ###
    echo "MEZOD_VERSION $MEZOD_VERSION"
    echo "MEZOD_ARCH $MEZOD_ARCH"
    echo "MEZOD_PUBLIC_IP $MEZOD_PUBLIC_IP"

    ### Github ###
    echo "MEZOD_DOWNLOAD_LINK $MEZOD_DOWNLOAD_LINK"

    set -x
}

# TODO:
# Validator info names a couple of these fields incorrectly. Please change them in the
# same manner as in https://github.com/mezo-org/mezod/pull/344. Discussion
# with more info https://github.com/mezo-org/validator-kit/pull/5#discussion_r1852275107
show_validator_info() {
    # below makes my eyes twitch
    # (but it works)
    raw_operator_address=$(echo ${MEZOD_KEYRING_PASSWORD} | "${MEZO_EXEC}" --home="${MEZOD_HOME}" keys show "${MEZOD_KEYRING_NAME}" --address)
    raw_conspubkey=$(cat "${MEZOD_HOME}"/config/genval/genval-*.json | jq -r '.validator.cons_pub_key_bech32')

    validator_id="$(cat "${MEZOD_HOME}"/config/genval/genval-*.json | jq -r '.memo' | awk -F'@' '{print $1}')"

    parsed_raw_conspubkey=$(${MEZO_EXEC} --home=${MEZOD_HOME} keys parse ${raw_conspubkey} | grep bytes | awk '{printf "%s", $2}' | tail -c 64)

    operator_address="$(${MEZO_EXEC} --home="${MEZOD_HOME}" keys parse "${raw_operator_address}" | grep bytes | awk '{print "0x"$2}' | tr '[:upper:]' '[:lower:]')"
    conspubkey=$(echo -n $parsed_raw_conspubkey | tr '[:upper:]' '[:lower:]' | xargs -I {} echo 0x{})

    validator_consensus_addr="$(jq -r '.address' "${MEZOD_HOME}"/config/priv_validator_key.json | tr '[:upper:]' '[:lower:]' | awk '{print "0x"$1}')"

    echo "Your validator addresses info:"
    echo "Validator address: ${operator_address}"
    echo "Validator ID: ${validator_id}"
    echo "Validator consensus pubkey: ${conspubkey}"
    echo "Validator consensus address: ${validator_consensus_addr}"
    echo "Moniker: $MEZOD_MONIKER"
}

main() {
    update_system
    install_tools
    open_ports
    install_mezo
    install_skip
    init_mezo_config
    configure_mezo
    init_genval
    setup_systemd_skip
    setup_systemd_sidecar
    setup_systemd_mezo
    systemd_restart
    show_validator_info
}

setenvs() {
    echo "------------------------------------------------"
    echo "Reading configuration from environment files"
    echo "------------------------------------------------"
    echo ""
    . ${ENVIRONMENT_FILE}

    MEZOD_DESTINATION=$MEZOD_HOME/bin/mezod-${MEZOD_VERSION}
    MEZO_EXEC=$MEZOD_DESTINATION/mezod

}

validate_opt() {
    if [[ "$1" == "" ]]; then
        echo "Error: No service provided" >&2
        exit 1
    fi

    services=("mezo" "ethereum-sidecar" "connect-sidecar")
    for s in "${services[@]}"; do
        if [[ "$1" == "$s" ]]; then
            echo "$s"
            return
        fi
    done

    echo "Error: No such service \"$1\"" >&2
    exit 1
}

start_service() {
    service=$(validate_opt "$1") || exit 1
    echo "Starting service $service"
    systemctl start "$service"
    exit 0
}

stop_service() {
    service=$(validate_opt "$1") || exit 1
    echo "Stopping service $service"
    systemctl stop "$service"    
    exit 0
}

restart_service() {
    service=$(validate_opt "$1") || exit 1
    echo "Restarting service $service"
    systemctl restart "$service"
    exit 0
}

show_logs() {
    service=$(validate_opt "$1") || exit 1
    echo "Showing logs for $service"
    journalctl -u "$service"
    exit 0
}

export_private_key() {
    echo "Fetching validator private key..."
    yes $MEZOD_KEYRING_PASSWORD | ${MEZO_EXEC} --home="${MEZOD_HOME}" keys unsafe-export-eth-key "${MEZOD_KEYRING_NAME}" 2>/dev/null
}

generate_mnemonic() {
    tmp_mezod_path="./tmp"

    mkdir -p "${tmp_mezod_path}"
     
    download_binary "$MEZOD_DOWNLOAD_LINK"
    unpack_binary "${tmp_mezod_path}"

    echo "Generating mnemonic..."
    echo "Save it into your environment file under the variable MEZOD_KEYRING_MNEMONIC"
    echo ""
    echo "---BEGIN MNEMONIC---"
    ${tmp_mezod_path}/mezod keys mnemonic
    echo "---END MNEMONIC---"
    echo ""

    echo "Removing temporary mezod binary..."
    rm -rf "${tmp_mezod_path}"
}

# default env file name - can be changed through -e/--envfile option
ENVIRONMENT_FILE="testnet.env"
healthcheck_flag=false
show_variables_flag=false
cleanup_flag=false
backup_flag=false
validator_info=false

while [[ $# -gt 0 ]]; do
    case $1 in
        start)
            start_service "$2"
            exit 0
        ;;
        stop)
            stop_service "$2"
            exit 0
        ;;
        restart)
            restart_service "$2"
            exit 0
        ;;
        logs)
            show_logs "$2"
            exit 0
        ;;
        mnemonic)
            setenvs
            generate_mnemonic
            exit 0
        ;;
        export-private-key)
            setenvs
            export_private_key
            exit 0
        ;;
        health)
            healthcheck
            exit 0
            ;;
       -s|--show-variables)
            show_variables_flag=true
            shift
            ;;
        -e|--envfile)
            ENVIRONMENT_FILE="$2"
            shift 2
            ;;
        -c|--cleanup)
            cleanup_flag=true
            shift
            ;;
        -b|--backup)
            backup_flag=true
            shift
            ;;
        -v|--validator-info)
            validator_info=true
            shift
            ;;
        -h|--help)
            setenvs
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [ ! -f "${ENVIRONMENT_FILE}" ]; then
    echo "Error: Environment file ${ENVIRONMENT_FILE} not found!"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi

if [[ "$backup_flag" == true ]]; then
    setenvs
    backup
    exit 0
fi

if [[ "$cleanup_flag" == true ]]; then
    setenvs
    cleanup
    exit 0
fi

if [[ "$validator_info" == true ]]; then
    setenvs
    show_validator_info
    exit 0
fi

if [[ "$show_variables_flag" == true ]]; then
    setenvs
    show_variables
fi

setenvs
main
