FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser

WORKDIR /app

COPY app/ .

# Install dependencies if exists
RUN pip install --no-cache-dir -r requirements.txt

# Switch to non-root
USER appuser

EXPOSE 8080

CMD ["python", "main.py"]
