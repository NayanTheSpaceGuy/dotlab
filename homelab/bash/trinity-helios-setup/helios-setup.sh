#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy
# Author: NayanTheSpaceGuy (nayantsg@proton.me)
# License: GPLv3.0+
# https://github.com/NayanTheSpaceGuy/dotfiles-and-homelab/raw/main/LICENSE

####################
# Special Functions
###################
# Detect Linux distribution
function distribution ()
{
        local dtype="unknown"  # Default to unknown

        # Use /etc/os-release for modern distro identification
        if [ -r /etc/os-release ]; then
            source /etc/os-release
            case $ID in
                fedora|rhel|centos)
                    dtype="redhat"
                    ;;
                sles|opensuse*)
                    dtype="suse"
                    ;;
                ubuntu|debian)
                    dtype="debian"
                    ;;
                gentoo)
                    dtype="gentoo"
                    ;;
                arch)
                    dtype="arch"
                    ;;
                slackware)
                    dtype="slackware"
                    ;;
                *)
                    # If ID is not recognized, keep dtype as unknown
                    ;;
            esac
        fi

        echo "$dtype"
}

# Detect locale
function locale ()
{
    local localetype="unknown" # Default to unknown

    if [ "$LANG" == "*.*8" ]; then
        localetype="UTF-8"
    else
        localetype="UTF"
    fi

    echo "$localetype"
}

############
# Functions
###########

function header_info ()
{
    clear
    echo " _   _  _____  _      _____  _____  _____            _____  _____  _____  _   _ ______  "
    echo "| | | ||  ___|| |    |_   _||  _  |/  ___|          /  ___||  ___||_   _|| | | || ___ \ "
    echo "| |_| || |__  | |      | |  | | | |\ '--.   ______  \ '--. | |__    | |  | | | || |_/ / "
    echo "|  _  ||  __| | |      | |  | | | | '--. \ |______|  '--. \|  __|   | |  | | | ||  __/  "
    echo "| | | || |___ | |____ _| |_ \ \_/ //\__/ /          /\__/ /| |___   | |  | |_| || |     "
    echo "\_| |_/\____/ \_____/ \___/  \___/ \____/           \____/ \____/   \_/   \___/ \_|     "
    echo ""
    echo "Loading..."
}

