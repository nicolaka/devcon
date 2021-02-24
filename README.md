## DEVCON: a Complete Dev Environment in a Container 📦 

**Development Container Blog Post:** [link](https://medium.com/@nicolakabar/the-ultimate-development-environment-moving-from-vagrant-to-docker-for-mac-532bcf07e186)

As a rule of thumb, I never install any packages directly onto my Mac unless I absolutely have to. So I created this sample development container that I use with Docker for Mac to be my sole dev environment. There is a breakdown in the Dockerfile of which tools are installed. 

### Packages & Versions

- DOCKER_VERSION 5:20.10.3~3-0~ubuntu-groovy
- GOLANG_VERSION 1.15.2
- TERRAFORM_VERSION 0.14.5
- TECLI_VERSION 0.2.0
- VAULT_VERSION 1.6.2
- PACKER_VERSION 1.6.6
- KUBECTL_VER 1.19.2
- HELM_VERSION 3.2.0
- CALICO_VERSION 3.16.1

### Usage

```
$ docker run -it --rm --hostname devcon -v /var/run/docker.sock:/var/run/docker.sock nicolaka/devcon:latest
```

![img](devcon.png)

Optionally, you can mount your local Mac dev directory inside the container by adding `-v /path/to/dir:/root`. Typically, I mount a specific dev directory from my Mac that contains my dot files (including  git, ssh config + keys) to make it easier to use across both Mac and within the dev container. This way I can make sure that the dev container is a throw-away, leaving no keys/secrets exposed or written in it. 

Feel free to use and adjust to fit your own dev tooling!

Cheers 🍺
 

