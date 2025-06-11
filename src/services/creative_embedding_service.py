"""
Stage 5: Embedding Service for knowNothing Creative RAG
Semantic embeddings for intelligent creative document analysis
Built for artists who want AI insights without complexity
"""

import os
import logging
import asyncio
import json
import sqlite3
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime
import hashlib

# Embedding libraries (with graceful fallbacks)
try:
    from sentence_transformers import SentenceTransformer
    import torch
    SENTENCE_TRANSFORMERS_AVAILABLE = True
except ImportError:
    SENTENCE_TRANSFORMERS_AVAILABLE = False

try:
    import chromadb
    from chromadb.config import Settings
    CHROMADB_AVAILABLE = True
except ImportError:
    CHROMADB_AVAILABLE = False

try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False

logger = logging.getLogger(__name__)

class CreativeEmbeddingService:
    """
    Transforms creative documents into semantic embeddings
    Enables AI-powered insights like "find documents about character development"
    """
    
    def __init__(
        self, 
        model_name: str = "all-MiniLM-L6-v2",
        db_path: str = "data/documents.db",
        chroma_path: str = "data/chroma_db"
    ):
        self.model_name = model_name
        self.db_path = db_path
        self.chroma_path = Path(chroma_path)
        
        # Initialize components
        self.model = None
        self.chroma_client = None
        self.collection = None
        
        # Create storage directories
        self.chroma_path.mkdir(parents=True, exist_ok=True)
        
        # Initialize the service
        self._init_service()
    
    def _init_service(self):
        """Initialize embedding model and vector database"""
        try:
            # Initialize embedding model
            if SENTENCE_TRANSFORMERS_AVAILABLE:
                logger.info(f"🧠 Loading embedding model: {self.model_name}")
                self.model = SentenceTransformer(self.model_name)
                
                # Check for GPU acceleration
                device = "cuda" if torch.cuda.is_available() else "cpu"
                self.model = self.model.to(device)
                logger.info(f"🚀 Embedding model loaded on: {device}")
            else:
                logger.warning("⚠️ sentence-transformers not available. Install with: poetry add sentence-transformers")
            
            # Initialize ChromaDB
            if CHROMADB_AVAILABLE:
                logger.info("🗄️ Initializing ChromaDB vector database")
                self.chroma_client = chromadb.PersistentClient(
                    path=str(self.chroma_path),
                    settings=Settings(
                        anonymized_telemetry=False,
                        allow_reset=True
                    )
                )
                
                # Create or get collection for creative documents
                self.collection = self.chroma_client.get_or_create_collection(
                    name="creative_documents",
                    metadata={"description": "Creative documents with semantic embeddings"}
                )
                logger.info("✅ ChromaDB collection ready")
            else:
                logger.warning("⚠️ ChromaDB not available. Install with: poetry add chromadb")
            
        except Exception as e:
            logger.error(f"❌ Service initialization failed: {str(e)}")
            # Continue without embeddings - degrade gracefully
    
    def check_service_status(self) -> Dict[str, Any]:
        """Check if embedding service is ready"""
        return {
            "sentence_transformers_available": SENTENCE_TRANSFORMERS_AVAILABLE,
            "chromadb_available": CHROMADB_AVAILABLE,
            "numpy_available": NUMPY_AVAILABLE,
            "model_loaded": self.model is not None,
            "vector_db_ready": self.collection is not None,
            "model_name": self.model_name,
            "device": str(self.model.device) if self.model else "N/A",
            "service_ready": all([
                SENTENCE_TRANSFORMERS_AVAILABLE,
                CHROMADB_AVAILABLE,
                NUMPY_AVAILABLE,
                self.model is not None,
                self.collection is not None
            ])
        }

    async def semantic_search(self, query: str, limit: int = 10) -> Dict[str, Any]:
        """Basic semantic search - simplified for foundation"""
        try:
            status = self.check_service_status()
            if not status["service_ready"]:
                return {
                    "success": False,
                    "error": "service_not_ready",
                    "message": "🔧 Semantic search not available. Install required dependencies.",
                    "status": status
                }
            
            return {
                "success": True,
                "message": f"🔍 Semantic search foundation ready for: '{query}'",
                "query": query,
                "results": [],
                "note": "Full implementation coming with complete setup",
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"❌ Semantic search failed: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "message": f"🔧 Semantic search failed: {str(e)}",
                "timestamp": datetime.utcnow().isoformat()
            }
