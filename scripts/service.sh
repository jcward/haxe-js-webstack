#!/bin/bash
# (re)start a service and write the pid to a file

# Source the env.source file
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source $SCRIPT_DIR/../tools/env.source

if [ $# -eq 0 ]; then
    echo "Usage: service.sh <start|stop> <name> <port> <dir> -- <cmd> [...]"
    exit 1
fi

ACTION=$1
NAME=$2
PORT=$3
DIR=$4
DASHDASH=$5 # Just for readability

shift
shift
shift
shift
shift

if [ "$ACTION" != "start" ] && [ "$ACTION" != "stop" ]; then
    echo "Invalid action $ACTION"
    exit 1
fi

if [ -z $PORT ]; then
    echo "Please specify a port"
    exit 1
fi

if [ "$DASHDASH" != "--" ]; then
    echo "Invalid formatting, missing --"
    exit 1
fi

mkdir -p $PWD/$DIR
cd $PWD/$DIR

# Kill existing by .pid file
if [ -f $NAME.pid ]; then
    KPID=`cat $NAME.pid`
    if [ ! -z $KPID ]; then
        echo "Killing existing $NAME / $KPID"
        kill $KPID 2> /dev/null
        rm $NAME.pid
        sleep 0.5
    fi
fi

$SCRIPT_DIR/kill_service_on_port.sh $PORT
sleep 0.5

if [ "$ACTION" == "stop" ]; then
  exit 0
fi

# Launch the rest of the args, writing stdout and stderr to log
$@ &> $NAME.log &
disown

# Write .pid file
sleep 0.1
PID=`ps | grep -i $NAME | awk '{print $1}'`
echo $PID > $NAME.pid
echo "Launched $NAME / $PID"

if [ -z $PID ]; then
    echo "Hmm, launch failed? Check $DIR/$NAME.log"
fi

