#!/bin/bash

while true
do
	docker exec -it cassandra-node nodetool status
	IP=$(docker exec -it cassandra-node nodetool status | grep DN | awk '{print $2}')
	if [ ! -z "$IP" ]
	then
		ssh student@$IP "docker restart cassandra-node"
	fi
	sleep 5

done
