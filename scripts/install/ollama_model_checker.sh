#!/bin/bash

set -euo pipefail

REQUIRED_MODELS=(
  "qwen2.5vl"
  "nomic-embed-text"
)

echo "🤖 Checking for required Ollama models..."

for model in "${REQUIRED_MODELS[@]}"; do
  if ollama list | grep -q "$model"; then
    echo "✅ Model '$model' is already installed."
  else
    echo "⬇️  Model '$model' not found. Downloading..."
    ollama pull "$model"
  fi
done

echo "🎉 All required models are ready!"
