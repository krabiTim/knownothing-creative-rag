"""
Stage 5: Semantic Search API Endpoints
Artist-friendly API for intelligent creative document discovery
"""

from fastapi import APIRouter, HTTPException, Query, Body
from fastapi.responses import JSONResponse
from typing import Dict, Any, Optional
import logging
from datetime import datetime

from ..services.creative_embedding_service import CreativeEmbeddingService

logger = logging.getLogger(__name__)

# Create router with prefix
router = APIRouter(prefix="/api/embeddings", tags=["Semantic Search"])

# Initialize embedding service
embedding_service = CreativeEmbeddingService()

@router.get("/status")
async def get_embedding_service_status() -> Dict[str, Any]:
    """
    Check if the AI semantic search service is ready
    
    Shows what AI capabilities are available for creative analysis!
    """
    logger.info("🔍 Checking embedding service status")
    
    try:
        status = embedding_service.check_service_status()
        
        # Determine overall readiness message
        if status["service_ready"]:
            message = "🧠 AI semantic search is ready! Upload documents and start discovering connections."
            recommendations = [
                "Generate embeddings for your documents",
                "Search with natural language: 'character development'",
                "Find similar documents automatically",
                "Discover themes across your creative library"
            ]
        else:
            message = "🔧 AI semantic search needs setup. Install dependencies to unlock full power!"
            recommendations = [
                "Install sentence-transformers: poetry add sentence-transformers",
                "Install ChromaDB: poetry add chromadb", 
                "Install NumPy: poetry add numpy",
                "Restart server after installation",
                "Then generate embeddings for intelligent search"
            ]
        
        return {
            "success": True,
            "message": message,
            "service_status": status,
            "capabilities": {
                "semantic_search": status["service_ready"],
                "document_similarity": status["service_ready"],
                "theme_discovery": status["service_ready"],
                "content_recommendations": status["service_ready"]
            },
            "recommendations": recommendations,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Status check failed: {str(e)}")
        return {
            "success": False,
            "error": str(e),
            "message": f"🔧 Status check failed: {str(e)}",
            "timestamp": datetime.utcnow().isoformat()
        }

@router.post("/search")
async def semantic_search(
    query: str = Body(..., description="Natural language search query"),
    limit: int = Body(default=10, description="Maximum results to return")
) -> Dict[str, Any]:
    """
    Semantic search across your creative documents
    
    - **query**: Natural language search (e.g., "character development", "visual metaphors")
    - **limit**: How many results to return (1-50)
    
    Find content by meaning, not just keywords!
    """
    logger.info(f"🔍 Semantic search: '{query}' (limit: {limit})")
    
    try:
        if not query.strip():
            raise HTTPException(
                status_code=400,
                detail="🔍 Please provide a search query (e.g., 'character development')"
            )
        
        if limit < 1 or limit > 50:
            limit = min(max(limit, 1), 50)  # Clamp between 1 and 50
        
        result = await embedding_service.semantic_search(
            query=query.strip(),
            limit=limit
        )
        
        if result["success"]:
            return {
                "success": True,
                "message": f"🔍 Semantic search foundation ready for: '{query}'",
                **result,
                "search_tips": [
                    "Try different phrasings for varied perspectives",
                    "Search for themes: 'redemption', 'family conflict', 'visual metaphors'",
                    "Search for elements: 'dialogue', 'character descriptions', 'setting details'",
                    "Semantic search understands meaning beyond exact words"
                ]
            }
        else:
            raise HTTPException(
                status_code=422 if "not_ready" in result.get("error", "") else 500,
                detail=result.get("message", "Semantic search failed")
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Semantic search failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Semantic search failed: {str(e)}"
        )

@router.get("/stats")
async def get_embedding_statistics() -> Dict[str, Any]:
    """
    Get AI embedding statistics for your creative library
    
    See how much of your creative content is AI-searchable!
    """
    logger.info("📊 Getting embedding statistics")
    
    try:
        return {
            "success": True,
            "message": "📊 Embedding statistics - Stage 5 foundation ready!",
            "statistics": {
                "service_status": embedding_service.check_service_status(),
                "note": "Full statistics available after completing dependency setup"
            },
            "next_steps": [
                "Resolve dependency conflicts",
                "Install missing AI libraries",
                "Generate embeddings for documents",
                "Start semantic searching"
            ],
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Statistics failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Statistics retrieval failed: {str(e)}"
        )

@router.post("/generate/{document_id}")
async def generate_document_embeddings(document_id: str) -> Dict[str, Any]:
    """
    Generate AI embeddings for a document's text
    
    - **document_id**: ID of document to process for semantic search
    
    Transforms your creative documents into AI-searchable content!
    """
    logger.info(f"🧠 Generating embeddings for document: {document_id}")
    
    try:
        # Check if embedding service is ready
        service_status = embedding_service.check_service_status()
        
        if not service_status.get("service_ready", False):
            return {
                "success": False,
                "error": "service_not_ready",
                "message": "🔧 Embedding service not fully ready",
                "service_status": service_status,
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Get document text from the text extraction service
        import sqlite3
        try:
            conn = sqlite3.connect("data/documents.db")
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Get extracted text
            cursor.execute("""
                SELECT extracted_text, word_count, character_count
                FROM document_text 
                WHERE document_id = ?
            """, (document_id,))
            
            text_row = cursor.fetchone()
            
            # Get document metadata
            cursor.execute("""
                SELECT original_filename, file_type
                FROM documents 
                WHERE id = ?
            """, (document_id,))
            
            doc_row = cursor.fetchone()
            conn.close()
            
            if not text_row:
                raise HTTPException(
                    status_code=404,
                    detail=f"📄 No extracted text found for document {document_id}. Extract text first!"
                )
            
            if not doc_row:
                raise HTTPException(
                    status_code=404,
                    detail=f"📄 Document {document_id} not found in database!"
                )
            
            text = text_row["extracted_text"]
            word_count = text_row["word_count"]
            filename = doc_row["original_filename"]
            
            # Simple text chunking for embedding generation
            chunks = []
            chunk_size = 500  # 500 character chunks
            overlap = 50      # 50 character overlap
            
            for i in range(0, len(text), chunk_size - overlap):
                chunk_text = text[i:i + chunk_size]
                if chunk_text.strip():
                    chunks.append({
                        "text": chunk_text.strip(),
                        "chunk_index": len(chunks),
                        "start_position": i,
                        "end_position": min(i + chunk_size, len(text)),
                        "word_count": len(chunk_text.split())
                    })
            
            # For now, return a detailed preview of what would be embedded
            # In the full implementation, this would actually generate and store embeddings
            return {
                "success": True,
                "message": f"🧠 Ready to generate embeddings for '{filename}'!",
                "document_id": document_id,
                "document_info": {
                    "filename": filename,
                    "file_type": doc_row["file_type"],
                    "word_count": word_count,
                    "character_count": text_row["character_count"]
                },
                "embedding_plan": {
                    "total_chunks": len(chunks),
                    "chunk_size": chunk_size,
                    "overlap": overlap,
                    "estimated_embeddings": len(chunks),
                    "model": service_status.get("model_name", "all-MiniLM-L6-v2"),
                    "device": service_status.get("device", "cpu")
                },
                "chunks_preview": chunks[:3] if chunks else [],
                "next_steps": [
                    "Full embedding generation would happen here",
                    "Embeddings would be stored in ChromaDB",
                    "Document would become searchable via semantic similarity",
                    "Artists could then search: 'Find documents about character development'"
                ],
                "note": "🚧 This is the foundation - full embedding generation ready to implement!",
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except sqlite3.Error as e:
            raise HTTPException(
                status_code=500,
                detail=f"🔧 Database error: {str(e)}"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Embedding generation failed for {document_id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Embedding generation failed: {str(e)}"
        )

@router.get("/generate/{document_id}")
async def get_document_embedding_status(document_id: str) -> Dict[str, Any]:
    """
    Check if embeddings exist for a document
    
    - **document_id**: ID of document to check
    
    See if your creative document is ready for AI search!
    """
    logger.info(f"📊 Checking embedding status for document: {document_id}")
    
    try:
        # For now, return that embeddings are ready to be generated
        # In full implementation, this would check ChromaDB for existing embeddings
        
        return {
            "success": True,
            "message": "📊 Embedding status check complete",
            "document_id": document_id,
            "embedding_status": {
                "embeddings_exist": False,  # Would check ChromaDB in full implementation
                "ready_for_generation": True,
                "service_available": embedding_service.check_service_status().get("service_ready", False)
            },
            "recommendation": f"Generate embeddings with: POST /api/embeddings/generate/{document_id}",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Status check failed for {document_id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Status check failed: {str(e)}"
        )
