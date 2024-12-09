#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy
# Author: NayanTheSpaceGuy (nayantsg@proton.me)
# License: GPLv3.0+
# https://github.com/NayanTheSpaceGuy/dotlab/raw/main/LICENSE

HELIOLENS_SETUP_BASE_PATH="$HOME/heliolens-setup"
GIT_REPO_RAW_URL="https://raw.githubusercontent.com/NayanTheSpaceGuy/dotlab/main"

# Remove exisiting directory and create new directories
rm -rf "$HELIOLENS_SETUP_BASE_PATH"
mkdir -p "$HELIOLENS_SETUP_BASE_PATH"

# Download common scripts
wget -O "$HELIOLENS_SETUP_BASE_PATH/detect_linux_distribution.sh" "$GIT_REPO_RAW_URL/boilerplates/shell_scripts/detect_linux_distribution.sh"
wget -O "$HELIOLENS_SETUP_BASE_PATH/update_packages.sh" "$GIT_REPO_RAW_URL/homelab/boilerplates/shell_scripts/update_packages.sh"
wget -O "$HELIOLENS_SETUP_BASE_PATH/install_sops.sh" "$GIT_REPO_RAW_URL/homelab/boilerplates/shell_scripts/install_sops.sh"

# Source scripts
source "$HELIOLENS_SETUP_BASE_PATH/detect_linux_distribution.sh"
source "$HELIOLENS_SETUP_BASE_PATH/update_packages.sh"
source "$HELIOLENS_SETUP_BASE_PATH/install_sops.sh"
# source "../common/necronux_header_info.sh"

###############################
# Functions
##############################
function part_one_header_info ()
{
    echo "----------------------------------"
    echo "TRINITY-HELIOLENS SETUP : PART ONE"
    echo "----------------------------------"
    echo ""
    echo "Loading..."
}

function base_installation ()
{
    echo ""
    echo "------------------------------------------------"
    echo "Updating package lists and upgrading packages..."
    echo "------------------------------------------------"
    update_packages

    echo ""
    echo "------------------------------------------------------------------------"
    echo "Installing required packages (curl, sops, age, git, ansible, sshpass)..."
    echo "------------------------------------------------------------------------"
    apt-get install -y curl age git ansible sshpass
    install_sops

    echo ""
    echo "--------------------------------------------------------"
    echo "Installing required ansible roles with ansible-galaxy..."
    echo "--------------------------------------------------------"
    ansible-galaxy role install artis3n.tailscale
}

function github_pat_setup ()
{
    echo ""
    echo "------------------------------------------"
    echo "Setting up GitHub Personal Access Token..."
    echo "------------------------------------------"

    # Check and create ~/.github directory if it doesn't exist
    if [ ! -d ~/.github ]; then
        echo "Creating ~/.github directory..."
        mkdir "$HOME"/.github
    fi

    # Check if ~/.github/dotlab-pat.txt exists
    if [ -f ~/.github/dotfiles-and-homelab-pat.txt ]; then
        echo "The Personal Access Token already exists."
        read -r -p "Do you want to overwrite it? (y/n) " overwrite
        if [ "$overwrite" == "y" ]; then
            read -r -s -p "Enter the new value for PAT: " new_pat_key_value
            echo "$new_pat_key_value" > ~/.github/dotlab-pat.txt
            chmod 600 ~/.github/dotlab-pat.txt
            echo "GitHub PAT updated with the new value."
        else
            echo "Keeping the existing GitHub PAT."
        fi
    else
        read -r -s -p "Enter the value for PAT: " pat_key_value
        echo "$pat_key_value" > ~/.github/dotlab-pat.txt
        chmod 600 ~/.github/dotlab-pat.txt
        echo "GitHub PAT created with the provided value."
    fi

    echo "Finished setting up GitHub Personal Access Token."
}

function github_pat ()
{
    github_pat_value=$(cat ~/.github/dotlab-pat.txt)
    echo "$github_pat_value"
}

