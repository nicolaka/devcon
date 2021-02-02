## Devcon: a Sample Development Environment in a Container


**Development Container Blog Post:** [link](https://medium.com/@nicolakabar/the-ultimate-development-environment-moving-from-vagrant-to-docker-for-mac-532bcf07e186)

This is a sample development container that I use with Docker for Mac. There is a breakdown in the Dockerfile of which tools are installed. Feel free to use it as your dev environment.

How to use:

```
$ docker run -it --rm --hostname devcon -v /var/run/docker.sock:/var/run/docker.sock nicolaka/devcon:latest
```

Currently the below dev tools are installed:


Optionally, you can mount your local dev directory inside the container by adding `-v /path/to/dir:/root`

Enjoy!
 

