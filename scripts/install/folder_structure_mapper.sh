#!/bin/bash

echo "🗂️ === CREATIVE RAG SYSTEM STRUCTURE ANALYSIS ==="
echo ""

PROJECT_ROOT=~/creative-rag-multimodal
cd "$PROJECT_ROOT" || { echo "❌ Project folder not found at $PROJECT_ROOT"; exit 1; }

echo "📍 Current location: $(pwd)"
echo ""

echo "🌳 PROJECT STRUCTURE:"
echo "creative-rag-multimodal/"
find . -type f -name "*.py" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.md" -o -name "*.txt" | head -20 | sort

echo ""
echo "📊 === FILE ANALYSIS ==="
echo "📈 File counts by type:"
find . -type f -name "*.py" | wc -l | xargs echo "  Python files:"
find . -type f -name "*.sh" | wc -l | xargs echo "  Shell scripts:"
find . -type f -name "*.yml" -o -name "*.yaml" | wc -l | xargs echo "  YAML configs:"
find . -type f -name "*.toml" | wc -l | xargs echo "  TOML configs:"

echo ""
echo "🔍 === KEY FILES PREVIEW ==="
for file in "pyproject.toml" "docker-compose.yml" "src/main.py"; do
    if [ -f "$file" ]; then
        echo "📄 $file exists ($(ls -lh "$file" | awk '{print $5}'))"
    else
        echo "❌ $file - NOT FOUND"
    fi
done

echo ""
echo "📊 Total size: $(du -sh . 2>/dev/null | cut -f1)"
echo "✅ Analysis complete! Ready for repository setup."
