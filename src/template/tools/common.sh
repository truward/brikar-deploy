#!/usr/bin/env bash

# Infer directories
TOOLS_DIR=$(dirname "$0")
BASE_DIR=$(cd "$TOOLS_DIR/../" && pwd)

# Infer application name
APP_NAME_FILE="$BASE_DIR/name.txt"
if [ ! -f $APP_NAME_FILE ]; then
  echo "Missing $APP_NAME_FILE"
  exit -1
fi
APP_NAME=$(cat $APP_NAME_FILE)

BIN_DIR="$BASE_DIR/bin"
CUSTOM_APP_SETTINGS_DIR="$HOME/.brikar/$APP_NAME"
VAR_DIR="/opt/var/$APP_NAME"
LOGS_DIR="$VAR_DIR/log"

if [ ! -d "$LOGS_DIR" ]; then
  mkdir -p "$LOGS_DIR"
fi

PID_PATH="$VAR_DIR/process-pid"

# Get properties file
PROPERTIES_FILE="$BASE_DIR/init/app.properties"

VAR_PROPERTIES_FILE="$VAR_DIR/app.properties"
if [ -f "$VAR_PROPERTIES_FILE" ]; then
  PROPERTIES_FILE="$VAR_PROPERTIES_FILE"
fi

CUSTOM_PROPERTIES_FILE="$CUSTOM_APP_SETTINGS_DIR/app.properties"
if [ -f "$CUSTOM_PROPERTIES_FILE" ]; then
  PROPERTIES_FILE="$CUSTOM_PROPERTIES_FILE"
fi

# Helper function to extract app property values
function prop {
  grep "${1}" "$PROPERTIES_FILE" | cut -d '=' -f2
}
