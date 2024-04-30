#!/bin/bash
USAGE="Usage: $0 IP"

if [ "$#" != "1" ]; then
        echo "$USAGE"
        exit 1
fi


HOSTID=$(docker exec -it cassandra-node nodetool status | grep $1 | awk '{print $(NF-1)}')

ssh student@$1 "docker container stop cassandra-node; docker container rm cassandra-node;"
docker exec -it cassandra-node nodetool removenode $HOSTID
