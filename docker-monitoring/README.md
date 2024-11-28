# Docker Monitoring

## Runbooks

### Access Prometheus UI

Some of the services expose port only for internal Docker network. Prometheus is one of them. To access Prometheus UI, you need to use SSH tunneling.

```bash
# Get the IP address of the Prometheus container
ip="$(docker inspect --format json prometheus | jq -r '.[0].NetworkSettings.Networks.mezo.IPAddress')"

# Create an SSH tunnel
ssh -N -L 9090:$ip:9090 user@host
```
