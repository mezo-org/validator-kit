# Validator kit

## Overview

This repository contains the validator kit for Mezo chain. The validator kit is a collection of tools and documentation to help you run a validator node on Mezo chain. There are three main components of the validator kit:

1) Docker Compose - contains files to run a validator node using Docker. This is the recommended way to run a validator node as it requires less setup and maintenance.

2) Native Binary - contains files to fetch the `mezod` binary from GCP Artifacts Registry and run it manually. This is an alternative way to run a validator node if you prefer to run it natively.

3) Tools Hardhat - tasks to help you with the validator node management. This is a collection of tasks that can be used to interact with the validator node e.g. submit your application to become one of the PoA validators.

As a validator you can chose between option 1) and 2) to run your validator node. Option 3) is common for both. In other words as a validator you can follow 1) -> 3) OR 2) -> 3) flow.

## Acknowledgements

Shout out to [thevops](https://github.com/thevops) and [tscrond](https://github.com/tscrond) from [Boar.network](https://boar.network/) for implementing Docker Compose and Native Binary kit!
