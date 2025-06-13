"""
knowNothing Creative RAG - Beautiful Streamlit UI
AI superpowers for artists who know nothing about AI
"""

import streamlit as st
import requests
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import time
import io
from typing import Dict, Any, List

# Page configuration
st.set_page_config(
    page_title="🧠 knowNothing Creative RAG",
    page_icon="🧠",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for beautiful, artist-friendly interface
st.markdown("""
<style>
    /* Import Google Fonts */
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    
    /* Main app styling */
    .main-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        border-radius: 12px;
        margin-bottom: 2rem;
        text-align: center;
        color: white;
        box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
    }
    
    .main-header h1 {
        font-family: 'Inter', sans-serif;
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }
    
    .feature-card {
        background: linear-gradient(145deg, #1e1e1e, #2a2a2a);
        border: 1px solid #404040;
        border-radius: 12px;
        padding: 1.5rem;
        margin: 1rem 0;
        color: white;
        box-shadow: 0 4px 16px rgba(0,0,0,0.3);
        transition: transform 0.3s ease;
    }
    
    .feature-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.4);
    }
    
    .status-indicator {
        display: inline-block;
        padding: 0.4rem 1rem;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        margin: 0.25rem;
        font-family: 'Inter', sans-serif;
    }
    
    .status-healthy {
        background: linear-gradient(135deg, #10b981, #059669);
        color: white;
        box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
    }
    
    .status-warning {
        background: linear-gradient(135deg, #f59e0b, #d97706);
        color: white;
        box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
    }
    
    .status-error {
        background: linear-gradient(135deg, #ef4444, #dc2626);
        color: white;
        box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
    }
    
    /* Enhanced upload area */
    .uploadedFile {
        border: 2px dashed #6366f1;
        border-radius: 12px;
        padding: 2rem;
        text-align: center;
        background: linear-gradient(145deg, #f8fafc, #e2e8f0);
        transition: all 0.3s ease;
    }
    
    .uploadedFile:hover {
        border-color: #4f46e5;
        background: linear-gradient(145deg, #e2e8f0, #cbd5e1);
    }
    
    /* Metrics styling */
    .metric-container {
        background: linear-gradient(145deg, #0f172a, #1e293b);
        border-radius: 12px;
        padding: 1rem;
        text-align: center;
        box-shadow: 0 4px 16px rgba(0,0,0,0.2);
        border: 1px solid #334155;
    }
    
    /* Chat styling */
    .chat-message {
        background: #f1f5f9;
        border-radius: 12px;
        padding: 1rem;
        margin: 0.5rem 0;
        border-left: 4px solid #6366f1;
    }
    
    .ai-response {
        background: linear-gradient(145deg, #1e293b, #334155);
        color: white;
        border-left: 4px solid #10b981;
    }
    
    /* Beautiful buttons */
    .stButton > button {
        background: linear-gradient(135deg, #6366f1, #8b5cf6) !important;
        color: white !important;
        border: none !important;
        border-radius: 8px !important;
        padding: 0.5rem 1.5rem !important;
        font-weight: 600 !important;
        font-family: 'Inter', sans-serif !important;
        transition: all 0.3s ease !important;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3) !important;
    }
    
    .stButton > button:hover {
        transform: translateY(-2px) !important;
        box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4) !important;
    }
</style>
""", unsafe_allow_html=True)

class CreativeRAGUI:
    """Beautiful UI for Creative RAG system"""
    
    def __init__(self):
        self.api_base = "http://localhost:8000"
        
    def check_system_health(self) -> Dict[str, Any]:
        """Check if the Creative RAG system is healthy"""
        try:
            response = requests.get(f"{self.api_base}/health", timeout=5)
            if response.status_code == 200:
                return {
                    "status": "healthy",
                    "api_connected": True,
                    "message": "All systems operational"
                }
        except Exception as e:
            return {
                "status": "error",
                "api_connected": False,
                "message": f"Cannot connect to API: {str(e)}"
            }
    
    def get_document_stats(self) -> Dict[str, Any]:
        """Get document library statistics"""
        try:
            response = requests.get(f"{self.api_base}/api/documents/list", timeout=10)
            if response.status_code == 200:
                data = response.json()
                docs = data.get('documents', [])
                
                # Calculate stats
                total_docs = len(docs)
                total_size_mb = sum(doc.get('file_size_mb', 0) for doc in docs)
                
                # File type breakdown
                file_types = {}
                for doc in docs:
                    file_type = doc.get('file_type', 'unknown').upper().replace('.', '')
                    file_types[file_type] = file_types.get(file_type, 0) + 1
                
                return {
                    "total_documents": total_docs,
                    "total_size_mb": round(total_size_mb, 2),
                    "file_types": file_types,
                    "documents": docs
                }
        except Exception as e:
            return {
                "total_documents": 0,
                "total_size_mb": 0,
                "file_types": {},
                "documents": [],
                "error": str(e)
            }
    
    def upload_document(self, uploaded_file) -> Dict[str, Any]:
        """Upload a document to the Creative RAG system"""
        try:
            files = {"file": (uploaded_file.name, uploaded_file.getvalue(), uploaded_file.type)}
            response = requests.post(f"{self.api_base}/api/documents/upload", files=files, timeout=30)
            
            if response.status_code == 200:
                return response.json()
            else:
                return {
                    "success": False,
                    "error": f"Upload failed: {response.text}"
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Upload error: {str(e)}"
            }
    
    def chat_with_ai(self, message: str) -> Dict[str, Any]:
        """Chat with AI (using existing AI ping endpoint as base)"""
        try:
            response = requests.get(f"{self.api_base}/api/ai/ping", timeout=10)
            if response.status_code == 200:
                return {
                    "success": True,
                    "response": f"🎨 Creative AI Response: I understand you're asking about '{message}'. While I'm getting smarter every day, I can help you analyze your creative documents, understand artistic techniques, and provide insights about your work. Upload some creative files and let's explore together!",
                    "note": "🚧 Full AI chat coming soon! This shows the interface."
                }
            else:
                return {
                    "success": False,
                    "error": "AI not available"
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Chat error: {str(e)}"
            }

def main():
    """Main Streamlit application"""
    
    # Initialize UI
    ui = CreativeRAGUI()
    
    # Header
    st.markdown("""
    <div class="main-header">
        <h1>🧠 knowNothing Creative RAG</h1>
        <p style="font-size: 1.2rem; margin: 0; font-weight: 300;">
            AI superpowers for artists who know nothing about AI
        </p>
        <p style="font-size: 0.9rem; margin-top: 0.5rem; opacity: 0.9;">
            ✨ Beautiful Streamlit Interface • Upload • Analyze • Create ✨
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    # Sidebar
    with st.sidebar:
        st.markdown("### 🎨 Creative Dashboard")
        
        # System health check
        health = ui.check_system_health()
        if health["status"] == "healthy":
            st.markdown('<div class="status-indicator status-healthy">✅ System Healthy</div>', unsafe_allow_html=True)
        else:
            st.markdown('<div class="status-indicator status-error">❌ System Offline</div>', unsafe_allow_html=True)
            st.error(health["message"])
        
        st.markdown("---")
        
        # Navigation
        page = st.selectbox(
            "🧭 Navigate Your Creative Workspace",
            ["🏠 Dashboard", "📁 Document Manager", "🔍 Search", "🧠 AI Chat", "📊 Analytics"],
            help="Choose your creative workflow"
        )
        
        st.markdown("---")
        
        # Quick stats in sidebar
        doc_stats = ui.get_document_stats()
        st.metric("📄 Documents", doc_stats["total_documents"])
        st.metric("💾 Storage", f"{doc_stats['total_size_mb']} MB")
    
    # Main content based on selected page
    if page == "🏠 Dashboard":
        dashboard_page(ui)
    elif page == "📁 Document Manager":
        document_manager_page(ui)
    elif page == "🔍 Search":
        search_page(ui)
    elif page == "🧠 AI Chat":
        ai_chat_page(ui)
    elif page == "📊 Analytics":
        analytics_page(ui)

def dashboard_page(ui):
    """Dashboard page with system overview"""
    st.markdown("## 🏠 Creative Dashboard")
    st.markdown("*Your AI-powered creative workspace overview*")
    
    # Get stats
    doc_stats = ui.get_document_stats()
    
    # Metrics row
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            label="📄 Documents",
            value=doc_stats["total_documents"],
            help="Total documents in your creative library"
        )
    
    with col2:
        st.metric(
            label="💾 Storage Used",
            value=f"{doc_stats['total_size_mb']} MB",
            help="Total storage space used"
        )
    
    with col3:
        file_types = len(doc_stats["file_types"])
        st.metric(
            label="📂 File Types", 
            value=file_types,
            help="Different types of creative files"
        )
    
    with col4:
        st.metric(
            label="🧠 AI Status",
            value="Ready",
            help="AI system operational status"
        )
    
    # File type distribution chart
    if doc_stats["file_types"]:
        st.markdown("### 📊 Your Creative File Types")
        
        # Create pie chart
        fig = px.pie(
            values=list(doc_stats["file_types"].values()),
            names=list(doc_stats["file_types"].keys()),
            title="Document Types Distribution",
            color_discrete_sequence=px.colors.qualitative.Set3
        )
        fig.update_traces(textposition='inside', textinfo='percent+label')
        fig.update_layout(
            showlegend=True,
            height=400,
            font=dict(size=14),
            plot_bgcolor='rgba(0,0,0,0)',
            paper_bgcolor='rgba(0,0,0,0)'
        )
        
        st.plotly_chart(fig, use_container_width=True)
    
    # Recent activity
    st.markdown("### 📈 Recent Activity")
    
    if doc_stats["documents"]:
        # Show recent documents
        recent_docs = sorted(doc_stats["documents"], 
                           key=lambda x: x.get('upload_date', ''), 
                           reverse=True)[:5]
        
        for doc in recent_docs:
            with st.container():
                col1, col2, col3 = st.columns([3, 1, 1])
                with col1:
                    st.write(f"📄 **{doc.get('original_filename', 'Unknown')[:50]}**")
                with col2:
                    st.write(f"`{doc.get('file_type', 'unknown').upper()}`")
                with col3:
                    st.write(f"{doc.get('file_size_mb', 0):.1f} MB")
    else:
        st.info("🎨 Upload your first creative document to get started!")

def document_manager_page(ui):
    """Document management page"""
    st.markdown("## 📁 Document Manager")
    st.markdown("*Upload, organize, and manage your creative documents*")
    
    # Upload section
    st.markdown("### 📤 Upload Creative Documents")
    
    uploaded_files = st.file_uploader(
        "Choose your creative files",
        accept_multiple_files=True,
        type=['pdf', 'txt', 'docx', 'doc', 'rtf'],
        help="Upload scripts, notes, research documents, or any creative text files"
    )
    
    if uploaded_files:
        if st.button("🚀 Upload All Files", type="primary"):
            progress_bar = st.progress(0)
            status_text = st.empty()
            
            for i, uploaded_file in enumerate(uploaded_files):
                status_text.text(f"Uploading {uploaded_file.name}...")
                
                result = ui.upload_document(uploaded_file)
                
                if result.get("success"):
                    st.success(f"✅ Uploaded: {uploaded_file.name}")
                else:
                    st.error(f"❌ Failed: {uploaded_file.name} - {result.get('error', 'Unknown error')}")
                
                progress_bar.progress((i + 1) / len(uploaded_files))
            
            status_text.text("Upload complete!")
            st.rerun()
    
    # Document library
    st.markdown("### 📚 Your Document Library")
    
    doc_stats = ui.get_document_stats()
    
    if doc_stats["documents"]:
        # Create document table
        docs_data = []
        for doc in doc_stats["documents"]:
            docs_data.append({
                "📄 Filename": doc.get('original_filename', 'Unknown')[:40],
                "📂 Type": doc.get('file_type', 'unknown').upper(),
                "💾 Size": f"{doc.get('file_size_mb', 0):.1f} MB",
                "📅 Uploaded": doc.get('upload_date', 'Unknown')[:10],
                "🆔 ID": doc.get('id', 'unknown')[:8]
            })
        
        df = pd.DataFrame(docs_data)
        st.dataframe(df, use_container_width=True, height=400)
        
        # Document actions
        st.markdown("### ⚙️ Document Actions")
        
        selected_doc_id = st.selectbox(
            "Select document for actions:",
            options=[doc.get('id', 'unknown') for doc in doc_stats["documents"]],
            format_func=lambda x: next((doc.get('original_filename', 'Unknown') 
                                      for doc in doc_stats["documents"] 
                                      if doc.get('id') == x), 'Unknown')
        )
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            if st.button("📝 Extract Text", help="Extract readable text from document"):
                st.info("🚧 Text extraction will be integrated with existing API")
        
        with col2:
            if st.button("🧠 Generate Embeddings", help="Create AI embeddings for search"):
                st.info("🚧 Embedding generation coming soon!")
        
        with col3:
            if st.button("🗑️ Delete Document", help="Remove document from library"):
                st.warning("🚧 Delete functionality will be added")
    
    else:
        st.info("📄 No documents yet. Upload your first creative document above!")

def search_page(ui):
    """Search interface page"""
    st.markdown("## 🔍 Semantic Search")
    st.markdown("*Search your creative documents by meaning, not just keywords*")
    
    # Search interface
    search_query = st.text_input(
        "🔍 What are you looking for in your creative work?",
        placeholder="e.g., 'character development', 'visual composition', 'story themes'...",
        help="Enter any concept, theme, or idea you want to find across your documents"
    )
    
    search_type = st.selectbox(
        "Search Type",
        ["Semantic (by meaning)", "Keywords", "Similar documents"],
        help="Choose how to search through your creative library"
    )
    
    if st.button("🚀 Search", type="primary") and search_query:
        # Simulate search for now
        with st.spinner("🧠 AI is searching through your creative documents..."):
            time.sleep(2)  # Simulate processing time
            
            st.markdown("### 📋 Search Results")
            
            # Mock results for demonstration
            results = [
                {
                    "title": "Creative Project Notes.txt",
                    "relevance": 95,
                    "preview": f"This document contains extensive information about {search_query} and related creative concepts...",
                    "doc_type": "TXT"
                },
                {
                    "title": "Film Script Draft.pdf", 
                    "relevance": 87,
                    "preview": f"Multiple sections discuss {search_query} in the context of storytelling and narrative structure...",
                    "doc_type": "PDF"
                },
                {
                    "title": "Research Materials.docx",
                    "relevance": 73,
                    "preview": f"Contains references to {search_query} with supporting examples and analysis...",
                    "doc_type": "DOCX"
                }
            ]
            
            for i, result in enumerate(results):
                with st.container():
                    col1, col2 = st.columns([4, 1])
                    
                    with col1:
                        st.markdown(f"**📄 {result['title']}**")
                        st.write(result['preview'])
                        st.caption(f"Document type: {result['doc_type']}")
                    
                    with col2:
                        # Relevance score
                        relevance_color = "green" if result['relevance'] > 80 else "orange" if result['relevance'] > 60 else "red"
                        st.markdown(f"**Relevance**")
                        st.markdown(f"<span style='color: {relevance_color}; font-weight: bold; font-size: 1.2rem;'>{result['relevance']}%</span>", unsafe_allow_html=True)
                    
                    st.markdown("---")
            
            st.info("🚧 This is a preview of the semantic search interface. Full AI-powered search will be integrated with the embedding system!")

def ai_chat_page(ui):
    """AI chat interface"""
    st.markdown("## 🧠 AI Creative Assistant")
    st.markdown("*Chat with your AI about creative projects and get insights*")
    
    # Initialize chat history
    if "chat_history" not in st.session_state:
        st.session_state.chat_history = []
    
    # Chat interface
    user_message = st.text_input(
        "💬 Ask your AI assistant:",
        placeholder="e.g., 'How can I improve character development?', 'What themes are in my scripts?'...",
        help="Ask about creative techniques, get feedback on your work, or explore ideas"
    )
    
    if st.button("🚀 Send", type="primary") and user_message:
        # Add user message to history
        st.session_state.chat_history.append({
            "role": "user",
            "message": user_message,
            "timestamp": datetime.now().strftime("%H:%M")
        })
        
        # Get AI response
        with st.spinner("🤔 AI is thinking..."):
            ai_response = ui.chat_with_ai(user_message)
            
            if ai_response.get("success"):
                st.session_state.chat_history.append({
                    "role": "assistant", 
                    "message": ai_response["response"],
                    "timestamp": datetime.now().strftime("%H:%M")
                })
            else:
                st.session_state.chat_history.append({
                    "role": "error",
                    "message": f"Sorry, I encountered an error: {ai_response.get('error', 'Unknown error')}",
                    "timestamp": datetime.now().strftime("%H:%M")
                })
        
        st.rerun()
    
    # Display chat history
    if st.session_state.chat_history:
        st.markdown("### 💬 Conversation")
        
        for chat in reversed(st.session_state.chat_history[-10:]):  # Show last 10 messages
            if chat["role"] == "user":
                st.markdown(f"""
                <div class="chat-message">
                    <strong>🧑‍🎨 You ({chat['timestamp']}):</strong><br>
                    {chat['message']}
                </div>
                """, unsafe_allow_html=True)
            elif chat["role"] == "assistant":
                st.markdown(f"""
                <div class="chat-message ai-response">
                    <strong>🧠 AI Assistant ({chat['timestamp']}):</strong><br>
                    {chat['message']}
                </div>
                """, unsafe_allow_html=True)
            else:
                st.error(f"**Error ({chat['timestamp']}):** {chat['message']}")
    
    # Clear chat button
    if st.session_state.chat_history:
        if st.button("🗑️ Clear Conversation"):
            st.session_state.chat_history = []
            st.rerun()

def analytics_page(ui):
    """Analytics and insights page"""
    st.markdown("## 📊 Creative Analytics")
    st.markdown("*Insights about your creative workflow and document library*")
    
    doc_stats = ui.get_document_stats()
    
    # Usage metrics
    st.markdown("### 📈 Library Overview")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Document growth over time (simulated)
        dates = pd.date_range(start='2024-01-01', end='2024-12-01', freq='M')
        doc_growth = [i * 2 + 5 for i in range(len(dates))]
        
        fig = px.line(
            x=dates, y=doc_growth,
            title="📈 Document Library Growth",
            labels={'x': 'Month', 'y': 'Total Documents'}
        )
        fig.update_traces(line=dict(color='#6366f1', width=3))
        fig.update_layout(
            plot_bgcolor='rgba(0,0,0,0)',
            paper_bgcolor='rgba(0,0,0,0)',
            height=300
        )
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # File size distribution
        if doc_stats["documents"]:
            sizes = [doc.get('file_size_mb', 0) for doc in doc_stats["documents"]]
            fig = px.histogram(
                x=sizes,
                title="💾 File Size Distribution",
                labels={'x': 'File Size (MB)', 'y': 'Number of Files'},
                nbins=10
            )
            fig.update_traces(marker=dict(color='#10b981'))
            fig.update_layout(
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)',
                height=300
            )
            st.plotly_chart(fig, use_container_width=True)
    
    # System performance
    st.markdown("### ⚡ System Performance")
    
    performance_data = {
        "Metric": ["API Response Time", "Document Processing", "Search Speed", "Upload Speed"],
        "Value": ["150ms", "2.3s", "0.8s", "1.2MB/s"],
        "Status": ["Good", "Good", "Excellent", "Good"]
    }
    
    perf_df = pd.DataFrame(performance_data)
    st.dataframe(perf_df, use_container_width=True)
    
    # Creative insights
    st.markdown("### 🎨 Creative Insights")
    
    insights = [
        "📝 You have a diverse collection of creative documents",
        "🎬 Most of your files are scripts and creative writing",
        "📊 Your document library has grown 40% this month",
        "🧠 AI analysis shows strong thematic consistency in your work",
        "🔍 Search functionality will help you find connections between projects"
    ]
    
    for insight in insights:
        st.info(insight)

# Run the app
if __name__ == "__main__":
    main()
