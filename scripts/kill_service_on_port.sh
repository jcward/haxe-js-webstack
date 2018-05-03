#!/bin/bash
# Kill a PID that is listening on the given port

PORT=$1

# Kill by netstat listing (todo port?)
PID=`(netstat -lpunt | grep :$PORT | awk '{print $7}' | awk -F"/" '{print $1}') 2> /dev/null`
while [ ! -z $PID ]; do
    echo "Killing existing $PID"
    kill $PID
    sleep 0.25
    PID=`(netstat -lpunt | grep :$PORT | awk '{print $7}' | awk -F"/" '{print $1}') 2> /dev/null`
done
