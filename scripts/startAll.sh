#!/bin/bash
USAGE="Usage: $0 IP1 IP2 IP3 ..."

if [ "$#" == "0" ]; then
        echo "$USAGE"
        exit 1
fi

./startCassandraCluster.sh "$@"

MASTER="$1"
while (( "$#" )); do
	echo "$1"
        if [ "$1" = "$MASTER" ]; 
        then
		COMMAND=$(docker swarm init --advertise-addr $1 | grep "docker swarm join --token")
		echo $COMMAND > dockerSwarmToken
		mkdir -p /home/student/urlShortnerLogs
		mkdir -p /home/student/cassandraVolume
		mkdir -p /home/student/redisVolume
	        docker pull zhaoalan/csc409:python-url-shortner
	        git pull
        else
		ssh student@$1 "$COMMAND; docker pull zhaoalan/csc409:python-url-shortner; mkdir -p /home/student/urlShortnerLogs; mkdir -p /home/student/cassandraVolume; mkdir -p /home/student/redisVolume; docker pull zhaoalan/csc409:python-url-shortner; cd a2group98; "
        fi
  
        shift
done

docker stack deploy -c /home/student/a2group98/docker-compose.yml a2
./cassandraMonitor.sh
