# lab-devops

A hands-on platform engineering laboratory built by a software engineering student exploring Infrastructure as Code, cloud provisioning, container orchestration, and CI/CD automation.

This project started as a practical follow-up to a platform engineering acceleration course. It is not a polished production system — it is a learning record, with real decisions, real failures, and real infrastructure.

---

## Context

I am a software engineering student, not a DevOps engineer. This lab was built to understand, in practice, what platform engineers actually do: provision infrastructure as code, manage cloud resources, connect machines over a network, deploy applications in containers, and automate the entire delivery pipeline.

Everything here was built incrementally, one resource at a time, with intentional stops to understand what each piece does before moving to the next.

---

## Repository Structure

```
lab-devops/
│
├── app/                              # FastAPI application
│   ├── main.py
│   ├── test_main.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .dockerignore
│
├── cloud-lab/
│   └── azure/                        # Cloud Lab: Terraform + Azure
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── terraform.tfvars.example
│       └── terraform.tfvars          (not versioned — credentials)
│
├── infrastructure-lab/
│   ├── vagrant/
│   │   └── Vagrantfile               # 3 local VMs with private network
│   └── ansible/
│       ├── inventory.ini             (not versioned — local IPs)
│       ├── inventory.ini.example
│       └── playbooks/
│           ├── install_docker.yml
│           └── setup_swarm.yml
│
├── .github/
│   └── workflows/
│       └── ci.yml                    # GitHub Actions CI pipeline
│
└── Jenkinsfile                       # Jenkins CD pipeline
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
| 10 | Container | Application accessible publicly at the VM's public IP |

### Architecture

```
Internet
    │
    ▼
Public IP (static)
    │
    ▼
NSG (firewall)
  ├── port 22 → SSH (restricted by ssh_source_address_prefix)
  └── port 80 → HTTP allowed
    │
    ▼
NIC (virtual network interface)
    │
    ▼
VM — Ubuntu 22.04 (mexicocentral, zone 1)
  └── Docker
        └── container (appuser, non-root) → port 8000
```

### Key decisions and why

**Why Azure instead of OCI or GCP**
The original plan used Oracle Cloud Free Tier. After account creation, the region had no A1 capacity available. GCP required pre-payment. Azure for Students (provided by the university) was the viable path.

**Why `mexicocentral` instead of `brazilsouth`**
The university's Azure policy restricts deployments to five regions. `brazilsouth` had no available VM capacity. `mexicocentral` zone 1 had `Standard_B2ats_v2` available with quota.

**Why resources were built incrementally**
Each resource was planned, applied, and verified before the next one was added — making it possible to identify exactly which layer caused each error.

### Known limitations

- Terraform state is local only. A remote backend is the next step.
- `ssh_source_address_prefix` defaults to `"*"` due to dynamic residential IP.

---

## Cloud Lab — Phase 2: FastAPI Application

### Goal

Build a minimal REST API in Python with FastAPI, containerize it with Docker, and deploy it manually to the Azure VM — validating the full path from code to public endpoint.

### Application endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Returns `{"status": "ok"}` |
| `GET` | `/api/tasks` | Returns list of tasks |
| `POST` | `/api/tasks` | Creates a new task (title required, max 120 chars) |
| `GET` | `/docs` | Auto-generated interactive documentation (FastAPI) |

### Stack

- **Python 3.12** with **FastAPI** and **Pydantic** for data validation
- **Uvicorn** as the ASGI server
- **Docker** with `python:3.12-slim` base image (~212MB)
- **Non-root container** — application runs as `appuser` (UID 10001)
- **In-memory storage** — resets on container restart
- **pytest** — 6 tests covering success and error cases

### What was learned

- FastAPI, Pydantic models, and automatic documentation
- Dockerfile best practices: layer caching, slim base image, non-root user
- Why manual deploy is error-prone and what CI/CD solves

---

## Infrastructure Lab — Phase 3: Vagrant + Ansible + Docker Swarm

### Goal

Provision 3 local Ubuntu VMs using Vagrant and VirtualBox, configure Docker and Docker Swarm using Ansible, deploy the FastAPI application as a replicated service, and validate failover and zero-downtime behavior in a real multi-node cluster.

### Environment

| VM | IP | Role | RAM |
|---|---|---|---|
| manager | 192.168.56.10 | Swarm Manager + Leader | 2GB |
| worker-01 | 192.168.56.11 | Swarm Worker | 2GB |
| worker-02 | 192.168.56.12 | Swarm Worker | 2GB |

> Note: the original plan used Multipass for VM provisioning. This was blocked by Windows 10 Home (no Hyper-V) and VirtualBox 6.1 incompatibility with WSL 2. After upgrading to VirtualBox 7.2, Vagrant was chosen for its precise network configuration control — particularly the `private_network` setting that assigns fixed IPs and enables inter-VM communication.

### What Ansible automated

| Playbook | What it does |
|---|---|
| `install_docker.yml` | Installs Docker Engine on all 3 nodes simultaneously |
| `setup_swarm.yml` | Initializes Swarm on manager, retrieves join token, joins workers |

### What was validated

| Experiment | Result |
|---|---|
| Multi-node Swarm initialization | 3 distinct Docker Engine instances forming a real cluster |
| Local registry | Image pushed to `192.168.56.10:5000`, pulled by all nodes |
| 3 replicas across 3 nodes | Each replica running on a different physical VM |
| Worker node failure (VM halt) | Swarm rescheduled replica automatically within seconds |
| Zero-downtime failover | API remained responsive during node failure and recovery |

### Key concepts demonstrated

**Why a local registry is necessary in multi-node Swarm**
Each node has its own Docker Engine and image cache. Without a shared registry, workers fail with `pull access denied` when trying to start service replicas.

**Failover and zero downtime**
When `worker-01` was halted, the Swarm manager detected the node as unavailable and rescheduled its replica on another node within seconds — without manual intervention and without interrupting service.

**Docker Swarm node definition**
A Swarm node is a Docker Engine instance running on a separate host. Running multiple containers on a single Docker daemon does not create multiple Swarm nodes.

---

## CI/CD — Phase 4: GitHub Actions + Jenkins

### Goal

Automate the full delivery pipeline: validate code on every push with GitHub Actions, and automatically build, push, and deploy to the Swarm cluster with Jenkins triggered by GitHub webhooks.

### Pipeline architecture

```
git push to GitHub
      ↓
