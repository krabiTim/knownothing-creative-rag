"""
Stage 5: Simple Embeddings & Semantic Search API
Add semantic search capabilities to Creative RAG
"""

from fastapi import APIRouter, HTTPException, Form
from typing import List, Dict, Any
import logging
from datetime import datetime
import sqlite3
import os
import numpy as np

logger = logging.getLogger(__name__)

router = APIRouter()

# Global variables for lazy loading
embedding_service = None

class SimpleEmbeddingService:
    """Simple embedding service for semantic search"""
    
    def __init__(self):
        self.model = None
        self.chroma_client = None
        self.collection = None
        self.initialized = False
        self.model_name = "all-MiniLM-L6-v2"
    
    def initialize(self):
        """Initialize embedding model and vector database"""
        try:
            logger.info("🧠 Initializing embedding service...")
            
            # Import here to avoid startup delays
            from sentence_transformers import SentenceTransformer
            import chromadb
            
            # Initialize sentence transformer
            self.model = SentenceTransformer(self.model_name)
            logger.info(f"✅ Loaded embedding model: {self.model_name}")
            
            # Initialize ChromaDB
            chroma_path = "./data/chroma_db"
            os.makedirs(chroma_path, exist_ok=True)
            
            self.chroma_client = chromadb.PersistentClient(path=chroma_path)
            
            # Get or create collection
            self.collection = self.chroma_client.get_or_create_collection(
                name="creative_documents",
                metadata={"description": "Creative RAG document embeddings"}
            )
            
            self.initialized = True
            logger.info("✅ ChromaDB initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"❌ Embedding service initialization failed: {e}")
            return False
    
    def chunk_text(self, text: str, chunk_size: int = 500, overlap: int = 50) -> List[str]:
        """Split text into overlapping chunks"""
        if len(text) <= chunk_size:
            return [text.strip()]
        
        chunks = []
        start = 0
        
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            
            # Try to break at sentence boundary
            if end < len(text):
                last_period = chunk.rfind('.')
                last_newline = chunk.rfind('\n')
                break_point = max(last_period, last_newline)
                
                if break_point > start + chunk_size // 2:
                    chunk = text[start:break_point + 1]
                    end = break_point + 1
            
            chunks.append(chunk.strip())
            start = end - overlap
            
            if start >= len(text):
                break
        
        return [chunk for chunk in chunks if chunk.strip()]
    
    def embed_document(self, document_id: str, text: str, metadata: Dict = None) -> Dict:
        """Create embeddings for a document"""
        if not self.initialized and not self.initialize():
            return {"success": False, "error": "Embedding service not available"}
        
        try:
            # Chunk the text
            chunks = self.chunk_text(text)
            
            if not chunks:
                return {"success": False, "error": "No text to embed"}
            
            # Generate embeddings
            embeddings = self.model.encode(chunks)
            
            # Prepare data for ChromaDB
            chunk_ids = [f"{document_id}_chunk_{i}" for i in range(len(chunks))]
            
            chunk_metadata = []
            for i, chunk in enumerate(chunks):
                meta = {
                    "document_id": document_id,
                    "chunk_index": i,
                    "chunk_text": chunk[:200] + "..." if len(chunk) > 200 else chunk,
                    "word_count": len(chunk.split())
                }
                if metadata:
                    meta.update(metadata)
                chunk_metadata.append(meta)
            
            # Store in ChromaDB
            self.collection.add(
                embeddings=embeddings.tolist(),
                documents=chunks,
                metadatas=chunk_metadata,
                ids=chunk_ids
            )
            
            return {
                "success": True,
                "message": f"✅ Embedded {len(chunks)} chunks",
                "chunks_created": len(chunks),
                "total_tokens": sum(len(chunk.split()) for chunk in chunks)
            }
            
        except Exception as e:
            return {"success": False, "error": f"Embedding failed: {str(e)}"}
    
    def search_similar(self, query: str, limit: int = 5) -> Dict:
        """Search for similar text chunks"""
        if not self.initialized and not self.initialize():
            return {"success": False, "error": "Embedding service not available"}
        
        try:
            # Generate query embedding
            query_embedding = self.model.encode([query])
            
            # Search ChromaDB
            results = self.collection.query(
                query_embeddings=query_embedding.tolist(),
                n_results=limit,
                include=["documents", "metadatas", "distances"]
            )
            
            # Format results
            search_results = []
            if results["documents"] and results["documents"][0]:
                for i, (doc, metadata, distance) in enumerate(zip(
                    results["documents"][0],
                    results["metadatas"][0], 
                    results["distances"][0]
                )):
                    similarity_score = 1 - distance
                    search_results.append({
                        "rank": i + 1,
                        "content": doc,
                        "document_id": metadata.get("document_id", "unknown"),
                        "similarity_score": round(similarity_score, 3),
                        "word_count": metadata.get("word_count", 0)
                    })
            
            return {
                "success": True,
                "query": query,
                "results": search_results,
                "total_found": len(search_results)
            }
            
        except Exception as e:
            return {"success": False, "error": f"Search failed: {str(e)}"}

def get_embedding_service():
    """Get or create embedding service (lazy loading)"""
    global embedding_service
    if embedding_service is None:
        embedding_service = SimpleEmbeddingService()
    return embedding_service

@router.post("/embeddings/embed/{document_id}")
async def embed_document(document_id: str):
    """Create embeddings for a document - Stage 5"""
    try:
        # Get document text from database
        conn = sqlite3.connect("data/documents.db")
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        # Get document info
        cursor.execute("SELECT * FROM documents WHERE id = ?", (document_id,))
        doc = cursor.fetchone()
        
        if not doc:
            raise HTTPException(status_code=404, detail="Document not found")
        
        # Get extracted text
        cursor.execute("SELECT extracted_text FROM document_text WHERE document_id = ?", (document_id,))
        text_row = cursor.fetchone()
        conn.close()
        
        if not text_row or not text_row["extracted_text"]:
            raise HTTPException(
                status_code=400, 
                detail=f"No extracted text found for document {document_id}. Extract text first!"
            )
        
        # Create embeddings
        service = get_embedding_service()
        metadata = {
            "filename": doc["original_filename"],
            "file_type": doc["file_type"],
            "upload_date": doc["upload_date"]
        }
        
        result = service.embed_document(
            document_id=document_id,
            text=text_row["extracted_text"],
            metadata=metadata
        )
        
        if result["success"]:
            return {
                "success": True,
                "message": f"🧠 Created embeddings for '{doc['original_filename']}'",
                "document_id": document_id,
                "filename": doc["original_filename"],
                "embedding_stats": result,
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            raise HTTPException(status_code=500, detail=result["error"])
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Embedding creation failed: {str(e)}")

@router.post("/search/semantic")
async def semantic_search(query: str = Form(...), limit: int = Form(5)):
    """Semantic search across all documents - Stage 5"""
    try:
        if not query.strip():
            raise HTTPException(status_code=400, detail="Search query cannot be empty")
        
        # Perform semantic search
        service = get_embedding_service()
        results = service.search_similar(query, limit)
        
        if results["success"]:
            return {
                "success": True,
                "message": f"🔍 Found {results['total_found']} results for '{query}'",
                "query": query,
                "results": results["results"],
                "search_stats": {
                    "total_found": results["total_found"],
                    "search_type": "semantic_similarity"
                },
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            raise HTTPException(status_code=500, detail=results["error"])
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@router.get("/embeddings/stats")
async def embedding_stats():
    """Get embedding service statistics - Stage 5"""
    try:
        service = get_embedding_service()
        
        if service.initialized:
            collection_count = service.collection.count()
            stats = {
                "initialized": True,
                "model_name": service.model_name,
                "total_chunks": collection_count,
                "database_path": "./data/chroma_db"
            }
        else:
            stats = {"initialized": False, "status": "Not initialized yet"}
        
        # Get document count from main database
        conn = sqlite3.connect("data/documents.db")
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM documents")
        total_docs = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM document_text WHERE extracted_text IS NOT NULL")
        docs_with_text = cursor.fetchone()[0]
        conn.close()
        
        return {
            "embedding_service": stats,
            "document_stats": {
                "total_documents": total_docs,
                "documents_with_text": docs_with_text,
                "ready_for_embedding": docs_with_text
            },
            "features": {
                "semantic_search": stats.get("initialized", False),
                "similarity_matching": stats.get("initialized", False)
            }
        }
        
    except Exception as e:
        return {
            "error": f"Stats retrieval failed: {str(e)}",
            "embedding_service": {"initialized": False}
        }
