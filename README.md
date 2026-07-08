# Validator Kit

>[!NOTE]
> Always use the latest release of the Validator Kit. The main branch is not guaranteed to be stable.

## Overview

This repository contains the Validator Kit for Mezo chain. The Validator Kit is
a collection of tools and documentation to help you run a Mezo chain node.

Although the Validator Kit is primarily designed for validator nodes, it can be
used to run [non-validator nodes](#non-validator-nodes) as well.

### Main components

There are a couple of main components of the Validator Kit:

1. [`docker`](./docker): contains files to run a validator node using Docker Compose.
   This is the easiest way to run a validator node as it requires less setup and maintenance.
2. [`native`](./native): provides files to fetch the `mezod` binary from a remote source
   and run it manually. This is an alternative way to run a validator node if
   you prefer to run it natively.
3. [`helm-chart`](./helm-chart): contains files to deploy a validator node on a Kubernetes cluster.
   This is an advanced way to run a validator node if you have a Kubernetes cluster.
4. [`manual`](./manual): provides a step-by-step guide to run a validator node manually.
   This is the way to run a validator node if you prefer to do everything manually
   or none of the above options suit your needs.

As a validator you can choose between the above options to run your validator node.

### Auxiliary components

Moreover, there are auxiliary components of the Validator Kit that can help you with various 
operational tasks:

1. [`docker-monitoring`](./docker-monitoring): contains files to run a monitoring
   stack for your validator node using Docker. This is an optional way to monitor
   your validator node. The monitoring stack is dedicated to the `docker` setup.
   You can use it for the `native` variant after some adjustments (not covered in this repo).

## Artifacts

Regardless of the chosen way to run a validator node, you may want to use 
pre-built artifacts provided by the Mezo team. These include Docker images and
binary files for the `mezod` node software. Alternatively, you can build the
necessary artifacts yourself.

### Stable releases (Mainnet)

Stable releases are ready to be rolled out on Mainnet nodes. You can find relevant
artifacts in the following locations (substitute `VERSION` with the desired 
stable version, e.g. `v1.0.0`):

- Docker image (DockerHub): `mezo/mezod:VERSION`
- Binary (amd64): `https://github.com/mezo-org/mezod/releases/download/VERSION/linux-amd64.tar.gz`

### Candidate releases (Testnet)

>[!WARNING]
> Candidate releases are **NOT READY** for Mainnet use.

Candidate releases are intended to be rolled out on Testnet nodes. You can find
relevant artifacts in the following locations (substitute `VERSION` with the 
desired candidate version, e.g. `v1.0.0-rc0`):

- Docker image: `us-central1-docker.pkg.dev/mezo-test-420708/mezo-staging-docker-public/mezod:VERSION`
- Binary (amd64): `https://artifactregistry.googleapis.com/download/v1/projects/mezo-test-420708/locations/us-central1/repositories/mezo-staging-binary-public/files/mezod:VERSION:linux-amd64.tar.gz:download?alt=media`

## Public seed nodes

You can use the following seed nodes to connect your node to the given Mezo chain:

- Testnet: [testnet/mezo_31611-1/seeds.txt](https://github.com/mezo-org/mezod/blob/main/chain/testnet/mezo_31611-1/seeds.txt)
- Mainnet: [mainnet/mezo_31612-1/seeds.txt](https://github.com/mezo-org/mezod/blob/main/chain/mainnet/mezo_31612-1/seeds.txt)

## Node synchronization

There are two ways to synchronize your node with the Mezo blockchain.

### Block sync from genesis

>[!NOTE]
> See [CometBFT Block Sync](https://docs.cometbft.com/v0.38/core/block-sync)
documentation for further reference.

This is the most basic way to synchronize your node. You start your node from
the genesis block and download all blocks from the chain. This process can take
a long time depending on your network connection and the number of blocks in
the network. Moreover, you need to start with the initial version
of `mezod` and upgrade along the way to handle on-chain upgrades properly.

#### Version ordering for Mezo Testnet

Asterisk (*) denotes the latest minor/patch version.

- `v0.2.0-rc3`: initial version from genesis to block 1093500
- `v0.3.0-rc3`: from block 1093500 to block 1745000
- `v0.4.0-rc1`: from block 1745000 to block 2213000
- `v0.5.0-rc1`: from block 2213000 to block 2563000
- `v0.6.0-rc2`: from block 2563000 to block 3078794
- `v0.7.0-rc0`: from block 3078794 to block 3569000
- `v1.0.0-rc0`: from block 3569000 to block 3712500
- `v1.0.0-rc1`: from block 3712500 to block 5559500
- `v2.0.2`: from block 5559500 to block 5695000
- `v3.*.*`: from block 5695000 to block 6853500
- `v4.*.*`: from block 6853500 to block 8838000
- `v5.*.*`: from block 8838000 to block 10325250
- `v6.*.*`: from block 10325250 to block 11688500
- `v7.*.*`: from block 11688500 to block 11854127
- `v8.*.*`: from block 11854127 to block 12193600
- `v9.*.*`: from block 12193600 to block 12872000
- `v10.*.*`: from block 12872000 to block 13206900
- `v11.*.*`: from block 13206900 to the current chain tip

#### Version ordering for Mezo Mainnet

Asterisk (*) denotes the latest minor/patch version.

- `v1.*.*`: from genesis to block 706500
- `v2.*.*`: from block 706500 to block 1735000
- `v3.*.*`: from block 1735000 to block 3194000
- `v4.*.*`: from block 3194000 to block 5207000
- `v5.*.*`: from block 5207000 to block 6773500
- `v6.*.*`: from block 6773500 to block 7691500
- `v7.*.*`: from block 7691500 to block 7739500
- `v8.*.*`: from block 7739500 to block 8194500
- `v9.*.*`: from block 8194500 to block 8773000
- `v10.*.*`: from block 8773000 to block 9275000
- `v11.*.*`: from block 9275000 to the current chain tip

### State sync from snapshot

>[!NOTE]
> See [CometBFT State Sync](https://docs.cometbft.com/v0.38/core/state-sync)
documentation for further reference.

This is a quicker way to synchronize your node. You download a snapshot of the
Mezo blockchain state and apply it to your node. This process is faster than
block sync from genesis. You can start with the latest version of `mezod` and
apply the snapshot to get the latest state of the chain. The downside here
is the fact that your node won't have the chain history prior to the snapshot.
Moreover, you need to trust the source of the snapshot.

Mezo team provides snapshots only for Mezo Matsnet testnet. Mezo team **DOES NOT** 
provide snapshots for Mezo Mainnet. In any case, you can ask trusted community members
for a snapshot.

Please refer to [this runbook](./manual/README.md#State-sync-from-snapshot)
to learn how to sync your node from a snapshot in practice.

## PoA application submission

The final step to becoming a PoA validator is submitting your application to the Mezo
team. Before you proceed, ensure you have sufficient funds on your validator's node
address. You can submit your application using a CLI command exposed by `mezod`:

```bash
mezod --home=<mezod_home_path> --rpc-url <rpc_url> poa submit-application <key_name>
```

- `key_name` denotes the private key from your node's keyring that corresponds to
the aforementioned validator's node address.
- `rpc-url` optional flag that specifies the RPC node you want to use to submit your application.
It defaults to local RPC node `http://127.0.0.1:8545` if not provided.

Once you submit your application, the Mezo team will verify your node status and approve 
your application if everything is in order. Please provide your public IP, your node address, 
and any custom port settings. Moreover please adhere to the [central monitoring](#central-monitoring) 
requirements so that the Mezo team can monitor your node's health.

Before you submit, double-check that your firewall follows the
[port and firewall configuration](#port-and-firewall-configuration) rules
for validator nodes.

## Non-validator nodes

Non-validator nodes require neither the Ethereum sidecar nor Connect sidecar to be deployed.

### Network seed nodes

If you want to run a seed node to help network peer discovery, follow the configuration
process as for a validator node but:
- Do not submit an application to PoA.
- Set the `p2p.seed_mode` parameter in your node's `config.toml` file to `true`.
- Set `pruning=everything` in `app.toml` to enable storing only current chain state
- Set `state-sync.snapshot-interval` in `app.toml` to `0` to disable snapshots of the state
- Set `tx_index.indexer` in `config.toml` to `null` to disable indexing

Setting those parameters will significantly reduce node's storage usage, thus improving the resource efficiency.

Ensure your firewall follows the
[port and firewall configuration](#port-and-firewall-configuration) rules
for seed nodes.

### RPC node

To run an RPC node (serving both EVM JSON-RPC and CometBFT RPC), follow the configuration
process as for a validator node but:
- Do not submit an application to PoA.
- If you want to run an archiving node (i.e. with full history of the chain),
  set the `pruning` parameter in your node's `app.toml` file to `nothing`.

Ensure your firewall follows the
[port and firewall configuration](#port-and-firewall-configuration) rules
for RPC nodes.

## Port and firewall configuration

`mezod` uses the following ports:

| Default port | Purpose                  | Can be changed using                                    |
|--------------|--------------------------|---------------------------------------------------------|
| `26656`      | CometBFT P2P             | `p2p.laddr` and `p2p.external_address` in `config.toml` |
| `26657`      | CometBFT RPC             | `rpc.laddr` in `config.toml`                            |
| `8545`       | EVM JSON-RPC (HTTP)      | `json-rpc.address` in `app.toml`                        |
| `8546`       | EVM JSON-RPC (WebSocket) | `json-rpc.ws-address` in `app.toml`                     |
| `9090`       | Cosmos gRPC              | `grpc.address` in `app.toml`                            |
| `1317`       | Cosmos REST API          | `api.address` in `app.toml` (disabled by default)       |

Expose ports depending on your node type and keep everything else closed:

| Node type | CometBFT P2P (`26656`) | CometBFT RPC (`26657`) | EVM JSON-RPC (HTTP) (`8545`)                       | EVM JSON-RPC (WebSocket) (`8546`) | Cosmos gRPC (`9090`) | Cosmos REST API (`1317`) |
|-----------|------------------------|------------------------|----------------------------------------------------|-----------------------------------|----------------------|--------------------------|
| Validator | Public                 | Closed                 | [Central monitoring](#central-monitoring) IPs only | Closed                            | Closed               | Closed                   |
| RPC       | Optional               | Optional               | Public                                             | Public                            | Optional             | Optional                 |
| Seed      | Public                 | Closed                 | Closed                                             | Closed                            | Closed               | Closed                   |

Do NOT expose any RPC ports of a validator node to the public. A validator
with publicly exposed RPC ports is vulnerable to denial-of-service attacks
that can lead to downtime and missed blocks.

Opening the P2P port on an RPC node is optional: the node syncs through
outbound connections on its own, but an open P2P port helps network peer
discovery. The CometBFT RPC, Cosmos gRPC, and Cosmos REST API ports are
optional as well: RPC nodes primarily serve EVM JSON-RPC, so open them
only if you want to serve these APIs to your clients.

## Hardware requirements

Here are the minimum recommended hardware requirements for running different 
types of Mezo chain nodes:

| Node Type | vCPU | RAM   | Disk    |
|-----------|------|-------|---------|
| Validator | 4    | 16 GB | 256 GB  |
| RPC       | 8    | 32 GB | 512 GB  |
| Seed      | 2    | 8 GB  | 128 GB  |

## Central monitoring

The Mezo team runs a central monitoring stack based on Prometheus and Grafana 
to monitor the health of the Mezo chain and its underlying nodes. The monitoring
currently relies on the EVM JSON-RPC API (default port `8545`) to fetch some
information about the node. It is strongly recommended that you allowlist the following
IP addresses to access your node's EVM JSON-RPC port so the monitoring stack can
fetch the required information:

- Testnet: `34.28.107.238`
- Mainnet: `34.72.231.166`

Allowlisting means granting access to these specific IP addresses only. On a
validator node, keep the port closed for everyone else, as described in
[port and firewall configuration](#port-and-firewall-configuration).

## Acknowledgements

Shout out to [thevops](https://github.com/thevops) and [tscrond](https://github.com/tscrond) from [Boar.network](https://boar.network/) for
implementing `docker`, `docker-monitoring`, `native`, and `helm-chart` components!
