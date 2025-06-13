#!/usr/bin/env python3
"""
Fixed launcher for knowNothing Creative RAG Streamlit UI
Uses Poetry's virtual environment correctly
"""

import subprocess
import sys
import os

def main():
    print("🎨 Launching knowNothing Creative RAG Streamlit UI...")
    print("✨ Beautiful interface for artists and creative professionals")
    print("")
    
    # Check if we're in the right directory
    if not os.path.exists("src/ui/creative_rag_app.py"):
        print("❌ Cannot find Streamlit app. Make sure you're in the project directory.")
        sys.exit(1)
    
    # Check if we have Poetry
    try:
        subprocess.run(["poetry", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Poetry not found. Please install Poetry first.")
        sys.exit(1)
    
    try:
        # Use Poetry to run Streamlit
        cmd = [
            "poetry", "run", "streamlit", "run", 
            "src/ui/creative_rag_app.py",
            "--server.port", "8501",
            "--server.address", "localhost",
            "--browser.gatherUsageStats", "false"
        ]
        
        print("🚀 Starting Streamlit server with Poetry...")
        print("📱 Access your creative interface at: http://localhost:8501")
        print("🛑 Press Ctrl+C to stop the server")
        print("")
        
        subprocess.run(cmd)
        
    except KeyboardInterrupt:
        print("\n🛑 Shutting down Streamlit server...")
    except Exception as e:
        print(f"❌ Error launching Streamlit: {e}")
        print("💡 Try running manually: poetry run streamlit run src/ui/creative_rag_app.py")
        sys.exit(1)

if __name__ == "__main__":
    main()
