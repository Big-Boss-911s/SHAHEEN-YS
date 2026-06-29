# ============================================================
# SHAHEEN-YS — Django Backend Dockerfile
# Base image: python:3.13-slim  (matches existing web_service)
# ============================================================

FROM python:3.13-slim

# ── Build arguments ─────────────────────────────────────────
ARG TARGETARCH

# ── Environment flags ───────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBUG=0 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# ── System dependencies ─────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Python toolchain ─────────────────────────────────────────
RUN pip install --upgrade pip poetry

# ── Install Python dependencies ──────────────────────────────
# Copy only the dependency manifests first (layer caching).
# The actual source code lives in source/web_service and is
# mounted at runtime; this Dockerfile installs deps from the
# manifests so the heavy install step is cached between rebuilds.
COPY requirements.txt ./requirements.txt

RUN pip install -r requirements.txt

# ── Copy source (for production image; dev uses volume mount) ─
COPY . .

# ── Expose the ASGI port ─────────────────────────────────────
EXPOSE 8000

# ── Default command (overridden by docker-compose.yml) ───────
CMD ["gunicorn", "pequeroku.asgi:application", \
     "-k", "uvicorn.workers.UvicornWorker", \
     "-w", "4", \
     "-b", "0.0.0.0:8000", \
     "--graceful-timeout", "30", \
     "--timeout", "600"]
