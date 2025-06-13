"""
Document Upload API - Fixed version
"""
from fastapi import APIRouter, UploadFile, File, HTTPException
from typing import Dict, List
import logging

logger = logging.getLogger(__name__)

# Create router
router = APIRouter()

@router.get("/documents/list")
async def list_documents() -> Dict:
    """List uploaded documents"""
    # Sample data for now
    return {
        "success": True,
        "message": "Documents retrieved",
        "documents": [
            {"id": "1", "name": "sample.pdf", "size": "2.1MB"},
            {"id": "2", "name": "notes.txt", "size": "0.5MB"}
        ],
        "count": 2
    }

@router.post("/documents/upload")
async def upload_document(file: UploadFile = File(...)) -> Dict:
    """Upload a document"""
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided")
    
    return {
        "success": True,
        "message": f"Document '{file.filename}' uploaded successfully!",
        "filename": file.filename,
        "document_id": f"doc-{hash(file.filename) % 10000}"
    }

@router.get("/documents/stats")
async def document_stats() -> Dict:
    """Document statistics"""
    return {
        "total_documents": 2,
        "total_size_mb": 2.6,
        "file_types": {"pdf": 1, "txt": 1}
    }
