#!/bin/sh
#
# Server script for deploying applications with embedded servlet container.
# 2015 Alexander Shabanov
################################################################

# Exit on error
set -e

#
# Check input properties
#

if [ -z "$SERVICE_NAME" ]; then
    echo "ERROR: Please, set up SERVICE_NAME environment variable before running this script"
    exit -1
fi

if [ -z "$SRC_PROPS" ]; then
    echo "ERROR: Please, set up SRC_PROPS (path to source app properties) variable before running this script"
    exit -1
fi

#
# Check for existence of source files
#

if [ ! -z "$SRC_JAR" ]; then
    if [ ! -f $SRC_JAR ]; then
        echo "ERROR: No jar file at $SRC_JAR"
        exit -1
    fi
fi

if [ ! -f $SRC_PROPS ]; then
    echo "ERROR: No property file at $SRC_PROPS"
    exit -1
fi

#
# Set up directory
#

BASE_DIR=/usr/local/$SERVICE_NAME
I_AM=`whoami`

mkdir -p $BASE_DIR/var/log

if [ ! -z "$SRC_JAR" ]; then
    cp $SRC_JAR $BASE_DIR/app.jar
fi

cp $SRC_PROPS $BASE_DIR/var/app.properties

