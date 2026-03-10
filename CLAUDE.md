# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DEVCON** is a Docker-based development environment container. The entire project is essentially a single `Dockerfile` that builds a comprehensive Ubuntu 24.04 LTS image with development, DevOps, and infrastructure tools pre-installed. There is no application code — only container configuration.

## Build and Run

```bash
# Build the image
docker build -t devcon:latest .

# Run the container (with Docker socket for Docker-in-Docker CLI access)
docker run -it --rm --hostname devcon \
  -v /var/run/docker.sock:/var/run/docker.sock \
  nicolaka/devcon:latest

# Optionally mount a local directory as the working directory
docker run -it --rm --hostname devcon \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /path/to/dir:/root \
  nicolaka/devcon:latest
```

There are no tests, linting tools, or CI/CD configs in this repo.

## Architecture

All configuration lives in two files:

- **`Dockerfile`** — The main artifact. Installs all tools in layered `RUN` steps. Version numbers are defined as `ARG`/`ENV` variables at the top, making updates straightforward.
- **`zshrc`** — Copied into the image as `/root/.zshrc`. Configures Oh My Zsh with the Powerlevel10k theme and development-oriented plugins.

### Tool Categories in the Dockerfile

1. **Base:** Ubuntu 24.04 (`ubuntu:noble`), system packages via `apt-get`
2. **Languages:** Go (compiled from source), Python 3, Node.js, Maven
3. **HashiCorp stack:** Terraform, Vault, Consul, Packer, Boundary, Waypoint, Vault Radar
4. **Cloud CLIs:** AWS CLI v2 + plugins (Session Manager, IAM Authenticator), Azure CLI, Google Cloud SDK
5. **Kubernetes:** kubectl, kubectx/kubens, Helm, Krew, eksctl
6. **Container tools:** Docker CLI, Docker Compose
7. **Security/Supply chain:** Cosign, Snyk, Infracost, CFSSL
8. **AI tools:** Claude Code CLI, Ollama
9. **Shell:** Oh My Zsh + Powerlevel10k + plugins

## Key Version Variables

Versions are defined as `ARG`/`ENV` at the top of the Dockerfile:

```
GOLANG_VERSION, TERRAFORM_VERSION, TERRAFORM_STACKS_VERSION,
VAULT_VERSION, CONSUL_VERSION, PACKER_VERSION, BOUNDARY_VERSION,
WAYPOINT_VERSION, RADAR_VERSION, KUBECTL_VER, HELM_VERSION
```

When updating tool versions, change these variables rather than hunting through the install steps.

## Published Image

The image is published to Docker Hub as `nicolaka/devcon:latest`.
