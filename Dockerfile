# ── Stage: Builder ───────────────────────────────────────────
FROM python:3.11-slim AS builder
WORKDIR /app

# install build tools
RUN apt-get update && apt-get install -y \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

# install Poetry just to export requirements
RUN pip install poetry==1.7.1

# copy only lock files first for caching
COPY pyproject.toml poetry.lock* ./

# generate requirements.txt
RUN poetry export \
      --without-hashes \
      --format=requirements.txt \
      --output=requirements.txt

# install all deps via pip (fast!)
RUN pip install --no-cache-dir -r requirements.txt

# copy your code
COPY src/ ./src
COPY configs/ ./configs


# ── Stage: Production ────────────────────────────────────────
FROM python:3.11-slim AS production
WORKDIR /app

# copy installed packages
COPY --from=builder /usr/local/lib/python3.11/site-packages \
     /usr/local/lib/python3.11/site-packages

# copy your app code
COPY --from=builder /app/src ./src
COPY --from=builder /app/configs ./configs

# create runtime dirs
RUN mkdir -p data logs

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
