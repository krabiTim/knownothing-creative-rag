"""
Stage 1: AI Connectivity Test
Minimal code to test AI connection without breaking existing functionality
"""

from fastapi import APIRouter
import httpx
import logging
from typing import Dict, Any
from datetime import datetime

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/ai", tags=["AI Testing"])

OLLAMA_BASE_URL = "http://localhost:11434"
DEFAULT_MODEL = "qwen2.5vl:latest"
TIMEOUT_SECONDS = 30.0

@router.get("/ping")
async def ping_ai() -> Dict[str, Any]:
    """Test AI connectivity - the simplest possible AI call"""
    logger.info("Testing AI connectivity...")
    
    try:
        test_prompt = "Say 'Hello from knowNothing Creative RAG!' in exactly 5 words."
        
        async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS) as client:
            response = await client.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json={
                    "model": DEFAULT_MODEL,
                    "prompt": test_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,
                        "max_tokens": 50
                    }
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                ai_response = result.get("response", "AI responded but no content received")
                
                return {
                    "status": "ai_connected",
                    "message": "🧠 Your AI is awake and ready to help with creative tasks!",
                    "ai_response": ai_response.strip(),
                    "model": DEFAULT_MODEL,
                    "response_time_ms": response.elapsed.total_seconds() * 1000,
                    "timestamp": datetime.utcnow().isoformat()
                }
            elif response.status_code == 404:
                return {
                    "status": "model_not_found",
                    "message": f"🤖 Model '{DEFAULT_MODEL}' not found. You may need to download it first.",
                    "suggestion": f"Run: ollama pull {DEFAULT_MODEL}",
                    "timestamp": datetime.utcnow().isoformat()
                }
            else:
                return {
                    "status": "ai_error",
                    "message": "🔧 AI service responded but there's an issue",
                    "error_code": response.status_code,
                    "timestamp": datetime.utcnow().isoformat()
                }
                
    except httpx.TimeoutException:
        return {
            "status": "ai_timeout",
            "message": "⏰ AI is thinking too hard. Try again in a moment!",
            "timeout_seconds": TIMEOUT_SECONDS,
            "timestamp": datetime.utcnow().isoformat()
        }
    except httpx.ConnectError:
        return {
            "status": "ai_unavailable",
            "message": "🚫 Can't reach the AI service. Is Ollama running?",
            "ollama_url": OLLAMA_BASE_URL,
            "suggestion": "Start Ollama: ollama serve",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "unexpected_error",
            "message": "🤔 Something unexpected happened while testing AI",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }

@router.get("/models")
async def list_available_models() -> Dict[str, Any]:
    """List available AI models"""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(f"{OLLAMA_BASE_URL}/api/tags")
            
            if response.status_code == 200:
                data = response.json()
                models = data.get("models", [])
                
                model_list = []
                for model in models:
                    model_info = {
                        "name": model.get("name", "unknown"),
                        "size": model.get("size", 0),
                        "modified": model.get("modified_at", "unknown")
                    }
                    model_list.append(model_info)
                
                default_available = any(model["name"] == DEFAULT_MODEL for model in model_list)
                
                return {
                    "status": "models_retrieved",
                    "message": f"📋 Found {len(model_list)} available models",
                    "models": model_list,
                    "count": len(model_list),
                    "default_model": DEFAULT_MODEL,
                    "default_model_available": default_available,
                    "timestamp": datetime.utcnow().isoformat()
                }
            else:
                return {
                    "status": "models_error",
                    "message": "🔧 Could not fetch available models",
                    "error_code": response.status_code,
                    "timestamp": datetime.utcnow().isoformat()
                }
                
    except httpx.ConnectError:
        return {
            "status": "service_unavailable",
            "message": "🚫 Can't reach Ollama to check models",
            "ollama_url": OLLAMA_BASE_URL,
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "unexpected_error",
            "message": "🤔 Unexpected error checking models",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }
