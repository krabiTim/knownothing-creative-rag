#!/bin/bash

echo "🔧 === STAGE 5: QUICK FIX - ADD MISSING ENDPOINT ==="
echo "Adding the missing /generate/{document_id} endpoint"
echo "=================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "📋 Current endpoints in semantic search API:"
grep -n "@router" src/api/semantic_search_api.py

echo ""
echo "🔧 Adding the missing generate endpoint..."

# Add the missing endpoint to the API file
cat >> src/api/semantic_search_api.py << 'EOF'

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
EOF

echo -e "${GREEN}✅ Missing endpoints added to semantic search API${NC}"

echo ""
echo "🔧 Checking the updated API file..."
echo "📋 All endpoints now in semantic search API:"
grep -n "@router" src/api/semantic_search_api.py

echo ""
echo -e "${GREEN}🎉 ENDPOINT FIX COMPLETE! 🎉${NC}"
echo ""
echo "🚀 NEXT STEPS:"
echo ""
echo "1️⃣  RESTART YOUR SERVER:"
echo "   # Stop current server (Ctrl+C in the server terminal)"
echo "   pkill -f 'python -m src.main'"
echo "   sleep 2"
echo "   poetry run python -m src.main"
echo ""
echo "2️⃣  TEST THE FIXED ENDPOINTS:"
echo "   # Test generate endpoint (now should work!)"
echo "   curl -X POST http://localhost:8000/api/embeddings/generate/10ecc1d3-d658-469f-aa64-c18f178e3348"
echo ""
echo "   # Test GET status"
echo "   curl http://localhost:8000/api/embeddings/generate/10ecc1d3-d658-469f-aa64-c18f178e3348"
echo ""
echo "3️⃣  EXPECTED RESULTS:"
echo "   ✅ No more 404 errors"
echo "   ✅ Detailed embedding generation preview"
echo "   ✅ Chunk breakdown of your fantasy script"
echo "   ✅ Ready for full AI implementation"
echo ""
echo "🎯 The Fix:"
echo "   • Added missing POST /generate/{document_id} endpoint"
echo "   • Added GET /generate/{document_id} status endpoint"
echo "   • Proper database integration with text extraction"
echo "   • Artist-friendly responses with next steps"
echo ""
echo "🧠 What Artists Get:"
echo "   • See how their documents will be processed by AI"
echo "   • Understand the chunking strategy for large texts"
echo "   • Preview of semantic search capabilities"
echo "   • Foundation ready for full embedding implementation"