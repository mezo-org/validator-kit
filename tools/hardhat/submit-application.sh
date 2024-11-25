#!/bin/bash

# Default network value
DOCKER_DIR="../../docker"
NATIVE_DIR="../../native"
HOME_DIR="$(pwd)"
NETWORK="testnet" # default
FLOW=""

# install dependencies
npm i

# Function to display usage
usage() {
  echo "Usage: $0 [--network <network>] --flow <flow_value>"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --network)
      NETWORK="$2"
      shift # past argument
      shift # past value
      ;;
    --flow)
      FLOW="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      usage
      ;;
  esac
done

# Check if mandatory field is set
if [ -z "$FLOW" ]; then
  echo "Error: --flow is a mandatory flag."
  usage
fi

# Output the values used
echo "Network: $NETWORK"
echo "Flow: $FLOW"

# Specify the path to the *.env file (e.g. testnet.env)
env_file="$NETWORK.env"

if [ "$FLOW" = "docker" ]; then
    cd $DOCKER_DIR || { echo "Failed to navigate to docker directory"; exit 1; }
    output=$(./v-kit.sh validator-info)
    moniker=$(grep "^MEZOD_MONIKER=" "$env_file" | awk -F'=' '{print $2}')
    priv_key=$(./v-kit.sh export-private-key)
elif [ "$FLOW" = "native" ]; then
    cd $NATIVE_DIR || { echo "Failed to navigate to native directory"; exit 1; }
    output=$(sudo ./v-kit.sh --validator-info)
    moniker=$(grep "^MEZOD_MONIKER=" "$env_file" | awk -F'=' '{print $2}')
    priv_key=$(sudo ./v-kit.sh export-private-key | tail -n 1)
else
    echo "Error: Invalid flow value. Please use 'docker' or 'native'."
    exit 1
fi
cd $HOME_DIR

# Extract "Validator address"
signer=$(echo "$output" | grep "Validator address" | awk -F': ' '{print $2}')

# Extract "Validator consensus address"
conspubkey=$(echo "$output" | grep "Validator consensus address" | awk -F': ' '{print $2}')

moniker=${moniker#\"} #trim quotes
moniker=${moniker%\"} #trim quotes

# Print the extracted values
echo "Validator address: $signer"
echo "Validator consensus address: $conspubkey"
echo "Moniker: $moniker"
# echo "Private key: $priv_key"

# Set private key to MEZO_ACCOUNTS as it is used by signer to sign transactions.
npx hardhat vars set MEZO_ACCOUNTS $priv_key

# Run the hardhat command with the extracted values. 
# Important! Make sure your signer has funds to execute this transaction.
npx hardhat --network $NETWORK validatorPool:submitApplication --signer $signer --conspubkey $conspubkey --moniker $moniker