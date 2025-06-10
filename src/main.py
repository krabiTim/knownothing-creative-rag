"""
knowNothing Creative RAG - Main Application
"""

from fastapi import FastAPI
import uvicorn

# Create FastAPI app
app = FastAPI(
    title="knowNothing Creative RAG",
    description="AI superpowers for artists who know nothing about AI",
    version="1.0.0"
)

@app.get("/")
async def root():
    return {
        "message": "🧠 knowNothing Creative RAG is running!",
        "endpoints": {
            "health": "/api/health",
            "ai_ping": "/api/ai/ping",
            "ai_models": "/api/ai/models",
            "docs": "/docs"
        }
    }

@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "message": "knowNothing Creative RAG is running!"}

# Stage 1: AI Connectivity Testing
try:
    from .api.ai_ping import router as ai_ping_router
    app.include_router(ai_ping_router)
    print("✅ AI ping endpoints registered")
except ImportError as e:
    print(f"⚠️ AI ping module not loaded: {e}")
except Exception as e:
    print(f"❌ Error loading AI ping module: {e}")

# Server startup
if __name__ == "__main__":
    print("🚀 Starting knowNothing Creative RAG server...")
    uvicorn.run(
        "src.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

# Stage 2: Image Analysis
try:
    from .api.image_analysis import router as image_analysis_router
    app.include_router(image_analysis_router)
    print("✅ Image analysis endpoints registered")
except ImportError as e:
    print(f"⚠️ Image analysis module not loaded: {e}")
except Exception as e:
    print(f"❌ Error loading image analysis module: {e}")
