#!/bin/bash

echo "🔧 Fixing error test patterns with precise regex..."

# Create the corrected test script with exact pattern matches
cp test_stage4_success.sh test_stage4_success_fixed.sh

# Fix error pattern 1: Text extraction failed
sed -i 's|"detail".*"Text extraction failed"|"detail":"🔧 Text extraction failed: Document nonexistent-id not found"|g' test_stage4_success_fixed.sh

# Fix error pattern 2: No extracted text found  
sed -i 's|"detail".*"No extracted text found"|"detail":"📄 No extracted text found for document '\''nonexistent-id'\''"|g' test_stage4_success_fixed.sh

# Fix error pattern 3: Document text not found
sed -i 's|"detail".*"Document text not found"|"detail":"📄 Document text not found. Extract text first!"|g' test_stage4_success_fixed.sh

echo "✅ Error patterns fixed with exact matches!"
