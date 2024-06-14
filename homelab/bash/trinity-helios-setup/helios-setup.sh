#!/bin/bash

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
    OS='Debian'
else
    OS='Unknown'
fi

if [ "$OS" == "Debian" ]; then
    echo "Here we go.."
    echo "Detected Debian distribution. Proceeding with the setup..."

    echo "Updating package lists and dist-upgrading packages..."
    apt-get update
    apt-get dist-upgrade -y

    echo "Installing required packages (git, ansible)..."
    apt-get install -y git ansible

    echo "Creating new setup directory and navigating to it..."
    mkdir ~/helios-setup
    cd ~/helios-setup || return

    echo "Cloning GitHub repository using SSH..."
    git clone git@github.com:NayanTheSpaceGuy/dotfiles-and-homelab.git

    echo "Running the helios-setup ansible playbook..."
    ansible-playbook -i ~/helios-setup/dotfiles-and-homelab/homelab/ansible/inventory/spacehlship.yml ~/helios-setup/dotfiles-and-homelab/homelab/ansible/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml

    echo "helios-setup bash script completed successfully!"
else
    echo "This script is only intended to run on Debian distributions currently."
fi
