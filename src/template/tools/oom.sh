#!/usr/bin/env bash

TOOLS_DIR=$(dirname "$0")
source "$TOOLS_DIR/common.sh"

if [ -f $PID_PATH ]; then
  PID=$(cat $PID_PATH)
  kill -9 $PID
  rm $PID_PATH
fi
