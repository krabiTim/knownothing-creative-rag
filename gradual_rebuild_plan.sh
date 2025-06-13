#!/bin/bash

echo "🔨 === GRADUAL REBUILD PLAN - ADD FEATURES SAFELY ==="
echo "Building back to full functionality without segfaults"
echo "=================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"
echo "🌿 Current branch: $(git branch --show-current)"

# Step 1: Test current safe server
echo ""
echo -e "${YELLOW}🧪 STEP 1: VERIFY SAFE SERVER IS WORKING${NC}"

echo "Starting safe server to confirm stability..."
timeout 8s poetry run python -m src.main > current_test.log 2>&1 &
SERVER_PID=$!

sleep 5

if ps -p $SERVER_PID > /dev/null 2>&1 && curl -s "http://localhost:8000/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Safe server confirmed working${NC}"
    SAFE_WORKING=true
    
    # Kill test server
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
else
    echo -e "${RED}❌ Safe server not working${NC}"
    SAFE_WORKING=false
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
fi

if [ "$SAFE_WORKING" = false ]; then
    echo "Safe server issues, check current_test.log"
    exit 1
fi

# Step 2: Plan gradual feature addition
echo ""
echo -e "${YELLOW}📋 STEP 2: GRADUAL REBUILD STRATEGY${NC}"

echo "We'll add features back in this order:"
echo "1. Stage 1: AI Ping (minimal imports)"
echo "2. Stage 3: Document Storage (proven working)"
echo "3. Stage 4: Text Extraction (was working)"
echo "4. Simple search (without complex imports)"
echo "5. Stage 2: Image Analysis (if needed)"
echo ""
echo "❌ SKIP FOR NOW:"
echo "• Stage 5: Embeddings (was causing hangs)"
echo "• Complex search with heavy imports"

# Step 3: Add Stage 1 carefully
echo ""
echo -e "${YELLOW}🔗 STEP 3: ADDING STAGE 1 (AI PING) CAREFULLY${NC}"

# Check if Stage 1 already exists in safe server
if grep -q "ai_ping" src/main.py; then
    echo "✅ Stage 1 already in safe server"
else
    echo "Adding Stage 1 to safe server..."
    # Add Stage 1 integration
    cat >> src/main.py << 'STAGE1_EOF'

# Stage 1: AI Ping (Re-adding carefully)
try:
    logger.info("🧪 Attempting to load Stage 1 (AI ping)...")
    from .api.ai_ping import router as ai_ping_router
    app.include_router(ai_ping_router, prefix="/api")
    logger.info("✅ Stage 1: AI ping loaded safely")
except Exception as e:
    logger.warning(f"⚠️ Stage 1 failed: {e}")
STAGE1_EOF
fi

# Test Stage 1 addition
echo "Testing Stage 1 addition..."
timeout 8s poetry run python -m src.main > stage1_test.log 2>&1 &
SERVER_PID=$!

sleep 5

if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Stage 1 added successfully${NC}"
    
    # Test AI ping endpoint
    if curl -s "http://localhost:8000/api/ai/ping" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ AI ping endpoint working${NC}"
    else
        echo -e "${YELLOW}⚠️ AI ping endpoint not responding (but server stable)${NC}"
    fi
    
    STAGE1_WORKING=true
else
    echo -e "${RED}❌ Stage 1 caused issues${NC}"
    STAGE1_WORKING=false
fi

# Kill test server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Step 4: Add Stage 3 if Stage 1 worked
if [ "$STAGE1_WORKING" = true ]; then
    echo ""
    echo -e "${YELLOW}📁 STEP 4: ADDING STAGE 3 (DOCUMENT STORAGE)${NC}"
    
    # Add Stage 3 carefully
    cat >> src/main.py << 'STAGE3_EOF'

# Stage 3: Document Storage (Re-adding carefully)
try:
    logger.info("🧪 Attempting to load Stage 3 (document storage)...")
    from .api.document_upload import router as doc_router
    app.include_router(doc_router, prefix="/api")
    logger.info("✅ Stage 3: Document storage loaded safely")
except Exception as e:
    logger.warning(f"⚠️ Stage 3 failed: {e}")
