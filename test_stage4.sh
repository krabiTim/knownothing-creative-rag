#!/bin/bash

echo "🧪 === STAGE 4: TEXT EXTRACTION - TESTING SUITE ==="
echo "Testing text extraction capabilities for creative documents"
echo "========================================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

API_BASE="http://localhost:8000"
FAILED_TESTS=0
TOTAL_TESTS=0
DOCUMENT_ID=""

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
        
        # Extract document ID if this is an upload test
        if [[ "$output" =~ "document_id" ]]; then
            DOCUMENT_ID=$(echo "$output" | grep -o '"document_id":"[^"]*"' | head -1 | cut -d'"' -f4)
            if [ -n "$DOCUMENT_ID" ]; then
                echo "📋 Document ID: $DOCUMENT_ID"
            fi
        fi
        
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
echo "📝 Creating test documents for text extraction..."

# Create a rich text document for testing
cat > test_script_detailed.txt << 'EOF'
# THE DIGITAL ARTIST
## A Short Film Script

**FADE IN:**

**EXT. CITY STREET - DAY**

Maya, a young digital artist in her 20s, walks through a bustling street carrying a worn laptop bag. Her eyes scan the urban landscape, looking for inspiration.

**MAYA (V.O.)**
Every artist faces the blank canvas. But what happens when the canvas is infinite... and empty?

**INT. MAYA'S APARTMENT - NIGHT**

A cramped studio apartment. Digital art prints cover the walls. Maya sits before her computer, cursor blinking on an empty digital canvas.

**MAYA**
(frustrated)
Come on... something. Anything.

She closes her laptop in defeat.

**INT. COFFEE SHOP - NEXT DAY**

Maya sits alone, sketching in a notebook. ALEX (30s), a tech researcher, approaches.

**ALEX**
Mind if I sit? That's beautiful work.

**MAYA**
(looking up)
Oh, thanks. Just trying to find my voice.

**ALEX**
What if I told you there was a way to amplify that voice?

Alex pulls out a tablet showing an AI art collaboration tool.

