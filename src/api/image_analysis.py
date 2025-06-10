"""
Stage 2: Simple Image Analysis
Upload artwork and get instant AI feedback
"""

from fastapi import APIRouter, UploadFile, File, HTTPException
from PIL import Image
import io
import base64
import httpx
import logging
from typing import Dict, Any
from datetime import datetime

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/analyze", tags=["Image Analysis"])

OLLAMA_BASE_URL = "http://localhost:11434"
DEFAULT_MODEL = "qwen2.5vl:latest"
TIMEOUT_SECONDS = 60.0

@router.post("/image/quick")
async def quick_image_analysis(file: UploadFile = File(...)) -> Dict[str, Any]:
    """Quick image analysis - What does the AI see?"""
    logger.info(f"Analyzing uploaded image: {file.filename}")
    
    try:
        # Validate image file
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="🖼️ Please upload an image file")
        
        # Read and process image
        image_data = await file.read()
        if len(image_data) == 0:
            raise HTTPException(status_code=400, detail="📷 The uploaded file appears to be empty")
        
        # Open image with PIL
        try:
            image = Image.open(io.BytesIO(image_data))
            original_size = image.size
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"🚫 Could not process image: {str(e)}")
        
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize if too large (for faster processing)
        max_size = 1024
        if max(image.size) > max_size:
            ratio = max_size / max(image.size)
            new_size = tuple(int(dim * ratio) for dim in image.size)
            image = image.resize(new_size, Image.Resampling.LANCZOS)
        
        # Convert to base64 for AI model
        buffer = io.BytesIO()
        image.save(buffer, format='JPEG', quality=90)
        image_bytes = buffer.getvalue()
        image_b64 = base64.b64encode(image_bytes).decode('utf-8')
        
        # Artist-friendly prompt
        prompt = """
        Look at this artwork and tell me in a friendly, encouraging way:

        1. What do you see? (main elements in simple terms)
        2. What style or mood does it have?
        3. What colors dominate?
        4. What's the overall feeling?

        Keep it positive and accessible - like talking to an artist friend!
        """
        
        # Send to AI model
        async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS) as client:
            response = await client.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": DEFAULT_MODEL,
                    "prompt": prompt,
                    "images": [image_b64],
                    "stream": False,
                    "options": {"temperature": 0.7, "max_tokens": 300}
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                ai_response = result.get("response", "I can see your artwork, but having trouble describing it.")
                
                return {
                    "success": True,
                    "message": "🎨 Your artwork has been analyzed!",
                    "filename": file.filename,
                    "analysis": {
                        "ai_sees": ai_response.strip(),
                        "confidence": "high"
                    },
                    "image_info": {
                        "original_dimensions": original_size,
                        "processed_dimensions": image.size,
                        "file_size_mb": round(len(image_data) / (1024 * 1024), 2)
                    },
                    "processing_time_ms": response.elapsed.total_seconds() * 1000,
                    "timestamp": datetime.utcnow().isoformat()
                }
            else:
                return {
                    "success": False,
                    "message": "🎭 The AI is having a creative moment. Please try again!",
                    "error_code": response.status_code,
                    "timestamp": datetime.utcnow().isoformat()
                }
                
    except HTTPException:
        raise
    except httpx.TimeoutException:
        return {
            "success": False,
            "message": "⏰ Analysis taking too long. Try a smaller image.",
            "timestamp": datetime.utcnow().isoformat()
        }
    except httpx.ConnectError:
        return {
            "success": False,
            "message": "🚫 Can't reach AI service. Make sure Ollama is running.",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "success": False,
            "message": "🤔 Something unexpected happened while analyzing your artwork.",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }

@router.post("/image/colors")
async def extract_colors(file: UploadFile = File(...)) -> Dict[str, Any]:
    """Extract dominant colors from artwork"""
    try:
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="🖼️ Please upload an image file")
        
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        original_size = image.size
        
        # Convert to RGB and resize for faster processing
        if image.mode != 'RGB':
            image = image.convert('RGB')
        image = image.resize((150, 150), Image.Resampling.LANCZOS)
        
        # Get color histogram
        colors = image.getcolors(maxcolors=256*256*256)
        
        if colors:
            colors.sort(key=lambda x: x[0], reverse=True)
            top_colors = []
            total_pixels = 150 * 150
            
            for count, color in colors[:6]:  # Top 6 colors
                hex_color = "#{:02x}{:02x}{:02x}".format(color[0], color[1], color[2])
                percentage = (count / total_pixels) * 100
                
                top_colors.append({
                    "hex": hex_color,
                    "rgb": color,
                    "percentage": round(percentage, 1)
                })
            
            return {
                "success": True,
                "message": "🌈 Colors extracted successfully!",
                "filename": file.filename,
                "colors": top_colors,
                "image_info": {"original_dimensions": original_size},
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            return {
                "success": False,
                "message": "🎨 Could not extract colors from this image",
                "timestamp": datetime.utcnow().isoformat()
            }
            
    except Exception as e:
        return {
            "success": False,
            "message": f"🔧 Color extraction failed: {str(e)}",
            "timestamp": datetime.utcnow().isoformat()
        }
