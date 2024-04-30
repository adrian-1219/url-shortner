#!/bin/bash
USAGE="Usage: $0 IP"

if [ "$#" != "1" ]; then
        echo "$USAGE"
        exit 1
fi

COMMAND=$(cat dockerSwarmToken) 
ssh student@$1 "$COMMAND;"

      
