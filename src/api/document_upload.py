"""
Stage 3: Document Upload API Endpoints
RESTful API for document storage and management
Part of knowNothing Creative RAG
"""

from fastapi import APIRouter, HTTPException, UploadFile, File, Query
from fastapi.responses import JSONResponse
from typing import List, Dict, Any
import logging
from datetime import datetime

from ..services.storage_manager import StorageManager

logger = logging.getLogger(__name__)

# Create router with prefix
router = APIRouter(prefix="/api/documents", tags=["Document Storage"])

# Initialize storage manager
storage_manager = StorageManager()

@router.post("/upload")
async def upload_document(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Upload a document for storage and future analysis
    
    - **file**: Document file (PDF, TXT, DOCX supported)
    - **Returns**: Document ID and metadata
    
    Perfect for artists who want to upload scripts, notes, or research documents!
    """
    logger.info(f"📄 Uploading document: {file.filename}")
    
    try:
        # Validate file exists
        if not file.filename:
            raise HTTPException(
                status_code=400, 
                detail="📁 No file selected. Please choose a document to upload!"
            )
        
        # Store the document
        document_id = await storage_manager.store_document(file)
        
        # Get stored document info
        doc_info = await storage_manager.get_document(document_id)
        
        if not doc_info:
            raise HTTPException(
                status_code=500,
                detail="🔧 Document uploaded but couldn't retrieve info. Please try again!"
            )
        
        return {
            "success": True,
            "message": f"📄 Document '{file.filename}' uploaded successfully!",
            "document_id": document_id,
            "document_info": {
                "id": doc_info["id"],
                "original_filename": doc_info["original_filename"],
                "file_type": doc_info["file_type"],
                "file_size_mb": doc_info["file_size_mb"],
                "upload_date": doc_info["upload_date"],
                "status": doc_info["status"]
            },
            "next_steps": [
                f"Extract text: POST /api/documents/{document_id}/extract",
                f"Get document info: GET /api/documents/{document_id}",
                "List all documents: GET /api/documents/list"
            ],
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except ValueError as e:
        # Handle validation errors (file type, size, etc.)
        raise HTTPException(status_code=400, detail=f"📋 {str(e)}")
        
    except Exception as e:
        logger.error(f"❌ Document upload failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Upload failed: {str(e)}"
        )

@router.get("/list")
async def list_documents(
    limit: int = Query(default=20, ge=1, le=100, description="Number of documents to return"),
    offset: int = Query(default=0, ge=0, description="Number of documents to skip")
) -> Dict[str, Any]:
    """
    List all uploaded documents
    
    - **limit**: Maximum number of documents to return (1-100)
    - **offset**: Number of documents to skip (for pagination)
    
    Great for seeing all your uploaded creative materials!
    """
    logger.info(f"📋 Listing documents (limit={limit}, offset={offset})")
    
    try:
        documents = await storage_manager.list_documents(limit=limit, offset=offset)
        total_count = await storage_manager.get_document_count()
        
        # Format documents for display
        formatted_docs = []
        for doc in documents:
            formatted_docs.append({
                "id": doc["id"],
                "filename": doc["original_filename"],
                "type": doc["file_type"],
                "size_mb": doc["file_size_mb"],
                "uploaded": doc["upload_date"],
                "status": doc["status"],
                "file_exists": doc["file_exists"]
            })
        
        return {
            "success": True,
            "message": f"📚 Found {len(formatted_docs)} documents",
            "documents": formatted_docs,
            "pagination": {
                "total_documents": total_count,
                "returned": len(formatted_docs),
                "limit": limit,
                "offset": offset,
                "has_more": offset + len(formatted_docs) < total_count
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Failed to list documents: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Couldn't list documents: {str(e)}"
        )

@router.get("/{document_id}")
async def get_document_info(document_id: str) -> Dict[str, Any]:
    """
    Get detailed information about a specific document
    
    - **document_id**: Unique document identifier
    
    Shows everything about your uploaded document!
    """
    logger.info(f"📄 Getting info for document: {document_id}")
    
    try:
        doc_info = await storage_manager.get_document(document_id)
        
        if not doc_info:
            raise HTTPException(
                status_code=404,
                detail=f"📁 Document '{document_id}' not found. Check the document ID!"
            )
        
        return {
            "success": True,
            "message": f"📄 Document info retrieved",
            "document": {
                "id": doc_info["id"],
                "original_filename": doc_info["original_filename"],
                "stored_filename": doc_info["stored_filename"],
                "file_type": doc_info["file_type"],
                "mime_type": doc_info["mime_type"],
                "file_size_mb": doc_info["file_size_mb"],
                "upload_date": doc_info["upload_date"],
                "status": doc_info["status"],
                "file_exists": doc_info["file_exists"],
                "file_path": doc_info["file_path"]  # For debugging
            },
            "available_operations": [
                f"Extract text: POST /api/documents/{document_id}/extract",
                f"Delete document: DELETE /api/documents/{document_id}",
                "List all documents: GET /api/documents/list"
            ],
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
        
    except Exception as e:
        logger.error(f"❌ Failed to get document info: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Couldn't get document info: {str(e)}"
        )

@router.delete("/{document_id}")
async def delete_document(document_id: str) -> Dict[str, Any]:
    """
    Delete a document and its file
    
    - **document_id**: Unique document identifier
    
    Permanently removes the document - use with caution!
    """
    logger.info(f"🗑️ Deleting document: {document_id}")
    
    try:
        # Check if document exists first
        doc_info = await storage_manager.get_document(document_id)
        if not doc_info:
            raise HTTPException(
                status_code=404,
                detail=f"📁 Document '{document_id}' not found. Nothing to delete!"
            )
        
        # Delete the document
        success = await storage_manager.delete_document(document_id)
        
        if success:
            return {
                "success": True,
                "message": f"🗑️ Document '{doc_info['original_filename']}' deleted successfully",
                "deleted_document": {
                    "id": document_id,
                    "filename": doc_info["original_filename"],
                    "file_type": doc_info["file_type"]
                },
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            raise HTTPException(
                status_code=500,
                detail="🔧 Document exists but couldn't be deleted. Please try again!"
            )
            
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
        
    except Exception as e:
        logger.error(f"❌ Failed to delete document: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Deletion failed: {str(e)}"
        )

@router.get("/stats/storage")
async def get_storage_stats() -> Dict[str, Any]:
    """
    Get storage statistics and system info
    
    Shows how much storage you're using and system health!
    """
    logger.info("📊 Getting storage statistics")
    
    try:
        stats = await storage_manager.get_storage_stats()
        
        return {
            "success": True,
            "message": "📊 Storage statistics retrieved",
            "stats": stats,
            "recommendations": [
                "PDF files are best for text extraction",
                "Keep individual files under 50MB for best performance",
                "TXT files process fastest for simple documents"
            ] if stats.get('total_documents', 0) > 0 else [
                "Upload your first document to get started!",
                "Supported formats: PDF, TXT, DOCX",
                "Perfect for scripts, notes, and research documents"
            ],
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Failed to get storage stats: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Couldn't get storage stats: {str(e)}"
        )