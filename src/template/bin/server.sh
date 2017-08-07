#!/bin/sh
#
# Server script for applications with embedded servlet container.
################################################################

#
# Properties
#


# Read init parameters
ACTION=$1

# Infer directories
BIN_PATH=$(dirname "$0")
BASE_DIR=$(cd "$BIN_PATH/../" && pwd)
SERVICE_NAME=$BASE_DIR

HEALTH_CHECK=$BIN_PATH/healthcheck.sh
OOM_PATH=$BIN_PATH/oom.sh
JAR_PATH=$BIN_PATH/app.jar
CONFIG_PATH=file:$BASE_DIR/var/app.properties
PID_PATH=$BASE_DIR/var/process-pid
LOGDIR_PATH=$BASE_DIR/var/log
JUL_LOG_FILE=$BASE_DIR/var/log/jul.log
JMX_PORT=7299
HEAP_DUMP_PATH=$BASE_DIR/var/heapdump

# No: 0 or Yes: 1
JVM_DEBUG_ENABLED=0

# No: n or Yes: y
JVM_DEBUG_SUSPEND=n

JVM_DEBUG_PORT=7301

# Java Heap Settings
GC_MAX_HEAP_SIZE=256m
GC_START_HEAP_SIZE=64m


#
# Preparations
#

# Prepare JVM command line

JVM_PROPS="-server"

# Logging Configuration
JVM_PROPS="$JVM_PROPS -Dapp.logback.logBaseName=$LOGDIR_PATH/app -Dapp.logback.rootLogId=ROLLING_FILE"

# Internal Java Logging
JVM_PROPS="$JVM_PROPS -Djava.util.logging.config.file=$JUL_LOG_FILE"

# Inet Settings
# TODO: enable if needed
# JVM_PROPS="$JVM_PROPS -Dsun.net.inetaddr.ttl=60 -Dnetworkaddress.cache.ttl=60 -Dsun.net.inetaddr.negative.ttl=10 -Djava.net.preferIPv4Stack=true"

# JMX Settigns
if [ ! -z "$ENABLE_DEV_JMX" ]; then
    JVM_PROPS="$JVM_PROPS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
fi

# OOM handling
JVM_PROPS="$JVM_PROPS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HEAP_DUMP_PATH"

# GC Heap Settings
JVM_PROPS="$JVM_PROPS -XX:+UseCompressedOops -Xmx$GC_MAX_HEAP_SIZE -Xms$GC_START_HEAP_SIZE"

# Debug Settings
if [ $JVM_DEBUG_ENABLED -eq 1 ]; then
  # TODO: consider adding -verbose:gc and -XX:+PrintGCDetails
  JVM_PROPS="$JVM_PROPS -agentlib:jdwp=transport=dt_socket,server=y,suspend=$JVM_DEBUG_SUSPEND,address=$JVM_DEBUG_PORT"
fi

echo "Using JVM settings: $JVM_PROPS"

#
# Server Start/Stop Functions
#

start_server ()
{
    echo "Starting $SERVICE_NAME ..."
    if [ ! -f $PID_PATH ]; then
        # Entry Point
        # Uses custom configuration as well as "live" log settings
        # Explicitly add out of memory error handling as bash is unable to expand quoted args
        nohup java $JVM_PROPS -XX:OnOutOfMemoryError=$OOM_PATH -Dbrikar.settings.path=$CONFIG_PATH -jar $JAR_PATH > $LOGDIR_PATH/nohup.out 2> $LOGDIR_PATH/nohup.err &
        echo $! > $PID_PATH
        echo "$SERVICE_NAME started ..."

        # Wait until healthcheck returns OK
        SERVER_STARTED=0
        for attempt in `seq 1 50`; do
            # Sleep one second
            echo "Attempt $attempt - waiting until server starts"
            sleep 1

            # Check if started
            HEALTH_CHECK_OUTPUT=`bash $HEALTH_CHECK`
            if [ "$HEALTH_CHECK_OUTPUT" = "OK" ]; then
                echo "Health check succeeded"
                SERVER_STARTED=1
                break
            fi
        done

        # Check if server actually started
        if [ "$SERVER_STARTED" -eq 0 ]; then
            echo "Health check failed, exiting..."
            exit 1
        fi 
    else
        echo "$SERVICE_NAME is already running ..."
    fi
}

stop_server ()
{
    STOP_SUCCEEDED=0

    if [ -f $PID_PATH ]; then
        PID=$(cat $PID_PATH);

        if ps -p $PID > /dev/null; then
            for attempt in `seq 1 50`; do
                # Sleep if attempt>1
                if [ "$attempt" -gt 1 ]; then
                    echo "Attempt $attempt - trying to stop server using pid=$PID"
                    sleep 1
                fi
      
                # Check if we still have process with the given pid
                if ps -p $PID > /dev/null; then
                    echo "Service $SERVICE_NAME is still running, attempting to stop..."
                else
                    STOP_SUCCEEDED=1
                    echo "Server stopped"
                    break
                fi
      
                # Use TERM instead of INT as SIGINT does not work for nohup processes
                kill -TERM $PID
            done
        else
            STOP_SUCCEEDED=1
            echo "Server $SERVICE_NAME already stopped"
        fi

        # Check if stop succeeded
        if [ "$STOP_SUCCEEDED" -eq 0 ]; then
            echo "Failed to stop server, exiting..."
            exit 1
        fi

        rm $PID_PATH
    else
        echo "$SERVICE_NAME is not running, stop is not required ..."
    fi
}

if [ -z $ACTION ]; then
    echo "Server start action has not been set, expected: start, stop or restart."
    exit 1
fi

echo "About to $ACTION server..."

case $ACTION in
    start)
        start_server
    ;;
    stop)
        stop_server
    ;;
    restart)
        stop_server
        start_server
    ;;
esac

echo "Done."

