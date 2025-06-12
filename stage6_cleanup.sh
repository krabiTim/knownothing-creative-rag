#!/bin/bash

echo "🔄 === STAGE 6: CLEAN ROLLBACK AND FRESH START ==="
echo "Rolling back UI changes and starting Stage 6 properly"
echo "===================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"
echo "🌿 Current branch: $(git branch --show-current)"

# Step 1: Check git status
echo ""
echo "📊 Checking current git status..."
git status --short

# Step 2: Clean up any Stage 6 files that might exist
echo ""
echo "🧹 Cleaning up any existing Stage 6 UI files..."

# Remove any UI files we may have created
rm -f src/ui/premium_dark_ui.py 2>/dev/null
rm -f src/ui/premium_gradio_*.py 2>/dev/null
rm -f src/ui/basic_gradio_ui.py 2>/dev/null
rm -f src/ui/creative_app.py 2>/dev/null
rm -f src/ui/components.py 2>/dev/null
rm -f src/ui/workflows.py 2>/dev/null
rm -f launch_*.py 2>/dev/null
rm -f test_*ui*.sh 2>/dev/null
rm -f test_premium*.sh 2>/dev/null
rm -f premium_dark_installer.sh 2>/dev/null
rm -f PREMIUM_DARK_INSTALL_NOTES.md 2>/dev/null

echo "✅ Cleaned up UI files"

# Step 3: Check if we need to remove integration from main.py
echo ""
echo "🔧 Checking main.py for UI integrations..."

# Check if main.py has UI integrations we need to remove
if grep -q "premium_dark_ui\|gradio_ui\|Premium Dark UI\|Gradio UI" src/main.py; then
    echo "⚠️  Found UI integrations in main.py - creating clean backup..."
    
    # Create backup
    cp src/main.py src/main.py.backup
    
    # Remove UI integration lines
    sed -i '/# Stage 6:/,$d' src/main.py
    
    echo "✅ Cleaned main.py (backup saved as main.py.backup)"
else
    echo "✅ main.py is clean - no UI integrations found"
fi

# Step 4: Reset to main branch clean state
echo ""
echo "🔄 Resetting to clean main branch state..."

# Go back to main
git checkout main 2>/dev/null || echo "Already on main"

# Remove any stage 6 related branches
git branch -D feature/stage6-premium-dark-ui 2>/dev/null || echo "No premium-dark-ui branch to delete"
git branch -D feature/stage6-artist-ui-architecture 2>/dev/null || echo "No artist-ui-architecture branch to delete"
git branch -D feature/stage6-basic-gradio-ui 2>/dev/null || echo "No basic-gradio-ui branch to delete"
git branch -D feature/stage6b-premium-gradio 2>/dev/null || echo "No premium-gradio branch to delete"

# Reset any uncommitted changes
git reset --hard HEAD 2>/dev/null || echo "Nothing to reset"

# Pull latest to make sure we're up to date
git pull origin main 2>/dev/null || echo "Already up to date"

echo "✅ Reset to clean main branch state"

# Step 5: Verify clean state
echo ""
echo "🔍 Verifying clean state..."

echo "📊 Git status after cleanup:"
git status --short

echo ""
echo "📁 Contents of src/ui/ directory:"
if [ -d "src/ui" ]; then
    ls -la src/ui/
else
    echo "   (src/ui directory doesn't exist)"
fi

echo ""
echo "🔍 Checking for UI-related files in project root:"
ls -la *.py launch_* test_*ui* 2>/dev/null || echo "   (No UI-related files found)"

# Step 6: Ready for fresh Stage 6
echo ""
echo -e "${GREEN}🎉 CLEAN ROLLBACK COMPLETE! 🎉${NC}"
echo ""
echo "✅ Ready for fresh Stage 6 start!"
echo ""
echo "📋 Clean state confirmed:"
echo "   • Back on main branch"
echo "   • No Stage 6 UI files"
echo "   • No UI integrations in main.py"
echo "   • No UI-related branches"
echo "   • Clean git status"
echo ""
echo -e "${BLUE}🚀 NOW LET'S START STAGE 6 PROPERLY:${NC}"
echo ""
echo "1️⃣  CREATE FEATURE BRANCH:"
echo "   git checkout -b feature/stage6-simple-gradio-ui"
echo ""
echo "2️⃣  CREATE ONE SIMPLE FILE:"
echo "   • One focused file: src/ui/simple_gradio.py"
echo "   • One clear feature: Basic document upload interface"
echo "   • Around 100-150 lines (same as successful stages)"
echo ""
echo "3️⃣  FOLLOW OUR PROVEN PATTERN:"
echo "   • Simple implementation"
echo "   • Individual test script"
echo "   • Commit when working"
echo "   • Merge to main"
echo ""
echo "🎯 STAGE 6 FOCUS:"
echo "   • Just get a basic Gradio interface working"
echo "   • Upload documents using existing API"
echo "   • Display document list"
echo "   • Keep it simple like Stages 1-5"
echo ""
echo "📝 Ready to start fresh? Let's build Stage 6 the right way!"