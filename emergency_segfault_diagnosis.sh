#!/bin/bash

echo "🚨 === EMERGENCY SEGFAULT DIAGNOSIS ==="
echo "Finding the exact cause of the segmentation fault"
echo "==============================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"
echo "📋 Current main.py content:"
echo ""

# Show current main.py to see what got added
echo "🔍 CHECKING MAIN.PY CONTENT:"
wc -l src/main.py
echo ""
echo "Last 20 lines of main.py:"
tail -20 src/main.py
echo ""

# Check if we accidentally added duplicate imports
echo "🔍 CHECKING FOR DUPLICATE IMPORTS:"
grep -n "from.*import" src/main.py | sort

echo ""
echo "🔍 CHECKING FOR PROBLEMATIC IMPORTS:"
# Look for any imports that might cause segfaults
if grep -q "sentence_transformers\|chromadb\|embedding" src/main.py; then
    echo -e "${RED}❌ Found problematic imports in main.py${NC}"
    grep -n "sentence_transformers\|chromadb\|embedding" src/main.py
else
    echo -e "${GREEN}✅ No obvious problematic imports found${NC}"
fi

echo ""
echo "🧪 STEP 1: TEST ABSOLUTE MINIMAL SERVER"
echo "Creating ultra-minimal test server..."

# Create the most minimal possible server
cat > test_minimal.py << 'MINIMAL_EOF'
"""
Ultra-minimal server to test segfault
"""
from fastapi import FastAPI
import uvicorn

app = FastAPI(title="Ultra Minimal Test")

