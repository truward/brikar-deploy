#!/bin/sh
#
# Deployment script for AWS EC2 servers.
# 2015 Alexander Shabanov
################################################################

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

if [ -z "$AWS_PEM" ]; then
    echo "ERROR: Please, set up AWS_PEM (PEM file location) variable before running this script"
    exit -1
fi

if [ -z "$AWS_HOSTNAME" ]; then
    echo "ERROR: Please, set up AWS_HOSTNAME (AWS EC2 hostname) variable before running this script"
    exit -1
fi

if [ -z "$AWS_LOGIN" ]; then
    echo "ERROR: Please, set up AWS_LOGIN (AWS EC2 login name, e.g. ubuntu, ec2-user, etc.) variable before running this script"
    exit -1
fi

if [ -z "$SRC_JAR" ]; then
    echo "INFO: Source jar is missing, skipping jar checks and copy"
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

if [ ! -f $AWS_PEM ]; then
    echo "ERROR: No pem file at $AWS_PEM"
    exit -1
fi

echo "[OK] Initial checks"

#
# Variables
#

RAND_PREFIX=$(xxd -l 10 -p /dev/random)

if [ ! -z "$SRC_JAR" ]; then
    TARGET_JAR=/tmp/$RAND_PREFIX-app.jar
else
    TARGET_JAR=
fi

TARGET_PROPS=/tmp/$RAND_PREFIX-app.properties

TEMP_LAYOUT_SCRIPT=/tmp/$RAND_PREFIX-setup-layout.sh
TEMP_SERVER_SCRIPT=/tmp/$RAND_PREFIX-server.sh

#
# Deploy and restart
#

if [ ! -z "$SRC_JAR" ]; then
    scp -i $AWS_PEM $SRC_JAR $AWS_LOGIN@$AWS_HOSTNAME:$TARGET_JAR
    echo "[OK] Copied $SRC_JAR to $TARGET_JAR"
fi

scp -i $AWS_PEM $SRC_PROPS $AWS_LOGIN@$AWS_HOSTNAME:$TARGET_PROPS
echo "[OK] Copied $SRC_PROPS to $TARGET_PROPS"

# Create contents of TEMP_LAYOUT_SETTER
echo "
export SERVICE_NAME=$SERVICE_NAME
export SRC_JAR=$TARGET_JAR
export SRC_PROPS=$TARGET_PROPS
" > $TEMP_LAYOUT_SCRIPT
cat setup-layout.sh >> $TEMP_LAYOUT_SCRIPT
echo "[OK] Temporary directory structure script created at $TEMP_LAYOUT_SCRIPT"

# Create contents of TEMP_SERVER_SCRIPT
echo "
export SERVICE_NAME=$SERVICE_NAME
export SERVER_START_ACTION=restart
" > $TEMP_SERVER_SCRIPT
cat server.sh >> $TEMP_SERVER_SCRIPT
echo "[OK] Temporary server script created at $TEMP_SERVER_SCRIPT"

# Execute scripts
ssh -i $AWS_PEM $AWS_LOGIN@$AWS_HOSTNAME 'bash -s' < $TEMP_LAYOUT_SCRIPT
echo "[OK] Temporary directory script executed"

ssh -i $AWS_PEM $AWS_LOGIN@$AWS_HOSTNAME 'bash -s' < $TEMP_SERVER_SCRIPT
echo "[OK] Temporary server script executed, server should be restarted"

# Cleanup

if [ -z "$KEEP_TEMP_FILES" ]; then
    rm -rf /tmp/${RAND_PREFIX}*
    ssh -i $AWS_PEM $AWS_LOGIN@$AWS_HOSTNAME "rm -rf /tmp/${RAND_PREFIX}*"
    echo "[OK] Cleanup done"
fi
