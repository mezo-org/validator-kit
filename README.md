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

Moreover, there are several auxiliary components of the Validator Kit that
can help you with various operational tasks:

1. [`tools`](./tools): provides a collection of Hardhat tasks designed to simplify
   interactions with the blockchain’s Proof-of-Authority (PoA) based network.
   For example, you can submit your application to become one of the PoA validators.
2. [`docker-monitoring`](./docker-monitoring): contains files to run a monitoring
   stack for your validator node using Docker. This is an optional way to monitor
   your validator node. The monitoring stack is dedicated to the `docker` setup.
   You can use it for the `native` variant after some adjustments (not covered in this repo).

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

Version ordering for Mezo Matsnet testnet:
- `v0.2.0-rc3`: initial version from genesis to block 1093500
- `v0.3.0-rc3`: from block 1093500 to block 1745000
- `v0.4.0-rc*`: from block 1745000 to the current chain tip (pick the latest `-rc*`)

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

Mezo team provides snapshots for Mezo Matsnet testnet. Please refer to
[this runbook](./manual/README.md#State-sync-from-snapshot)
for details. Alternatively, you can ask trusted community members for a snapshot.

## Acknowledgements

Shout out to [thevops](https://github.com/thevops) and [tscrond](https://github.com/tscrond) from [Boar.network](https://boar.network/) for
implementing `docker`, `docker-monitoring`, `native`, and `helm-chart` components!