GitHub Actions (validation — runs on GitHub servers)
  ├── pytest (6 tests)
  ├── terraform validate + fmt check
  └── docker build
      ↓
GitHub webhook → ngrok → Jenkins (192.168.56.10:8080)
      ↓
Jenkins pipeline (deployment — runs on local Swarm)
  ├── Test: pip3 install + python3 -m pytest
  ├── Build: docker build (tagged with git commit SHA)
  ├── Push: docker push to local registry
  └── Deploy: docker service update (rolling, 1 replica at a time)
      ↓
new version live on Swarm cluster
```

### What each tool does

| Tool | Responsibility | Where it runs |
|---|---|---|
| GitHub Actions | Validation (tests, IaC, image build) | GitHub servers (free) |
| Jenkins | Build + deploy to Swarm | Local container on manager VM |
| ngrok | Tunnel GitHub webhooks to local Jenkins | WSL terminal |

### Key decisions and why

**Why GitHub Actions AND Jenkins**
GitHub Actions handles validation — it runs on GitHub's infrastructure with no setup required and provides fast feedback on every push. Jenkins handles deployment — it runs locally with direct access to the Docker socket and Swarm manager, without exposing cloud credentials to external services.

**Why commit SHA as image tag**
Each image is tagged with the first 7 characters of the Git commit hash (`b94272f`). This creates a direct traceability between the running container and the exact code that produced it — standard practice in production CI/CD pipelines.

**Why rolling update**
`--update-parallelism 1 --update-delay 5s` updates one replica at a time with a 5-second pause between each. The service remains available throughout the update — zero downtime deployment.

### What was learned

- Pipeline as code: `Jenkinsfile` and `.github/workflows/ci.yml` versioned alongside application code
- Webhook mechanics: how GitHub notifies Jenkins via HTTP POST on push events
- ngrok for local webhook development: exposing local services to the internet temporarily
- The difference between CI (validation) and CD (deployment)
- Why companies use self-hosted Jenkins alongside cloud CI tools

---

## Getting Started

### Prerequisites

- Windows 10/11 with WSL 2 (Ubuntu 24.04)
- Terraform v1.7+ (inside WSL)
- Ansible core 2.16+ (inside WSL)
- Docker Desktop with WSL integration
- Azure CLI inside WSL
- VirtualBox 7.2+
- Vagrant 2.4+
- Git 2.43+

### Cloud Lab (Azure)

```bash
cp cloud-lab/azure/terraform.tfvars.example cloud-lab/azure/terraform.tfvars
# edit terraform.tfvars with your subscription ID and SSH public key
cd cloud-lab/azure
az login
terraform init && terraform plan && terraform apply
```

### Infrastructure Lab (local VMs)

```bash
# Start VMs (Windows PowerShell as Administrator)
cd C:\path\to\infrastructure-lab\vagrant
vagrant up

# Configure inventory (WSL)
cp infrastructure-lab/ansible/inventory.ini.example infrastructure-lab/ansible/inventory.ini
# edit with your Vagrant SSH key paths

# Install Docker and configure Swarm
cd infrastructure-lab
ansible-playbook -i ansible/inventory.ini ansible/playbooks/install_docker.yml --forks 1
ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_swarm.yml
```

### Run Jenkins pipeline manually

```
http://192.168.56.10:8080 → lab-devops → Build Now
```

### Suspend VMs when not in use

```bash
vagrant suspend   # saves state, frees RAM immediately
vagrant resume    # restores state
```

---

## Upcoming

- **Phase 5 — Comparison:** structured analysis of differences between cloud (Azure) and local (Swarm) infrastructure — provisioning time, cost, scalability, and operational complexity

---

## Notes

This repository documents a learning journey, not a finished product. Errors, dead ends, and constraint workarounds are part of the record — they are where the actual learning happened.
