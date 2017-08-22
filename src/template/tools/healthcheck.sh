#!/usr/bin/env bash

# The output of healthcheck script should be exactly "OK" to consider health check to be successful.
set -e

TOOLS_DIR=$(dirname "$0")
bash "$TOOLS_DIR/api.sh" healthcheck
