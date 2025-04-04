# Native binaries

This document describes:

- prerequisites for Mezo Validator Kit,
- how Mezo Validator Kit for native binaries works,
- deployment process for the validator.

## Prerequisites

Native binaries installation is tested on the following operating systems:

- Ubuntu 24 LTS and higher (x86_64 arch)
- Debian 13 Trixie and higher (x86_64 arch)

> [!IMPORTANT]
> If you are planning to install on older system versions or other distributions,
> it's not guaranteed it will work.

Before setup, make sure:
- You have `v-kit.sh` and the right `*.env` file on your machine.
- You can run the setup script as `root` or using `sudo`.

## Setup

> [!IMPORTANT]
> The following instruction uses `mainnet` environment as an example. 
> For `testnet`, follow the same steps but use `testnet.env` 
> (from the `testnet.env.example` template) as your configuration file and
> point it using the `--envfile` flag while running the `v-kit.sh` script.

### 1. Prepare environment file

Copy the `mainnet.env.example` and create your own file `mainnet.env`.

For the validator to be successfully deployed, it's necessary to fill the environment file.

1. Edit the following variables in `mainnet.env`:

- `MEZOD_MONIKER` - a human-readable name for the validator
(Example: `my-lovely-validator`)
- `MEZOD_KEYRING_NAME` - a human-readable name for the mezod keyring
(Example: `my-lovely-keyring`)
- `MEZOD_KEYRING_PASSWORD` - password for the keyring
(to generate best possible password, you can use `openssl rand -hex 32` command)
- `MEZOD_KEYRING_MNEMONIC` - mnemonic for keyring (the best option is to generate it using `v-kit.sh`)
- `MEZOD_ETHEREUM_SIDECAR_SERVER_ETHEREUM_NODE_ADDRESS` - address for the Ethereum node
(required for the sidecar to run). The URL must be WebSocket, i.e. start with `wss://` (recommended) or `ws://`.
- `MEZOD_PUBLIC_IP` - public IP address of the validator
- `MEZOD_DOWNLOAD_LINK` - link to a public repository hosting a `tar.gz` file with mezo binary
- `MEZOD_PORT_P2P` - the port for the P2P connection. Default is `26656`
- `CONNECT_VERSION` - version for the connect sidecar
- `CONNECT_DOWNLOAD_SCRIPT` - link (or path) for the connect download script

> [!NOTE]
> You can use your custom connect installation script (example for that is `install_skip.sh`). This one is customized to set a connect version to be installed (default installation script always installs binary with `latest` tag on it).

### 2. Prepare installation script to run

Before running `v-kit.sh`, make sure it can be executed by your shell:

```bash
chmod +x v-kit.sh
```

### 3. Generate keyring mnemonic
```
./v-kit.sh mnemonic
```

Output mnemonic of this command should be written to the environment file as `MEZOD_KEYRING_MNEMONIC` variable.

Sample output:
```
------------------------------------------------
Reading configuration from environment files
------------------------------------------------

Generating mnemonic...
Save it into your environment file under the variable MEZOD_KEYRING_MNEMONIC

---BEGIN MNEMONIC---
mention maid fashion vibrant nuclear humble welcome screen saddle beauty mango half actress bicycle thank crime shrug pizza car palace silk save credit man
---END MNEMONIC---

Removing temporary mezod binary...
```
In this case, you should copy `mention maid fashion vibrant nuclear humble welcome screen saddle beauty mango half actress bicycle thank crime shrug pizza car palace silk save credit man` to the environment file as instructed previously.

### 4. Run the script (setup validator)

#### Before running: acknowledge your options

Deployment script has the following options:

```text
Usage: ./v-kit.sh

        [stop <opt>]
                stop chosen mezo service (opts: mezo|ethereum-sidecar|connect-sidecar)

        [start <opt>]
                start chosen mezo service (opts: mezo|ethereum-sidecar|connect-sidecar)

        [restart <opt>]
                restart chosen mezo service (opts: mezo|ethereum-sidecar|connect-sidecar)

        [logs <opt>]
                show logs for  chosen mezo service (opts: mezo|ethereum-sidecar|connect-sidecar)

        [mnemonic]
                generate keyring mnemonic (this is required to run validator kit!)

        [-b/--backup]
                backup mezo home dir to /var/mezod-backups

        [-c/--cleanup]
                clean up the installation
                WARNING: this option removes whole Mezo directory (/var/mezod) INCLUDING PRIVATE KEYS

        [--health]
                check health of mezo systemd services

        [-s/--show-variables]
                output variables read from env files

        [-v/--validator-info]
                show validator info

        [-e/--envfile <arg>]
                set file with environment variables for setup script

        [-h/--help]
                show this prompt
```

To run full validator setup, run:

with sudo:

```bash
sudo ./v-kit.sh
```

or as root:

```bash
./v-kit.sh
```

> [!IMPORTANT]
> If you are using an environment file other than `mainnet.env` make sure to set `--envfile` flag.
>
> ```bash
> ./v-kit.sh --envfile <your_custom_envfile>
> ```

## Other options

### Backup mezo home directory

Backup creates a new folder using the name of mezo home dir suffixed by `-backups`
(example: `/var/mezod-backups` when home dir is `/var/mezod`).
After that it zips the whole home dir to the created folder.

```bash
./v-kit.sh -b
```

```bash
./v-kit.sh --backup
```

### Clean up the mezo installation

> [!WARNING]
> This option removes whole Mezo directory (/var/mezod) INCLUDING PRIVATE KEYS.
> It's highly recommended to backup the home dir before cleanup.

```bash
./v-kit.sh -c
```

```bash
./v-kit.sh --cleanup
```

### Check health of mezo systemd services

```bash
./v-kit.sh --health
```

### Verbose printing with variables

This option views all env variables read by the script and activates shell flag that prints
all executed commands and their results (`set -x`).

```bash
./v-kit.sh -s
```

```bash
./v-kit.sh --show-variables
```

### Start/Stop/Status/Logs

You can perform basic administrative actions using the script:

```bash
./v-kit.sh <start/stop/status/logs> <service>
```

Example:

```bash
./v-kit.sh logs mezo
```
