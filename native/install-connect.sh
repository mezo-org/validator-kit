#!/bin/bash

set -e

# Default values
REPO="mezo-org/validator-kit"
DEFAULT_VERSION="2.1.2-go1.26.10"

# CONNECT_SIDECAR_VERSION has to be defined if you want to install version other than default
VERSION=${CONNECT_SIDECAR_VERSION:-$DEFAULT_VERSION}

# Determine the system architecture
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Mezo builds connect only for linux-amd64
if [ "${OS}" != "linux" ] || [ "${ARCH}" != "x86_64" ]; then
    echo "Unsupported platform: ${OS}-${ARCH}. Only linux-x86_64 is supported."
    exit 1
fi

FILE_NAME="connect-${VERSION}-linux-amd64.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/connect-sidecar-v${VERSION}/${FILE_NAME}"

# Download the release
echo "Downloading ${FILE_NAME} from ${DOWNLOAD_URL}..."
curl -fLO "${DOWNLOAD_URL}"

if [ -z "${CONNECT_SIDECAR_SHA256}" ]; then
    echo "Warning: CONNECT_SIDECAR_SHA256 is not set. Skipping the checksum verification of ${FILE_NAME}."
elif ! echo "${CONNECT_SIDECAR_SHA256}  ${FILE_NAME}" | sha256sum --check --strict -; then
    rm "${FILE_NAME}"
    exit 1
fi

# Create a temporary directory for extraction
TEMP_DIR=$(mktemp -d)
echo "Extracting connect binary to ${TEMP_DIR}..."
tar -xzf "${FILE_NAME}" -C "${TEMP_DIR}"

# Find the connect binary
CONNECT_BIN=$(find "${TEMP_DIR}" -type f -name "connect")

if [ -z "${CONNECT_BIN}" ]; then
    echo "Failed to find connect binary in the extracted files"
    rm -rf "${TEMP_DIR}"
    rm "${FILE_NAME}"
    exit 1
fi

# Move the binary to /usr/local/bin
echo "Installing connect to /usr/local/bin..."
sudo mv "${CONNECT_BIN}" /usr/local/bin/

# Make it executable
sudo chmod +x /usr/local/bin/connect

# Clean up
rm -rf "${TEMP_DIR}"
rm "${FILE_NAME}"

echo "Connect ${VERSION} has been installed successfully!"
