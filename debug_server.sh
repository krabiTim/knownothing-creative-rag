#!/bin/bash

echo "🔍 === CREATIVE RAG DEBUGGING ==="
echo "Finding and fixing server issues"
echo "==============================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"
echo ""

# Check if server is running
echo "🔍 Checking if server is running..."
if lsof -i :8000 >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Something is running on port 8000${NC}"
    echo "Process on port 8000:"
    lsof -i :8000
    echo ""
    echo "🛑 Killing existing process..."
    pkill -f "python.*8000" || pkill -f "uvicorn.*8000" || pkill -f "poetry.*src.main"
    sleep 2
else
    echo -e "${GREEN}✅ Port 8000 is free${NC}"
fi

# Check project files
echo ""
echo "📁 Checking key project files..."
if [ -f "pyproject.toml" ]; then
    echo "✅ pyproject.toml exists"
else
    echo "❌ pyproject.toml missing - not in project directory?"
    exit 1
fi

if [ -f "src/main.py" ]; then
    echo "✅ src/main.py exists ($(wc -l < src/main.py) lines)"
else
    echo "❌ src/main.py missing"
fi

# Check which server files exist
echo ""
echo "🔍 Checking server files..."
ls -la *.py 2>/dev/null | grep -E "(main|server|app)" || echo "No main server files in root"

if [ -f "minimal_server.py" ]; then
    echo "✅ minimal_server.py exists ($(wc -l < minimal_server.py) lines)"
    MAIN_SERVER="minimal_server.py"
elif [ -f "src/main.py" ]; then
    echo "✅ src/main.py exists"
    MAIN_SERVER="src/main.py"
else
    echo "❌ No server file found"
    exit 1
fi

# Check Ollama status
echo ""
echo "🤖 Checking Ollama status..."
if ollama list >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Ollama is running${NC}"
    echo "Available models:"
    ollama list | grep -E "(qwen2.5vl|llama)"
else
    echo -e "${RED}❌ Ollama not running${NC}"
    echo "Starting Ollama..."
    ollama serve &
    sleep 3
fi

# Try to start the server
echo ""
echo "🚀 Starting Creative RAG server..."

if [ "$MAIN_SERVER" = "minimal_server.py" ]; then
    echo "Using minimal_server.py..."
    python minimal_server.py &
    SERVER_PID=$!
else
    echo "Using src/main.py..."
    poetry run python -m src.main &
    SERVER_PID=$!
fi

echo "Server PID: $SERVER_PID"
echo "Waiting for server to start..."
sleep 5

# Test if server responds
echo ""
echo "🧪 Testing server response..."
if curl -s http://localhost:8000/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Server is responding!${NC}"
    echo ""
    echo "🎉 SUCCESS! Your Creative RAG is running!"
    echo ""
    echo "🔗 Access Points:"
    echo "   🎨 Main Interface: http://localhost:8000"
    echo "   📡 API Docs: http://localhost:8000/docs"
    echo "   💚 Health Check: http://localhost:8000/health"
    echo ""
    echo "🧪 Quick Tests:"
    echo "   curl http://localhost:8000/health"
    echo "   curl http://localhost:8000/api/documents/list"
    
elif curl -s http://localhost:8000/ >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Server is responding on root!${NC}"
    echo "🔗 Access at: http://localhost:8000"
    
else
    echo -e "${RED}❌ Server not responding${NC}"
    echo ""
    echo "🔍 Checking server logs..."
    sleep 2
    
    # Check if process is still running
    if kill -0 $SERVER_PID 2>/dev/null; then
        echo "⚡ Server process is running but not responding"
        echo "This might be a startup issue. Let's check the logs..."
    else
        echo "💀 Server process died. Let's see what happened..."
    fi
    
    # Show any error output
    echo ""
    echo "📋 Recent error logs:"
    journalctl -u ollama --since "1 minute ago" --no-pager -n 5 2>/dev/null || echo "No systemd logs available"
    
    echo ""
    echo "🔧 TROUBLESHOOTING STEPS:"
    echo "1. Check if you're in the right directory: $(pwd)"
    echo "2. Ensure dependencies are installed: poetry install"
    echo "3. Check Python version: python --version"
    echo "4. Try minimal server: python minimal_server.py"
    echo "5. Check for import errors: python -c 'import src.main'"
fi

echo ""
echo "📊 System Status:"
echo "   Directory: $(pwd)"
echo "   Python: $(python --version 2>&1)"
echo "   Poetry: $(poetry --version 2>&1 || echo 'Not available')"
echo "   Ollama: $(ollama --version 2>&1 | head -1 || echo 'Not available')"
echo "   GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>/dev/null || echo 'No NVIDIA GPU detected')"

# Keep server running
if [ -n "$SERVER_PID" ] && kill -0 $SERVER_PID 2>/dev/null; then
    echo ""
    echo "🎯 Server is running with PID $SERVER_PID"
    echo "Press Ctrl+C to stop the server"
    wait $SERVER_PID
fi