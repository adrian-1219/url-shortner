#!/bin/bash
USAGE="Usage: $0 IP1 IP2 IP3 ..."

if [ "$#" == "0" ]; then
        echo "$USAGE"
        exit 1
fi

./stopCassandraCluster.sh "$@"
docker stack rm a2
MASTER="$1"
while (( "$#" )); do
	echo "$1"
        if [ "$1" = "$MASTER" ]; 
        then
		docker swarm leave --force
        else
		ssh student@$1 "docker swarm leave --force;"
        fi
  
        shift
done
