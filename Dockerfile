FROM ubuntu:18.04
MAINTAINER Nicola Kabar <nicolaka@gmail.com>

# Installing required packages
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
    gnupg \
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
    dnsutils \
    && rm -rf /var/lib/apt/lists/*


# Azure CLI + Powershell 
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" >> /etc/apt/sources.list
RUN echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/18.04/prod bionic main" >> /etc/apt/sources.list
RUN curl -L https://packages.microsoft.com/keys/microsoft.asc |  apt-key add -
RUN apt-get update && apt-get install -y azure-cli powershell 


# Installaing Docker Client and Docker Compose
RUN curl -Ssl https://get.docker.com | sh
RUN pip install docker-compose

# Installing Additional PIP based libraries
RUN pip install awscli \
    six \
    docker \ 
    httpie \
    python-bash-utils \
    pywinrm \
    xmltodict \
    pyOpenSSL==16.2.0 

# Installing + Setting Up GO Environment
ENV GOLANG_VERSION 1.12.6
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 dbcf71a3c1ea53b8d54ef1b48c85a39a6c9a935d01fc8291ff2b92028e59913c

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& sudo tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

# Setting up GOPATH. For me, i'm using $HOME/code/go
ENV HOME /root
ENV GOPATH $HOME/code/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH


# Installing Terraform 
ENV TERRAFORM_VERSION 0.12.24
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
RUN unzip terraform.zip  -d /usr/local/bin  
RUN rm terraform.zip

# Installing ccat (https://github.com/jingweno/ccat)
RUN go get -u github.com/jingweno/ccat

# Installing gcloud
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-bionic main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install -y google-cloud-sdk 

# Kubernetes Tools 
ENV KUBECTL_VER 1.18.2
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx && chmod +x /usr/local/bin/kubectx
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens && chmod +x /usr/local/bin/kubens
RUN wget https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VER/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Installing Helm
ENV HELM_VERSION 3.2.0
RUN wget https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz -O /tmp/helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    tar -zxvf /tmp/helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

# Calico
ENV GOLANG_VERSION 3.13.3
RUN wget https://github.com/projectcalico/calicoctl/releases/download/v$GOLANG_VERSION/calicoctl -O /usr/local/bin/calicoctl && chmod +x /usr/local/bin/calicoctl

# Node
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
RUN apt-get install -y nodejs
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && sudo apt-get install yarn 	

# Installing Krew
RUN set -x; cd "$(mktemp -d)" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" && \
  tar zxvf krew.tar.gz && \
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" && \
  "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz && \
  "$KREW" update && \
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Installing eksctl

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Setting WORKDIR and USER
USER root
WORKDIR /root
VOLUME ["/home/devcon"]

# Sample Bash Profile that will be overwritten if your mounted dir has a .profile
ADD bash_profile  .profile
# Running Bash
CMD ["/bin/bash", "-l"]
