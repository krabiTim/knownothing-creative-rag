"""
Stage 4: Text Extraction API Endpoints (ROUTING FIXED)
RESTful API for extracting and managing text from creative documents
Part of knowNothing Creative RAG
"""

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import JSONResponse
from typing import Dict, Any, Optional
import logging
from datetime import datetime

from ..services.text_extractor import TextExtractor

logger = logging.getLogger(__name__)

# Create router with prefix
router = APIRouter(prefix="/api/text", tags=["Text Extraction"])

# Initialize text extractor
text_extractor = TextExtractor()

# CRITICAL FIX: Put specific routes BEFORE parameterized routes
# Statistics endpoint MUST come before /{document_id} route

@router.get("/stats")
async def get_text_extraction_stats() -> Dict[str, Any]:
    """
    Get text extraction statistics
    
    Shows extraction progress and system capabilities!
    """
    logger.info("📊 Getting text extraction statistics")
    
    try:
        stats = await text_extractor.get_text_extraction_status()
        
        return {
            "success": True,
            "message": "📊 Text extraction statistics retrieved",
            "statistics": stats,
            # Compatibility fields at root level for tests
            "total_documents": stats.get("total_documents", 0),
            "extracted_documents": stats.get("extracted_documents", 0),
            "extraction_percentage": stats.get("extraction_percentage", 0),
            "recommendations": [
                "PDF files work best with clear, text-based content",
                "DOCX files provide the most accurate extraction",
                "TXT files are processed instantly with perfect accuracy"
            ] if stats.get("total_documents", 0) > 0 else [
                "Upload documents to see extraction statistics",
                "Supported formats: PDF, DOCX, TXT",
                "Text extraction enables search and AI analysis"
            ],
            "capabilities": {
                "formats_supported": ["TXT", "PDF (if PyPDF2 installed)", "DOCX (if python-docx installed)"],
                "features": [
                    "Automatic text cleaning and normalization",
                    "Word and character counting",
                    "Page counting for PDFs",
                    "Search within extracted text",
                    "Multiple encoding support for text files"
                ]
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Failed to get extraction stats: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Couldn't get extraction stats: {str(e)}"
        )

@router.post("/extract-all")
async def extract_all_documents() -> Dict[str, Any]:
    """
    Extract text from all documents that don't have text extracted yet
    
    Batch process all your creative documents!
    """
    logger.info("📄 Starting batch text extraction")
    
    try:
        return {
            "success": True,
            "message": "🚧 Batch extraction feature coming soon!",
            "recommendation": "For now, extract text from individual documents using POST /api/text/extract/{document_id}",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"❌ Batch extraction failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Batch extraction failed: {str(e)}"
        )

# Document-specific routes come AFTER static routes

@router.post("/extract/{document_id}")
async def extract_text_from_document(document_id: str) -> Dict[str, Any]:
    """
    Extract text from an uploaded document
    
    - **document_id**: ID of document to extract text from
    
    Perfect for getting readable text from scripts, notes, and research documents!
    """
    logger.info(f"📄 Extracting text from document: {document_id}")
    
    try:
        # Check if text already extracted
        existing_text = await text_extractor.get_extracted_text(document_id)
        if existing_text:
            return {
                "success": True,
                "message": "📄 Text already extracted (returning cached version)",
                "document_id": document_id,
                "extraction_method": existing_text["method"],
                "text_preview": existing_text["text"][:500] + "..." if len(existing_text["text"]) > 500 else existing_text["text"],
                "statistics": {
                    "word_count": existing_text["word_count"],
                    "character_count": existing_text["character_count"],
                    "page_count": existing_text["page_count"]
                },
                "extraction_date": existing_text["extraction_date"],
                "cached": True,
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Extract text
        result = await text_extractor.extract_text_from_document(document_id)
        
        if result["success"]:
            return {
                "success": True,
                "message": "📄 Text extracted successfully!",
                **result,
                "cached": False,
                "next_steps": [
                    f"Get full text: GET /api/text/{document_id}",
                    f"Search within text: POST /api/text/{document_id}/search",
                    "Get extraction statistics: GET /api/text/stats"
                ]
            }
        else:
            raise HTTPException(
                status_code=422,
                detail=f"🔧 Text extraction failed: {result.get('error', 'Unknown error')}"
            )
            
    except HTTPException:
        raise
        
    except Exception as e:
        logger.error(f"❌ Text extraction failed for {document_id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Text extraction failed: {str(e)}"
        )

@router.get("/{document_id}")
async def get_extracted_text(
    document_id: str,
    format: str = Query(default="preview", regex="^(preview|full|metadata)$", description="Text format to return")
) -> Dict[str, Any]:
    """
    Get extracted text for a document
    
    - **document_id**: ID of document
    - **format**: Return format (preview/full/metadata)
    
    Access the full text content of your creative documents!
    """
    logger.info(f"📖 Getting extracted text for document: {document_id} (format: {format})")
    
    try:
        text_data = await text_extractor.get_extracted_text(document_id)
        
        if not text_data:
            raise HTTPException(
                status_code=404,
                detail=f"📄 No extracted text found for document '{document_id}'. Try extracting it first!"
            )
        
        if format == "metadata":
            return {
                "success": True,
                "message": "📊 Text metadata retrieved",
                "document_id": document_id,
                "metadata": {
                    "extraction_method": text_data["method"],
                    "word_count": text_data["word_count"],
                    "character_count": text_data["character_count"],
                    "page_count": text_data["page_count"],
                    "extraction_date": text_data["extraction_date"],
                    "processing_notes": text_data["processing_notes"]
                },
                # Compatibility fields at root level for tests
                "word_count": text_data["word_count"],
                "extraction_method": text_data["method"],
                "timestamp": datetime.utcnow().isoformat()
            }
        
        elif format == "preview":
            preview_text = text_data["text"][:1000] + "..." if len(text_data["text"]) > 1000 else text_data["text"]
            return {
                "success": True,
                "message": "📖 Text preview retrieved",
                "document_id": document_id,
                "text_preview": preview_text,
                "is_truncated": len(text_data["text"]) > 1000,
                "full_length": len(text_data["text"]),
                "statistics": {
                    "word_count": text_data["word_count"],
                    "character_count": text_data["character_count"],
                    "extraction_method": text_data["method"]
                },
                "timestamp": datetime.utcnow().isoformat()
            }
        
        else:  # format == "full"
            return {
                "success": True,
                "message": "📖 Full text retrieved",
                "document_id": document_id,
                "extracted_text": text_data["text"],
                "statistics": {
                    "word_count": text_data["word_count"],
                    "character_count": text_data["character_count"],
                    "page_count": text_data["page_count"],
                    "extraction_method": text_data["method"],
                    "extraction_date": text_data["extraction_date"]
                },
                "processing_notes": text_data["processing_notes"],
                "timestamp": datetime.utcnow().isoformat()
            }
            
    except HTTPException:
        raise
        
    except Exception as e:
        logger.error(f"❌ Failed to get extracted text: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Couldn't get extracted text: {str(e)}"
        )

@router.post("/{document_id}/search")
async def search_in_document(
    document_id: str,
    query: str = Query(..., description="Text to search for"),
    case_sensitive: bool = Query(default=False, description="Case-sensitive search"),
    whole_words: bool = Query(default=False, description="Match whole words only")
) -> Dict[str, Any]:
    """
    Search for text within a document
    
    Find specific content in your creative documents!
    """
    logger.info(f"🔍 Searching in document {document_id} for: '{query}'")
    
    try:
        text_data = await text_extractor.get_extracted_text(document_id)
        
        if not text_data:
            raise HTTPException(
                status_code=404,
                detail=f"📄 Document text not found. Extract text first!"
            )
        
        # Perform search
        text = text_data["text"]
        search_text = text if case_sensitive else text.lower()
        search_query = query if case_sensitive else query.lower()
        
        # Find matches
        matches = []
        start = 0
        
        while True:
            if whole_words:
                import re
                pattern = r'\b' + re.escape(search_query) + r'\b'
                match = re.search(pattern, search_text[start:])
                if not match:
                    break
                pos = start + match.start()
            else:
                pos = search_text.find(search_query, start)
                if pos == -1:
                    break
            
            # Get context around match
            context_start = max(0, pos - 100)
            context_end = min(len(text), pos + len(query) + 100)
            context = text[context_start:context_end]
            
            matches.append({
                "position": pos,
                "context": context,
                "line_number": text[:pos].count('\n') + 1
            })
            
            start = pos + 1
        
        return {
            "success": True,
            "message": f"🔍 Found {len(matches)} matches for '{query}'",
            "document_id": document_id,
            "query": query,
            "matches": matches[:50],  # Limit to 50 matches
            "total_matches": len(matches),
            "search_options": {
                "case_sensitive": case_sensitive,
                "whole_words": whole_words
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
        
    except Exception as e:
        logger.error(f"❌ Search failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"🔧 Search failed: {str(e)}"
        )
