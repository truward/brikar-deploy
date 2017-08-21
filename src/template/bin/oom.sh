#!/usr/bin/env bash

BIN_PATH=$(dirname "$0")

PID_PATH="$BIN_PATH/../var/process-pid"
PID=$(cat $PID_PATH)

kill -9 $PID
rm $PID_PATH

