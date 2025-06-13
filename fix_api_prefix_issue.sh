#!/bin/bash

echo "🔧 === FIX DOUBLE API PREFIX ISSUE ==="
echo "Correcting the /api/api/ prefix problem"
echo "===================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"

# Step 1: First let's test the current working endpoints
echo ""
echo "🧪 STEP 1: TEST CURRENT WORKING ENDPOINTS"

echo "Starting server to test current state..."
poetry run python -m src.main > server_test.log 2>&1 &
SERVER_PID=$!

sleep 5

if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "✅ Server running, testing endpoints..."
    
    # Test the double-prefix endpoints that should work
    echo -n "• Testing /api/api/ai/ping: "
    AI_RESPONSE=$(curl -s "http://localhost:8000/api/api/ai/ping" 2>/dev/null)
    if echo "$AI_RESPONSE" | grep -q "status\|message\|ollama"; then
        echo -e "${GREEN}✅ WORKING!${NC}"
        echo "   Response: $AI_RESPONSE"
        DOUBLE_PREFIX_WORKS=true
    else
        echo -e "${RED}❌ Failed: $AI_RESPONSE${NC}"
        DOUBLE_PREFIX_WORKS=false
    fi
    
    echo -n "• Testing /api/api/documents/list: "
    DOC_RESPONSE=$(curl -s "http://localhost:8000/api/api/documents/list" 2>/dev/null)
    if echo "$DOC_RESPONSE" | grep -q "success\|documents\|count"; then
        echo -e "${GREEN}✅ WORKING!${NC}"
        echo "   Response preview: $(echo "$DOC_RESPONSE" | cut -c1-50)..."
    else
        echo -e "${RED}❌ Failed: $DOC_RESPONSE${NC}"
    fi
    
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
    
else
    echo -e "${RED}❌ Server failed to start${NC}"
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
    DOUBLE_PREFIX_WORKS=false
fi

# Step 2: Fix the API routing if double prefix works
echo ""
echo "🔧 STEP 2: FIX THE API ROUTING"

if [ "$DOUBLE_PREFIX_WORKS" = true ]; then
    echo "Since double prefix works, we need to fix the route definitions..."
    echo "The issue is in the API files - they have /api/ in the route paths"
    
    # Backup current files
    cp src/api/ai_ping.py src/api/ai_ping.py.backup
    cp src/api/document_upload.py src/api/document_upload.py.backup
    
    echo "Fixing ai_ping.py routes..."
    # Fix ai_ping.py - remove /api/ from route paths
    sed -i 's|@router.get("/api/|@router.get("/|g' src/api/ai_ping.py
    sed -i 's|@router.post("/api/|@router.post("/|g' src/api/ai_ping.py
    
    echo "Fixing document_upload.py routes..."
    # Fix document_upload.py - remove /api/ from route paths  
    sed -i 's|@router.get("/api/|@router.get("/|g' src/api/document_upload.py
    sed -i 's|@router.post("/api/|@router.post("/|g' src/api/document_upload.py
    sed -i 's|@router.delete("/api/|@router.delete("/|g' src/api/document_upload.py
    
    echo "✅ API route paths fixed"
    
else
    echo "Double prefix doesn't work, need to check main.py routing..."
    
    # Check main.py for router mounting issues
    echo "Checking main.py router mounting..."
    grep -n "include_router" src/main.py
    
    echo "The issue might be in how routers are mounted in main.py"
fi

# Step 3: Test the fixed endpoints
echo ""
echo "🧪 STEP 3: TEST FIXED ENDPOINTS"

echo "Starting server with fixed routes..."
poetry run python -m src.main > fixed_test.log 2>&1 &
FIXED_PID=$!

sleep 5

if ps -p $FIXED_PID > /dev/null 2>&1; then
    echo "✅ Fixed server running, testing endpoints..."
    
    # Test the correctly fixed endpoints
    echo -n "• Testing /api/ai/ping: "
    AI_FIXED=$(curl -s "http://localhost:8000/api/ai/ping" 2>/dev/null)
    if echo "$AI_FIXED" | grep -q "status\|message\|ollama"; then
        echo -e "${GREEN}✅ FIXED!${NC}"
        echo "   Response: $AI_FIXED"
        AI_ENDPOINT_FIXED=true
    else
        echo -e "${RED}❌ Still broken: $AI_FIXED${NC}"
        AI_ENDPOINT_FIXED=false
    fi
    
    echo -n "• Testing /api/documents/list: "
    DOC_FIXED=$(curl -s "http://localhost:8000/api/documents/list" 2>/dev/null)
    if echo "$DOC_FIXED" | grep -q "success\|documents\|count"; then
        echo -e "${GREEN}✅ FIXED!${NC}"
        echo "   Response preview: $(echo "$DOC_FIXED" | cut -c1-50)..."
        DOC_ENDPOINT_FIXED=true
    else
        echo -e "${RED}❌ Still broken: $DOC_FIXED${NC}"
        DOC_ENDPOINT_FIXED=false
    fi
    
    # Test the UI
    echo -n "• Testing /ui: "
    if curl -s "http://localhost:8000/ui" | grep -q "knowNothing"; then
        echo -e "${GREEN}✅ Working${NC}"
    else
        echo -e "${RED}❌ Issue${NC}"
    fi
    
    kill $FIXED_PID 2>/dev/null || true
    wait $FIXED_PID 2>/dev/null || true
    
