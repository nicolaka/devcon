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

### Architecture: ARM64 Only

All download URLs and binary paths in the Dockerfile target **linux/arm64** (aarch64). When adding a new tool, always use the `arm64` or `aarch64` binary URL, not `amd64`/`x86_64`.

### Tool Categories in the Dockerfile

1. **Base:** Ubuntu 24.04 (`ubuntu:noble`), system packages via `apt-get`
2. **Languages:** Go (compiled from source), Python 3, Node.js, Maven
3. **HashiCorp stack:** Terraform, Terraform Stacks, Vault, Consul, Packer, Boundary, Waypoint, Vault Radar
4. **Cloud CLIs:** AWS CLI v2 + plugins (Session Manager, IAM Authenticator), Azure CLI, Google Cloud SDK
5. **Kubernetes:** kubectl, kubectx/kubens, Helm, Krew, eksctl
6. **Container tools:** Docker CLI, Docker Compose
7. **Security/Supply chain:** Cosign, Snyk, Infracost, CFSSL
8. **AI tools:** Claude Code CLI, Ollama (configured to connect to host via `OLLAMA_HOST=host.docker.internal:11434`)
9. **Shell:** Oh My Zsh + Powerlevel10k + plugins

### Adding New Tools

There are two patterns for adding tools:

- **Binary download** (HashiCorp pattern): use separate `RUN` steps for download, extract, and cleanup to keep layers readable. Example:
  ```dockerfile
  RUN curl https://releases.hashicorp.com/tool/${VERSION}/tool_${VERSION}_linux_arm64.zip -o tool.zip
  RUN unzip -o tool.zip -d /usr/local/bin
  RUN rm tool.zip
  ```
- **Go install** (for Go-based tools): `RUN go install github.com/owner/repo@latest` — binary lands in `$GOPATH/bin` which is on `$PATH`.

## Key Version Variables

All versions are defined as `ENV` at the top of the Dockerfile. Update these variables rather than editing install steps:

```
GOLANG_VERSION, TERRAFORM_VERSION, TERRAFORM_STACKS_VERSION,
VAULT_VERSION, CONSUL_VERSION, PACKER_VERSION, BOUNDARY_VERSION,
WAYPOINT_VERSION, RADAR_VERSION, KUBECTL_VER, HELM_VERSION,
CALICO_VERSION, COSIGN_VERSION, INFRACOST_VERSION
```

Go also requires updating `GOLANG_DOWNLOAD_SHA256` to match the new version's tarball hash.

## Published Image

The image is published to Docker Hub as `nicolaka/devcon:latest`.
