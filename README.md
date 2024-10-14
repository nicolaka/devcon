# DEVCON: a Complete Dev Environment in a Container 📦 

**Development Container Blog Post [by Nico Kabar]:** [link](https://medium.com/@nicolakabar/the-ultimate-development-environment-moving-from-vagrant-to-docker-for-mac-532bcf07e186)

"As a rule of thumb, I never install any packages directly onto my Mac unless I absolutely have to. So I created this sample development container that I use with Docker for Mac to be my sole dev environment." - Nico Kabar

The Dockerfile contains a breakdown of which tools are installed.
Shoutout to Nico Kabar for the inspiration and guidance to create my own version of his DevCon


## Package Versions - updated 10/14/2024
```
ENV GOLANG_VERSION 1.23.2
ENV GOLANG_DOWNLOAD_SHA256 f626cdd92fc21a88b31c1251f419c17782933a42903db87a174ce74eeecc66a9
ENV TERRAFORM_VERSION 1.9.7
ENV VAULT_VERSION 1.18.0+ent
ENV CONSUL_VERSION 1.19.2+ent
ENV PACKER_VERSION 1.11.2
ENV BOUNDARY_VERSION 0.17.1+ent
ENV WAYPOINT_VERSION 0.11.4
ENV HCDIAG_VERSION 0.5.1
ENV HCDIAG_EXT_VERSION 0.5.0
ENV KUBECTL_VER 1.31.0
ENV HELM_VERSION 3.14.0
ENV CALICO_VERSION 3.28.2
ENV COSIGN_VERSION 2.4.0
ENV INFRACOST_VERSION 0.10.36
```
### Usage
If you have Docker Desktop installed, you can run the following command to start the container from image `cesteban29/devcon:latest` found on Docker Hub:

```
$ docker run -it --rm --hostname devcon -v $(pwd):/app -v /var/run/docker.sock:/var/run/docker.sock cesteban29/devcon:latest
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

5. **`-v $(pwd):/app`**:  
   - `$(pwd)` refers to the current working directory (where you executed the `docker run` command) on the host machine.  
   - `/app` is the directory inside the container where the current directory will be mounted. You can replace `/app` with any desired path inside the container.

6. **`-v /var/run/docker.sock:/var/run/docker.sock`**:  
   This mounts the Docker socket from the host machine (`/var/run/docker.sock`) into the container at the same location (`/var/run/docker.sock`). This allows the container to communicate with the Docker daemon running on the host machine.  
   In practical terms, this gives the container access to the host’s Docker engine, enabling the container to run and manage Docker commands or even spawn other Docker containers as if it were running directly on the host.

7. **`cesteban29/devcon:latest`**:  
   This specifies the image to use for the container. In this case, it’s the latest version of the `devcon` image created by the user `cesteban29` stored in Docker Hub.

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



 

