#!/bin/bash
USAGE="Usage: $0 IP1 IP2 IP3 ..."

if [ "$#" == "0" ]; then
        echo "$USAGE"
        exit 1
fi

while (( "$#" )); do
        ssh student@$1 "docker container stop cassandra-node; docker container rm cassandra-node;"
        shift
done
