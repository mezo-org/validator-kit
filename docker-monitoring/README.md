# Docker Monitoring

## Setup

### Prerequisites

- Docker
- Docker Compose

### Steps

1. Clone the repository

2. Prepare configuration file

```shell
cp monitoring.env.example monitoring.env
# Edit the file
```

- `NETWORK` - testnet or mainnet - the network to monitor
- `DOMAIN` - public domain used to issue SSL certificate (Let's Encrypt) and access Grafana UI.
If you don't have any, use your.public.ip.address.nip.io (Check out https://nip.io/)
- `GRAFANA_ADMIN_USER` - Grafana admin username
- `GRAFANA_ADMIN_PASSWORD` - Grafana admin password
- `CONFIG_PATH` - custom path to configuration folder. Can be used with
`make customize-configs` to move config files outside Git folder.
It's useful when you want to customize configs and update your stack
from time to time. Running `git pull` will not overwrite your custom folder,
and `make diff-custom-configs` helps in comparing changes.

3. Run the stack

```shell
make start
```

> Check out `make help` for more commands.


## Runbooks

### Access Prometheus UI

Some of the services expose ports only for internal Docker network.
Prometheus is one of them. To access Prometheus UI, you need to use SSH tunneling.

```bash
# Get the IP address of the Prometheus container
ip="$(docker inspect --format json prometheus | jq -r '.[0].NetworkSettings.Networks.mezo.IPAddress')"

# Create an SSH tunnel
ssh -N -L 9090:$ip:9090 user@host
```
