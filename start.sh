#!/bin/sh
set -e

echo "Waiting for Docker to start..."
dockerd-entrypoint.sh &

# Wait for Docker socket to be ready
until docker info >/dev/null 2>&1; do
  sleep 1
done
echo "Docker is ready!"

# Start k3d cluster (single node)
echo "Creating k3d cluster..."
k3d cluster create wiki-cluster --servers 1 --agents 1 -p "8000:80@loadbalancer" --wait || true

echo "k3d cluster ready!"
echo "Access your cluster inside this container using kubectl."

# Keep container alive
tail -f /dev/null
