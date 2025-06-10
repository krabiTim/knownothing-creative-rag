#!/bin/bash

echo "🚀 SETTING UP CREATIVE RAG MULTIMODAL SYSTEM"
echo "=========================================="

PROJECT_ROOT=~/creative-rag-multimodal
mkdir -p $PROJECT_ROOT
cd $PROJECT_ROOT

mkdir -p {src,tests,docs,data,scripts,configs,notebooks}
mkdir -p src/{api,core,models,services,utils}
mkdir -p data/{uploads,processed,embeddings,cache}
mkdir -p tests/{unit,integration,e2e}
mkdir -p docs/{api,setup,architecture}
mkdir -p configs/{development,production}
mkdir -p scripts/{setup,deployment,maintenance}

echo "✅ Project structure created at $PROJECT_ROOT"
