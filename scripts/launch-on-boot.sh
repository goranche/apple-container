#!/usr/bin/env bash

# Start container system, iterate over containers and start the ones
# that have a label named "restart" with the value "boot".

error() {
	>&2 echo $1
	exit 1
}

# Since container is by default installed to /usr/local/bin, and that is not in the path for launchd, we need to add it
PATH=$PATH:/usr/local/bin

# Some sanity checks

command -v container >/dev/null 2>&1 || error "container is not installed"
command -v jq >/dev/null 2>&1 || error "jq is not installed"

# Make sure the container system is up and running
container system start

# Just in case, not sure it's needed
sleep 3

for id in $(container list --all --format json | jq -r '[ .[] | select(.configuration.labels | has("restart")) | select(.configuration.labels.restart == "boot" ) | .configuration.id ] | to_entries[] | "\(.value)"'); do
	container start $id
done
