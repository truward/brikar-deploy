#!/usr/bin/env bash

TOOLS_DIR=$(dirname "$0")
source "$TOOLS_DIR/common.sh"

# Put custom installation steps here.
# This file is ran every time server attempted to be started
# If this file exits with non-success error code, e.g. ``exit 1``
# server fails to start.