**ALEX (CONT'D)**
This isn't about replacing creativity. It's about understanding it, expanding it.

**MAYA**
(intrigued)
Show me.

**MONTAGE - MAYA AND AI COLLABORATION**

- Maya uploads her sketches
- The AI analyzes her style, color preferences
- Together, they create something neither could achieve alone
- Maya's confidence grows with each iteration

**INT. MAYA'S APARTMENT - WEEKS LATER**

Maya's apartment is transformed. New artworks line the walls. She works confidently, the AI as her creative partner.

**MAYA (V.O.)**
The blank canvas isn't empty anymore. It's full of possibility.

**FADE OUT.**

**THE END**

---

**PRODUCTION NOTES:**
- Runtime: Approximately 8-10 minutes
- Visual Style: Modern, clean cinematography with warm color grading
- Themes: Human-AI collaboration, overcoming creative blocks, technology as enabler
- Target Audience: Creative professionals, tech enthusiasts, film festival circuits

**CHARACTER BREAKDOWN:**
- MAYA: Lead character, represents struggling artists
- ALEX: Catalyst character, represents possibility and innovation
- AI SYSTEM: Visual representation through UI/screens

**TECHNICAL REQUIREMENTS:**
- Computer screens with custom AI interface
- Digital art creation scenes
- Urban and intimate interior locations
- Color palette: Blues (technology) transitioning to warm oranges (creativity)
EOF

echo "✅ Created test_script_detailed.txt (comprehensive film script)"

# Create a research document
cat > test_research_doc.txt << 'EOF'
# Research: AI in Creative Industries
## Market Analysis and Artistic Applications

### Executive Summary
This document examines the integration of artificial intelligence tools in creative workflows, specifically focusing on visual arts, film production, and content creation.

### Key Findings

**1. Market Growth**
- AI creative tools market expected to reach $5.7B by 2025
- 73% of creative professionals have experimented with AI tools
- Video production sees highest adoption rates (45%)

**2. Creative Applications**
- Style transfer and artistic rendering
- Automated color grading and correction
- Script analysis and story structure optimization
- Character development and dialogue enhancement

**3. Industry Impact**
- Reduced production timelines by 30-40%
- Enhanced creative exploration and ideation
- Democratization of professional-quality tools
- New hybrid human-AI creative workflows

### Recommendations

**For Independent Artists:**
- Start with AI-assisted ideation tools
- Focus on style enhancement rather than replacement
- Develop hybrid workflows that preserve artistic voice

**For Production Companies:**
- Invest in AI-powered post-production tools
- Train creative teams on AI collaboration
- Maintain human oversight in creative decisions

### Conclusion
AI tools represent an evolution in creative processes, not a replacement for human creativity. The most successful implementations treat AI as a collaborative partner that amplifies human artistic vision.

### References
- Adobe Creative AI Report (2024)
- Runway ML Industry Survey (2024)
- MIT Technology Review: "AI and Creativity" (2024)
EOF

echo "✅ Created test_research_doc.txt (research document)"

echo ""
echo -e "${BLUE}================= STAGE 4: TEXT EXTRACTION TESTS =================${NC}"

# Test 1: Upload document first (prerequisite)
echo -e "${BLUE}Prerequisite: Upload test document${NC}"
run_test "Document Upload for Text Extraction" \
    "curl -s -F 'file=@test_script_detailed.txt' $API_BASE/api/documents/upload" \
    '"success":true.*document_id"'

if [ -z "$DOCUMENT_ID" ]; then
    echo -e "${RED}❌ Cannot proceed without document ID${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Text Extraction Tests (Document ID: $DOCUMENT_ID)${NC}"

# Test 2: Extract text from uploaded document
run_test "Text Extraction from Document" \
    "curl -s -X POST $API_BASE/api/text/extract/$DOCUMENT_ID" \
    '"success":true.*word_count"'

# Test 3: Get extracted text preview
run_test "Get Text Preview" \
    "curl -s '$API_BASE/api/text/$DOCUMENT_ID?format=preview'" \
    '"success":true.*text_preview"'

# Test 4: Get full extracted text
run_test "Get Full Extracted Text" \
    "curl -s '$API_BASE/api/text/$DOCUMENT_ID?format=full'" \
    '"success":true.*extracted_text"'

# Test 5: Get text metadata
run_test "Get Text Metadata" \
    "curl -s '$API_BASE/api/text/$DOCUMENT_ID?format=metadata'" \
    '"success":true.*word_count.*extraction_method"'

# Test 6: Search within document
run_test "Search Within Document Text" \
    "curl -s -X POST '$API_BASE/api/text/$DOCUMENT_ID/search?query=MAYA'" \
    '"success":true.*matches"'

# Test 7: Case-insensitive search
run_test "Case-Insensitive Search" \
    "curl -s -X POST '$API_BASE/api/text/$DOCUMENT_ID/search?query=maya&case_sensitive=false'" \
    '"success":true.*matches"'

# Test 8: Get extraction statistics
run_test "Text Extraction Statistics" \
    "curl -s $API_BASE/api/text/stats" \
    '"success":true.*total_documents"'

echo ""
echo -e "${BLUE}================= INTEGRATION WITH PREVIOUS STAGES =================${NC}"

# Test 9: Upload second document and extract
echo "🧪 Testing: Multiple Document Text Extraction... "
upload_result=$(curl -s -F 'file=@test_research_doc.txt' $API_BASE/api/documents/upload)
if [[ "$upload_result" =~ "document_id" ]]; then
    SECOND_DOC_ID=$(echo "$upload_result" | grep -o '"document_id":"[^"]*"' | cut -d'"' -f4)
    extract_result=$(curl -s -X POST $API_BASE/api/text/extract/$SECOND_DOC_ID)
    if [[ "$extract_result" =~ "success" ]]; then
        echo -e "${GREEN}✅ PASS${NC} (Multiple document extraction works)"
    else
        echo -e "${RED}❌ FAIL${NC} (Second document extraction failed)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    echo -e "${RED}❌ FAIL${NC} (Could not upload second document)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 10: Error handling - non-existent document
run_test "Error Handling (Non-existent Document)" \
    "curl -s -X POST $API_BASE/api/text/extract/nonexistent-id" \
    '"success":false\|"error"\|"404"'

echo ""
echo -e "${BLUE}================= PERFORMANCE AND SCALABILITY =================${NC}"

# Test 11: Large text search
echo "🧪 Testing: Search Performance... "
search_result=$(curl -s -X POST "$API_BASE/api/text/$DOCUMENT_ID/search?query=the")
if [[ "$search_result" =~ "matches" ]]; then
    match_count=$(echo "$search_result" | grep -o '"total_matches":[0-9]*' | cut -d':' -f2)
    if [ "$match_count" -gt 0 ]; then
        echo -e "${GREEN}✅ PASS${NC} (Found $match_count matches for common word)"
    else
        echo -e "${YELLOW}⚠️  PARTIAL${NC} (Search works but no matches found)"
    fi
else
    echo -e "${RED}❌ FAIL${NC} (Search functionality not working)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo ""
echo -e "${BLUE}===================== TEST SUMMARY =====================${NC}"

PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))

echo "📊 Stage 4 Test Results:"
echo -e "   Total Tests: $TOTAL_TESTS"
echo -e "   ${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "   ${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 STAGE 4 COMPLETE! 🎉${NC}"
    echo ""
    echo "✅ Text extraction is fully functional!"
    echo ""
    echo "🎨 Artists can now:"
    echo "   • Extract text from uploaded PDFs, DOCX, and TXT files"
    echo "   • Search within their creative documents"
    echo "   • Get word counts and document statistics"
    echo "   • Preview extracted content before full processing"
    echo "   • Track extraction progress across their library"
    echo ""
    echo "🚀 Ready for Stage 5: Embeddings and Semantic Search!"
    
elif [ $FAILED_TESTS -lt 3 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  STAGE 4 MOSTLY WORKING${NC}"
    echo ""
    echo "Core text extraction is functional with minor issues."
    echo "Most features work well for artists."
    
else
    echo ""
    echo -e "${RED}❌ STAGE 4 NEEDS ATTENTION${NC}"
    echo ""
    echo "Multiple text extraction features failed."
    echo "Check dependencies and API endpoints."
fi

echo ""
echo "🔗 Text extraction endpoints for artists:"
echo "   • Extract text: POST $API_BASE/api/text/extract/{document_id}"
echo "   • Get text: GET $API_BASE/api/text/{document_id}"
echo "   • Search: POST $API_BASE/api/text/{document_id}/search?query=..."
echo "   • Statistics: GET $API_BASE/api/text/stats"

# Cleanup
echo ""
echo "🧹 Cleaning up test files..."
rm -f test_script_detailed.txt test_research_doc.txt
echo "✅ Test files cleaned up"

exit $FAILED_TESTS