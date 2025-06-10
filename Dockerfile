# ── Stage: Base image ───────────────────────────────────────
FROM python:3.11-slim AS base

# set working directory
WORKDIR /app

# install system deps
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libgl1-mesa-glx \
  && rm -rf /var/lib/apt/lists/*

# install Poetry
RUN pip install poetry==1.7.1

# ── Stage: Install dependencies ─────────────────────────────
FROM base AS deps

# copy pyproject and lock file first, for layer caching
COPY pyproject.toml poetry.lock* ./

# copy your application code *before* installing the project
COPY src/ ./src/
COPY configs/ ./configs/

# configure Poetry to install into system Python, skip dev deps
RUN poetry config virtualenvs.create false \
  && poetry install --no-dev --no-interaction --no-ansi \
  && rm -rf /opt/poetry-cache

# ── Stage: Production image ─────────────────────────────────
FROM base AS production

# copy installed site-packages from deps stage
COPY --from=deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# bring in your code & configs
COPY --from=deps /app/src ./src
COPY --from=deps /app/configs ./configs

# create data/logs dirs
RUN mkdir -p data logs

EXPOSE 8000

# command to run your FastAPI app
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
