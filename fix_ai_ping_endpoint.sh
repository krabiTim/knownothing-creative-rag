#!/bin/bash

echo "🔍 === DEBUGGING AI PING ENDPOINT ==="
echo "Finding and fixing the 404 issue"
echo "=================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Let's check what endpoints are actually available..."

# Test available endpoints
echo ""
echo "📡 Testing available endpoints:"

echo -n "🧪 Root endpoint... "
if curl -s http://localhost:8000/ >/dev/null; then
    echo -e "${GREEN}✅ Working${NC}"
else
    echo -e "${RED}❌ Failed${NC}"
fi

echo -n "🧪 Health endpoint... "
if curl -s http://localhost:8000/health >/dev/null; then
    echo -e "${GREEN}✅ Working${NC}"
else
    echo -e "${RED}❌ Failed${NC}"
fi

echo -n "🧪 Documents list... "
if curl -s http://localhost:8000/api/documents/list >/dev/null; then
    echo -e "${GREEN}✅ Working${NC}"
else
    echo -e "${RED}❌ Failed${NC}"
fi

echo -n "🧪 AI ping endpoint... "
if curl -s http://localhost:8000/api/ai/ping >/dev/null; then
    echo -e "${GREEN}✅ Working${NC}"
else
    echo -e "${RED}❌ 404 Not Found${NC}"
fi

echo ""
echo "🔍 Let's check what's actually available in the API docs:"
echo "📋 Available endpoints from /docs:"
curl -s http://localhost:8000/openapi.json | grep -o '"paths":{[^}]*}' | grep -o '"/[^"]*"' | sort

echo ""
echo "🔍 Let's check if there are different AI endpoints:"
curl -s http://localhost:8000/openapi.json | grep -i "ai\|ping\|llama\|ollama"

echo ""
echo "🔧 POTENTIAL FIXES:"
echo ""
echo "1️⃣  **Check if endpoint exists with different path**:"
echo "   Try: curl http://localhost:8000/ai/ping"
echo "   Try: curl http://localhost:8000/ping"
echo "   Try: curl http://localhost:8000/api/ping"
echo ""
echo "2️⃣  **Check your src/main.py for AI endpoint**:"
echo "   grep -n 'ai.*ping\\|ping.*ai' src/main.py"
echo ""
echo "3️⃣  **Add missing AI ping endpoint**:"
echo "   The endpoint might not be registered properly"
echo ""

# Try alternative paths
echo "🧪 Testing alternative AI endpoint paths:"

for endpoint in "/ai/ping" "/ping" "/api/ping" "/api/ai" "/api/ai/status" "/api/ai/health"; do
    echo -n "   Testing $endpoint... "
    if curl -s "http://localhost:8000$endpoint" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Found!${NC}"
        echo "      Response: $(curl -s "http://localhost:8000$endpoint" | head -c 100)..."
    else
        echo -e "${RED}❌ 404${NC}"
    fi
done

echo ""
echo "🔍 Checking your main.py for AI-related code:"
if [ -f "src/main.py" ]; then
    echo "📄 AI-related lines in src/main.py:"
    grep -n -i "ai\|ping\|ollama" src/main.py | head -10
    
    echo ""
    echo "📄 Router/endpoint registrations:"
    grep -n "@app\|router\|include_router" src/main.py | head -10
else
    echo "❌ src/main.py not found"
fi

echo ""
echo "💡 QUICK FIX OPTIONS:"
echo ""
echo "🔧 **Option 1: Add AI ping endpoint directly to main.py**"
echo "Add this to your src/main.py:"
echo ""
cat << 'AI_ENDPOINT_EOF'
@app.get("/api/ai/ping")
async def ping_ai():
    """Test AI connectivity"""
    try:
        import requests
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get("models", [])
            return {
                "status": "connected",
                "message": "🤖 AI is ready!",
                "models_available": len(models)
            }
    except:
        return {
            "status": "error",
            "message": "AI service not available"
        }
AI_ENDPOINT_EOF

echo ""
echo "🔧 **Option 2: Check if endpoint exists with different name**"
echo "Look at: http://localhost:8000/docs for actual endpoint names"
echo ""
echo "🔧 **Option 3: Restart server after adding endpoint**"
echo "After adding the endpoint, restart: poetry run python -m src.main"