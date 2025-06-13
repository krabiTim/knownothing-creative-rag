"""
Simple Working Server: Stages 1-4 + Basic UI
No Stage 5 embeddings (they hang)
"""

import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="knowNothing Creative RAG",
    description="AI superpowers for artists",
    version="1.0.0"
)

# Add CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "knowNothing Creative RAG - Working Foundation"}

@app.get("/health")
async def health():
    return {"status": "healthy", "stages": ["1-4", "basic-ui"]}

# Stage 1: AI Ping (WORKING)
try:
    from .api.ai_ping import router as ai_ping_router
    app.include_router(ai_ping_router, prefix="/api")
    logger.info("✅ Stage 1: AI ping loaded")
except Exception as e:
    logger.warning(f"⚠️ Stage 1 issue: {e}")

# Stage 2: Image Analysis (WORKING)
try:
    from .api.image_analysis import router as image_router
    app.include_router(image_router)
    logger.info("✅ Stage 2: Image analysis loaded")
except Exception as e:
    logger.warning(f"⚠️ Stage 2 issue: {e}")

# Stage 3: Document Storage (WORKING)
try:
    from .api.document_upload import router as doc_router
    app.include_router(doc_router, prefix="/api")
    logger.info("✅ Stage 3: Document storage loaded")
except Exception as e:
    logger.warning(f"⚠️ Stage 3 issue: {e}")

# Stage 4: Text Extraction (WORKING)
try:
    from .api.text_extraction_api import router as text_router
    app.include_router(text_router, prefix="/api")
    logger.info("✅ Stage 4: Text extraction loaded")
except Exception as e:
    logger.warning(f"⚠️ Stage 4 issue: {e}")

# Skip Stage 5 - it hangs
logger.info("⚠️ Stage 5: Skipped (hangs on embedding loading)")

# Simple HTML UI
@app.get("/ui", response_class=HTMLResponse)
async def simple_ui():
    return HTMLResponse("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>knowNothing Creative RAG</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                background: #2a2a2a; 
                color: white; 
                margin: 0; 
                padding: 20px; 
            }
            .container { max-width: 800px; margin: 0 auto; }
            .header { 
                text-align: center; 
                background: #3a3a3a; 
                padding: 20px; 
                border-radius: 8px; 
                margin-bottom: 20px; 
            }
            .section { 
                background: #353535; 
                padding: 20px; 
                border-radius: 8px; 
                margin-bottom: 15px; 
            }
            .working { color: #90ee90; }
            .disabled { color: #ffa500; }
            input[type="file"] { 
                background: #404040; 
                color: white; 
                padding: 10px; 
                border: 1px solid #555; 
                border-radius: 4px; 
            }
            button { 
                background: #555; 
                color: white; 
                padding: 10px 15px; 
                border: none; 
                border-radius: 4px; 
                cursor: pointer; 
            }
            button:hover { background: #666; }
            .result { 
                background: #404040; 
                padding: 15px; 
                border-radius: 4px; 
                margin-top: 10px; 
                min-height: 100px; 
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🧠 knowNothing Creative RAG</h1>
                <p>AI superpowers for artists who know nothing about AI</p>
            </div>
            
            <div class="section">
                <h2>📊 System Status</h2>
                <p><span class="working">✅ Stage 1:</span> AI Ping - Working</p>
                <p><span class="working">✅ Stage 2:</span> Image Analysis - Working</p>
                <p><span class="working">✅ Stage 3:</span> Document Storage - Working</p>
                <p><span class="working">✅ Stage 4:</span> Text Extraction - Working</p>
                <p><span class="disabled">⚠️ Stage 5:</span> Embeddings - Disabled (hangs)</p>
            </div>
            
            <div class="section">
                <h2>📁 Upload Documents</h2>
                <input type="file" id="fileInput" accept=".pdf,.txt,.docx">
                <button onclick="uploadFile()">Upload</button>
                <div id="uploadResult" class="result">Select a file to upload...</div>
            </div>
            
            <div class="section">
                <h2>📋 Your Documents</h2>
                <button onclick="loadDocuments()">Refresh List</button>
                <div id="docList" class="result">Click refresh to see your documents...</div>
            </div>
            
            <div class="section">
                <h2>🔗 API Links</h2>
                <p><a href="/api/docs" style="color: #87ceeb;">API Documentation</a></p>
                <p><a href="/health" style="color: #87ceeb;">Health Check</a></p>
            </div>
        </div>
        
        <script>
            async function uploadFile() {
                const fileInput = document.getElementById('fileInput');
                const result = document.getElementById('uploadResult');
                const file = fileInput.files[0];
                
                if (!file) {
                    result.textContent = 'Please select a file first';
                    return;
                }
                
                const formData = new FormData();
                formData.append('file', file);
                
                try {
                    result.textContent = 'Uploading...';
                    const response = await fetch('/api/documents/upload', {
                        method: 'POST',
                        body: formData
                    });
                    
                    if (response.ok) {
                        const data = await response.json();
                        result.textContent = `✅ Uploaded: ${file.name}`;
                    } else {
                        result.textContent = `❌ Upload failed: ${response.status}`;
                    }
                } catch (error) {
                    result.textContent = `❌ Error: ${error.message}`;
                }
            }
            
            async function loadDocuments() {
                const result = document.getElementById('docList');
                
                try {
                    result.textContent = 'Loading...';
                    const response = await fetch('/api/documents/list');
                    
                    if (response.ok) {
                        const data = await response.json();
                        const docs = data.documents || [];
                        
                        if (docs.length === 0) {
                            result.textContent = 'No documents uploaded yet';
                        } else {
                            result.innerHTML = docs.map(doc => 
                                `<p>📄 ${doc.original_filename} (${doc.file_size_mb} MB)</p>`
                            ).join('');
                        }
                    } else {
                        result.textContent = `❌ Failed to load documents: ${response.status}`;
                    }
                } catch (error) {
                    result.textContent = `❌ Error: ${error.message}`;
                }
            }
        </script>
    </body>
    </html>
    """)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