function base_installation ()
{
    echo "Updating package lists and dist-upgrading..."
    apt-get update
    apt-get dist-upgrade -y

    echo "Installing required packages (curl, sops, age, git, ansible)..."
    apt-get install -y curl age git ansible

    SOPS_LATEST_VERSION=$(curl -s "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    curl -Lo sops.deb "https://github.com/getsops/sops/releases/download/v${SOPS_LATEST_VERSION}/sops_${SOPS_LATEST_VERSION}_amd64.deb"
    apt --fix-broken install ./sops.deb

    echo "Installing required ansible roles with ansible-galaxy..."
    ansible-galaxy role install artis3n.tailscale

    echo "Cleaning up..."
    rm -rf sops.deb
}

function github_deploy_key_setup ()
{
    echo "Setting up GitHub Deploy Key..."

    # Check if ~/.ssh/deploy-dotfiles-and-homelab-ntsg exists
    if [ -f ~/.ssh/dotfiles-and-homelab-ntsg ]; then
        echo "The key file ~/.ssh/deploy-dotfiles-and-homelab-ntsg already exists."
        read -r -p "Do you want to overwrite it? (y/n) " overwrite
        if [ "$overwrite" == "y" ]; then
            read -r -p "Enter the new value for the key: " new_deploy_key_value
            echo "$new_deploy_key_value" > ~/.ssh/deploy-dotfiles-and-homelab-ntsg
            echo "Deploy key file updated with the new value."
        else
            echo "Keeping the existing deploy key file."
        fi
    else
        read -r -p "Enter the value for the key: " deploy_key_value
        echo "$deploy_key_value" > ~/.ssh/deploy-dotfiles-and-homelab-ntsg
        echo "Deploy key file created with the provided value."
    fi

    # Update the GitHub repository configuration in ~/.ssh/config
    echo "Updating ~/.ssh/config with GitHub repository configuration..."
    {
        echo "Host github.com-dotfiles-and-homelab"
        echo "    Hostname github.com"
        echo "    IdentityFile=$HOME/.ssh/deploy-dotfiles-and-homelab-ntsg"
    } > ~/.ssh/config
    echo "GitHub repository configuration updated in ~/.ssh/config"

    echo "Finished setting up GitHub Deploy Key"
}

function sops_setup ()
{
    echo "Setting up SOPS..."

    # Check and create ~/.sops directory if it doesn't exist
    if [ ! -d ~/.sops ]; then
        echo "Creating ~/.sops directory..."
        mkdir ~/.sops
    fi

    # Check if ~/.sops/dotfiles-and-homelab-key.txt exists
    if [ -f ~/.sops/dotfiles-and-homelab-key.txt ]; then
        echo "The key file ~/.sops/dotfiles-and-homelab-key.txt already exists."
        read -r -p "Do you want to overwrite it? (y/n) " overwrite
        if [ "$overwrite" == "y" ]; then
            read -r -p "Enter the new value for the key: " new_sops_key_value
            echo "$new_sops_key_value" > ~/.sops/dotfiles-and-homelab-key.txt
            echo "SOPS key file updated with the new value."
        else
            echo "Keeping the existing SOPS key file."
        fi
    else
        read -r -p "Enter the value for the key: " sops_key_value
        echo "$sops_key_value" > ~/.sops/dotfiles-and-homelab-key.txt
        echo "SOPS key file created with the provided value."
    fi

    # Check if SOPS_AGE_KEY_FILE is set correctly
    SOPS_AGE_KEY_FILE_NEW_VALUE="$HOME/.sops/dotfiles-and-homelab-key.txt"
    if [ "${SOPS_AGE_KEY_FILE:-}" != "$SOPS_AGE_KEY_FILE_NEW_VALUE" ]; then
        echo "Setting SOPS_AGE_KEY_FILE environment variable"
        export SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE_NEW_VALUE"
        if grep -q "^export SOPS_AGE_KEY_FILE=" "$HOME/.bashrc"; then
            sed -i "s|^export SOPS_AGE_KEY_FILE=.*|export SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE_NEW_VALUE|" "$HOME/.bashrc"
        else
            echo "export SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE_NEW_VALUE" >> "$HOME/.bashrc"
        fi
    else
        echo "SOPS_AGE_KEY_FILE environment variable already set correctly"
    fi

    source ~/.bashrc

    echo "Finished setting up SOPS"
}

function sops_decryption ()
{
    HELIOS_SETUP_ANSIBLE_DIR="$HOME/helios-setup/dotfiles-and-homelab/homelab/ansible"
    sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") \
    -i "${HELIOS_SETUP_ANSIBLE_DIR}/vars/spacehlship/helios-setup-vars.env"
}

function run_ansible_playbook ()
{
    echo "Proceeding with ansible for further setup..."
    echo "Running the helios-setup ansible playbook..."
    HELIOS_SETUP_ANSIBLE_DIR="$HOME/helios-setup/dotfiles-and-homelab/homelab/ansible"
    if [ "$(locale)" == "UTF-8" ]; then
        ansible-playbook \
        -i "${HELIOS_SETUP_ANSIBLE_DIR}/inventory/spacehlship.ini" \
        "${HELIOS_SETUP_ANSIBLE_DIR}/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml"
    else
        LANG=en_IN.UTF_8 ansible-playbook \
        -i "${HELIOS_SETUP_ANSIBLE_DIR}/inventory/spacehlship.ini" \
        "${HELIOS_SETUP_ANSIBLE_DIR}/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml" \
        --user root --ask-pass
    fi
}

#######
# Main
######
set -eEuo pipefail
if [ "$(distribution)" == "debian" ]; then
    header_info
    echo "Detected Debian distribution. Proceeding with the setup..."
    echo "-------------"
    echo "Here we go..."
    echo "-------------"
    echo ""

    base_installation
    github_deploy_key_setup
    sops_setup

    echo "Creating new setup directory and navigating to it..."
    rm -rf ~/helios-setup || return
    mkdir ~/helios-setup
    cd ~/helios-setup

    echo "Cloning GitHub repository using SSH..."
    git clone --recurse-submodules git@github.com-dotfiles-and-homelab:NayanTheSpaceGuy/dotfiles-and-homelab.git
    sops_decryption

    run_ansible_playbook

    echo "helios-setup bash script and ansible playbook completed successfully!"
else
    header_info
    echo "This script is only intended to run on Debian distributions currently."
fi