function sops_setup ()
{
    echo ""
    echo "------------------"
    echo "Setting up SOPS..."
    echo "------------------"

    # Check and create ~/.sops directory if it doesn't exist
    if [ ! -d ~/.sops ]; then
        echo "Creating ~/.sops directory..."
        mkdir ~/.sops
    fi

    # Check if ~/.sops/dotlab-key.txt exists
    if [ -f ~/.sops/dotlab-key.txt ]; then
        echo "The key file ~/.sops/dotlab-key.txt already exists."
        read -r -p "Do you want to overwrite it? (y/n) " overwrite
        if [ "$overwrite" == "y" ]; then
            echo "Enter the new value for the key (press Enter on a new line to finish):"
            new_sops_key_value=""
            while IFS= read -r -s line; do
                [[ -z "$line" ]] && break
                new_sops_key_value+="$line"$'\n'
            done
            echo "$new_sops_key_value" > ~/.sops/dotlab-key.txt
            echo "SOPS key file updated with the new value."
        else
            echo "Keeping the existing SOPS key file."
        fi
    else
        echo "Enter the value for the key (press Enter on a new line to finish):"
        sops_key_value=""
        while IFS= read -r -s line; do
                [[ -z "$line" ]] && break
                sops_key_value+="$line"$'\n'
        done
        echo "$sops_key_value" > ~/.sops/dotlab-key.txt
        echo "SOPS key file created with the provided value."
    fi

    source ~/.bashrc

    # Check if SOPS_AGE_KEY_FILE is set correctly
    SOPS_AGE_KEY_FILE_NEW_VALUE="$HOME/.sops/dotlab-key.txt"
    if [ "${SOPS_AGE_KEY_FILE:-}" != "$SOPS_AGE_KEY_FILE_NEW_VALUE" ]; then
        echo "Setting up SOPS_AGE_KEY_FILE environment variable."
        export SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE_NEW_VALUE"
        if grep -q "^export SOPS_AGE_KEY_FILE=" "$HOME/.bashrc"; then
            sed -i "s|^export SOPS_AGE_KEY_FILE=.*|export SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE_NEW_VALUE|" "$HOME/.bashrc"
        else
            echo "export SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE_NEW_VALUE" >> "$HOME/.bashrc"
        fi
    else
        echo "SOPS_AGE_KEY_FILE environment variable already set correctly."
    fi

    source ~/.bashrc

    echo "Finished setting up SOPS."
}

function clone_repo ()
{
    echo ""
    echo "----------------------"
    echo "Cloning GitHub Repo..."
    echo "----------------------"

    echo "Creating new setup directory and navigating to it..."
    rm -rf "$HOME"/heliolens-setup || return
    mkdir "$HOME"/heliolens-setup
    cd "$HOME"/heliolens-setup

    echo "Cloning GitHub repository with HTTPS URL..."
    git clone https://NayanTheSpaceGuy:"$(github_pat)"@github.com/NayanTheSpaceGuy/dotlab.git
    cd dotlab

    echo "Removing all existing submodules..."
    rm -rf dotlab-private
    rm -rf dotlab/nvim/.config/nvim
    rm -f .gitmodules
    touch .gitmodules
    rm -rf .git/modules

    echo "Adding submodules with HTTPS URL..."
    git submodule add -f \
    https://NayanTheSpaceGuy:"$(github_pat)"@github.com/NayanTheSpaceGuy/dotlab-private.git \
    dotlab-private

    echo "Initializing submodules..."
    git submodule update --init --recursive dotlab-private
}

function sops_decryption ()
{
    echo ""
    echo "-------------------------------"
    echo "Decrypting secrets with SOPS..."
    echo "-------------------------------"

    HELIOLENS_SETUP_ANSIBLE_DIR="$HOME/heliolens-setup/dotlab/homelab/ansible"
    sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") \
    -i "$HELIOLENS_SETUP_ANSIBLE_DIR/inventory/group_vars/trinity_heliolens_parent/secrets.yml"

    echo "Finished decrypting secrets with SOPS."
}

function run_ansible_playbook ()
{
    echo "Proceeding with ansible for further setup..."

    echo ""
    echo "-----------------------------------------------"
    echo "Running the heliolens-setup ansible playbook..."
    echo "-----------------------------------------------"

    HELIOLENS_SETUP_ANSIBLE_DIR="$HOME/heliolens-setup/dotlab/homelab/ansible"
    cd "$HELIOLENS_SETUP_ANSIBLE_DIR"
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    "playbooks/scheduled/heliolens-cockpit-1-semaphore/setup-trinity-heliolens-part-1.yml" \
    --user root --ask-pass -e "desired_hosts=trinity_heliolens_ip"
}

#######
# Main
######
set -eEuo pipefail
if [ "$(detect_linux_distribution)" == "debian" ]; then
    # necronux_header_info
    part_one_header_info
    echo "Detected Debian distribution. Proceeding with the setup..."

    base_installation
    github_pat_setup
    sops_setup
    clone_repo
    sops_decryption
    run_ansible_playbook

    echo ""
    echo "'Trinity-Heliolens Setup : Part One' script completed successfully!"
    echo "Reboot trinity-heliolens for some changes to take effect."
else
    # necronux_header_info
    part_one_header_info
    echo ""
    echo "Uh-oh. Your distribution is currently not supported."
    echo "This script is only intended to run on Debian distributions currently."
fi
