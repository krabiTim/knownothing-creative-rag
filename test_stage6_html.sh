#!/bin/bash

echo "🧪 === STAGE 6: SIMPLE HTML UI TESTING ==="
echo "Testing clean HTML interface functionality"
echo "========================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

API_BASE="http://localhost:8000"
FAILED_TESTS=0
TOTAL_TESTS=0

# Function to run a test
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
        echo "   Got: $output"
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
echo "🧪 Running Stage 6 HTML UI tests..."

# Test 1: UI module import
run_test "HTML UI Module Import" \
    "python -c 'from src.ui.simple_html_ui import router'" \
    ""

# Test 2: UI endpoint accessibility
run_test "UI Endpoint Access" \
    "curl -s $API_BASE/ui | head -1" \
    "<!DOCTYPE"

# Test 3: Root redirect
run_test "Root Redirect" \
    "curl -s $API_BASE/ | grep -q 'Redirecting'; echo \$?" \
    "0"

# Test 4: HTML content check
run_test "HTML Content Validation" \
    "curl -s $API_BASE/ui | grep -q 'knowNothing Creative RAG'; echo \$?" \
    "0"

echo ""
echo "📊 Stage 6 HTML UI Test Summary:"
PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))
echo -e "   ${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "   ${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 Stage 6 HTML UI is ready!${NC}"
    echo ""
    echo "🚀 ACCESS YOUR INTERFACE:"
    echo "   🎨 http://localhost:8000/ui"
    echo "   🏠 http://localhost:8000/ (redirects to UI)"
    echo ""
    echo "🎯 What you'll get:"
    echo "   • Beautiful gradient interface"
    echo "   • Drag-and-drop file upload"
    echo "   • Document library management"
    echo "   • Text extraction workflow"
    echo "   • Zero external dependencies!"
    echo ""
    echo "✅ Ready to commit and merge!"
else
    echo -e "${RED}❌ Stage 6 needs fixes${NC}"
    echo "Fix failing tests before proceeding"
fi

exit $FAILED_TESTS
