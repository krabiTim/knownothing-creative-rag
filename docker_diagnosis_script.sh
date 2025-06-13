#!/bin/bash

echo "🐳 === DOCKER & OLLAMA DIAGNOSIS ==="
echo "Checking if models were in Docker and need container restart"
echo "====================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"

# Step 1: Check Docker status and containers
echo ""
echo "🐳 STEP 1: DOCKER STATUS CHECK"

if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        echo "✅ Docker daemon is running"
        
        # Check for any Ollama-related containers
        echo ""
        echo "📋 Checking for Ollama containers:"
        OLLAMA_CONTAINERS=$(docker ps -a --filter name=ollama --format "table {{.Names}}\t{{.Status}}\t{{.Image}}")
        if [ -n "$OLLAMA_CONTAINERS" ]; then
            echo "$OLLAMA_CONTAINERS"
        else
            echo "❌ No Ollama containers found"
        fi
        
        # Check for any knownothing containers
        echo ""
        echo "📋 Checking for knownothing-creative-rag containers:"
        KN_CONTAINERS=$(docker ps -a --filter name=knownothing --format "table {{.Names}}\t{{.Status}}\t{{.Image}}")
        if [ -n "$KN_CONTAINERS" ]; then
            echo "$KN_CONTAINERS"
        else
            echo "❌ No knownothing containers found"
        fi
        
        # Check all running containers
        echo ""
        echo "📋 All running containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"
        
    else
        echo "❌ Docker daemon not running"
        echo "   Try: sudo systemctl start docker"
    fi
else
    echo "❌ Docker not installed"
fi

# Step 2: Check Docker Compose files
echo ""
echo "🐳 STEP 2: DOCKER COMPOSE CONFIGURATION CHECK"

if [ -f "docker-compose.yml" ]; then
    echo "✅ Found docker-compose.yml in root"
    echo "   Ollama services found:"
    grep -A 5 -B 2 "ollama" docker-compose.yml || echo "   No ollama services in root compose file"
elif [ -f "configs/docker/docker-compose.yml" ]; then
    echo "✅ Found docker-compose.yml in configs/docker/"
    echo "   Ollama services found:"
    grep -A 5 -B 2 "ollama" configs/docker/docker-compose.yml || echo "   No ollama services in configs compose file"
else
    echo "❌ No docker-compose.yml found"
fi

# Check for other Docker configs
echo ""
echo "📁 Docker-related files in project:"
find . -name "Dockerfile*" -o -name "docker-compose*" -o -name "*.yml" | grep -v ".git" | head -10

# Step 3: Check current Ollama process
echo ""
echo "🔍 STEP 3: CURRENT OLLAMA PROCESS ANALYSIS"

echo "Current Ollama processes:"
ps aux | grep ollama | grep -v grep || echo "No Ollama processes found"

echo ""
echo "Ollama process details:"
if pgrep ollama > /dev/null; then
    OLLAMA_PID=$(pgrep ollama)
    echo "PID: $OLLAMA_PID"
    echo "Command line: $(ps -p $OLLAMA_PID -o args --no-headers)"
    echo "Working directory: $(lsof -p $OLLAMA_PID 2>/dev/null | grep cwd | awk '{print $9}')"
    echo "Open files: $(lsof -p $OLLAMA_PID 2>/dev/null | wc -l) files open"
else
    echo "No Ollama process running"
fi

# Step 4: Check Ollama installation method
echo ""
echo "🔍 STEP 4: OLLAMA INSTALLATION METHOD"

echo "Ollama binary location:"
which ollama || echo "Ollama not in PATH"

echo ""
echo "Ollama version:"
ollama --version 2>/dev/null || echo "Cannot get Ollama version"

echo ""
echo "Is Ollama a Docker container?"
if docker ps --format "{{.Names}}" | grep -q ollama; then
    echo "✅ Ollama appears to be running in Docker"
    docker ps --filter name=ollama --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"
else
    echo "❌ Ollama not running in Docker (or Docker not running)"
fi

echo ""
echo "Is Ollama a system service?"
if systemctl is-active ollama &>/dev/null; then
    echo "✅ Ollama is running as systemd service"
    systemctl status ollama --no-pager
elif service ollama status &>/dev/null; then
    echo "✅ Ollama is running as system service"
    service ollama status
else
    echo "❌ Ollama not running as system service"
fi

# Step 5: Check for model storage in Docker volumes
echo ""
echo "🐳 STEP 5: DOCKER VOLUME CHECK"

if command -v docker &> /dev/null && docker info &> /dev/null; then
    echo "Docker volumes (looking for ollama data):"
    docker volume ls | grep -i ollama || echo "No ollama volumes found"
    
    echo ""
    echo "All Docker volumes:"
    docker volume ls | head -10
    
    # Check if there are any volumes with models
    echo ""
    echo "Checking volumes for model data:"
    for vol in $(docker volume ls -q); do
        if docker run --rm -v $vol:/data alpine find /data -name "*gguf" -o -name "*bin" 2>/dev/null | head -1 | grep -q .; then
            echo "📦 Volume $vol may contain models:"
            docker run --rm -v $vol:/data alpine ls -la /data 2>/dev/null | head -5
        fi
    done
else
    echo "Cannot check Docker volumes (Docker not available)"
fi

# Step 6: Recommendations
echo ""
echo "🎯 RECOMMENDATIONS BASED ON FINDINGS:"

# Check what we found and give specific advice
if docker ps --filter name=ollama -q | grep -q .; then
    echo -e "${YELLOW}🐳 DOCKER OLLAMA DETECTED${NC}"
    echo "Your models are likely in the Docker container."
    echo ""
    echo "To restore your models:"
    echo "1. Check container status: docker ps -a --filter name=ollama"
    echo "2. Start container if stopped: docker start <ollama-container-name>"
    echo "3. Or restart the whole stack: docker-compose up -d"
    echo "4. Check models: docker exec <ollama-container> ollama list"
    
elif [ -f "configs/docker/docker-compose.yml" ] && grep -q "ollama" configs/docker/docker-compose.yml; then
    echo -e "${YELLOW}🐳 DOCKER COMPOSE SETUP DETECTED${NC}"
    echo "Your project was configured to use Docker Compose with Ollama."
    echo ""
    echo "To restore your setup:"
    echo "1. cd configs/docker/"
    echo "2. docker-compose up -d"
    echo "3. Wait for containers to start"
    echo "4. Check: docker-compose exec ollama ollama list"
    
elif pgrep ollama > /dev/null; then
    echo -e "${GREEN}🖥️ NATIVE OLLAMA DETECTED${NC}"
    echo "Ollama is running natively (not in Docker)."
    echo "Models were likely deleted during an update/reinstall."
    echo ""
    echo "To restore:"
    echo "1. ollama pull llama3.2-vision"
    echo "2. ollama pull qwen2.5vl:latest"
    echo "3. ollama pull nomic-embed-text"
    
else
    echo -e "${RED}❓ UNCLEAR SETUP${NC}"
    echo "Cannot determine how Ollama was running."
    echo "Check the specific recommendations above."
fi

echo ""
echo "🔍 Diagnosis complete! Check recommendations above."
