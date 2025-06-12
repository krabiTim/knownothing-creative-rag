#!/bin/bash

echo "🎨 === STAGE 6: SIMPLE HTML UI - ZERO DEPENDENCIES ==="
echo "Building a clean web interface with just HTML/CSS/JS"
echo "=================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo "📍 Current directory: $(pwd)"
echo "🌿 Current branch: $(git branch --show-current)"

# Step 1: Remove the Gradio-based files
echo ""
echo "🧹 Removing Gradio-based files..."
rm -f src/ui/simple_gradio.py
rm -f launch_simple_ui.py
rm -f test_stage6_simple.sh

# Step 2: Create simple HTML-based UI endpoint
echo ""
echo "🎨 Creating simple HTML UI endpoint..."

cat > src/ui/simple_html_ui.py << 'HTML_UI_EOF'
"""
Stage 6: Simple HTML UI
Clean web interface with zero external dependencies
Uses FastAPI to serve HTML/CSS/JS - no Gradio needed!
"""

from fastapi import APIRouter, Request, UploadFile, File, Form
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

# Simple HTML template - self-contained, no external dependencies
SIMPLE_UI_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🧠 knowNothing Creative RAG</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .tabs {
            display: flex;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            margin-bottom: 20px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }
        
        .tab {
            flex: 1;
            padding: 15px 20px;
            text-align: center;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            color: #666;
            transition: all 0.3s ease;
        }
        
        .tab.active {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .tab:hover:not(.active) {
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
        }
        
        .tab-content {
            display: none;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .tab-content.active {
            display: block;
            animation: fadeIn 0.3s ease;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .upload-area {
            border: 3px dashed #667eea;
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            background: rgba(102, 126, 234, 0.05);
            margin: 20px 0;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .upload-area:hover {
            border-color: #764ba2;
            background: rgba(118, 75, 162, 0.05);
            transform: translateY(-2px);
        }
        
        .upload-area.dragover {
            border-color: #764ba2;
            background: rgba(118, 75, 162, 0.1);
            transform: scale(1.02);
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            margin: 10px 5px;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .result-area {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
            white-space: pre-wrap;
            font-family: 'Courier New', monospace;
            max-height: 300px;
            overflow-y: auto;
        }
        
        .file-input {
            margin: 20px 0;
        }
        
        .file-input input[type="file"] {
            width: 100%;
            padding: 10px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 16px;
        }
        
        .status {
            padding: 10px 15px;
            border-radius: 5px;
            margin: 10px 0;
            font-weight: 500;
        }
        
        .status.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .status.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .status.loading {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        .document-list {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .document-item {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .document-info h4 {
            margin-bottom: 5px;
            color: #333;
        }
        
        .document-info p {
            color: #666;
            font-size: 14px;
        }
        
        select {
            width: 100%;
            padding: 10px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 16px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧠 knowNothing Creative RAG</h1>
            <p style="font-size: 1.2rem; margin-top: 10px; color: #666;">
                AI superpowers for artists who know nothing about AI
            </p>
        </div>
        
        <div class="tabs">
            <button class="tab active" onclick="switchTab('upload')">📁 Upload Documents</button>
            <button class="tab" onclick="switchTab('library')">📚 Your Documents</button>
            <button class="tab" onclick="switchTab('extract')">📝 Extract Text</button>
        </div>
        
        <!-- Upload Documents Tab -->
        <div id="upload" class="tab-content active">
            <h2>📁 Upload Your Creative Files</h2>
            <p style="margin-bottom: 20px; color: #666;">
                Supported formats: PDF, TXT, DOCX files up to 50MB
            </p>
            
            <div class="upload-area" id="uploadArea">
                <h3>📤 Drag files here or click to browse</h3>
                <p>Drop your creative documents to get started</p>
                <input type="file" id="fileInput" accept=".pdf,.txt,.docx" style="display: none;">
            </div>
            
            <button class="btn" onclick="document.getElementById('fileInput').click()">
                📁 Choose Files
            </button>
            <button class="btn" id="uploadBtn" onclick="uploadFile()" disabled>
                📤 Upload Document
            </button>
            
            <div id="uploadResult" class="result-area" style="display: none;"></div>
        </div>
        
        <!-- Document Library Tab -->
        <div id="library" class="tab-content">
            <h2>📚 Your Creative Document Library</h2>
            
            <button class="btn" onclick="loadDocuments()">🔄 Refresh Library</button>
            
            <div id="documentList" class="document-list">
                <p style="color: #666; text-align: center; padding: 20px;">
                    Click "Refresh Library" to load your documents
                </p>
            </div>
        </div>
        
        <!-- Extract Text Tab -->
        <div id="extract" class="tab-content">
            <h2>📝 Extract Text from Documents</h2>
            <p style="margin-bottom: 20px; color: #666;">
                Select a document to extract readable text for AI analysis
            </p>
            
            <button class="btn" onclick="loadDocumentChoices()">🔄 Refresh Document List</button>
            
            <select id="documentSelect">
                <option value="">Select a document...</option>
            </select>
            
            <button class="btn" onclick="extractText()">🧠 Extract Text</button>
            
            <div id="extractResult" class="result-area" style="display: none;"></div>
        </div>
    </div>

    <script>
        let selectedFile = null;
        
        // Tab switching
        function switchTab(tabName) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            
            // Remove active class from all tabs
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected tab content
            document.getElementById(tabName).classList.add('active');
            
            // Add active class to clicked tab
            event.target.classList.add('active');
        }
        
        // File upload functionality
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const uploadBtn = document.getElementById('uploadBtn');
        
        uploadArea.addEventListener('click', () => fileInput.click());
        
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });
        
        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });
        
        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                selectedFile = files[0];
                updateUploadUI();
            }
        });
        
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                selectedFile = e.target.files[0];
                updateUploadUI();
            }
        });
        
        function updateUploadUI() {
            if (selectedFile) {
                uploadArea.innerHTML = `
                    <h3>✅ File Selected</h3>
                    <p><strong>${selectedFile.name}</strong></p>
                    <p>Size: ${(selectedFile.size / (1024*1024)).toFixed(2)} MB</p>
                `;
                uploadBtn.disabled = false;
            }
        }
        
        // Upload file
        async function uploadFile() {
            if (!selectedFile) {
                showResult('uploadResult', 'Please select a file first', 'error');
                return;
            }
            
            const formData = new FormData();
            formData.append('file', selectedFile);
            
            showResult('uploadResult', '⏳ Uploading file...', 'loading');
            
            try {
                const response = await fetch('/api/documents/upload', {
                    method: 'POST',
                    body: formData
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    showResult('uploadResult', `✅ Upload successful!\\nDocument ID: ${result.document_id}\\nFilename: ${result.filename}`, 'success');
                    // Reset upload area
                    selectedFile = null;
                    uploadBtn.disabled = true;
                    uploadArea.innerHTML = `
                        <h3>📤 Drag files here or click to browse</h3>
                        <p>Drop your creative documents to get started</p>
                    `;
                } else {
                    showResult('uploadResult', `❌ Upload failed: ${result.detail || 'Unknown error'}`, 'error');
                }
            } catch (error) {
                showResult('uploadResult', `❌ Network error: ${error.message}`, 'error');
            }
        }
        
        // Load documents
        async function loadDocuments() {
            const listDiv = document.getElementById('documentList');
            listDiv.innerHTML = '<p style="text-align: center;">⏳ Loading documents...</p>';
            
            try {
                const response = await fetch('/api/documents/list');
                const result = await response.json();
                
                if (response.ok && result.documents) {
                    if (result.documents.length === 0) {
                        listDiv.innerHTML = '<p style="text-align: center; color: #666;">📄 No documents uploaded yet. Go to "Upload Documents" to get started!</p>';
                    } else {
                        listDiv.innerHTML = result.documents.map(doc => `
                            <div class="document-item">
                                <div class="document-info">
                                    <h4>📄 ${doc.original_filename}</h4>
                                    <p>${doc.file_type} • ${doc.file_size_mb.toFixed(1)} MB • Uploaded ${new Date(doc.upload_date).toLocaleDateString()}</p>
                                </div>
                            </div>
                        `).join('');
                    }
                } else {
                    listDiv.innerHTML = '<p style="text-align: center; color: #721c24;">❌ Failed to load documents</p>';
                }
            } catch (error) {
                listDiv.innerHTML = `<p style="text-align: center; color: #721c24;">❌ Network error: ${error.message}</p>`;
            }
        }
        
        // Load document choices for extraction
        async function loadDocumentChoices() {
            const select = document.getElementById('documentSelect');
            select.innerHTML = '<option value="">⏳ Loading...</option>';
            
            try {
                const response = await fetch('/api/documents/list');
                const result = await response.json();
                
                if (response.ok && result.documents) {
                    select.innerHTML = '<option value="">Select a document...</option>';
                    result.documents.forEach(doc => {
                        const option = document.createElement('option');
                        option.value = doc.id;
                        option.textContent = `${doc.original_filename} (${doc.file_type})`;
                        select.appendChild(option);
                    });
                } else {
                    select.innerHTML = '<option value="">❌ Failed to load documents</option>';
                }
            } catch (error) {
                select.innerHTML = '<option value="">❌ Network error</option>';
            }
        }
        
        // Extract text
        async function extractText() {
            const select = document.getElementById('documentSelect');
            const docId = select.value;
            
            if (!docId) {
                showResult('extractResult', '❌ Please select a document first', 'error');
                return;
            }
            
            showResult('extractResult', '⏳ Extracting text...', 'loading');
            
            try {
                const response = await fetch(`/api/text/extract/${docId}`, {
                    method: 'POST'
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    showResult('extractResult', `✅ Text extraction successful!\\n\\n${result.message}`, 'success');
                } else {
                    showResult('extractResult', `❌ Extraction failed: ${result.detail || 'Unknown error'}`, 'error');
                }
            } catch (error) {
                showResult('extractResult', `❌ Network error: ${error.message}`, 'error');
            }
        }
        
        // Helper function to show results
        function showResult(elementId, message, type) {
            const element = document.getElementById(elementId);
            element.style.display = 'block';
            element.textContent = message;
            element.className = `result-area status ${type}`;
        }
        
        // Auto-load documents when library tab is opened
        document.addEventListener('DOMContentLoaded', () => {
            loadDocuments();
        });
    </script>
</body>
</html>
"""

@router.get("/ui", response_class=HTMLResponse)
async def get_simple_ui():
    """Serve the simple HTML UI"""
    return HTMLResponse(content=SIMPLE_UI_HTML)

@router.get("/", response_class=HTMLResponse) 
async def redirect_to_ui():
    """Redirect root to UI"""
    return HTMLResponse(content="""
    <script>window.location.href = '/ui';</script>
    <p>Redirecting to Creative Interface...</p>
    """)
HTML_UI_EOF

echo "✅ Simple HTML UI created ($(wc -l < src/ui/simple_html_ui.py) lines)"

# Step 3: Update main.py to include the HTML UI
echo ""
echo "🔗 Integrating HTML UI with main application..."

# Check if integration already exists
if grep -q "simple_html_ui" src/main.py; then
    echo "✅ HTML UI already integrated in main.py"
else
    cat >> src/main.py << 'INTEGRATION_EOF'

# Stage 6: Simple HTML UI Integration
try:
    from .ui.simple_html_ui import router as html_ui_router
    app.include_router(html_ui_router)
    logger.info("✅ Simple HTML UI endpoints registered")
except ImportError as e:
    logger.warning(f"⚠️ Simple HTML UI module not loaded: {e}")
except Exception as e:
    logger.error(f"❌ Error loading Simple HTML UI module: {e}")
INTEGRATION_EOF
    echo "✅ Simple HTML UI integrated into main.py"
fi

# Step 4: Create test script
echo ""
echo "🧪 Creating HTML UI test script..."

cat > test_stage6_html.sh << 'TEST_EOF'
#!/bin/bash

echo "🧪 === STAGE 6: SIMPLE HTML UI TESTING ==="
echo "Testing clean HTML interface functionality"
echo "========================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

API_BASE="http://localhost:8000"
FAILED_TESTS=0
TOTAL_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "🧪 Testing: $test_name... "
    
    output=$(eval "$test_command" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ] && [[ "$output" =~ $expected_pattern ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "   Expected: $expected_pattern"
        echo "   Got: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Check API is running
echo "🔍 Checking API status..."
if ! curl -s "$API_BASE/api/health" > /dev/null; then
    echo -e "${RED}❌ API not running${NC}"
    echo "Start with: poetry run python -m src.main"
    exit 1
fi
echo -e "${GREEN}✅ API is running${NC}"

echo ""
echo "🧪 Running Stage 6 HTML UI tests..."

# Test 1: UI module import
run_test "HTML UI Module Import" \
    "python -c 'from src.ui.simple_html_ui import router'" \
    ""

# Test 2: UI endpoint accessibility
run_test "UI Endpoint Access" \
    "curl -s $API_BASE/ui | head -1" \
    "<!DOCTYPE html>"

# Test 3: Root redirect
run_test "Root Redirect" \
    "curl -s $API_BASE/ | grep -q 'Redirecting'; echo \$?" \
    "0"

# Test 4: HTML content check
run_test "HTML Content Validation" \
    "curl -s $API_BASE/ui | grep -q 'knowNothing Creative RAG'; echo \$?" \
    "0"

echo ""
echo "📊 Stage 6 HTML UI Test Summary:"
PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))
echo -e "   ${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "   ${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 Stage 6 HTML UI is ready!${NC}"
    echo ""
    echo "🚀 ACCESS YOUR INTERFACE:"
    echo "   🎨 http://localhost:8000/ui"
    echo "   🏠 http://localhost:8000/ (redirects to UI)"
    echo ""
    echo "🎯 What you'll get:"
    echo "   • Beautiful gradient interface"
    echo "   • Drag-and-drop file upload"
    echo "   • Document library management"
    echo "   • Text extraction workflow"
    echo "   • Zero external dependencies!"
    echo ""
    echo "✅ Ready to commit and merge!"
else
    echo -e "${RED}❌ Stage 6 needs fixes${NC}"
    echo "Fix failing tests before proceeding"
fi

exit $FAILED_TESTS
TEST_EOF

chmod +x test_stage6_html.sh

echo "✅ Test script created"

# Step 5: Test the implementation
echo ""
echo "🧪 Running Stage 6 HTML UI tests..."

if ./test_stage6_html.sh; then
    echo ""
    echo -e "${GREEN}🎉 STAGE 6 HTML UI IMPLEMENTATION SUCCESSFUL! 🎉${NC}"
    
    echo ""
    echo "🚀 NEXT STEPS:"
    echo ""
    echo "1️⃣  RESTART YOUR API SERVER:"
    echo "   # Stop current server (Ctrl+C in the API terminal)"
    echo "   poetry run python -m src.main"
    echo ""
    echo "2️⃣  ACCESS YOUR BEAUTIFUL INTERFACE:"
    echo "   🎨 http://localhost:8000/ui"
    echo ""
    echo "3️⃣  TEST THE WORKFLOW:"
    echo "   • Upload documents with drag-and-drop"
    echo "   • View document library"
    echo "   • Extract text from documents"
    echo ""
    echo "🎯 WHAT ARTISTS GET:"
    echo "   • Beautiful gradient design"
    echo "   • Professional appearance"
    echo "   • Drag-and-drop file upload"
    echo "   • Real-time feedback"
    echo "   • Mobile-responsive design"
    echo "   • ZERO external dependencies!"
    echo ""
    echo "✅ No Gradio conflicts!"
    echo "✅ No dependency hell!"
    echo "✅ Works immediately!"
    echo ""
    echo "📝 COMMIT WHEN READY:"
    echo "   git add ."
    echo "   git commit -m 'feat: Stage 6 - Simple HTML UI ✅'"
    echo "   git push -u origin feature/stage6-simple-gradio-ui"
    
else
    echo ""
    echo -e "${RED}❌ Stage 6 tests failed${NC}"
    echo "Please fix the issues above before proceeding"
    exit 1
fi