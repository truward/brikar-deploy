# !/bin/bash

# The output of healthcheck script should be exactly "OK" to consider health check to be successful.

set -e

BIN_PATH=$(dirname "$0")
bash "$BIN_PATH/../tools/api.sh" healthcheck

