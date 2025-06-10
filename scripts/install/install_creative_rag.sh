#!/bin/bash

set -e
set -o pipefail

LOG_FILE=~/creative_rag_install.log
exec > >(tee -i $LOG_FILE)
exec 2>&1

echo "🧹 STEP 1: Cleaning up previous installations..."
bash ./cleanup_morphik.sh

echo "📁 STEP 2: Creating project structure..."
bash ./setup_creative_rag.sh

cd ~/creative-rag-multimodal

echo "🔧 STEP 3: Installing Poetry dependencies..."
if ! command -v poetry &> /dev/null; then
  echo "📦 Installing Poetry..."
  curl -sSL https://install.python-poetry.org | python3 -
  export PATH="$HOME/.local/bin:$PATH"
fi

poetry install

echo "🐳 STEP 4: Starting Docker services..."
docker compose up -d

echo "🔎 STEP 5: Verifying services..."
sleep 10

function check_service() {
  SERVICE=$1
  docker inspect --format='{{.State.Health.Status}}' $SERVICE 2>/dev/null || echo "unhealthy"
}

for svc in postgres redis; do
  STATUS=$(check_service $svc)
  if [[ "$STATUS" != "healthy" ]]; then
    echo "❌ Service $svc failed health check. Please check logs with: docker compose logs $svc"
    exit 1
  else
    echo "✅ $svc is healthy"
  fi
done

echo "🚦 STEP 6: GPU availability check..."
poetry run python3 -c "import torch; print(f'GPU Available: {torch.cuda.is_available()}'); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'No GPU')"

echo "🎉 All done! Visit http://localhost:8000/docs to try the API."
