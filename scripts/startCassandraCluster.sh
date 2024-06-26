#!/bin/bash
USAGE="Usage: $0 IP1 IP2 IP3 ..."

if [ "$#" == "0" ]; then
        echo "$USAGE"
        exit 1
fi

MASTER="$1"
while (( "$#" )); do
	echo "$1"
        if [ "$1" = "$MASTER" ]; 
        then
                COMMAND="docker run -v /home/student/cassandraVolume:/var/lib/cassandra --name cassandra-node -d -e CASSANDRA_BROADCAST_ADDRESS=$1 -p 7000:7000 -p 9042:9042 cassandra"
        else
                COMMAND="docker run -v /home/student/cassandraVolume:/var/lib/cassandra --name cassandra-node -d -e CASSANDRA_BROADCAST_ADDRESS=$1 -p 7000:7000 -p 9042:9042 -e CASSANDRA_SEEDS=$MASTER cassandra"
        fi
        # ssh student@$1 "docker container stop cassandra-node"
        # ssh student@$1 "docker container rm cassandra-node"
        # ssh student@$1 "$COMMAND"

        ssh student@$1 "mkdir -p /home/student/cassandraVolume; docker container stop cassandra-node; docker container rm cassandra-node; $COMMAND;"
        sleep 10
        while true;
        do
                sleep 5
                STATUS=$(docker exec -it cassandra-node nodetool status | grep -e $1)
                STATUSUN=$(echo $STATUS | grep -e "UN")
                echo $STATUS
                [[ ! -z "$STATUSUN" ]] && break;
        done;
        shift
done
