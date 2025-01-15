#!/bin/bash

# Function to install AWS CLI
install_aws() {
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
    echo "AWS CLI installation complete."
}

# Function to install eksctl
install_eksctl() {
    echo "Installing eksctl..."
    PLATFORM=$(uname -s)_amd64
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl installation complete."
}

# Function to install kubectl
install_kubectl() {
    echo "Installing kubectl..."
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) BIN_ARCH="amd64" ;;
        aarch64) BIN_ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$BIN_ARCH/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo "kubectl installation complete."
}

# Function to install Terraform & mdbook
install_terraform() {
    echo "Installing Terraform..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Cannot determine OS type. Exiting."
        exit 1
    fi

    if [[ "$OS" == "ubuntu" ]]; then
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install -y terraform
        # # Install cargo and mdbook
        # curl https://sh.rustup.rs -sSf | sh -s -- -y
        # # Automatically source the Rust environment for the current session
        # . "$HOME/.cargo/env"
        # # For bash/zsh:
        # echo 'source $HOME/.cargo/env' >> ~/.bashrc
        # # install mdbook
        # source ~/.bashrc
        # cargo install mdbook

    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
        sudo yum install -y yum-utils uuid-runtime jq
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        sudo yum -y install terraform
    elif [[ "$OS" == "amzn" ]]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
        sudo yum -y install terraform
    else
        echo "Unsupported OS: $OS. Please install Terraform manually."
        exit 1
    fi
    echo "Terraform installation complete."
}

# Function to install jq & other dependencies
install_jq() {
    echo "Installing jq..."
    if [[ "$OS" == "ubuntu" ]]; then
        sudo apt-get update && sudo apt-get install -y jq uuid-runtime
    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
        sudo yum install -y jq
    else
        echo "Unsupported OS: $OS. Please install jq manually."
        exit 1
    fi
    echo "jq installation complete."
}

# Function to check if a binary is installed
check_binary() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 could not be found. Installing $1..."
        install_$1
    else
        echo "$1 is already installed."
    fi
}

# Check CPU architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
    echo "Error: This script only supports Intel/AMD64 or ARM64 architectures. Detected architecture: $ARCH."
    exit 1
fi

# Determine OS type
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo "Operating System detected: $OS."
else
    echo "Cannot determine operating system type. Exiting."
    exit 1
fi

# Check and install required binaries
echo "Checking and installing required binaries..."
check_binary aws
check_binary eksctl
check_binary kubectl
check_binary terraform
check_binary jq

echo "Pre-deployment checks and installations are complete."
