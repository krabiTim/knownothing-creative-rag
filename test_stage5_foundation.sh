#!/bin/bash

echo "🧪 === STAGE 5: FOUNDATION TEST ==="
echo "Testing basic semantic search API structure"
echo "========================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

API_BASE="http://localhost:8000"
FAILED_TESTS=0
TOTAL_TESTS=0

# Test runner function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "🧪 Testing: $test_name... "
    
    output=$(eval "$test_command" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ] && [[ "$output" =~ $expected_pattern ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "   Expected: $expected_pattern"
        echo "   Got: ${output:0:200}..."
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Check API is running
echo "🔍 Checking API status..."
if ! curl -s "$API_BASE/api/health" > /dev/null; then
    echo -e "${RED}❌ API not running${NC}"
    echo "Start with: poetry run python -m src.main"
    exit 1
fi
echo -e "${GREEN}✅ API is running${NC}"

echo ""
echo -e "${BLUE}=============== STAGE 5 FOUNDATION TESTS ===============${NC}"

# Test 1: System health
run_test "System Health Check" \
    "curl -s $API_BASE/api/health" \
    '"status":"healthy"'

# Test 2: Embedding service status
run_test "Embedding Service Status" \
    "curl -s $API_BASE/api/embeddings/status" \
    '"success":true'

# Test 3: Embedding statistics
run_test "Embedding Statistics" \
    "curl -s $API_BASE/api/embeddings/stats" \
    '"success":true'

# Test 4: Semantic search API structure
run_test "Semantic Search API" \
    "curl -s -X POST $API_BASE/api/embeddings/search -H 'Content-Type: application/json' -d '{\"query\": \"test\"}'" \
    '"message"'

echo ""
echo -e "${BLUE}===================== TEST SUMMARY =====================${NC}"

PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))

echo "📊 Test Results:"
echo -e "   Total Tests: $TOTAL_TESTS"
echo -e "   ${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "   ${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 STAGE 5 FOUNDATION IS READY! 🎉${NC}"
    echo ""
    echo "✅ All API endpoints responding correctly!"
    echo "🧠 Semantic search structure in place"
    echo "📊 Service status and statistics working"
    echo ""
    echo "🔧 Next: Resolve ChromaDB dependency conflict for full AI features"
    
else
    echo ""
    echo -e "${BLUE}🔧 Foundation needs attention${NC}"
    echo ""
    echo "Check server logs for import errors"
fi

echo ""
echo "🧠 Available Endpoints:"
echo "   • GET  /api/embeddings/status"
echo "   • POST /api/embeddings/search"
echo "   • GET  /api/embeddings/stats"
