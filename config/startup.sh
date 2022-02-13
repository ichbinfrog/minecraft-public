#!/bin/bash

docker run -d -p 25565:25565 \
%{ for k, v in CONTAINER_ENV ~}
    -e ${k}=${v} \
%{ endfor ~}
    --name mc \
    --restart on-failure:3 \
    -v ${MOUNT_DIR}:/data \
    ${IMAGE}
