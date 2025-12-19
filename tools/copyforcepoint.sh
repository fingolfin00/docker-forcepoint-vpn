#!/usr/bin/env bash

SERVERPATH=$1
LOCALPATH=$2

FILENAME=$(basename ${SERVERPATH})
CONTAINERID=$(docker container ls -lq)
COPYCMD="scp"
# COPYCMD="rsync -L --progress"
CONTAINERHOME=$(docker exec ${CONTAINERID} bash -c 'echo "$HOME"')
echo $FILENAME $CONTAINERID $CONTAINERHOME

docker container exec -it ${CONTAINERID} ${COPYCMD} ${SERVERPATH} ${CONTAINERHOME}/${FILENAME}
docker container cp ${CONTAINERID}:${CONTAINERHOME}/${FILENAME} ${LOCALPATH}

