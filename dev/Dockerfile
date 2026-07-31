# Use Ubuntu 22.04 LTS as the base
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    git \
    groff \
    less \
    gnupg \
    lsb-release \
    openssh-client \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# ---------- AWS CLI v2 ----------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && /usr/local/bin/aws --version

# ---------- Session Manager Plugin ----------
# Architecture detection
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "sm-plugin.deb"; \
    else \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "sm-plugin.deb"; \
    fi \
    && dpkg -i sm-plugin.deb \
    && rm sm-plugin.deb \
    && session-manager-plugin --version

# ---------- Terraform ----------
ARG TERRAFORM_VERSION=1.9.8
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip" -o terraform.zip; \
    else \
        curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip; \
    fi \
    && unzip terraform.zip -d /usr/local/bin/ \
    && rm terraform.zip \
    && terraform version

# ---------- AWS Vault (optional but recommended) ----------
# Skip if you don't want it. Useful for managing AWS credentials safely.
# RUN curl -fsSL https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64 -o /usr/local/bin/aws-vault \
#     && chmod +x /usr/local/bin/aws-vault

# Default working directory
WORKDIR /workspace

# Default command — drop into a bash shell
CMD ["/bin/bash"]