#!/bin/bash

echo "🔧 === FIXING DOUBLE API PATH ISSUE ==="
echo "Correcting /api/api/ai/ping to /api/ai/ping"
echo "====================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🧪 First, let's test the current working endpoint:"
echo ""
echo -n "Testing /api/api/ai/ping (current)... "
if response=$(curl -s http://localhost:8000/api/api/ai/ping 2>/dev/null); then
    echo -e "${GREEN}✅ Working!${NC}"
    echo "Response: $response" | head -c 100
    echo "..."
else
    echo -e "${RED}❌ Failed${NC}"
fi

echo ""
echo "🔧 Now let's fix the double API path in src/main.py..."

# Create backup
cp src/main.py src/main.py.before_fix

# Fix the router registration
echo "📝 Fixing router registrations..."

# Fix AI router
sed -i 's/app.include_router(ai_ping_router, prefix="\/api"/app.include_router(ai_ping_router/' src/main.py

# Fix text router 
sed -i 's/app.include_router(text_router, prefix="\/api"/app.include_router(text_router/' src/main.py

echo "✅ Fixed router registrations in src/main.py"

echo ""
echo "🔄 Now restart your server to apply the fix:"
echo ""
echo "# Stop current server"
echo "pkill -f 'python.*src.main'"
echo ""
echo "# Start with the fix"
echo "poetry run python -m src.main &"
echo ""
echo "# Test the corrected endpoint"
echo "curl http://localhost:8000/api/ai/ping"
echo ""

echo "🎯 WHAT WAS FIXED:"
echo "   ❌ Before: /api/api/ai/ping (double api)"
echo "   ✅ After:  /api/ai/ping (correct path)"
echo ""
echo "📋 The issue was router prefix duplication in main.py"
echo "   Router already had /api in the path"
echo "   Adding prefix='/api' created /api/api"
echo ""

# Show the specific lines that were changed
echo "📄 Changes made to src/main.py:"
echo "   Line ~237: Removed prefix='/api' from ai_ping_router"
echo "   Line ~255: Removed prefix='/api' from text_router"
echo ""

echo "🚀 After restart, test all endpoints:"
echo "   ✅ curl http://localhost:8000/api/ai/ping"
echo "   ✅ curl http://localhost:8000/api/documents/list"  
echo "   ✅ curl http://localhost:8000/health"