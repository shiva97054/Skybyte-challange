# Skybyte API

A small Python service that returns a greeting. Runs in Kubernetes via Helm.

> **Note:** the engineer who set this up is no longer with the team. Some of this README may be out of date. **The challenge brief is in [`CHALLENGE.md`](./CHALLENGE.md) — start there.**

## Prerequisites

- Docker Desktop (or any Docker engine)
- A local Kubernetes cluster (Minikube or Kind)
- Helm 3.x
- Terraform 1.5+
- Python 3.9+ (for running tests locally)

## Quick start

```bash
./setup.sh
```

This script will build the image, apply Terraform, and install the Helm chart.

To verify the deployment:

```bash
kubectl -n devops-challenge get pods
kubectl -n devops-challenge port-forward svc/skybyte-app 8080:80
curl http://localhost:8080/
# expected: {"message": "Hello, Candidate", "version": "1.0.0"}
```

## Architecture

```
[Client] ──► [Service:80] ──► [Pod:appuser:80]
```

The pod runs as a non-root user (appuser) and listens on port 80. Health checks are wired to `/healthz`.

## CI

GitHub Actions runs lint, helm lint, terraform validate, and a Docker build on every push. See `.github/workflows/ci.yml`.

## Layout

```
/
├── app/                  Python service
├── Dockerfile
├── helm/skybyte-app/     Helm chart
├── terraform/            Namespace + ResourceQuota + secret
├── .github/workflows/    CI
├── setup.sh
└── CHALLENGE.md          ← read this
```




---------------------------------------------------------------


# DevOps Engineering Challenge — Hardened & Production-Ready

##  Overview

This repository contains a hardened version of the provided starter project.
The original setup had multiple issues across security, reliability, observability, and CI/CD.

###  Key Improvements

*  Removed root execution and enforced non-root containers
*  Moved secrets out of Helm values into Kubernetes Secrets
*  Added resource requests and limits
*  Implemented liveness and readiness probes
*  Added Prometheus metrics (`/metrics`)
*  Introduced Kyverno policy enforcement
*  Built a full CI pipeline with linting, validation, and security scans
*  Created automated setup and validation scripts

---

## Prerequisites

Ensure the following tools are installed:

* Docker
* Kubernetes (Minikube or Kind)
* kubectl
* Helm
* Terraform
* Git

---

##  Setup Instructions

Run the full setup:

```bash
./setup.sh
```

This script will:

* Start Kubernetes cluster (Minikube)
* Build Docker image
* Apply Terraform resources
* Deploy Helm chart
* Ensure secrets are configured

---

##  System Validation

Run:

```bash
./system-checks.sh
```

This will verify:

* Container runs as non-root
* Application endpoints are working
* Metrics endpoint is available
* Pod recovers automatically after deletion

---

## Observability

Metrics are exposed at:

```bash
http://localhost:8080/metrics
```

Includes:

* `http_requests_total`
* Request duration histogram

---
##  Service Level Objective (SLO)

**99% of requests to `/` complete in under 200ms over a rolling 7-day window.**

---

## Policy Enforcement

Kyverno policies enforce:

* Non-root container execution
* Mandatory resource requests and limits

---

##CI Pipeline

The GitHub Actions pipeline includes:

* Python linting (ruff)
* Unit testing (pytest)
* Helm validation
* Terraform validation
* Docker multi-arch build
* Trivy security scans
* Kyverno policy checks

---

## 📁 Repository Structure

```
app/                    # Python application
helm/                   # Helm chart
terraform/              # Infrastructure provisioning
policies/               # Kyverno policies
.github/workflows/      # CI pipeline
Dockerfile
setup.sh
system-checks.sh
AUDIT.md
DECISIONS.md
README.md
```
---

## 📌 Summary

This project demonstrates a complete DevOps workflow including:

* Secure containerization
* Kubernetes hardening
* Observability implementation
* Policy-as-code enforcement
* CI/CD automation

The focus was on **small, meaningful improvements with clear reasoning**, rather than large rewrites.

