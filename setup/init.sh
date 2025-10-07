#!/usr/bin/env bash

USER="fcoppens"
ROOT="/home/$USER/LibreChat"

cp -v $ROOT/setup/env $ROOT/.env
cd $ROOT
docker compose up -d
su -m root -c 'chown -Rv $USER:users \
    data-node \
    images \
    logs \
    meili_data_v1.12 \
    uploads'
watch -c -n 1 docker compose ps
