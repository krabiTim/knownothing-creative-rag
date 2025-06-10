#!/bin/bash

echo "🔧 Checking Docker containers..."
docker ps

echo "📦 Checking Poetry virtualenv..."
poetry env info

echo "🔥 Checking GPU status..."
nvidia-smi || echo "⚠️ NVIDIA driver or GPU not found"

echo "🧪 Testing service endpoints..."
curl -s http://localhost:8000/api/health || echo "❌ API health check failed"
