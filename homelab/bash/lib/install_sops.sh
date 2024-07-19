#!/bin/bash

function install_sops_deb ()
{
    if ! dpkg -s sops &> /dev/null; then
        echo "SOPS is not installed. Installing now..."
        SOPS_LATEST_VERSION=$(curl -s "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        curl -Lo sops.deb "https://github.com/getsops/sops/releases/download/v${SOPS_LATEST_VERSION}/sops_${SOPS_LATEST_VERSION}_amd64.deb"
        dpkg -i ./sops.deb
        apt-get install -f # Install missing dependencies
        echo "SOPS has been installed successfully."
        sops --version
    else
        echo "SOPS is already installed."
        sops --version
    fi
}

function cleanup_sops_installation_files ()
{
    if [ -f sops.deb ]; then
        rm -rf sops.deb
        echo "Removed installation files that are no longer required."
    else
        echo "No installation files to remove."
    fi
}

function install_sops ()
{
    install_sops_deb
    cleanup_sops_installation_files
}
