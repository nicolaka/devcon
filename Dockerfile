FROM ubuntu:20.10
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
    python3-pip \
    unzip \
    jq \
    tree \
    maven \
    locate \
    rsync \
    bash-completion \
    apt-transport-https \
    dnsutils \
    software-properties-common \
    ca-certificates \
    zsh \
    fonts-powerline \
    nodejs \
    npm \ 
    iproute2 \
    file \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Package Versions
ENV DOCKER_VERSION 5:20.10.3~3-0~ubuntu-groovy
ENV GOLANG_VERSION 1.15.2
ENV GOLANG_DOWNLOAD_SHA256 b49fda1ca29a1946d6bb2a5a6982cf07ccd2aba849289508ee0f9918f6bb4552
ENV TERRAFORM_VERSION 0.14.9
ENV TECLI_VERSION 0.2.0
ENV VAULT_VERSION 1.7.0
ENV PACKER_VERSION 1.7.1
ENV KUBECTL_VER 1.19.2
ENV HELM_VERSION 3.2.0
ENV CALICO_VERSION 3.16.1

# Installaing Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install docker-ce-cli=${DOCKER_VERSION}

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
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& sudo tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

# Setting up GOPATH. For me, i'm using $HOME/code/go
ENV HOME /root
ENV GOPATH $HOME/code/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Installing HashiCorp Stack
# Installing Terraform 
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
RUN unzip terraform.zip  -d /usr/local/bin  
RUN rm terraform.zip

# Installing tecli ( Terraform Cloud/Enterprise CLI)
RUN wget https://github.com/awslabs/tecli/releases/download/${TECLI_VERSION}/tecli-linux-amd64 -O /usr/local/bin/tecli && chmod +x /usr/local/bin/tecli

# Installing Vault
RUN curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
RUN unzip vault.zip  -d /usr/local/bin  
RUN rm vault.zip

# Installing Packer
RUN curl https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -o packer.zip
RUN unzip packer.zip -d /usr/local/bin
RUN rm packer.zip

# Installing ccat (https://github.com/jingweno/ccat)
RUN go get -u github.com/jingweno/ccat

# Installing gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

# Kubernetes Tools : kubectl, kubectx, and kubens
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx && chmod +x /usr/local/bin/kubectx
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens && chmod +x /usr/local/bin/kubens
RUN wget https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VER/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Installing Helm
RUN wget https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz -O /tmp/helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    tar -zxvf /tmp/helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

# Installing Krew
RUN OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" && \
    tar zxvf krew.tar.gz && \
    KREW=./krew-"${OS}_${ARCH}" && \
    "$KREW" install krew && \
    cp $HOME/.krew/bin/kubectl-krew /usr/local/bin/

# Installing eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Installing calicoctl
RUN wget https://github.com/projectcalico/calicoctl/releases/download/v$CALICO_VERSION/calicoctl -O /usr/local/bin/calicoctl && chmod +x /usr/local/bin/calicoctl

# Installing Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Setting WORKDIR and USER 
USER root
WORKDIR /root
VOLUME ["/home/devcon"]

# ZSH ENVs
ENV TERM xterm
ENV ZSH_THEME agnoster
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
COPY zshrc .zshrc

# Running ZSH
CMD ["zsh"]