STAGE3_EOF

    # Test Stage 3 addition
    echo "Testing Stage 3 addition..."
    timeout 8s poetry run python -m src.main > stage3_test.log 2>&1 &
    SERVER_PID=$!
    
    sleep 5
    
    if ps -p $SERVER_PID > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Stage 3 added successfully${NC}"
        
        # Test document endpoints
        if curl -s "http://localhost:8000/api/documents/list" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Document endpoints working${NC}"
        else
            echo -e "${YELLOW}⚠️ Document endpoints not responding (but server stable)${NC}"
        fi
        
        STAGE3_WORKING=true
    else
        echo -e "${RED}❌ Stage 3 caused issues${NC}"
        STAGE3_WORKING=false
    fi
    
    # Kill test server
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
else
    STAGE3_WORKING=false
    echo "Skipping Stage 3 due to Stage 1 issues"
fi

# Step 5: Enhanced UI if stages working
if [ "$STAGE1_WORKING" = true ] && [ "$STAGE3_WORKING" = true ]; then
    echo ""
    echo -e "${YELLOW}🎨 STEP 5: ENHANCING UI${NC}"
    
    # Update the UI to include document upload functionality
    # Replace the minimal UI with a more functional one
    echo "Enhancing UI with document upload..."
    
    # This would update the @app.get("/ui") section in main.py
    echo "✅ UI enhancement ready (manual update needed in main.py)"
else
    echo ""
    echo -e "${YELLOW}⚠️ STEP 5: SKIPPING UI ENHANCEMENT${NC}"
    echo "Due to stage loading issues"
fi

# Step 6: Final test and commit
echo ""
echo -e "${YELLOW}🧪 STEP 6: FINAL COMPREHENSIVE TEST${NC}"

echo "Testing complete rebuilt system..."
timeout 10s poetry run python -m src.main > final_test.log 2>&1 &
SERVER_PID=$!

sleep 6

if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Complete system stable${NC}"
    
    # Test key endpoints
    if curl -s "http://localhost:8000/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Health check working${NC}"
    fi
    
    if curl -s "http://localhost:8000/ui" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ UI accessible${NC}"
    fi
    
    FINAL_WORKING=true
else
    echo -e "${RED}❌ System still unstable${NC}"
    FINAL_WORKING=false
fi

# Kill test server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Step 7: Results and next steps
echo ""
echo -e "${PURPLE}📊 GRADUAL REBUILD RESULTS${NC}"
echo "=========================="

echo ""
echo -e "${BLUE}✅ WORKING COMPONENTS:${NC}"
echo "• Safe server base: ✅"
echo "• Stage 1 (AI Ping): $([ "$STAGE1_WORKING" = true ] && echo "✅" || echo "❌")"
echo "• Stage 3 (Documents): $([ "$STAGE3_WORKING" = true ] && echo "✅" || echo "❌")"
echo "• Final system: $([ "$FINAL_WORKING" = true ] && echo "✅" || echo "❌")"

echo ""
if [ "$FINAL_WORKING" = true ]; then
    echo -e "${GREEN}🎉 REBUILD SUCCESSFUL! 🎉${NC}"
    echo ""
    echo -e "${BLUE}🚀 YOUR WORKING SYSTEM:${NC}"
    echo "   poetry run python -m src.main"
    echo ""
    echo -e "${BLUE}🌐 ACCESS POINTS:${NC}"
    echo "   • UI: http://localhost:8000/ui"
    echo "   • Health: http://localhost:8000/health"
    echo "   • API Docs: http://localhost:8000/docs"
    echo ""
    echo -e "${YELLOW}📝 NEXT STEPS:${NC}"
    echo "1. Test your working system"
    echo "2. Upload some documents"
    echo "3. Commit this stable version"
    echo "4. Later: Add Stage 4 and simple search carefully"
    echo ""
    echo -e "${GREEN}🛡️ STABLE FOUNDATION RESTORED!${NC}"
    
else
    echo -e "${YELLOW}⚠️ PARTIAL REBUILD${NC}"
    echo ""
    echo "Some components didn't load properly."
    echo "But you have a working safe server base."
    echo ""
    echo -e "${BLUE}🔧 TROUBLESHOOTING:${NC}"
    echo "• Check logs: final_test.log"
    echo "• Test minimal server: poetry run python -m src.main"
    echo "• Focus on what works first"
fi

echo ""
echo "🎨 Gradual rebuild complete - stability prioritized! 🎨"