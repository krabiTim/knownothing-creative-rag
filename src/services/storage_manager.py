"""
Stage 3: Document Storage Manager
Simple document storage with SQLite metadata tracking
Part of knowNothing Creative RAG
"""

import os
import sqlite3
import uuid
import aiofiles
import aiofiles.os
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional
import logging
from fastapi import UploadFile

logger = logging.getLogger(__name__)

class StorageManager:
    """
    Manages document storage and metadata
    - Stores files in data/uploads/
    - Tracks metadata in SQLite
    - Returns document IDs for future reference
    """
    
    def __init__(self, upload_dir: str = "data/uploads", db_path: str = "data/documents.db"):
        self.upload_dir = Path(upload_dir)
        self.db_path = db_path
        
        # Create directories if they don't exist
        self.upload_dir.mkdir(parents=True, exist_ok=True)
        Path("data").mkdir(exist_ok=True)
        
        # Initialize database
        self._init_database()
    
    def _init_database(self):
        """Initialize SQLite database with documents table"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS documents (
                    id TEXT PRIMARY KEY,
                    original_filename TEXT NOT NULL,
                    stored_filename TEXT NOT NULL,
                    file_path TEXT NOT NULL,
                    file_size INTEGER NOT NULL,
                    file_type TEXT NOT NULL,
                    mime_type TEXT,
                    upload_date TEXT NOT NULL,
                    status TEXT DEFAULT 'stored'
                )
            """)
            
            conn.commit()
            conn.close()
            logger.info("✅ Document database initialized")
            
        except Exception as e:
            logger.error(f"❌ Database initialization failed: {e}")
            raise
    
    async def store_document(self, file: UploadFile) -> str:
        """
        Store uploaded document and return document ID
        
        Args:
            file: FastAPI UploadFile object
            
        Returns:
            str: Unique document ID
        """
        try:
            # Generate unique document ID
            document_id = str(uuid.uuid4())
            
            # Get file info
            original_filename = file.filename or "unknown_file"
            file_extension = Path(original_filename).suffix.lower()
            mime_type = file.content_type or "application/octet-stream"
            
            # Create stored filename (ID + extension)
            stored_filename = f"{document_id}{file_extension}"
            file_path = self.upload_dir / stored_filename
            
            # Read file content
            file_content = await file.read()
            file_size = len(file_content)
            
            # Validate file type
            allowed_extensions = {'.pdf', '.txt', '.docx', '.doc', '.rtf'}
            if file_extension not in allowed_extensions:
                raise ValueError(f"File type {file_extension} not supported. Allowed: {', '.join(allowed_extensions)}")
            
            # Validate file size (50MB limit)
            max_size = 50 * 1024 * 1024  # 50MB
            if file_size > max_size:
                raise ValueError(f"File too large ({file_size / (1024*1024):.1f}MB). Maximum size: 50MB")
            
            # Store file
            async with aiofiles.open(file_path, 'wb') as f:
                await f.write(file_content)
            
            # Store metadata in database
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute("""
                INSERT INTO documents 
                (id, original_filename, stored_filename, file_path, file_size, file_type, mime_type, upload_date)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                document_id,
                original_filename,
                stored_filename,
                str(file_path),
                file_size,
                file_extension,
                mime_type,
                datetime.utcnow().isoformat()
            ))
            
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Document stored: {original_filename} -> {document_id}")
            return document_id
            
        except Exception as e:
            logger.error(f"❌ Document storage failed: {e}")
            # Clean up partial file if it exists
            if 'file_path' in locals() and Path(file_path).exists():
                await aiofiles.os.remove(file_path)
            raise
    
    async def get_document(self, document_id: str) -> Optional[Dict]:
        """
        Get document metadata by ID
        
        Args:
            document_id: Document ID to retrieve
            
        Returns:
            Dict: Document metadata or None if not found
        """
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row  # Enable dict-like access
            cursor = conn.cursor()
            
            cursor.execute("SELECT * FROM documents WHERE id = ?", (document_id,))
            row = cursor.fetchone()
            conn.close()
            
            if row:
                # Convert row to dict and add computed fields
                doc = dict(row)
                doc['file_exists'] = Path(doc['file_path']).exists()
                doc['file_size_mb'] = round(doc['file_size'] / (1024 * 1024), 2)
                return doc
            
            return None
            
        except Exception as e:
            logger.error(f"❌ Failed to get document {document_id}: {e}")
            return None
    
    async def list_documents(self, limit: int = 100, offset: int = 0) -> List[Dict]:
        """
        List all stored documents
        
        Args:
            limit: Maximum number of documents to return
            offset: Number of documents to skip
            
        Returns:
            List[Dict]: List of document metadata
        """
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute("""
                SELECT * FROM documents 
                ORDER BY upload_date DESC 
                LIMIT ? OFFSET ?
            """, (limit, offset))
            
            rows = cursor.fetchall()
            conn.close()
            
            documents = []
            for row in rows:
                doc = dict(row)
                doc['file_exists'] = Path(doc['file_path']).exists()
                doc['file_size_mb'] = round(doc['file_size'] / (1024 * 1024), 2)
                documents.append(doc)
            
            return documents
            
        except Exception as e:
            logger.error(f"❌ Failed to list documents: {e}")
            return []
    
    async def get_document_count(self) -> int:
        """Get total number of stored documents"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM documents")
            count = cursor.fetchone()[0]
            conn.close()
            return count
        except Exception as e:
            logger.error(f"❌ Failed to count documents: {e}")
            return 0
    
    async def delete_document(self, document_id: str) -> bool:
        """
        Delete document and its file
        
        Args:
            document_id: Document ID to delete
            
        Returns:
            bool: True if deleted successfully
        """
        try:
            # Get document info first
            doc = await self.get_document(document_id)
            if not doc:
                return False
            
            # Delete file if it exists
            file_path = Path(doc['file_path'])
            if file_path.exists():
                await aiofiles.os.remove(file_path)
            
            # Delete from database
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("DELETE FROM documents WHERE id = ?", (document_id,))
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Document deleted: {document_id}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to delete document {document_id}: {e}")
            return False
    
    async def get_storage_stats(self) -> Dict:
        """Get storage statistics"""
        try:
            total_count = await self.get_document_count()
            documents = await self.list_documents(limit=1000)  # Get all for stats
            
            total_size = sum(doc['file_size'] for doc in documents)
            total_size_mb = round(total_size / (1024 * 1024), 2)
            
            # Count by file type
            type_counts = {}
            for doc in documents:
                file_type = doc['file_type']
                type_counts[file_type] = type_counts.get(file_type, 0) + 1
            
            # Check disk usage
            upload_dir_size = 0
            if self.upload_dir.exists():
                for file_path in self.upload_dir.rglob('*'):
                    if file_path.is_file():
                        upload_dir_size += file_path.stat().st_size
            
            return {
                'total_documents': total_count,
                'total_size_mb': total_size_mb,
                'disk_usage_mb': round(upload_dir_size / (1024 * 1024), 2),
                'file_types': type_counts,
                'upload_directory': str(self.upload_dir),
                'database_path': self.db_path
            }
            
        except Exception as e:
            logger.error(f"❌ Failed to get storage stats: {e}")
            return {
                'total_documents': 0,
                'total_size_mb': 0,
                'error': str(e)
            }