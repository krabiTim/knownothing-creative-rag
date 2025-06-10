#!/bin/bash

set -e

echo "🧠 === KNOWNOTHING CREATIVE RAG SETUP ==="
echo "Building AI superpowers for artists in WSL Ubuntu"
echo ""

# Get configuration
echo "📝 Configuration:"
read -p "GitHub username: " GITHUB_USERNAME
read -p "Repository name [knownothing-creative-rag]: " REPO_NAME
REPO_NAME=${REPO_NAME:-knownothing-creative-rag}
read -p "Your name [Creative Developer]: " USER_NAME
USER_NAME=${USER_NAME:-"Creative Developer"}
read -p "Your email [dev@example.com]: " USER_EMAIL
USER_EMAIL=${USER_EMAIL:-"dev@example.com"}

echo ""
echo "Configuration:"
echo "  GitHub: $GITHUB_USERNAME/$REPO_NAME"
echo "  Author: $USER_NAME <$USER_EMAIL>"
echo ""

read -p "Continue? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

# Paths
PROJECT_ROOT=~/creative-rag-multimodal
NEW_REPO_ROOT=~/$REPO_NAME

echo ""
echo "🗂️ Creating repository structure..."

# Create new repo
rm -rf "$NEW_REPO_ROOT" 2>/dev/null || true
mkdir -p "$NEW_REPO_ROOT"
cd "$NEW_REPO_ROOT"

# Create directories
mkdir -p src/{api,core,models,services,utils,ui/{components,themes}}
mkdir -p tests/{unit,integration,e2e}
mkdir -p docs/{setup,api,examples}
mkdir -p scripts/{install,maintenance,development}
mkdir -p configs/{docker,env,models}
mkdir -p data/{uploads,processed,cache,samples}
mkdir -p assets/{images,icons,styles}
mkdir -p notebooks
mkdir -p .github/{workflows,ISSUE_TEMPLATE}

echo "✅ Directory structure created"

echo ""
echo "📋 Copying existing files..."

# Copy source files
if [ -d "$PROJECT_ROOT/src" ]; then
    echo "📂 Copying source code..."
    cp -r "$PROJECT_ROOT/src/"* src/ 2>/dev/null || true
fi

# Copy configs
echo "⚙️ Copying configurations..."
[ -f "$PROJECT_ROOT/pyproject.toml" ] && cp "$PROJECT_ROOT/pyproject.toml" .
[ -f "$PROJECT_ROOT/docker-compose.yml" ] && cp "$PROJECT_ROOT/docker-compose.yml" configs/docker/

# Copy scripts
echo "🔧 Copying scripts..."
cp "$PROJECT_ROOT/"*.sh scripts/install/ 2>/dev/null || true

echo ""
echo "📄 Creating repository files..."

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.poetry/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Project specific
data/uploads/
data/processed/
data/cache/
*.log
.env.local
.env.development
.env.test
.env.production
user_settings.json

# Docker
docker-compose.override.yml

# GPU/CUDA
*.ptx
*.cubin
*.fatbin

