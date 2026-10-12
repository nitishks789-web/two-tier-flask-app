# Use an official Python runtime as the base image
FROM python:3.13-slim

# Set the working directory in the container
WORKDIR /app

# Dependencies are pure Python (PyMySQL), so no compiler or system packages are needed
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Run as a non-root user and give them a proper home directory
RUN useradd --system --create-home appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appuser /home/appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

# No curl in slim images, so use Python for the container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# Include --no-control-socket to prevent the permission denied error
CMD ["gunicorn", "--no-control-socket", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
