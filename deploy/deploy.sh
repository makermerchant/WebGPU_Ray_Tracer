#!/usr/bin/env sh
# Pulls the latest code and rebuilds the container. Run on the VPS from the clone.
set -eu
cd "$(dirname "$0")/.."
git pull --ff-only
docker compose -f deploy/docker-compose.yml up -d --build
docker image prune -f >/dev/null
