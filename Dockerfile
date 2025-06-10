# Multi-stage build for knowNothing Creative RAG
FROM python:3.11-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry==1.7.1

# Configure Poetry
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VENV_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/opt/poetry-cache

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml poetry.lock* ./

# Production stage
FROM base AS production

# Install dependencies
# Install dependencies: disable Poetry venv, skip dev deps, clean cache
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi \
    && rm -rf /opt/poetry-cache

# Create non-root user for security
RUN groupadd -r knownothing && useradd -r -g knownothing knownothing

# Copy application code
COPY src/ ./src/
COPY configs/ ./configs/

# Create necessary directories and set permissions
RUN mkdir -p data logs uploads processed cache && \
    chown -R knownothing:knownothing /app

# Switch to non-root user
USER knownothing

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/health || exit 1

# Expose port
EXPOSE 8000

# Run the application
CMD ["poetry", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
