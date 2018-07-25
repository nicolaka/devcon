FROM ubuntu:16.04
MAINTAINER Nicola Kabar <nicolaka@gmail.com>

RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main " >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

# Installing required packages
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
    build-essential \
    vim \
    git \
    curl \ 
    cmake \
    wget \
    sudo \
    iputils-ping \
    ssh \
    ansible \
    netcat \
    python-dev \
    python-setuptools \
    python-pip \ 
    ipython \
    unzip \
    jq \
    tree \
    maven \
    locate \
    rsync \ 
    bash-completion \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Azure CLI + Powershell 
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ xenial main" >> /etc/apt/sources.list
RUN echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/16.04/prod xenial main" >> /etc/apt/sources.list
RUN curl -L https://packages.microsoft.com/keys/microsoft.asc |  apt-key add -
RUN apt-get update && apt-get install -y azure-cli powershell 

# Installating Docker Client and Docker Compose
RUN curl -Ssl https://get.docker.com | sh
RUN pip install docker-compose
RUN pip install --upgrade pip
RUN pip install --ignore-installed \
    docker-compose \
    awscli \
    six \
    docker \ 
    httpie \
    python-bash-utils \
    pywinrm \
    xmltodict \
    pyOpenSSL==16.2.0 


# Installing + Setting Up GO Environment
ENV GOLANG_VERSION 1.10.2
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& sudo tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

# Setting up GOPATH. For me, i'm using $HOME/code/go
ENV HOME /root
ENV GOPATH $HOME/code/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH


# Installing Terraform and Packer
RUN curl https://releases.hashicorp.com/terraform/0.11.5/terraform_0.11.5_linux_amd64.zip?_ga=2.222080152.1480532662.1522865115-408330857.1522865115 -o terraform.zip
RUN unzip terraform.zip  -d /usr/local/bin  
RUN rm terraform.zip

RUN curl https://releases.hashicorp.com/packer/1.2.2/packer_1.2.2_linux_amd64.zip  -o packer.zip
RUN unzip packer.zip  -d /usr/local/bin
RUN rm packer.zip

# Installing ccat (https://github.com/jingweno/ccat)
RUN go get -u github.com/jingweno/ccat

# Installing gcloud
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install -y google-cloud-sdk 

# Salt
RUN curl https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2016.11/SALTSTACK-GPG-KEY.pub  | apt-key add - \
    echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" | tee -a /etc/apt/sources.list.d/saltstack.list \
    apt-get update && apt-get install -y salt-ssh salt-minion salt-master

# Kubernetes Tools 
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx && chmod +x /usr/local/bin/kubectx
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens && chmod +x /usr/local/bin/kubens
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.10.5/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/utils.bash -O /usr/local/bin/utils.bash

# Calico Version 1.6.1
RUN wget https://github.com/projectcalico/calicoctl/releases/download/v1.6.1/calicoctl -O /usr/local/bin/calicoctl && chmod +x /usr/local/bin/calicoctl

# Setting WORKDIR and USER
USER root
WORKDIR /root
VOLUME ["/home/devcon"]

# Sample Bash Profile that will be overwritted if your mounted dir has a .profile
ADD bash_profile  .profile
# Running Bash
CMD ["/bin/bash", "-l"]
