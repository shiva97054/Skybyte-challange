"""Skybyte greeting service."""

# 🔹 1. Imports (ADD HERE)
from flask import Flask, jsonify
import os
import time
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

# 🔹 2. App init
app = Flask(__name__)

VERSION = "1.0.0"
API_TOKEN = os.environ.get("API_TOKEN", "")

# 🔹 3. Metrics (ADD HERE)
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP Requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request latency",
    ["endpoint"]
)

# 🔹 4. Routes

@app.route("/")
def hello():
    start_time = time.time()

    response = jsonify({"message": "Hello, Candidate", "version": VERSION})
    status_code = 200

    REQUEST_COUNT.labels(method="GET", endpoint="/", status=status_code).inc()
    REQUEST_LATENCY.labels(endpoint="/").observe(time.time() - start_time)

    return response


@app.route("/healthz")
def healthz():
    return "ok", 200


# 🔹 5. Metrics endpoint (ADD HERE)
@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


# 🔹 6. App start (KEEP SAME)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
