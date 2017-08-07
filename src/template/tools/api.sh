# !/bin/bash

# Get input parameters
ACTION=$1

# Fail on error
set -e

# Infer directories
TOOLS_PATH=$(dirname "$0")
BASE_DIR=$(cd "$TOOLS_PATH/../" && pwd)

function prop {
  grep "${1}" $BASE_DIR/var/app.properties|cut -d'=' -f2
}

PORT=8080
SVC_URI="http://127.0.0.1:$PORT"
SVC_CREDS="testonly:test"

# Customize port/service URI, depending on whether they are included in app.properties:
#PORT="$(prop 'brikar.settings.port')"
#SVC_URI="http://127.0.0.1:$PORT"
#SVC_CREDS="$(prop 'userService.auth.1.username'):$(prop 'userService.auth.1.password')"

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

