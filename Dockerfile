FROM ubuntu:resolute

# Installing required packages
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    gnupg \
    vim \
    git \
    curl \
    wget \
    sudo \
    iputils-ping \
    ssh \
    netcat-traditional \
    python3-setuptools \
    python3-pip \
    zip \
    unzip \
    jq \
    tree \
    locate \
    rsync \
    bash-completion \
    apt-transport-https \
    dnsutils \
    ca-certificates \
    zsh \
    fonts-powerline \
    iproute2 \
    file \
    pipx \
    less \
    httpie \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Setting up GOPATH. For me, i'm using $HOME/code/go
ENV HOME=/root
ENV GOPATH=$HOME/code/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH:$HOME/.local/bin

# Package Versions
ENV GOLANG_VERSION=1.23.1
ENV GOLANG_DOWNLOAD_SHA256=faec7f7f8ae53fda0f3d408f52182d942cc89ef5b7d3d9f23ff117437d4b2d2f
ENV TERRAFORM_VERSION=1.14.6
ENV TERRAFORM_STACKS_VERSION=0.6.1
ENV PACKER_VERSION=1.14.2
ENV KUBECTL_VER=1.33.0
ENV HELM_VERSION=3.14.4
ENV OLLAMA_VERSION=0.40.14

# Installing Docker CLI & Docker Compose
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    . /etc/os-release && \
    echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Installing + Setting Up GO Environment
ENV GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-arm64.tar.gz
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& sudo tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

# Installing Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip -o terraform.zip \
    && unzip -o terraform.zip -d /usr/local/bin \
    && rm terraform.zip

# Installing Terraform Stacks
RUN curl -fsSL https://releases.hashicorp.com/tfstacks/${TERRAFORM_STACKS_VERSION}/tfstacks_${TERRAFORM_STACKS_VERSION}_linux_arm64.zip -o tfstacks.zip \
    && unzip -o tfstacks.zip -d /usr/local/bin \
    && rm tfstacks.zip

# Installing Packer
RUN curl -fsSL https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_arm64.zip -o packer.zip \
    && unzip -o packer.zip -d /usr/local/bin \
    && rm packer.zip

# Kubernetes Tools : kubectl, kubectx, and kubens
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx && chmod +x /usr/local/bin/kubectx
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens && chmod +x /usr/local/bin/kubens
RUN wget https://dl.k8s.io/release/v$KUBECTL_VER/bin/linux/arm64/kubectl -O /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Installing Helm
RUN wget https://get.helm.sh/helm-v$HELM_VERSION-linux-arm64.tar.gz -O /tmp/helm.tar.gz && \
    tar -zxf /tmp/helm.tar.gz -C /tmp && \
    mv /tmp/linux-arm64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz /tmp/linux-arm64

# Installing Krew
RUN OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/arm4/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxf ${KREW}.tar.gz && \
    ./krew-"${OS}_${ARCH}" install krew && \
    cp $HOME/.krew/bin/kubectl-krew /usr/local/bin/ && \
    rm -rf ${KREW}.tar.gz ./krew-"${OS}_${ARCH}" LICENSE

# Installing eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_arm64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin && \
    rm -rf /tmp/eksctl

# Installing gcloud sdk
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-arm.tar.gz -O /tmp/google-cloud-cli-linux-arm.tar.gz && \
    tar -zxf /tmp/google-cloud-cli-linux-arm.tar.gz && \
    rm /tmp/google-cloud-cli-linux-arm.tar.gz
ENV PATH=$PATH:/google-cloud-sdk/bin

# Installing AWS CLI v2 + Session Manager + IAM Authenticator
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o awscliv2.zip && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws
RUN curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o session-manager-plugin.deb && \
    dpkg -i session-manager-plugin.deb && \
    rm session-manager-plugin.deb
RUN curl -fsSL "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_arm64" -o /usr/local/bin/aws-iam-authenticator && chmod +x /usr/local/bin/aws-iam-authenticator

# Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Ollama client only. Inference runs on the Mac via OLLAMA_HOST, so skip the CUDA runner libs.
RUN curl -fsSL "https://github.com/ollama/ollama/releases/download/v${OLLAMA_VERSION}/ollama-linux-arm64.tar.zst" \
        | tar -I zstd -xOf - bin/ollama > /usr/local/bin/ollama && \
    chmod +x /usr/local/bin/ollama
ENV OLLAMA_HOST=host.docker.internal:11434

# Setting WORKDIR and USER
USER root
WORKDIR /root
VOLUME ["/home/devcon"]

# ZSH ENVs
ENV TERM=xterm
ENV ZSH_THEME=agnoster
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
COPY zshrc .zshrc

# Running ZSH
CMD ["zsh"]
