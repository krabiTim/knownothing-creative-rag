#!/bin/bash

echo "🔄 Committing knowNothing Creative RAG changes..."

# Check current status
echo "📊 Current git status:"
git status --short

echo ""
echo "📁 Project structure:"
find . -type d -name ".git" -prune -o -type f -print | head -15

echo ""
echo "🔍 Key files check:"
[ -f "README.md" ] && echo "✅ README.md exists ($(wc -l < README.md) lines)"
[ -f "pyproject.toml" ] && echo "✅ pyproject.toml exists"
[ -d "src" ] && echo "✅ src/ directory exists ($(find src -name "*.py" | wc -l) Python files)"
[ -d "configs" ] && echo "✅ configs/ directory exists"
[ -d "scripts" ] && echo "✅ scripts/ directory exists"

echo ""
read -p "🤔 Do you want to commit these changes? (y/N): " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ Commit cancelled"
    exit 0
fi

# Add all files
echo "➕ Adding files to git..."
git add .

# Show what will be committed
echo ""
echo "📋 Files to be committed:"
git diff --cached --name-status

# Commit with detailed message
echo ""
echo "💾 Creating commit..."
git commit -m "🧠 knowNothing Creative RAG: Foundation Complete

✨ Project Structure:
- Complete source code organization (src/)
- Configuration management (configs/)
- Installation scripts (scripts/)
- Comprehensive documentation

🎨 Features Added:
- Creative Analyzer framework
- Style Explorer foundation  
- Portfolio Intelligence setup
- Inspiration Engine structure

🧠 Philosophy:
- Artists first, technology second
- Zero technical knowledge required
- AI superpowers without the PhD

🚀 Ready for modular development and UI components"

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "🎉 SUCCESS! Your knowNothing Creative RAG is now on GitHub!"
echo "🔗 View at: https://github.com/krabiTim/knownothing-creative-rag"
echo ""
echo "🎯 Next steps:"
echo "1. Build modular UI components"
echo "2. Set up Docker configuration"  
echo "3. Create installation scripts"
echo "4. Test the complete system"
