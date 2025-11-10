# Use the official Python 3.13 slim image
FROM python:3.13-slim

# Create non-root app user
RUN useradd --create-home --shell /bin/bash appuser

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc build-essential libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Copy dependency files first (for caching)
COPY pyproject.toml poetry.lock* /app/

# Copy application source code
COPY app /app/app
COPY main.py /app/

# Install Python dependencies
RUN python -m pip install --upgrade pip setuptools wheel \
 && python -m pip install fastapi sqlalchemy aiosqlite prometheus-client pydantic uvicorn

# Create a writable data directory and fix permissions
RUN mkdir -p /data && chown -R appuser:appuser /data /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV PYTHONPATH=/app
ENV PORT=8000

# Expose the FastAPI port
EXPOSE 8000

#ENTRYPOINT: Start FastAPI directly via uvicorn
ENTRYPOINT ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
