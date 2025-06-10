FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install UI dependencies
RUN pip install gradio==4.15.0 requests==2.31.0 pillow==10.1.0 plotly==5.17.0

# Copy UI code
COPY src/ui/ ./src/ui/
COPY src/utils/ ./src/utils/

# Create non-root user
RUN groupadd -r knownothing && useradd -r -g knownothing knownothing
RUN chown -R knownothing:knownothing /app
USER knownothing

# Expose Gradio port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860 || exit 1

# Run the UI
CMD ["python", "-m", "src.ui.app"]
