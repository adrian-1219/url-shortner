#!/bin/bash
USAGE="Usage: $0 MASTERIP IP"

if [ "$#" != "2" ]; then
        echo "$USAGE"
        exit 1
fi

COMMAND="docker run -v /home/student/cassandraVolume:/var/lib/cassandra --name cassandra-node -d -e CASSANDRA_BROADCAST_ADDRESS=$2 -p 7000:7000 -p 9042:9042 -e CASSANDRA_SEEDS=$1 cassandra"
        
ssh student@$2 "mkdir -p /home/student/cassandraVolume; docker container stop cassandra-node; docker container rm cassandra-node; $COMMAND;"

        while true;
        do
                sleep 5
                STATUS=$(docker exec -it cassandra-node nodetool status | grep -e $2)
                STATUSUN=$(echo $STATUS | grep -e "UN")
                echo $STATUS
                [[ ! -z "$STATUSUN" ]] && break;
        done;
        shift