# Models (large files)
models/*.bin
models/*.gguf
models/downloads/
*.safetensors

# Jupyter
.ipynb_checkpoints/

# Backup files
*~
*.bak
*.backup

# Temporary files
tmp/
temp/
*.tmp

# Coverage reports
htmlcov/
.coverage
.coverage.*
coverage.xml
*.cover
.hypothesis/
.pytest_cache/
EOF

# Create comprehensive README
cat > README.md << README_EOF
# 🧠 $REPO_NAME

> **AI superpowers for artists who know nothing about AI**

GPU-accelerated multimodal RAG system designed for creative professionals. Built for WSL Ubuntu with RTX 4090 optimization. Zero technical knowledge required.

## 🎨 What knowNothing RAG Does For You

### 🔍 **Creative Analyzer**
Drag, drop, and discover:
- **"What style is this?"** - Instant artistic movement identification
- **"How is this composed?"** - Visual balance and flow analysis  
- **"What colors work here?"** - Smart palette extraction and theory
- **"How was this made?"** - Technique and medium detection

### 🎭 **Style Explorer** 
Explore art like never before:
- **"Show me dark moody landscapes"** - Mood-based discovery
- **"What influenced this style?"** - Historical context and connections
- **"Find similar but different"** - Cross-reference artistic approaches
- **Smart filters** - Era, medium, technique, whatever you need

### 📁 **Portfolio Intelligence**
Upload your work and get insights:
- **"How has my style evolved?"** - Visual timeline of your growth
- **"What's my artistic DNA?"** - Signature elements and patterns
- **"What do my colors say?"** - Psychology of your palette choices
- **"What should I work on next?"** - AI-powered growth recommendations

### 💡 **Inspiration Engine**
Never face blank canvas syndrome again:
- **Context-aware inspiration** - Based on your project and mood
- **Curated galleries** - AI-assembled collections just for you
- **Creative prompts** - Ideas that make sense for your style
- **Cross-pollination** - Unexpected connections from other arts

## 🚀 Get Started (Zero Technical Knowledge Required)

### Quick Setup
\`\`\`bash
# Clone the repository
git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
cd $REPO_NAME

# Run the magic installer
chmod +x scripts/install/*.sh
./scripts/install/install_creative_rag.sh

# Start your AI creative assistant
docker-compose -f configs/docker/docker-compose.yml up -d
./scripts/launch_ui.sh
\`\`\`

## 🎯 Your Creative AI Dashboard

- **🎨 Main Interface**: http://localhost:7860 ← **This is where the magic happens**
- **📡 API Documentation**: http://localhost:8000/docs  
- **📊 System Health**: http://localhost:8000/api/health

## 🎨 Perfect For Every Type of Artist

### **Digital Artists**
- "Is my style consistent across my work?"
- "What techniques should I explore next?"
- "How can I improve my compositions?"
- "Find inspiration for this client brief"

### **Traditional Artists**
- "What classical techniques am I unconsciously using?"
- "How does my work relate to art history?"
- "What patterns define my artistic voice?"
- "Show me masters who painted like I do"

### **Designers**
- "Extract the perfect color palette from this image"
- "What design trends match this project mood?"
- "Build me a comprehensive mood board"
- "How can I make this design more impactful?"

### **Art Students & Educators**
- "Break down this masterpiece to understand techniques"
- "Track artistic development over time"
- "Create visual comparisons between movements"
- "Generate educational content about art principles"

## 🏗️ System Architecture

Built for WSL Ubuntu with RTX 4090 optimization:

\`\`\`
Your Creative AI Stack:
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Beautiful UI   │    │  Smart Backend   │    │   AI Models     │
│ (Gradio-based)  │◄──►│   (FastAPI)      │◄──►│ (Qwen2.5VL+)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Your Browser   │    │   Database       │    │   GPU Power     │
│ (No downloads)  │    │ (PostgreSQL)     │    │ (RTX 4090)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
\`\`\`

### The Secret Sauce
- **🧠 Vision AI**: Qwen2.5VL sees and understands art like a trained curator
- **⚡ GPU Acceleration**: Your RTX 4090 makes everything lightning fast
- **🐳 Container Magic**: Docker ensures everything works everywhere
- **🎨 Artist-First Design**: Every feature designed for creative workflows

## 📁 Project Structure

\`\`\`
$REPO_NAME/
├── src/                     # The brain
│   ├── ui/                 # Beautiful artist interface
│   │   ├── components/     # Modular UI pieces
│   │   └── themes/         # Custom styling
│   ├── api/                # Smart backend services
│   ├── models/             # AI model connections
│   ├── core/               # Business logic
│   └── utils/              # Helper functions
├── scripts/                # Installation & maintenance magic
│   ├── install/           # Setup scripts
│   ├── maintenance/       # System upkeep
│   └── development/       # Dev tools
├── configs/                # Settings that just work
│   ├── docker/            # Container configs
│   ├── env/               # Environment settings
│   └── models/            # AI model configs
├── docs/                   # Help when you need it
├── tests/                  # Quality assurance
├── data/                   # Your creative data lives here
│   ├── uploads/           # Your artwork uploads
│   ├── processed/         # AI-processed results
│   └── cache/             # Speed optimization
└── assets/                 # Static resources
    ├── images/            # UI graphics
    ├── icons/             # Interface icons
    └── styles/            # Custom CSS
\`\`\`

## 🧠 The knowNothing Philosophy

**"You don't need to understand how paint is made to create a masterpiece"**

- **🎨 Artists First**: Every feature designed with creative workflows in mind
- **🚫 No Jargon**: Plain language, visual interfaces, intuitive interactions
- **⚡ Just Works**: Advanced AI that feels like creative magic, not technology
- **🔓 Always Free**: Open source, customizable, community-driven
- **🌍 For Everyone**: Democratizing AI tools for all creative professionals

## 🛠️ Technical Details (For the Curious)

### System Requirements
- **OS**: WSL Ubuntu (Windows Subsystem for Linux)
- **GPU**: NVIDIA RTX 4090 (or compatible)
- **RAM**: 16GB+ recommended
- **Storage**: 20GB+ free space
- **Python**: 3.11+
- **Docker**: Latest version with GPU support

### Key Technologies
- **Frontend**: Gradio 4.x (artist-friendly interfaces)
- **Backend**: FastAPI (async, high-performance)
- **AI Models**: Qwen2.5VL, Nomic embeddings
- **Database**: PostgreSQL + Redis
- **Containerization**: Docker + Docker Compose
- **GPU**: CUDA acceleration, optimized for RTX 4090

## 🎯 Roadmap

Coming soon to knowNothing RAG:
- **🔌 Creative Tool Integration**: Photoshop, Blender, Figma plugins
- **🤝 Collaboration Features**: Share insights with other artists
- **📱 Mobile Companion**: Inspiration on the go
- **🎓 Learning Modules**: Guided artistic skill development
- **🌐 Community Gallery**: Showcase your AI-enhanced creativity

## 🤝 Contributing

Want to help make AI more accessible to artists?

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Add tests if applicable
5. Submit a pull request

## 📄 License

MIT License - Use it, hack it, share it, make incredible art with it!

## 🙏 Built With Love By

- **Artists**: Who demanded better creative technology
- **Developers**: Who believe AI should serve creativity
- **Community**: Who made this possible through open source
- **You**: For being brave enough to try AI for your art

## 🆘 Support

- **🐛 Bug Reports**: [GitHub Issues](https://github.com/$GITHUB_USERNAME/$REPO_NAME/issues)
- **💡 Feature Requests**: [GitHub Discussions](https://github.com/$GITHUB_USERNAME/$REPO_NAME/discussions)
- **📧 Contact**: [$USER_EMAIL](mailto:$USER_EMAIL)

---

**🧠 knowNothing RAG: Where AI meets Art, and Magic Happens**

*"The best creative tools are invisible - they amplify your vision without getting in the way"*

**Built for artists who want AI superpowers without the PhD** 🎨✨
README_EOF

# Create environment config
mkdir -p configs/env
cat > configs/env/.env.template << 'ENV_EOF'
# === KNOWNOTHING CREATIVE RAG CONFIGURATION ===

# Application Settings
APP_NAME="knowNothing Creative RAG"
APP_VERSION="1.0.0"
ENVIRONMENT=development
DEBUG=true
SECRET_KEY=your-super-secret-key-change-this-in-production

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4

# Database Configuration
DATABASE_URL=postgresql://creative_user:creative_pass@localhost:5432/creative_rag
DATABASE_POOL_SIZE=10
DATABASE_MAX_OVERFLOW=20

# Redis Configuration
REDIS_URL=redis://localhost:6379/0
REDIS_CACHE_TTL=3600

# AI Model Configuration
OLLAMA_URL=http://localhost:11434
VISION_MODEL=qwen2.5vl:latest
EMBEDDING_MODEL=nomic-embed-text:latest
MODEL_TEMPERATURE=0.7
MAX_TOKENS=2048

# GPU Configuration (RTX 4090 Optimized)
CUDA_VISIBLE_DEVICES=0
TORCH_CUDA_ARCH_LIST="8.6"
USE_GPU=true

# File Storage
UPLOAD_PATH=./data/uploads
PROCESSED_PATH=./data/processed
CACHE_PATH=./data/cache
MAX_FILE_SIZE=50MB
ALLOWED_EXTENSIONS=jpg,jpeg,png,gif,bmp,tiff,webp

# UI Configuration
UI_TITLE="knowNothing Creative RAG"
UI_DESCRIPTION="AI superpowers for artists who know nothing about AI"
UI_PORT=7860
UI_SHARE=false
UI_DEBUG=false

# Security
CORS_ORIGINS=["http://localhost:3000","http://localhost:7860","http://localhost:8000"]
ALLOWED_HOSTS=["localhost","127.0.0.1"]

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=detailed
LOG_FILE=./logs/app.log

# WSL Ubuntu Specific
WSL_HOST=localhost
WSL_DISTRO=Ubuntu
ENV_EOF

# Create updated pyproject.toml with knowNothing branding
cat > pyproject.toml << 'PYPROJECT_EOF'
[tool.poetry]
name = "knownothing-creative-rag"
version = "1.0.0"
description = "AI superpowers for artists who know nothing about AI"
authors = ["Creative Developer <dev@example.com>"]
license = "MIT"
readme = "README.md"
homepage = "https://github.com/username/knownothing-creative-rag"
repository = "https://github.com/username/knownothing-creative-rag"
keywords = ["ai", "art", "creative", "rag", "multimodal", "gpu", "wsl"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: End Users/Desktop",
    "Topic :: Artistic Software",
    "Topic :: Scientific/Engineering :: Artificial Intelligence",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
packages = [{ include = "src" }]

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.110.0"
uvicorn = {extras = ["standard"], version = "^0.27.0"}
pydantic = "^2.6.0"
pydantic-settings = "^2.2.0"
sqlalchemy = "^2.0.25"
asyncpg = "^0.29.0"
redis = "^5.0.1"
httpx = "^0.27.0"
aiofiles = "^23.2.1"
python-multipart = "^0.0.9"
pillow = "^10.2.0"
torch = "^2.1.2"
transformers = "^4.37.0"
sentence-transformers = "^2.3.1"
gradio = "^4.15.0"
plotly = "^5.17.0"
pandas = "^2.1.4"
numpy = "^1.26.3"
scikit-learn = "^1.4.0"
loguru = "^0.7.2"
rich = "^13.7.0"
typer = "^0.9.0"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0.0"
pytest-asyncio = "^0.23.0"
pytest-cov = "^4.1.0"
black = "^24.0.0"
ruff = "^0.2.0"
mypy = "^1.8.0"
pre-commit = "^3.6.0"

[tool.poetry.scripts]
knownothing = "src.cli:app"
knownothing-ui = "src.ui.launch:main"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
target-version = "py311"
line-length = 88
select = ["E", "W", "F", "I", "B", "C4", "UP"]
ignore = ["E501", "B008", "C901"]

[tool.mypy]
python_version = "3.11"
check_untyped_defs = true
disallow_any_generics = true
disallow_incomplete_defs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-ra -q --strict-markers"
testpaths = ["tests"]
pythonpath = ["."]
PYPROJECT_EOF

# Create Docker configuration optimized for WSL
mkdir -p configs/docker
cat > configs/docker/docker-compose.yml << 'DOCKER_EOF'
version: '3.9'

services:
  # knowNothing Creative RAG API
  knownothing-api:
    build: 
      context: ../..
      dockerfile: Dockerfile
    container_name: knownothing-creative-rag-api
    ports:
      - "${API_PORT:-8000}:8000"
    environment:
      - ENVIRONMENT=${ENVIRONMENT:-production}
      - DATABASE_URL=postgresql://creative_user:creative_pass@postgres:5432/creative_rag
      - REDIS_URL=redis://redis:6379/0
      - OLLAMA_URL=http://ollama:11434
      - CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}
    volumes:
      - ../../data:/app/data
      - ../../logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  # knowNothing Creative RAG UI
  knownothing-ui:
    build:
      context: ../..
      dockerfile: src/ui/Dockerfile
    container_name: knownothing-creative-rag-ui
    ports:
      - "${UI_PORT:-7860}:7860"
    environment:
      - API_URL=http://knownothing-api:8000
      - GRADIO_SERVER_NAME=0.0.0.0
      - GRADIO_SERVER_PORT=7860
    depends_on:
      - knownothing-api
    restart: unless-stopped

  # PostgreSQL Database
  postgres:
    image: postgres:14-alpine
    container_name: knownothing-postgres
    environment:
      POSTGRES_DB: creative_rag
      POSTGRES_USER: creative_user
      POSTGRES_PASSWORD: creative_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U creative_user -d creative_rag"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: knownothing-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped

  # Ollama AI Models
  ollama:
    image: ollama/ollama:latest
    container_name: knownothing-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_ORIGINS=*
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  ollama_data:
    driver: local

networks:
  default:
    name: knownothing-creative-rag
    driver: bridge
DOCKER_EOF

echo ""
echo "🔄 Initializing Git repository..."

# Git setup
git config user.name "$USER_NAME"
git config user.email "$USER_EMAIL"
git init --initial-branch=main
git add .
git commit -m "🧠 Initial commit: knowNothing Creative RAG

🎨 AI superpowers for artists who know nothing about AI

✨ Features:
- GPU-accelerated multimodal RAG (RTX 4090 optimized)
- Beautiful Gradio UI designed for artists, not engineers
- FastAPI backend with async creative workflows
- WSL Ubuntu optimization
- Docker containerization that just works
- Zero technical knowledge required

🎯 Creative Tools:
- Creative Analyzer: Instant artwork insights
- Style Explorer: Mood-based artistic discovery
- Portfolio Intelligence: Track your creative evolution
- Inspiration Engine: Never face blank canvas again

🧠 Philosophy:
- Artists first, technology second
- Powerful capabilities, simple interfaces
- Creative magic, not machine learning jargon
- Democratizing AI for all creative professionals

🚀 Ready to transform creative workflows worldwide!"

echo ""
echo "🎉 === KNOWNOTHING CREATIVE RAG SETUP COMPLETE! ==="
echo ""
echo "📍 Repository Location: $NEW_REPO_ROOT"
echo "🔗 Ready for GitHub: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "🚀 NEXT STEPS TO CREATIVE AI MASTERY:"
echo ""
echo "1️⃣  CREATE GITHUB REPOSITORY:"
echo "   → Visit: https://github.com/new"
echo "   → Repository name: $REPO_NAME"
echo "   → Description: AI superpowers for artists who know nothing about AI"
echo "   → Make it public (share the creative revolution!)"
echo ""
echo "2️⃣  PUSH YOUR CREATION TO THE WORLD:"
echo "   cd $NEW_REPO_ROOT"
echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "   git push -u origin main"
echo ""
echo "3️⃣  SETUP ENVIRONMENT:"
echo "   cd $NEW_REPO_ROOT"
echo "   cp configs/env/.env.template .env"
echo "   # Edit .env with your specific settings"
echo ""
echo "4️⃣  LAUNCH YOUR CREATIVE AI:"
echo "   docker-compose -f configs/docker/docker-compose.yml up -d"
echo "   ./scripts/launch_ui.sh"
echo ""
echo "5️⃣  START CREATING WITH AI:"
echo "   🎨 knowNothing UI: http://localhost:7860"
echo "   📡 Developer API: http://localhost:8000/docs"
echo "   📊 System Status: http://localhost:8000/api/health"
echo ""
echo "✅ Your knowNothing Creative RAG is ready to revolutionize your art!"
echo "🧠 AI superpowers activated. PhD not required. Creativity unlimited."
echo ""
echo "🌟 Welcome to the future of creative technology!"#!/bin/bash

set -e

echo "🧠 === KNOWNOTHING CREATIVE RAG SETUP ==="
echo "Building AI superpowers for artists in WSL Ubuntu"
echo ""

# Get configuration
echo "📝 Configuration:"
read -p "GitHub username: " GITHUB_USERNAME
read -p "Repository name [knownothing-creative-rag]: " REPO_NAME
REPO_NAME=${REPO_NAME:-knownothing-creative-rag}
read -p "Your name [Creative Developer]: " USER_NAME
USER_NAME=${USER_NAME:-"Creative Developer"}
read -p "Your email [dev@example.com]: " USER_EMAIL
USER_EMAIL=${USER_EMAIL:-"dev@example.com"}

echo ""
echo "Configuration:"
echo "  GitHub: $GITHUB_USERNAME/$REPO_NAME"
echo "  Author: $USER_NAME <$USER_EMAIL>"
echo ""

read -p "Continue? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

# Paths
PROJECT_ROOT=~/creative-rag-multimodal
NEW_REPO_ROOT=~/$REPO_NAME

echo ""
echo "🗂️ Creating repository structure..."

# Create new repo
rm -rf "$NEW_REPO_ROOT" 2>/dev/null || true
mkdir -p "$NEW_REPO_ROOT"
cd "$NEW_REPO_ROOT"

# Create directories
mkdir -p src/{api,core,models,services,utils,ui/{components,themes}}
mkdir -p tests/{unit,integration,e2e}
mkdir -p docs/{setup,api,examples}
mkdir -p scripts/{install,maintenance,development}
mkdir -p configs/{docker,env,models}
mkdir -p data/{uploads,processed,cache,samples}
mkdir -p assets/{images,icons,styles}
mkdir -p notebooks
mkdir -p .github/{workflows,ISSUE_TEMPLATE}

echo "✅ Directory structure created"

echo ""
echo "📋 Copying existing files..."

# Copy source files
if [ -d "$PROJECT_ROOT/src" ]; then
    echo "📂 Copying source code..."
    cp -r "$PROJECT_ROOT/src/"* src/ 2>/dev/null || true
fi

# Copy configs
echo "⚙️ Copying configurations..."
[ -f "$PROJECT_ROOT/pyproject.toml" ] && cp "$PROJECT_ROOT/pyproject.toml" .
[ -f "$PROJECT_ROOT/docker-compose.yml" ] && cp "$PROJECT_ROOT/docker-compose.yml" configs/docker/

# Copy scripts
echo "🔧 Copying scripts..."
cp "$PROJECT_ROOT/"*.sh scripts/install/ 2>/dev/null || true

echo ""
echo "📄 Creating repository files..."

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.poetry/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Project specific
data/uploads/
data/processed/
data/cache/
*.log
.env.local
.env.development
.env.test
.env.production
user_settings.json

# Docker
docker-compose.override.yml

# GPU/CUDA
*.ptx
*.cubin
*.fatbin

# Models (large files)
models/*.bin
models/*.gguf
models/downloads/
*.safetensors

# Jupyter
.ipynb_checkpoints/

# Backup files
*~
*.bak
*.backup

# Temporary files
tmp/
temp/
*.tmp

# Coverage reports
htmlcov/
.coverage
.coverage.*
coverage.xml
*.cover
.hypothesis/
.pytest_cache/
EOF

# Create comprehensive README
cat > README.md << README_EOF
# 🧠 $REPO_NAME

> **AI superpowers for artists who know nothing about AI**

GPU-accelerated multimodal RAG system designed for creative professionals. Built for WSL Ubuntu with RTX 4090 optimization. Zero technical knowledge required.

## 🎨 What knowNothing RAG Does For You

### 🔍 **Creative Analyzer**
Drag, drop, and discover:
- **"What style is this?"** - Instant artistic movement identification
- **"How is this composed?"** - Visual balance and flow analysis  
- **"What colors work here?"** - Smart palette extraction and theory
- **"How was this made?"** - Technique and medium detection

### 🎭 **Style Explorer** 
Explore art like never before:
- **"Show me dark moody landscapes"** - Mood-based discovery
- **"What influenced this style?"** - Historical context and connections
- **"Find similar but different"** - Cross-reference artistic approaches
- **Smart filters** - Era, medium, technique, whatever you need

### 📁 **Portfolio Intelligence**
Upload your work and get insights:
- **"How has my style evolved?"** - Visual timeline of your growth
- **"What's my artistic DNA?"** - Signature elements and patterns
- **"What do my colors say?"** - Psychology of your palette choices
- **"What should I work on next?"** - AI-powered growth recommendations

### 💡 **Inspiration Engine**
Never face blank canvas syndrome again:
- **Context-aware inspiration** - Based on your project and mood
- **Curated galleries** - AI-assembled collections just for you
- **Creative prompts** - Ideas that make sense for your style
- **Cross-pollination** - Unexpected connections from other arts

## 🚀 Get Started (Zero Technical Knowledge Required)

### Quick Setup
\`\`\`bash
# Clone the repository
git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
cd $REPO_NAME

# Run the magic installer
chmod +x scripts/install/*.sh
./scripts/install/install_creative_rag.sh

# Start your AI creative assistant
docker-compose -f configs/docker/docker-compose.yml up -d
./scripts/launch_ui.sh
\`\`\`

## 🎯 Your Creative AI Dashboard

- **🎨 Main Interface**: http://localhost:7860 ← **This is where the magic happens**
- **📡 API Documentation**: http://localhost:8000/docs  
- **📊 System Health**: http://localhost:8000/api/health

## 🎨 Perfect For Every Type of Artist

### **Digital Artists**
- "Is my style consistent across my work?"
- "What techniques should I explore next?"
- "How can I improve my compositions?"
- "Find inspiration for this client brief"

### **Traditional Artists**
- "What classical techniques am I unconsciously using?"
- "How does my work relate to art history?"
- "What patterns define my artistic voice?"
- "Show me masters who painted like I do"

### **Designers**
- "Extract the perfect color palette from this image"
- "What design trends match this project mood?"
- "Build me a comprehensive mood board"
- "How can I make this design more impactful?"

### **Art Students & Educators**
- "Break down this masterpiece to understand techniques"
- "Track artistic development over time"
- "Create visual comparisons between movements"
- "Generate educational content about art principles"

## 🏗️ System Architecture

Built for WSL Ubuntu with RTX 4090 optimization:

\`\`\`
Your Creative AI Stack:
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Beautiful UI   │    │  Smart Backend   │    │   AI Models     │
│ (Gradio-based)  │◄──►│   (FastAPI)      │◄──►│ (Qwen2.5VL+)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Your Browser   │    │   Database       │    │   GPU Power     │
│ (No downloads)  │    │ (PostgreSQL)     │    │ (RTX 4090)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
\`\`\`

### The Secret Sauce
- **🧠 Vision AI**: Qwen2.5VL sees and understands art like a trained curator
- **⚡ GPU Acceleration**: Your RTX 4090 makes everything lightning fast
- **🐳 Container Magic**: Docker ensures everything works everywhere
- **🎨 Artist-First Design**: Every feature designed for creative workflows

## 📁 Project Structure

\`\`\`
$REPO_NAME/
├── src/                     # The brain
│   ├── ui/                 # Beautiful artist interface
│   │   ├── components/     # Modular UI pieces
│   │   └── themes/         # Custom styling
│   ├── api/                # Smart backend services
│   ├── models/             # AI model connections
│   ├── core/               # Business logic
│   └── utils/              # Helper functions
├── scripts/                # Installation & maintenance magic
│   ├── install/           # Setup scripts
│   ├── maintenance/       # System upkeep
│   └── development/       # Dev tools
├── configs/                # Settings that just work
│   ├── docker/            # Container configs
│   ├── env/               # Environment settings
│   └── models/            # AI model configs
├── docs/                   # Help when you need it
├── tests/                  # Quality assurance
├── data/                   # Your creative data lives here
│   ├── uploads/           # Your artwork uploads
│   ├── processed/         # AI-processed results
│   └── cache/             # Speed optimization
└── assets/                 # Static resources
    ├── images/            # UI graphics
    ├── icons/             # Interface icons
    └── styles/            # Custom CSS
\`\`\`

## 🧠 The knowNothing Philosophy

**"You don't need to understand how paint is made to create a masterpiece"**

- **🎨 Artists First**: Every feature designed with creative workflows in mind
- **🚫 No Jargon**: Plain language, visual interfaces, intuitive interactions
- **⚡ Just Works**: Advanced AI that feels like creative magic, not technology
- **🔓 Always Free**: Open source, customizable, community-driven
- **🌍 For Everyone**: Democratizing AI tools for all creative professionals

## 🛠️ Technical Details (For the Curious)

### System Requirements
- **OS**: WSL Ubuntu (Windows Subsystem for Linux)
- **GPU**: NVIDIA RTX 4090 (or compatible)
- **RAM**: 16GB+ recommended
- **Storage**: 20GB+ free space
- **Python**: 3.11+
- **Docker**: Latest version with GPU support

### Key Technologies
- **Frontend**: Gradio 4.x (artist-friendly interfaces)
- **Backend**: FastAPI (async, high-performance)
- **AI Models**: Qwen2.5VL, Nomic embeddings
- **Database**: PostgreSQL + Redis
- **Containerization**: Docker + Docker Compose
- **GPU**: CUDA acceleration, optimized for RTX 4090

## 🎯 Roadmap

Coming soon to knowNothing RAG:
- **🔌 Creative Tool Integration**: Photoshop, Blender, Figma plugins
- **🤝 Collaboration Features**: Share insights with other artists
- **📱 Mobile Companion**: Inspiration on the go
- **🎓 Learning Modules**: Guided artistic skill development
- **🌐 Community Gallery**: Showcase your AI-enhanced creativity

## 🤝 Contributing

Want to help make AI more accessible to artists?

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Add tests if applicable
5. Submit a pull request

## 📄 License

MIT License - Use it, hack it, share it, make incredible art with it!

## 🙏 Built With Love By

- **Artists**: Who demanded better creative technology
- **Developers**: Who believe AI should serve creativity
- **Community**: Who made this possible through open source
- **You**: For being brave enough to try AI for your art

## 🆘 Support

- **🐛 Bug Reports**: [GitHub Issues](https://github.com/$GITHUB_USERNAME/$REPO_NAME/issues)
- **💡 Feature Requests**: [GitHub Discussions](https://github.com/$GITHUB_USERNAME/$REPO_NAME/discussions)
- **📧 Contact**: [$USER_EMAIL](mailto:$USER_EMAIL)

---

**🧠 knowNothing RAG: Where AI meets Art, and Magic Happens**

*"The best creative tools are invisible - they amplify your vision without getting in the way"*

**Built for artists who want AI superpowers without the PhD** 🎨✨
README_EOF

# Create environment config
mkdir -p configs/env
cat > configs/env/.env.template << 'ENV_EOF'
# === KNOWNOTHING CREATIVE RAG CONFIGURATION ===

# Application Settings
APP_NAME="knowNothing Creative RAG"
APP_VERSION="1.0.0"
ENVIRONMENT=development
DEBUG=true
SECRET_KEY=your-super-secret-key-change-this-in-production

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4

# Database Configuration
DATABASE_URL=postgresql://creative_user:creative_pass@localhost:5432/creative_rag
DATABASE_POOL_SIZE=10
DATABASE_MAX_OVERFLOW=20

# Redis Configuration
REDIS_URL=redis://localhost:6379/0
REDIS_CACHE_TTL=3600

# AI Model Configuration
OLLAMA_URL=http://localhost:11434
VISION_MODEL=qwen2.5vl:latest
EMBEDDING_MODEL=nomic-embed-text:latest
MODEL_TEMPERATURE=0.7
MAX_TOKENS=2048

# GPU Configuration (RTX 4090 Optimized)
CUDA_VISIBLE_DEVICES=0
TORCH_CUDA_ARCH_LIST="8.6"
USE_GPU=true

# File Storage
UPLOAD_PATH=./data/uploads
PROCESSED_PATH=./data/processed
CACHE_PATH=./data/cache
MAX_FILE_SIZE=50MB
ALLOWED_EXTENSIONS=jpg,jpeg,png,gif,bmp,tiff,webp

# UI Configuration
UI_TITLE="knowNothing Creative RAG"
UI_DESCRIPTION="AI superpowers for artists who know nothing about AI"
UI_PORT=7860
UI_SHARE=false
UI_DEBUG=false

# Security
CORS_ORIGINS=["http://localhost:3000","http://localhost:7860","http://localhost:8000"]
ALLOWED_HOSTS=["localhost","127.0.0.1"]

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=detailed
LOG_FILE=./logs/app.log

# WSL Ubuntu Specific
WSL_HOST=localhost
WSL_DISTRO=Ubuntu
ENV_EOF

# Create updated pyproject.toml with knowNothing branding
cat > pyproject.toml << 'PYPROJECT_EOF'
[tool.poetry]
name = "knownothing-creative-rag"
version = "1.0.0"
description = "AI superpowers for artists who know nothing about AI"
authors = ["Creative Developer <dev@example.com>"]
license = "MIT"
readme = "README.md"
homepage = "https://github.com/username/knownothing-creative-rag"
repository = "https://github.com/username/knownothing-creative-rag"
keywords = ["ai", "art", "creative", "rag", "multimodal", "gpu", "wsl"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: End Users/Desktop",
    "Topic :: Artistic Software",
    "Topic :: Scientific/Engineering :: Artificial Intelligence",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
packages = [{ include = "src" }]

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.110.0"
uvicorn = {extras = ["standard"], version = "^0.27.0"}
pydantic = "^2.6.0"
pydantic-settings = "^2.2.0"
sqlalchemy = "^2.0.25"
asyncpg = "^0.29.0"
redis = "^5.0.1"
httpx = "^0.27.0"
aiofiles = "^23.2.1"
python-multipart = "^0.0.9"
pillow = "^10.2.0"
torch = "^2.1.2"
transformers = "^4.37.0"
sentence-transformers = "^2.3.1"
gradio = "^4.15.0"
plotly = "^5.17.0"
pandas = "^2.1.4"
numpy = "^1.26.3"
scikit-learn = "^1.4.0"
loguru = "^0.7.2"
rich = "^13.7.0"
typer = "^0.9.0"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0.0"
pytest-asyncio = "^0.23.0"
pytest-cov = "^4.1.0"
black = "^24.0.0"
ruff = "^0.2.0"
mypy = "^1.8.0"
pre-commit = "^3.6.0"

[tool.poetry.scripts]
knownothing = "src.cli:app"
knownothing-ui = "src.ui.launch:main"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
target-version = "py311"
line-length = 88
select = ["E", "W", "F", "I", "B", "C4", "UP"]
ignore = ["E501", "B008", "C901"]

[tool.mypy]
python_version = "3.11"
check_untyped_defs = true
disallow_any_generics = true
disallow_incomplete_defs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-ra -q --strict-markers"
testpaths = ["tests"]
pythonpath = ["."]
PYPROJECT_EOF

# Create Docker configuration optimized for WSL
mkdir -p configs/docker
cat > configs/docker/docker-compose.yml << 'DOCKER_EOF'
version: '3.9'

services:
  # knowNothing Creative RAG API
  knownothing-api:
    build: 
      context: ../..
      dockerfile: Dockerfile
    container_name: knownothing-creative-rag-api
    ports:
      - "${API_PORT:-8000}:8000"
    environment:
      - ENVIRONMENT=${ENVIRONMENT:-production}
      - DATABASE_URL=postgresql://creative_user:creative_pass@postgres:5432/creative_rag
      - REDIS_URL=redis://redis:6379/0
      - OLLAMA_URL=http://ollama:11434
      - CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}
    volumes:
      - ../../data:/app/data
      - ../../logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  # knowNothing Creative RAG UI
  knownothing-ui:
    build:
      context: ../..
      dockerfile: src/ui/Dockerfile
    container_name: knownothing-creative-rag-ui
    ports:
      - "${UI_PORT:-7860}:7860"
    environment:
      - API_URL=http://knownothing-api:8000
      - GRADIO_SERVER_NAME=0.0.0.0
      - GRADIO_SERVER_PORT=7860
    depends_on:
      - knownothing-api
    restart: unless-stopped

  # PostgreSQL Database
  postgres:
    image: postgres:14-alpine
    container_name: knownothing-postgres
    environment:
      POSTGRES_DB: creative_rag
      POSTGRES_USER: creative_user
      POSTGRES_PASSWORD: creative_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U creative_user -d creative_rag"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: knownothing-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped

  # Ollama AI Models
  ollama:
    image: ollama/ollama:latest
    container_name: knownothing-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_ORIGINS=*
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  ollama_data:
    driver: local

networks:
  default:
    name: knownothing-creative-rag
    driver: bridge
DOCKER_EOF

echo ""
echo "🔄 Initializing Git repository..."

# Git setup
git config user.name "$USER_NAME"
git config user.email "$USER_EMAIL"
git init --initial-branch=main
git add .
git commit -m "🧠 Initial commit: knowNothing Creative RAG

🎨 AI superpowers for artists who know nothing about AI

✨ Features:
- GPU-accelerated multimodal RAG (RTX 4090 optimized)
- Beautiful Gradio UI designed for artists, not engineers
- FastAPI backend with async creative workflows
- WSL Ubuntu optimization
- Docker containerization that just works
- Zero technical knowledge required

🎯 Creative Tools:
- Creative Analyzer: Instant artwork insights
- Style Explorer: Mood-based artistic discovery
- Portfolio Intelligence: Track your creative evolution
- Inspiration Engine: Never face blank canvas again

🧠 Philosophy:
- Artists first, technology second
- Powerful capabilities, simple interfaces
- Creative magic, not machine learning jargon
- Democratizing AI for all creative professionals

🚀 Ready to transform creative workflows worldwide!"

echo ""
echo "🎉 === KNOWNOTHING CREATIVE RAG SETUP COMPLETE! ==="
echo ""
echo "📍 Repository Location: $NEW_REPO_ROOT"
echo "🔗 Ready for GitHub: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "🚀 NEXT STEPS TO CREATIVE AI MASTERY:"
echo ""
echo "1️⃣  CREATE GITHUB REPOSITORY:"
echo "   → Visit: https://github.com/new"
echo "   → Repository name: $REPO_NAME"
echo "   → Description: AI superpowers for artists who know nothing about AI"
echo "   → Make it public (share the creative revolution!)"
echo ""
echo "2️⃣  PUSH YOUR CREATION TO THE WORLD:"
echo "   cd $NEW_REPO_ROOT"
echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "   git push -u origin main"
echo ""
echo "3️⃣  SETUP ENVIRONMENT:"
echo "   cd $NEW_REPO_ROOT"
echo "   cp configs/env/.env.template .env"
echo "   # Edit .env with your specific settings"
echo ""
echo "4️⃣  LAUNCH YOUR CREATIVE AI:"
echo "   docker-compose -f configs/docker/docker-compose.yml up -d"
echo "   ./scripts/launch_ui.sh"
echo ""
echo "5️⃣  START CREATING WITH AI:"
echo "   🎨 knowNothing UI: http://localhost:7860"
echo "   📡 Developer API: http://localhost:8000/docs"
echo "   📊 System Status: http://localhost:8000/api/health"
echo ""
echo "✅ Your knowNothing Creative RAG is ready to revolutionize your art!"
echo "🧠 AI superpowers activated. PhD not required. Creativity unlimited."
echo ""
echo "🌟 Welcome to the future of creative technology!"