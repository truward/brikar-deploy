#!/usr/bin/env bash

# Include common script base
TOOLS_DIR=$(dirname "$0")
source "$TOOLS_DIR/common.sh"

# Get input parameters
ACTION=$1

# Infer application target parameters
HOST=$(prop 'brikar.tools.host')
PORT=$(prop 'brikar.tools.port')
SVC_URI="$HOST:$PORT"
SVC_CREDS="$(prop 'brikar.tools.username'):$(prop 'brikar.tools.password')"

# Execute toolbox action
case $ACTION in
  healthcheck)
    curl -u $SVC_CREDS -s -X POST $SVC_URI/api/health
    ;;
  h)
    echo "Interactive service toolbox"
    echo "Parameters:"
    echo "  Base URI:     $SVC_URI"
    echo "  Credentials:  $SVC_CREDS"
    ;;
  *)
    echo "Unknown action $ACTION"
esac