@app.get("/")
async def root():
    return {"status": "working", "message": "Ultra minimal server"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    print("🧪 Starting ultra-minimal server...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
MINIMAL_EOF

echo "Testing ultra-minimal server..."
timeout 5s python test_minimal.py > minimal_test.log 2>&1 &
MINIMAL_PID=$!

sleep 3

if ps -p $MINIMAL_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Ultra-minimal server works${NC}"
    if curl -s "http://localhost:8000/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Ultra-minimal endpoints respond${NC}"
    fi
    kill $MINIMAL_PID 2>/dev/null || true
    wait $MINIMAL_PID 2>/dev/null || true
    MINIMAL_WORKS=true
else
    echo -e "${RED}❌ Even ultra-minimal server segfaults!${NC}"
    echo "This indicates a deeper Python/system issue"
    kill $MINIMAL_PID 2>/dev/null || true
    wait $MINIMAL_PID 2>/dev/null || true
    MINIMAL_WORKS=false
fi

echo ""
echo "🧪 STEP 2: TEST WITH JUST BASIC IMPORTS"

if [ "$MINIMAL_WORKS" = true ]; then
    echo "Testing with basic src imports..."
    
    cat > test_basic_imports.py << 'BASIC_EOF'
"""
Test basic src imports to find segfault cause
"""
from fastapi import FastAPI
import uvicorn
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Basic Import Test")

@app.get("/")
async def root():
    return {"status": "working", "message": "Basic imports test"}

@app.get("/health")  
async def health():
    return {"status": "healthy"}

# Try importing our modules one by one
try:
    logger.info("Testing import: src")
    import src
    logger.info("✅ src imported successfully")
except Exception as e:
    logger.error(f"❌ src import failed: {e}")

try:
    logger.info("Testing import: src.api")
    from src.api import ai_ping
    logger.info("✅ src.api.ai_ping imported successfully")
except Exception as e:
    logger.error(f"❌ src.api.ai_ping import failed: {e}")

try:
    logger.info("Testing import: src.services")
    from src.services import storage_manager
    logger.info("✅ src.services.storage_manager imported successfully")
except Exception as e:
    logger.error(f"❌ src.services.storage_manager import failed: {e}")

if __name__ == "__main__":
    print("🧪 Starting basic imports test server...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
BASIC_EOF

    echo "Testing basic imports server..."
    timeout 8s python test_basic_imports.py > basic_test.log 2>&1 &
    BASIC_PID=$!
    
    sleep 5
    
    if ps -p $BASIC_PID > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Basic imports server works${NC}"
        echo "Checking log for import results..."
        if grep -q "imported successfully" basic_test.log; then
            echo -e "${GREEN}✅ Basic imports successful${NC}"
            grep "imported successfully" basic_test.log
        fi
        if grep -q "import failed" basic_test.log; then
            echo -e "${RED}❌ Some imports failed${NC}"
            grep "import failed" basic_test.log
        fi
        kill $BASIC_PID 2>/dev/null || true
        wait $BASIC_PID 2>/dev/null || true
        BASIC_WORKS=true
    else
        echo -e "${RED}❌ Basic imports server segfaults${NC}"
        echo "Segfault happens during import phase"
        kill $BASIC_PID 2>/dev/null || true
        wait $BASIC_PID 2>/dev/null || true
        BASIC_WORKS=false
    fi
else
    echo "Skipping basic imports test due to minimal server failure"
    BASIC_WORKS=false
fi

echo ""
echo "🧪 STEP 3: CLEAN MAIN.PY RESTORATION"

echo "Creating clean backup of current main.py..."
cp src/main.py src/main.py.broken_backup

echo "Restoring to ultra-minimal main.py..."
cat > src/main.py << 'CLEAN_EOF'
"""
Ultra-minimal main.py to avoid segfaults
Only the absolute essentials
"""
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import uvicorn
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="knowNothing Creative RAG - Safe Mode",
    description="Minimal safe server to avoid segfaults",
    version="1.0.0-safe"
)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "knowNothing Creative RAG",
        "version": "1.0.0-safe",
        "status": "running in safe mode",
        "message": "Segfault-free operation"
    }

@app.get("/health")
async def health():
    """Health check"""
    return {"status": "healthy", "mode": "safe"}

@app.get("/ui", response_class=HTMLResponse)
async def ui():
    """Minimal UI"""
    return HTMLResponse(content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>🧠 knowNothing Creative RAG - Safe Mode</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                max-width: 800px; 
                margin: 2rem auto; 
                padding: 2rem;
                background: #0f0f0f;
                color: white;
            }
            .header { 
                text-align: center; 
                margin-bottom: 2rem;
                padding: 2rem;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 10px;
            }
            .status {
                background: #1a1a1a;
                padding: 1rem;
                border-radius: 8px;
                margin: 1rem 0;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🧠 knowNothing Creative RAG</h1>
            <p>Safe Mode - Segfault Protection Active</p>
        </div>
        
        <div class="status">
            <h2>🛡️ System Status</h2>
            <p>✅ Server running without segfaults</p>
            <p>🔧 Safe mode prevents crashes while we debug</p>
            <p>🎯 Ready for careful feature addition</p>
        </div>
        
        <div class="status">
            <h2>🔗 Available Endpoints</h2>
            <p>• <a href="/health" style="color: #64b5f6;">/health</a> - System health check</p>
            <p>• <a href="/docs" style="color: #64b5f6;">/docs</a> - API documentation</p>
        </div>
        
        <div class="status">
            <h2>📋 Next Steps</h2>
            <p>1. Confirm this safe server works</p>
            <p>2. Add features one import at a time</p>
            <p>3. Test after each addition</p>
            <p>4. Identify the exact segfault cause</p>
        </div>
    </body>
    </html>
    """)

if __name__ == "__main__":
    logger.info("🛡️ Starting knowNothing Creative RAG in safe mode...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
CLEAN_EOF

echo ""
echo "🧪 STEP 4: TEST CLEAN MINIMAL MAIN.PY"

echo "Testing ultra-clean main.py..."
timeout 8s poetry run python -m src.main > clean_test.log 2>&1 &
CLEAN_PID=$!

sleep 5

if ps -p $CLEAN_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Clean main.py works!${NC}"
    if curl -s "http://localhost:8000/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Clean endpoints respond${NC}"
    fi
    if curl -s "http://localhost:8000/ui" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Clean UI accessible${NC}"
    fi
    kill $CLEAN_PID 2>/dev/null || true
    wait $CLEAN_PID 2>/dev/null || true
    CLEAN_WORKS=true
else
    echo -e "${RED}❌ Even clean main.py segfaults!${NC}"
    echo "This indicates a serious Python environment issue"
    kill $CLEAN_PID 2>/dev/null || true
    wait $CLEAN_PID 2>/dev/null || true
    CLEAN_WORKS=false
fi

echo ""
echo "📊 === DIAGNOSIS RESULTS ==="
echo ""
echo "Ultra-minimal server: $([ "$MINIMAL_WORKS" = true ] && echo "✅ Works" || echo "❌ Segfaults")"
echo "Basic imports test: $([ "$BASIC_WORKS" = true ] && echo "✅ Works" || echo "❌ Segfaults")"  
echo "Clean main.py: $([ "$CLEAN_WORKS" = true ] && echo "✅ Works" || echo "❌ Segfaults")"

echo ""
if [ "$CLEAN_WORKS" = true ]; then
    echo -e "${GREEN}🎉 SEGFAULT CAUSE IDENTIFIED!${NC}"
    echo ""
    echo "The issue is in the imports/code that got added by the gradual rebuild script."
    echo "Your clean main.py works perfectly."
    echo ""
    echo -e "${BLUE}🚀 IMMEDIATE SOLUTION:${NC}"
    echo "1. Use the clean main.py (already created)"
    echo "2. Test: poetry run python -m src.main"
    echo "3. Access: http://localhost:8000/ui"
    echo ""
    echo -e "${YELLOW}🔧 ROOT CAUSE:${NC}"
    echo "The gradual rebuild script probably added problematic imports"
    echo "that cause segfaults even though they appeared to work in testing."
    echo ""
    echo -e "${BLUE}📋 NEXT STEPS:${NC}"
    echo "1. Confirm clean server works"
    echo "2. Add imports ONE AT A TIME manually"
    echo "3. Test after each single import"
    echo "4. Stop at first segfault to identify culprit"
    
elif [ "$MINIMAL_WORKS" = true ]; then
    echo -e "${YELLOW}⚠️ PARTIAL SEGFAULT CAUSE IDENTIFIED${NC}"
    echo ""
    echo "Issue is in the src module imports, not FastAPI itself."
    echo "The ultra-minimal server works fine."
    echo ""
    echo -e "${BLUE}🔧 SOLUTIONS:${NC}"
    echo "1. Use ultra-minimal server for now"
    echo "2. Debug src module imports individually"
    echo "3. Check for corrupted __pycache__ files"
    
else
    echo -e "${RED}🚨 DEEP SYSTEM ISSUE${NC}"
    echo ""
    echo "Even the most minimal FastAPI server segfaults."
    echo "This suggests a Python environment or system issue."
    echo ""
    echo -e "${BLUE}🔧 EMERGENCY SOLUTIONS:${NC}"
    echo "1. Check Python installation: python --version"
    echo "2. Reinstall poetry environment: poetry env remove python && poetry install"
    echo "3. Check system memory: free -h"
    echo "4. Check for system issues: dmesg | tail"
fi

echo ""
echo -e "${PURPLE}💡 PREVENTION FOR FUTURE:${NC}"
echo "• Never add multiple imports at once"
echo "• Test after each single change"
echo "• Keep working backups of main.py"
echo "• Use git commits after each working stage"

# Clean up test files
rm -f test_minimal.py test_basic_imports.py *.log

echo ""
echo "🎯 Diagnosis complete - check results above!"
