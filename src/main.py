"""
knowNothing Creative RAG - Main Application
FastAPI server with Gradio UI integration
"""

import os
import logging
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import JSONResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import uvicorn
from pathlib import Path

# Configure logging FIRST
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="knowNothing Creative RAG",
    description="AI superpowers for artists who know nothing about AI",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files (if directory exists)
static_dir = Path("assets")
if static_dir.exists():
    app.mount("/static", StaticFiles(directory="assets"), name="static")

@app.get("/")
async def root():
    """Redirect to UI"""
    return HTMLResponse("""
    <html>
        <head>
            <title>knowNothing Creative RAG</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 0; padding: 2rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; }
                .container { max-width: 600px; margin: 0 auto; }
                .logo { font-size: 4rem; margin-bottom: 1rem; }
                .tagline { font-size: 1.5rem; margin-bottom: 2rem; opacity: 0.9; }
                .links { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 2rem; }
                .link { background: rgba(255,255,255,0.2); padding: 1rem; border-radius: 10px; text-decoration: none; color: white; transition: all 0.3s; }
                .link:hover { background: rgba(255,255,255,0.3); transform: translateY(-2px); }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="logo">🧠</div>
                <h1>knowNothing Creative RAG</h1>
                <p class="tagline">AI superpowers for artists who know nothing about AI</p>
                <div class="links">
                    <a href="http://localhost:7860" class="link">
                        <h3>🎨 Creative Interface</h3>
                        <p>Upload & analyze your artwork</p>
                    </a>
                    <a href="/api/docs" class="link">
                        <h3>📡 API Documentation</h3>
                        <p>Technical documentation</p>
                    </a>
                    <a href="/api/health" class="link">
                        <h3>📊 System Health</h3>
                        <p>Check system status</p>
                    </a>
                </div>
            </div>
        </body>
    </html>
    """)

@app.get("/api/health")
async def health_check():
    """System health check"""
    return {
        "status": "healthy",
        "message": "knowNothing Creative RAG is running!",
        "version": "1.0.0",
        "components": {
            "api": "running",
            "ui": "available at http://localhost:7860",
            "database": "configured"
        }
    }

# Import and include routers
try:
    from .api.ai_ping import router as ai_ping_router
    app.include_router(ai_ping_router)
    logger.info("✅ AI ping endpoints registered")
except ImportError as e:
    logger.warning(f"⚠️ AI ping endpoints not loaded: {e}")

try:
    from .api.image_analysis import router as image_analysis_router
    app.include_router(image_analysis_router)
    logger.info("✅ Image analysis endpoints registered")
except ImportError as e:
    logger.warning(f"⚠️ Image analysis module not loaded: {e}")

# Stage 3: Document Storage Integration
try:
    from .api.document_upload import router as document_router
    app.include_router(document_router)
    logger.info("✅ Document storage endpoints registered")
except ImportError as e:
    logger.warning(f"⚠️ Document storage module not loaded: {e}")
except Exception as e:
    logger.error(f"❌ Error loading document storage module: {e}")

if __name__ == "__main__":
    uvicorn.run(
        "src.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

# Stage 4: Text Extraction Integration
try:
    from .api.text_extraction_api import router as text_extraction_router
    app.include_router(text_extraction_router)
    logger.info("✅ Text extraction endpoints registered")
except ImportError as e:
    logger.warning(f"⚠️ Text extraction module not loaded: {e}")
    logger.info("💡 Install dependencies: poetry add PyPDF2 python-docx chardet")
except Exception as e:
    logger.error(f"❌ Error loading text extraction module: {e}")