# src/api/creative_endpoints.py
"""
FastAPI endpoints for knowNothing Creative RAG
Artist-friendly API that hides complexity
"""

from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import logging
from typing import Optional

from ..models.vision_analyzer import CreativeVisionAnalyzer
from ..models.model_manager import ModelManager

logger = logging.getLogger(__name__)

app = FastAPI(
    title="knowNothing Creative RAG API",
    description="AI superpowers for artists who know nothing about AI",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize components
vision_analyzer = CreativeVisionAnalyzer()
model_manager = ModelManager()

@app.get("/api/health")
async def health_check():
    """Check if the creative AI is ready to help artists"""
    health_status = await model_manager.health_check()
    
    return {
        "status": "healthy" if health_status["status"] == "ready" else "initializing",
        "message": "Your creative AI assistant is ready!" if health_status["status"] == "ready" else "Getting your AI ready...",
        "details": health_status,
        "version": "1.0.0"
    }

@app.post("/api/analyze/artwork")
async def analyze_artwork(
    file: UploadFile = File(...),
    analysis_type: str = Form("comprehensive"),
    context: Optional[str] = Form("")
):
    """
    Analyze artwork - the main creative magic endpoint
    
    - **file**: Your artwork image (JPG, PNG, etc.)
    - **analysis_type**: What you want to know (style, composition, color, technique, comprehensive)
    - **context**: Any additional info about your artwork
    """
    try:
        # Validate file type
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="Please upload an image file")
        
        # Read and process image
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        
        # Get AI analysis
        analysis = await vision_analyzer.analyze_artwork(
            image=image,
            analysis_type=analysis_type,
            context=context or ""
        )
        
        # Add friendly metadata
        analysis["original_filename"] = file.filename
        analysis["file_size"] = len(image_data)
        analysis["analysis_requested"] = analysis_type
        
        return JSONResponse(content={
            "success": True,
            "message": "Your artwork analysis is ready!",
            "analysis": analysis
        })
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Artwork analysis failed: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail="Our AI had a creative block. Please try again!"
        )

@app.post("/api/analyze/style")
async def analyze_style(
    file: UploadFile = File(...),
    context: Optional[str] = Form("")
):
    """Quick style analysis - 'What style is this?'"""
    return await analyze_artwork(file, "style", context)

@app.post("/api/analyze/composition")
async def analyze_composition(
    file: UploadFile = File(...),
    context: Optional[str] = Form("")
):
    """Composition analysis - 'How is this structured?'"""
    return await analyze_artwork(file, "composition", context)

@app.post("/api/analyze/colors")
async def analyze_colors(
    file: UploadFile = File(...),
    context: Optional[str] = Form("")
):
    """Color analysis - 'What colors work here?'"""
    return await analyze_artwork(file, "color", context)

@app.post("/api/analyze/technique")
async def analyze_technique(
    file: UploadFile = File(...),
    context: Optional[str] = Form("")
):
    """Technique analysis - 'How was this made?'"""
    return await analyze_artwork(file, "technique", context)

@app.get("/api/models/status")
async def models_status():
    """Check which AI models are ready"""
    model_status = await model_manager.check_models_available()
    
    return {
        "models": model_status,
        "all_ready": all(model_status.values()),
        "message": "All models ready!" if all(model_status.values()) else "Some models still downloading"
    }

@app.post("/api/models/download")
async def download_models():
    """Download missing AI models"""
    try:
        results = await model_manager.download_missing_models()
        
        return {
            "success": True,
            "message": "Model download initiated",
            "results": results
        }
    except Exception as e:
        logger.error(f"Model download failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to download models. Please check your connection."
        )

@app.get("/api/inspiration")
async def get_inspiration(
    mood: Optional[str] = None,
    style: Optional[str] = None,
    medium: Optional[str] = None
):
    """Get creative inspiration based on mood, style, or medium"""
    # This would connect to a curated database of inspiration
    # For now, return sample data
    
    inspirations = [
        {
            "title": "Moody Landscape Inspiration",
            "description": "Dark, atmospheric landscapes with dramatic lighting",
            "tags": ["landscape", "moody", "dramatic"],
            "color_palette": ["#2c3e50", "#34495e", "#7f8c8d"],
            "techniques": ["atmospheric perspective", "chiaroscuro lighting"]
        },
        {
            "title": "Abstract Color Study",
            "description": "Bold abstract compositions with vibrant colors",
            "tags": ["abstract", "colorful", "energetic"],
            "color_palette": ["#e74c3c", "#f39c12", "#3498db"],
            "techniques": ["color blocking", "gestural brushwork"]
        }
    ]
    
    return {
        "inspirations": inspirations,
        "filters_applied": {
            "mood": mood,
            "style": style,
            "medium": medium
        }
    }
