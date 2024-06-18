#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy
# Author: NayanTheSpaceGuy (nayantsg@proton.me)
# License: GPLv3.0+
# https://github.com/NayanTheSpaceGuy/dotfiles-and-homelab/raw/main/LICENSE

####################
# Special Functions
###################
# Detect Linux distribution
distribution ()
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
locale ()
{
    local localetype="unknown" # Default to unknown

    if [ "$LANG" == "*.*8" ]; then
        localetype="UTF-8"
    else
        localetype="UTF"
    fi

    echo "$localetype"
}

#######
# Main
######
main_helios_setup ()
{
    if [ "$(distribution)" == "debian" ]; then
        echo "-------------"
        echo "Here we go..."
        echo "-------------"
        echo ""
        echo "Detected Debian distribution. Proceeding with the setup..."

        echo "Updating package lists and dist-upgrading packages..."
        apt-get update
        apt-get dist-upgrade -y

        echo "Installing required packages (curl, sops, age, git, ansible)..."
        apt-get install -y curl age git ansible

        SOPS_LATEST_VERSION=$(curl -s "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        curl -Lo sops.deb "https://github.com/getsops/sops/releases/download/v${SOPS_LATEST_VERSION}/sops_${SOPS_LATEST_VERSION}_amd64.deb"
        apt --fix-broken install ./sops.deb
        rm -rf sops.deb

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
                read -r -p "Enter the new value for the key: " new_key
                echo "$new_key" > ~/.sops/dotfiles-and-homelab-key.txt
                echo "Key file updated with the new value."
            else
                echo "Keeping the existing key file."
            fi
        else
            read -r -p "Enter the value for the key: " key_value
            echo "$key_value" > ~/.sops/dotfiles-and-homelab-key.txt
            echo "Key file created with the provided value."
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

        echo "Creating new setup directory and navigating to it..."
        mkdir ~/helios-setup
        cd ~/helios-setup || return

        echo "Cloning GitHub repository using SSH..."
        git clone --recurse-submodules git@github.com:NayanTheSpaceGuy/dotfiles-and-homelab.git

        echo "Running the helios-setup ansible playbook..."
        HELIOS_SETUP_ANSIBLE_DIR="$HOME/helios-setup/dotfiles-and-homelab/homelab/ansible"
        if [ "$(locale)" == "UTF-8" ]; then
            ansible-playbook \
                -i "${HELIOS_SETUP_ANSIBLE_DIR}/inventory/spacehlship.yml" \
                "${HELIOS_SETUP_ANSIBLE_DIR}/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml"
        else
            LANG=en_IN.UTF_8 ansible-playbook \
                -i ~/helios-setup/dotfiles-and-homelab/homelab/ansible/inventory/spacehlship.yml \
                ~/helios-setup/dotfiles-and-homelab/homelab/ansible/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml
        fi

        echo "helios-setup bash script and ansible playbook completed successfully!"
    else
        echo "This script is only intended to run on Debian distributions currently."
    fi
}
