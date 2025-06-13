"""
Chat API with model selection and Ollama integration
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import requests
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime

logger = logging.getLogger(__name__)
router = APIRouter()

# Chat message models
class ChatMessage(BaseModel):
    role: str  # 'user' or 'assistant'
    content: str
    timestamp: str = ""
    document_context: str = ""

class ChatRequest(BaseModel):
    message: str
    document_id: str = ""
    chat_history: List[Dict[str, Any]] = []
    model: str = "llama3.2-vision"  # Default model

# In-memory chat storage
chat_sessions = {}

@router.get("/models")
async def get_available_models():
    """Get available Ollama models"""
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        if response.status_code == 200:
            models_data = response.json()
            models = []
            for model in models_data.get("models", []):
                models.append({
                    "name": model.get("name", "unknown"),
                    "size": model.get("size", 0),
                    "modified_at": model.get("modified_at", ""),
                    "digest": model.get("digest", "")[:12]  # Short digest
                })
            
            return {
                "success": True,
                "models": models,
                "ollama_running": True,
                "total_models": len(models)
            }
        else:
            return {
                "success": False,
                "models": [],
                "ollama_running": False,
                "error": f"Ollama API returned {response.status_code}"
            }
    except requests.exceptions.RequestException:
        return {
            "success": False,
            "models": [],
            "ollama_running": False,
            "error": "Ollama is not running. Please start it with: ollama serve"
        }

@router.get("/ollama/status")
async def get_ollama_status():
    """Check if Ollama is running and get system info"""
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=3)
        if response.status_code == 200:
            models_data = response.json()
            return {
                "running": True,
                "models_count": len(models_data.get("models", [])),
                "api_version": "working",
                "url": "http://localhost:11434"
            }
    except:
        pass
    
    return {
        "running": False,
        "models_count": 0,
        "error": "Ollama not accessible",
        "suggestion": "Start with: ollama serve"
    }

@router.post("/chat")
async def chat_with_llm(chat_request: ChatRequest):
    """Chat endpoint with model selection"""
    try:
        # Check if Ollama is running
        ollama_status = await get_ollama_status()
        if not ollama_status["running"]:
            return {
                "success": False,
                "response": "🤖 Ollama is not running. Please start it with 'ollama serve' in your terminal.",
                "error": "ollama_not_running"
            }
        
        # Get document context if document_id is provided
        document_context = ""
        if chat_request.document_id:
            try:
                text_response = requests.get(f"http://localhost:8000/api/text/{chat_request.document_id}")
                if text_response.status_code == 200:
                    text_data = text_response.json()
                    document_context = text_data.get('extracted_text', '')[:3000]
            except Exception as e:
                logger.warning(f"Failed to get document context: {e}")
        
        # Build conversation context
        conversation_history = ""
        for msg in chat_request.chat_history[-5:]:
            role = msg.get('role', 'user')
            content = msg.get('content', '')
            conversation_history += f"{role.capitalize()}: {content}\n"
        
        # Create prompt for Ollama
        system_prompt = """You are a creative writing and script analysis assistant. You help writers, filmmakers, and creative professionals analyze their scripts and creative documents.

You should:
- Analyze scripts for themes, character development, plot structure, dialogue quality
- Provide constructive feedback and suggestions
- Answer questions about creative writing techniques
- Help with character analysis, plot holes, pacing issues
- Be encouraging and supportive while providing honest feedback
- Keep responses concise but helpful (2-3 paragraphs max)

You are NOT a general AI assistant - focus specifically on creative writing and script analysis."""

        # Build the full prompt
        prompt_parts = [system_prompt]
        
        if document_context:
            prompt_parts.append(f"SCRIPT CONTEXT:\n{document_context}")
        
        if conversation_history:
            prompt_parts.append(f"CONVERSATION HISTORY:\n{conversation_history}")
        
        prompt_parts.append(f"USER QUESTION: {chat_request.message}")
        prompt_parts.append("RESPONSE:")
        
        prompt = "\n\n".join(prompt_parts)

        # Send to Ollama with selected model
        try:
            ollama_response = requests.post(
                "http://localhost:11434/api/generate",
                json={
                    "model": chat_request.model,
                    "prompt": prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.7,
                        "top_p": 0.9,
                        "num_predict": 500  # Max tokens
                    }
                },
                timeout=30
            )
            
            if ollama_response.status_code == 200:
                result = ollama_response.json()
                response_text = result.get("response", "I'm having trouble generating a response right now.")
                
                # Store chat message
                session_id = "default"
                if session_id not in chat_sessions:
                    chat_sessions[session_id] = []
                
                chat_sessions[session_id].extend([
                    {
                        "role": "user",
                        "content": chat_request.message,
                        "timestamp": datetime.now().isoformat(),
                        "document_context": chat_request.document_id,
                        "model": chat_request.model
                    },
                    {
                        "role": "assistant", 
                        "content": response_text,
                        "timestamp": datetime.now().isoformat(),
                        "document_context": chat_request.document_id,
                        "model": chat_request.model
                    }
                ])
                
                return {
                    "success": True,
                    "response": response_text,
                    "model_used": chat_request.model,
                    "timestamp": datetime.now().isoformat(),
                    "document_context": bool(document_context)
                }
            else:
                error_msg = f"Model '{chat_request.model}' returned error {ollama_response.status_code}"
                if ollama_response.status_code == 404:
                    error_msg = f"Model '{chat_request.model}' not found. Please download it with: ollama pull {chat_request.model}"
                
                return {
                    "success": False,
                    "response": f"🤖 {error_msg}",
                    "error": f"ollama_error_{ollama_response.status_code}",
                    "model_used": chat_request.model
                }
                
        except requests.exceptions.RequestException as e:
            return {
                "success": False,
                "response": f"🤖 Connection error with Ollama: {str(e)}",
                "error": "connection_error"
            }
            
    except Exception as e:
        logger.error(f"Chat error: {str(e)}")
        return {
            "success": False,
            "response": "An unexpected error occurred. Please try again.",
            "error": str(e)
        }

@router.get("/chat/history")
async def get_chat_history(session_id: str = "default"):
    """Get chat history for a session"""
    return {
        "success": True,
        "messages": chat_sessions.get(session_id, []),
        "session_id": session_id
    }
