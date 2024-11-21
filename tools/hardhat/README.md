# Precompile Hardhat Tasks

Node.js v20 or greater is recommended

Before getting started make sure you have changed to the hardhat directory and have installed the required
dependencies:

```bash
cd tools/hardhat
npm install
```

## Networks

Hardhat is configured with the following supported networks:

* `testnet` for connecting to the public testnet.
* `mainnet` soon..

All tasks and scripts support hardhat's global options which includes the `--network` flag. `testnet` is
used by default if no network is set. If running a task or script against `mainnet` ensure you include
`--network mainnet` as a hardhat argument.

## Accounts

Hardhat [vars](https://hardhat.org/hardhat-runner/docs/guides/configuration-variables) are used for configuring
accounts/keys.

```text
WARNING

Configuration variables are stored in plain text on your disk. Avoid using this feature for data you wouldn’t
normally save in an unencrypted file. Run npx hardhat vars path to find the storage's file location.
```

You can determine what `vars` are available by running:

```bash
npx hardhat vars setup
```

The vars can be set to either a) a single private key, or b) a comma separated list (no whitespace) of private keys.

```bash
npx hardhat vars set MEZO_ACCOUNTS
```

List availables accounts:

```bash
npx hardhat vars get MEZO_ACCOUNTS
```

And can be removed with:

```bash
npx hardhat vars delete MEZO_ACCOUNTS
```

## Tasks

We name Hardhat [Tasks](https://hardhat.org/hardhat-runner/docs/advanced/create-task) with a precompile prefix. This
provides clarity on which precompile the task runs against, and keeps the output of `npx hardhat help` clean as
precompile tasks get grouped together. You can view the available tasks with:

```bash
npx hardhat help
```

*Note: The default Hardhat tasks are still visible (e.g `compile`), many of these will do nothing as we are only using
Hardhat for tasks/testing.*

Help information for a specific task can be obtained using

```bash
npx hardhat help <TASK>
```

e.g:

```bash
npx hardhat help validatorPool:validator
```

```bash
Usage: hardhat [GLOBAL OPTIONS] validatorPool:validator --operator <STRING>

OPTIONS:

  --operator The validator's operator address

validatorPool:validator: Returns a validator's consensus public key & description
```

Here we can see the validatorPool:validator task has an operator argument - correct usage would be:

```bash
npx hardhat --network testnet validatorPool:validator --operator 0xc2f7Ae302a68CF215bb3dA243dadAB3290308015
```

### Running Tasks

Tasks get run as if they are built in hardhat commands. Read tasks are executed using a basic ethers provider
(no account), e.g:

```bash
npx hardhat --network testnet validatorPool:submitApplication --signer <validator address> --conspubkey <validator consensus address> --moniker <mezod moniker>
```

### How to Submit an application to Validator Pool

Here is a step by step guide on how to submit an application to the PoA validator pool.

```bash
# set your private key
npx hardhat vars set MEZO_ACCOUNTS <your private key>

# fund your account

# submit your application to the validator pool. Available flags:
# --flow (docker|native) This is mandatory
# --network (testnet) Thi is optional, it defaults to testnet
./submit-application.sh --flow docker

# you can check your application
npx hardhat --network testnet validatorPool:application --signer <your validator address>
```
