# DEVCON: a Complete Dev Environment in a Container 📦 

**Development Container Blog Post [by Nico Kabar]:** [link](https://medium.com/@nicolakabar/the-ultimate-development-environment-moving-from-vagrant-to-docker-for-mac-532bcf07e186)

"As a rule of thumb, I never install any packages directly onto my Mac unless I absolutely have to. So I created this sample development container that I use with Docker for Mac to be my sole dev environment." - Nico Kabar

The Dockerfile contains a breakdown of which tools are installed.
Shoutout to Nico Kabar for the inspiration and guidance to create my own version of his DevCon


## Package Versions - updated 10/17/2024
```
ENV GOLANG_VERSION 1.23.2
ENV GOLANG_DOWNLOAD_SHA256 f626cdd92fc21a88b31c1251f419c17782933a42903db87a174ce74eeecc66a9
ENV TERRAFORM_VERSION 1.9.8
ENV VAULT_VERSION 1.18.0+ent
ENV CONSUL_VERSION 1.20.0+ent
ENV NOMAD_VERSION 1.9.0+ent
ENV PACKER_VERSION 1.11.2
ENV BOUNDARY_VERSION 0.18.0+ent
ENV WAYPOINT_VERSION 0.11.4
ENV HCDIAG_VERSION 0.5.1
ENV HCDIAG_EXT_VERSION 0.5.0
ENV KUBECTL_VER 1.31.0
ENV HELM_VERSION 3.14.0
ENV CALICO_VERSION 3.28.2
ENV COSIGN_VERSION 2.4.0
ENV INFRACOST_VERSION 0.10.36
```
## Instructions

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Add the alias shortcut to your `.zshrc` file (or `.bashrc` if you're using Bash)
```
alias devcon='docker run -it --rm \
  --hostname devcon \
  -w /app \
  -v $(pwd):/app \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube:ro \
  carlosdev29/devcon:latest \
  bash -c "sed -i.bak '\''s/127.0.0.1/kubernetes.docker.internal/g'\'' /root/.kube/config && exec zsh"'
```
3. Run `devcon` from anywhere on your host machine and it will mount the current directory, Docker socket, and Kubernetes configuration files into the container

## Details
### Command
If you have Docker Desktop installed, you can run the following command to start the container from image `cesteban29/devcon:latest` found on Docker Hub:

```
$ docker run -it --rm \
  --hostname devcon \
  -w /app \
  -v $(pwd):/app \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube:ro \
  carlosdev29/devcon:latest \
  bash -c "sed -i.bak '\''s/127.0.0.1/kubernetes.docker.internal/g'\'' /root/.kube/config && exec zsh"
```

### Explanation of Each Part:

1. **`docker run`**:  
   This is the main Docker command to run a container from an image.

2. **`-it`**:  
   - `-i` (interactive): Keeps STDIN open, allowing you to interact with the container (e.g., use the terminal within the container).  
   - `-t` (tty): Allocates a pseudo-TTY (terminal) so you can use it like a regular terminal.

3. **`--rm`**:  
   Automatically removes the container when it exits. This ensures that the container doesn’t persist on your system after it’s done running, cleaning up resources after the run.

4. **`--hostname devcon`**:  
   This sets the hostname of the container to `devcon`. Inside the container, it will identify itself with the hostname `devcon`.

5. **`-w /app`**:  
   This sets the working directory inside the container to `/app`. This is where the container will look for files to work with if no other directory is specified.

6. **`-v $(pwd):/app`**:  
   - `$(pwd)` refers to the current working directory (where you executed the `docker run` command) on the host machine.  
   - `/app` is the directory inside the container where the current directory will be mounted. You can replace `/app` with any desired path inside the container.

7. **`-v /var/run/docker.sock:/var/run/docker.sock`**:  
   This mounts the Docker socket from the host machine (`/var/run/docker.sock`) into the container at the same location (`/var/run/docker.sock`). This allows the container to communicate with the Docker daemon running on the host machine.  
   In practical terms, this gives the container access to the host’s Docker engine, enabling the container to run and manage Docker commands or even spawn other Docker containers as if it were running directly on the host.

8. **`-v ~/.kube:/root/.kube`**:  
   This mounts the host machine's `.kube` directory into the container at the same location (`/root/.kube`). This allows the container to access the Kubernetes configuration files and use `kubectl` commands.

9. **`cesteban29/devcon:latest`**:  
   This specifies the image to use for the container. In this case, it’s the latest version of the `devcon` image created by the user `cesteban29` stored in Docker Hub.

10. **`bash -c "sed -i.bak '\''s/127.0.0.1/kubernetes.docker.internal/g'\'' /root/.kube/config && exec zsh"`**:  
   This runs a command inside the container to replace `127.0.0.1` with `kubernetes.docker.internal` in the Kubernetes configuration file. This is necessary because the Kubernetes API server is running on the host machine, not inside the container. For more info look at the [Errors Found](#errors-found) section.

### Build new image

Build locally:

```
$ docker build -t devcon:latest .
```

Build and push to Docker Hub:

```
$ docker login
$ docker build -t yourusername/devcon:latest .
$ docker push yourusername/devcon:latest
```

### Alias Shortcut in .zshrc

Add the following to your `.zshrc` file:

```
alias devcon='docker run -it --rm \
  --hostname devcon \
  -w /app \
  -v $(pwd):/app \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube:ro \
  carlosdev29/devcon:latest \
  bash -c "sed -i.bak '\''s/127.0.0.1/kubernetes.docker.internal/g'\'' /root/.kube/config && exec zsh"'
```

This allows you to run `devcon` from any directory on your host machine, and it will automatically mount the current directory, the Docker socket, and your Kubernetes configuration files into the container! 


Make sure to reload your `.zshrc` file:

```
$ source ~/.zshrc
```

Now you can start the container with:

```
$ devcon
```

## Errors Found
### Accessing Kubernetes API from Docker Containers on macOS/Windows

When running **Kubernetes** via **Docker Desktop** on macOS or Windows, accessing the Kubernetes API server from within a **Docker container** can present some challenges due to how network namespaces work between the host machine and containers. This document explains why and how we resolved these issues.

#### Problem: Why Replace `127.0.0.1`?

When you interact with the **Kubernetes API** on your host machine using **kubectl**, the **Kubeconfig** often points to `127.0.0.1`, which is the **loopback address** or **localhost**. This works fine when running commands directly on the host, but not when you're inside a **Docker container**.

##### Inside a Docker Container:
- **`127.0.0.1`** or **localhost** refers to the **container itself**, not the host machine. 
- Since the **Kubernetes API server** is running on the **host machine** (via Docker Desktop), attempting to reach `127.0.0.1` inside the container will fail because it's trying to connect to the container's own network, not the host's.

#### Solution: Use `kubernetes.docker.internal`

To solve this, **Docker** provides a special hostname, **`kubernetes.docker.internal`**, that allows containers to access the **host machine’s services**, including the Kubernetes API server.

By replacing `127.0.0.1` in your **Kubeconfig** with `kubernetes.docker.internal`, the container can now access the Kubernetes API server running on your host through Docker Desktop.
   
   ```bash
   sed -i.bak 's/127.0.0.1/kubernetes.docker.internal/g' /root/.kube/config
   ```

