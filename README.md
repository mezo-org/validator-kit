# Validator Kit

>[!NOTE]
> Always use the latest release of the Validator Kit. The main branch is not guaranteed to be stable.

## Overview

This repository contains the Validator Kit for Mezo chain. The Validator Kit is
a collection of tools and documentation to help you run a validator node on Mezo chain.

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

#### Version ordering for Mezo Matsnet testnet

- `v0.2.0-rc3`: initial version from genesis to block 1093500
- `v0.3.0-rc3`: from block 1093500 to block 1745000
- `v0.4.0-rc1`: from block 1745000 to block 2213000
- `v0.5.0-rc1`: from block 2213000 to block 2563000
- `v0.6.0-rc2`: from block 2563000 to block 3078794
- `v0.7.0-rc0`: from block 3078794 to block 3569000
- `v1.0.0-rc*`: from block 3569000 to the current chain tip (pick the latest `-rc*`)

#### Version ordering for Mezo Mainnet

- `v1.0.0`: from genesis to the current chain tip (pick the latest minor/patch version)

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
mezod --home=<mezod_home_path> poa submit-application <key_name>
```
where `key_name` denotes the private key from your node's keyring that corresponds to 
the aforementioned validator's node address.

Once you submit your application, the Mezo team will verify your node status and approve 
your application if everything is in order. Please provide your public IP, your node address, 
and any custom port settings. If you wish to close the CometBFT RPC port (note that the 
CometBFT P2P port must remain open), please whitelist the following IP address: `34.57.120.151` 
so that we can verify your status.

## Acknowledgements

Shout out to [thevops](https://github.com/thevops) and [tscrond](https://github.com/tscrond) from [Boar.network](https://boar.network/) for
implementing `docker`, `docker-monitoring`, `native`, and `helm-chart` components!
