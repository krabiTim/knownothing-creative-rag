#!/bin/bash

echo "🧹 CLEANING UP PROBLEMATIC MORPHIK INSTALLATIONS"
echo "=============================================="

docker compose down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

rm -rf ~/creative-rag-system
rm -rf ~/morphik-core
rm -rf ~/morphik-bide
rm -rf ~/creative-rag-morphik
rm -rf ~/creative-rag-wsl

docker system prune -f
docker volume prune -f
docker image prune -a -f

docker volume create postgres_data_keep
docker volume create redis_data_keep
docker volume create ollama_data_keep

echo "✅ Cleanup complete! Ready for fresh start."