else
    echo -e "${RED}❌ Fixed server failed to start${NC}"
    kill $FIXED_PID 2>/dev/null || true
    wait $FIXED_PID 2>/dev/null || true
    AI_ENDPOINT_FIXED=false
    DOC_ENDPOINT_FIXED=false
fi

# Step 4: Handle Docker models separately
echo ""
echo "🐳 STEP 4: DOCKER MODELS - ALTERNATIVE APPROACH"

echo "Since Docker container has mounting issues, let's try volume extraction..."

# Check if we can access the Docker volume directly
if docker volume inspect morphik-core_ollama_data &>/dev/null; then
    echo "✅ Docker volume with your models exists!"
    
    # Try to extract models from the volume
    echo "Attempting to copy models from Docker volume to native Ollama..."
    
    # Create a temporary container to access the volume
    docker run --rm -v morphik-core_ollama_data:/source -v ~/.ollama:/target alpine sh -c "
        if [ -d /source/models ]; then
            cp -r /source/models/* /target/ 2>/dev/null || echo 'Copy failed'
            echo 'Models copied to native Ollama'
        else
            echo 'No models directory found in volume'
        fi
    " 2>/dev/null || echo "Docker volume access failed"
    
    # Restart native Ollama to pick up copied models
    sudo systemctl restart ollama
    sleep 5
    
    # Check if models are now available
    echo "Checking native Ollama for copied models..."
    NATIVE_MODELS=$(ollama list 2>/dev/null)
    if echo "$NATIVE_MODELS" | grep -v "NAME.*ID.*SIZE" | grep -q "."; then
        echo -e "${GREEN}🎉 MODELS RECOVERED!${NC}"
        echo "$NATIVE_MODELS"
    else
        echo -e "${YELLOW}⚠️ Models not recovered, but Docker volume is safe${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Docker volume not accessible${NC}"
fi

# Step 5: Summary and next steps
echo ""
echo "📊 === FIX RESULTS SUMMARY ==="
echo ""
echo "API Endpoints:"
echo "  • AI ping: $([ "$AI_ENDPOINT_FIXED" = true ] && echo -e "${GREEN}✅ Fixed${NC}" || echo -e "${RED}❌ Needs work${NC}")"
echo "  • Documents: $([ "$DOC_ENDPOINT_FIXED" = true ] && echo -e "${GREEN}✅ Fixed${NC}" || echo -e "${RED}❌ Needs work${NC}")"
echo ""

if [ "$AI_ENDPOINT_FIXED" = true ] && [ "$DOC_ENDPOINT_FIXED" = true ]; then
    echo -e "${GREEN}🎉 API ENDPOINTS FULLY FIXED!${NC}"
    echo ""
    echo -e "${BLUE}🚀 YOUR CREATIVE RAG IS NOW COMPLETE:${NC}"
    echo "  • Start server: poetry run python -m src.main"
    echo "  • Access UI: http://localhost:8000/ui"
    echo "  • Test AI: http://localhost:8000/api/ai/ping"
    echo "  • Test Docs: http://localhost:8000/api/documents/list"
    echo ""
    echo -e "${PURPLE}🎨 Ready for professional creative work!${NC}"
    
elif [ "$DOUBLE_PREFIX_WORKS" = true ]; then
    echo -e "${YELLOW}⚠️ PARTIAL FIX - ENDPOINTS WORK WITH DOUBLE PREFIX${NC}"
    echo ""
    echo "Your endpoints work, just at different paths:"
    echo "  • AI: http://localhost:8000/api/api/ai/ping"
    echo "  • Docs: http://localhost:8000/api/api/documents/list"
    echo ""
    echo "This is functional but not ideal. The route definitions need adjustment."
    
else
    echo -e "${RED}❌ ENDPOINTS STILL NEED WORK${NC}"
    echo ""
    echo "Check the backup files and try manual route fixing:"
    echo "  • src/api/ai_ping.py.backup"
    echo "  • src/api/document_upload.py.backup"
fi

# Clean up log files
rm -f server_test.log fixed_test.log

echo ""
echo "🎯 API endpoint fix complete! Check summary above."
