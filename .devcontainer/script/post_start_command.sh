#!/bin/sh
echo "$(date '+%Y-%m-%dT%H:%M:%S+09:00') $0" | tee -a /home/node/workspace/init.log

echo "Starting dev-nginx-https service..." | tee -a /home/node/workspace/init.log
docker compose -f /dvc-wordpress/docker/dev-nginx-https/compose.yaml up -d | tee -a /home/node/workspace/init.log
