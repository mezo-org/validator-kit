# Validator kit

## Overview

This repository contains the validator kit for Mezo chain. The validator kit is a collection of tools and documentation to help you run a validator node on Mezo chain. There are a couple of main components of the validator kit:

1. Docker Compose - contains files to run a validator node using Docker. This is the recommended way to run a validator node as it requires less setup and maintenance.

2. Native Binary - contains files to fetch the `mezod` binary from a remote repository and run it manually. This is an alternative way to run a validator node if you prefer to run it natively.

3. Helm chart - contains files to deploy a validator node on a Kubernetes cluster. This is an advanced way to run a validator node if you have a Kubernetes cluster.

4. Tools Hardhat - this toolset provides a collection of Hardhat tasks designed to simplify interactions with the blockchain’s Proof-of-Authority (PoA) based network. E.g. you can submit your application to become one of the PoA validators.

5. Monitoring stack for Docker Compose - contains files to run a monitoring stack for your validator node using Docker. This is an optional way to monitor your validator node.

As a validator you can chose between option 1, 2 and 3 to run your validator node.
Point 4 is common for all.
In other words as a validator you can follow 1 or 2 or 3 -> 4 flow.

The monitoring stack is dedicated to the Docker Compose setup. You can use it
for Native Binary after some adjustments (not covered in this repo).

## Acknowledgements

Shout out to [thevops](https://github.com/thevops) and [tscrond](https://github.com/tscrond) from [Boar.network](https://boar.network/) for implementing Docker Compose, Native Binary and Helm chart kit!
