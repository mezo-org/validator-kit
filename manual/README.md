# Manual setup

This directory contains a guide describing how to run a validator node manually.
This is the way to run a validator node if you prefer to do everything on your own
or none of the other Validator Kit components suit your needs.

>[!WARNING]
> This guide assumes you are an experienced operator and have a good understanding
> of blockchains based on Cosmos SDK and CometBFT. Consider using the
> [`docker`](../docker/README.md) setup if you want an easier way to run
> a validator node.

## Prerequisites

1. Get the `mezod` binary from our public repository. Alternatively,
   clone https://github.com/mezo-org/mezod and build `mezod` from source.
   Remember to pick the correct version of the `mezod` binary, depending on
   the synchronization method you want to use. See the [Node synchronization](../README.md#node-synchronization)
   section in the root `README.md` for reference.
2. Install the [Skip Connect sidecar](https://docs.skip.build/connect/validators/quickstart#installation).
3. Get an Ethereum RPC node against the appropriate network (Sepolia for Mezo testnet).
   Full self-hosted node is recommended. Public providers like Alchemy/Infura
   are acceptable for now.

## Setup

The following setup assumes a Unix-like environment.

1. For simplicity, export the following env variables:
   ```shell
   export MEZOD_HOME=...      # e.g. /var/mezod
   export MEZOD_KEY=...       # e.g. my-key
   export MEZOD_MONIKER=...   # e.g. my-node
   export MEZOD_PUBLIC_IP=... # your static public IP
   ```

2. Create a fresh home directory:
   ```shell
   mkdir -p $MEZOD_HOME
   ```

3. Generate a BIP-39 mnemonic for the keyring. You can an arbitrary method to
   generate the mnemonic or leverage the CLI exposed by `mezod`:
   ```shell
   mezod keys mnemonic
   ```
   Store the mnemonic in a safe place.
   <br/><br/>

4. Generate a keyring password. You can use the following command to generate a password:
   ```shell
   openssl rand -hex 32
   ```
   Store the password in a safe place.
   <br/><br/>

5. Generate an account key:
   ```shell
   mezod keys add $MEZOD_KEY --home=$MEZOD_HOME --keyring-backend="file" --recover
   ```
   Pass the previously generated mnemonic and keyring password when prompted.
   <br/><br/>

6. Initialize the node:
   ```shell
   export MEZOD_CHAIN_ID=mezo_31611-1 # Mezo testnet

   mezod init $MEZOD_MONIKER \
    --home=$MEZOD_HOME \
    --keyring-backend="file" \
    --chain-id=$MEZOD_CHAIN_ID \
    --overwrite \
    --recover
   ```
   Pass the previously generated mnemonic when prompted.
   <br/><br/>
   This command initializes the node's home directory with the default
   configuration.
   <br/><br/>
   Moreover, it automatically:
   - Adds the appropriate `$MEZOD_HOME/config/genesis.json` file
   - Populates `$MEZOD_HOME/config/config.toml` with some seed nodes
   <br/><br/>

7. Customize the following configuration files according to your needs:
   - `$MEZOD_HOME/config/app.toml`
   - `$MEZOD_HOME/config/client.toml`
   - `$MEZOD_HOME/config/config.toml`
   <br/><br/>

   Tips:
   - Make sure your P2P configuration is correct. Most importantly, you have
     to use a static public IP and the P2P port must be open. Remember about
     setting the right `p2p.laddr` and `p2p.external_address` in `config.toml`.
   - If you want to use a custom address for the Ethereum sidecar, remember
     about changing `ethereum-sidecar.client.server-address` in `app.toml`.
   - If you want to use a custom address for the Connect sidecar, remember about
     changing `oracle.oracle-address` in `app.toml`.
   <br/><br/>

8. Prepare the genval file:
   ```shell
   mezod genesis genval $MEZOD_KEY \
    --home=$MEZOD_HOME \
    --keyring-backend="file" \
    --chain-id=$MEZOD_CHAIN_ID \
    --ip=$MEZOD_PUBLIC_IP
   ```
   Pass the previously generated keyring password when prompted.
   <br/><br/>

9. Run the `mezod` node:
   ```shell
   mezod start --home=$MEZOD_HOME
   ```
   The node will start syncing with the network. The process may take a while.
   You can check the current status using the CometBFT RPC `/status` endpoint:
   ```shell
   curl -s $MEZOD_PUBLIC_IP:26657/status
   ```
   The node is ready when the `sync_info.catching_up` field is `false`.
   <br/><br/>
   **Move to the next steps only when the node is fully synced.**
   <br/><br/>

10. Run the Connect sidecar. For example:
    ```shell
    connect --market-map-endpoint=localhost:9090
    ```
    The above command assumes your `mezod` node will be available at `localhost`
    and its Cosmos GRPC port is exposed under `9090`. Adjust the command according
    to your setup if needed. For further configuration options, see `connect --help`.
    <br/><br/>

11. Run the Ethereum sidecar. For example:
    ```shell
    mezod ethereum-sidecar \
     --ethereum-sidecar.server.ethereum-node-address=wss://eth-sepolia.g.alchemy.com/v2/<redacted>
    ```
    The above command assumes you are using the Alchemy provider. Adjust the command
    according to your setup if needed. For further configuration options, see
    `mezod ethereum-sidecar --help`.
    <br/><br/>
    **If you build `mezod` from source, remember about running `make bindings`
    before building the binary to ensure the `ethereum-sidecar` command works correctly.**
    <br/><br/>

12. Apply to PoA. Please contact the Mezo team for further instructions.

## Starting a node from a CometBFT snapshot

To start a node from a snapshot is no different to any other CometBFT based blockchain.

To start with select a block from a trusted node, you can do so using the following API:
`http://<NODE_OPERATOR_ADDRESS>:26657/block`, this will give you the very last block
executed by the node.

Then you will need to update the following fields in the cometbft config, you can find this
config under the following path `MEZOD_HOME/config/config.toml`:
- `enabled` should be set to true to enable state sync (to be disabled later, when
  the node have been running for normal stop and restart of the node without local state).
- `rpc_servers` is a list of trusted node rpc server that the light client can use
  to recovers blocks.
- `trust_height` should be the height of the selected trusted block
- `trust_hash`  should be the hash of the selected trusted block

This is an example configuration you can use with the mezo matsnet, be sure to
update the `trust_height` and `trust_hash` fields as explain previously everthing
else would be valid as is:

```toml
[statesync]
enable = true

rpc_servers = "mezo-node-0.test.mezo.org:26657,mezo-node-1.test.mezo.org:26657,mezo-node-2.test.mezo.org:26657,mezo-node-3.test.mezo.org:26657,mezo-node-4.test.mezo.org:26657,35.209.7.223:26657,35.209.252.61:26657"

trust_height = 1880001
trust_hash = "2185BC492BA0BD1FB1B0BFB16CE229736E850E5B64BB09B7363F9DB3EC5C2078"
trust_period = "112h0m0s"

discovery_time = "15s"

temp_dir = ""

chunk_request_timeout = "1m"

chunk_fetchers = "4"
```

> NOTE: When selecting a block, be sure to have a block which is close to a snapshot.
> Because the mezo matsnet takes snapshots every 5000 blocks, it is recommended to use
> just the next block height (this help reduce timeout issues with the light client),
> So if the last snapshot was on block 1885000, the best trusted block would be 1885001,
> for which you can access the block hash with the following URL
> `http://<NODE_OPERATOR_ADDRESS>:26657/block?height=188501`
