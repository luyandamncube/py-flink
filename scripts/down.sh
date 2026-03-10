#!/bin/sh
set -eu

REMOVE_VOLUMES="${REMOVE_VOLUMES:-false}"

echo "Stopping demo stack..."

if [ "${REMOVE_VOLUMES}" = "true" ]; then
  docker compose down -v
  echo
  echo "Demo stack stopped and volumes removed."
else
  docker compose down
  echo
  echo "Demo stack stopped."
  echo "Persistent data was kept in Docker volumes."
  echo "Set REMOVE_VOLUMES=true to remove them too."
fi