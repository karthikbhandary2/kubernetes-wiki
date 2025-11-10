#!/bin/sh
set -e

echo "Current directory: $(pwd)"
echo "Python path: $PYTHONPATH"

mkdir -p /data
ln -sf /data/app.db /app/app.db

echo "Starting FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
