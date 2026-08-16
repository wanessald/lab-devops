# lab-devops

A hands-on platform engineering laboratory built by a software engineering student exploring Infrastructure as Code, cloud provisioning, and container orchestration.

This project started as a practical follow-up to a platform engineering acceleration course. It is not a polished production system — it is a learning record, with real decisions, real failures, and real infrastructure.

---

## Context

I am a software engineering student, not a DevOps engineer. This lab was built to understand, in practice, what platform engineers actually do: provision infrastructure as code, manage cloud resources, connect machines over a network, and deploy applications in containers.

Everything here was built incrementally, one resource at a time, with intentional stops to understand what each piece does before moving to the next.

---

## Repository Structure

```
lab-devops/
│
├── cloud-lab/
│   └── azure/              # Cloud Lab: Terraform + Azure + Docker
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── terraform.tfvars (not versioned — credentials)
│
├── infrastructure-lab/
│   └── multipass/          # Infrastructure Lab: local VMs + Docker Swarm (upcoming)
│
└── app/                    # FastAPI application
    ├── main.py
    ├── Dockerfile
    ├── requirements.txt
    └── .dockerignore
```

---

## Cloud Lab — Phase 1: Azure + Terraform + VM

### Goal

Provision a Linux VM on Azure using Terraform, connect via SSH, install Docker, and deploy a containerized application accessible from the public internet.

### What was built, resource by resource

| Step | Resource | Purpose |
|------|----------|---------|
| 1 | `azurerm_resource_group` | Logical container for all Azure resources |
| 2 | `azurerm_virtual_network` | Isolated private network (`10.0.0.0/16`) |
| 3 | `azurerm_subnet` | Subdivision of the VNet (`10.0.1.0/24`) |
| 4 | `azurerm_network_security_group` | Firewall — inbound rules for SSH (22) and HTTP (80) |
| 5 | `azurerm_public_ip` | Static external IP address |
| 6 | `azurerm_network_interface` | Virtual NIC connecting the VM to the subnet and public IP |
| 7 | `azurerm_linux_virtual_machine` | Ubuntu 22.04 LTS, Standard_B2ats_v2, zone 1 |
| 8 | SSH connection | Key-based authentication via `~/.ssh/lab-devops` |
| 9 | Docker Engine | Installed via official `get.docker.com` script |
| 10 | Container (`traefik/whoami`) | API accessible publicly at the VM's public IP |

### Architecture

```
Internet
    │
    ▼
Public IP (static)
    │
    ▼
NSG (firewall)
  ├── port 22 → SSH allowed
  └── port 80 → HTTP allowed
    │
    ▼
NIC (virtual network interface)
    │
    ▼
VM — Ubuntu 22.04 (mexicocentral, zone 1)
  └── Docker
        └── container → port 80
```

### Key decisions and why

**Why Azure instead of OCI or GCP**
The original plan used Oracle Cloud Free Tier (Always Free A1 instances). After account creation, the `sa-saopaulo-1` region had no A1 capacity available. GCP required pre-payment for the student account. Azure for Students (provided by the university) was the viable path.

**Why `mexicocentral` instead of `brazilsouth`**
The university's Azure policy restricts deployments to five regions. `brazilsouth` had no available VM capacity for any SKU in the student subscription. `mexicocentral` zone 1 had `Standard_B2ats_v2` available with quota.

**Why `Standard_B2ats_v2`**
The only SKU available within the subscription's quota constraints in the allowed regions. 2 vCPUs, 1GB RAM — sufficient for Phase 1 and 2 validation but intentionally limited.

**Why resources were built incrementally**
Each resource was planned, applied, and verified before the next one was added. This approach made it possible to identify exactly which layer caused each error — NSG, quota, region policy, or SKU availability.

---

## Cloud Lab — Phase 2: FastAPI Application

### Goal

Build a minimal REST API in Python with FastAPI, containerize it with Docker, and deploy it manually to the Azure VM provisioned in Phase 1 — validating the full path from code to public endpoint.

### Application endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Returns `{"status": "ok"}` |
| `GET` | `/api/tasks` | Returns list of tasks |
| `POST` | `/api/tasks` | Creates a new task |
| `GET` | `/docs` | Auto-generated interactive documentation (FastAPI) |

### Stack

- **Python 3.12** with **FastAPI** and **Pydantic** for data validation
- **Uvicorn** as the ASGI server
- **Docker** with `python:3.12-slim` base image (~212MB)
- **In-memory storage** — data lives in a Python list; resets on container restart

### Deploy flow (manual — Phase 4 will automate this with Jenkins)

```
Write code locally (WSL)
        ↓
Test with Docker locally
        ↓
Push to GitHub
        ↓
SSH into Azure VM
        ↓
git clone the repository
        ↓
docker build
        ↓
docker run -p 80:80
        ↓
API publicly accessible
```

### What was learned

- FastAPI application structure and automatic documentation generation
- Dockerfile best practices: layer caching (copy `requirements.txt` before source code), `python:slim` base image, `--host 0.0.0.0` requirement for containers
- `.dockerignore` to exclude `__pycache__`, `.git`, and `.env` from the build context
- The difference between `-p 8000:80` (local testing) and `-p 80:80` (production)
- Why manual deploy is error-prone and what CI/CD solves
- `--restart unless-stopped` to survive VM reboots

---

## Prerequisites (local environment)

- Windows 11 with WSL 2 (Ubuntu 24.04)
- Terraform v1.7+ (installed inside WSL)
- Ansible core 2.16+ (installed inside WSL)
- Docker Desktop with WSL integration enabled
- Azure CLI (`az`) installed inside WSL
- Git 2.43+

All project work is done inside WSL. The repository lives at `~/projects/lab-devops` inside the Linux filesystem — not under `/mnt/c/` — to ensure correct file permissions for SSH keys and Ansible.

---

## Upcoming

- **Phase 3 — Infrastructure Lab:** provision 3 local VMs using Multipass, configure Docker Swarm, and study container networking, service discovery, rolling updates, and failover
- **Phase 4 — Jenkins:** CI/CD pipeline triggered by GitHub pushes, building and deploying to the Swarm cluster
- **Phase 5 — Comparison:** analyze the differences between cloud (Azure) and local (Multipass) infrastructure provisioned with the same toolchain

---

## Notes

This repository documents a learning journey, not a finished product. Errors, dead ends, and constraint workarounds are part of the record — they are where the actual learning happened.
