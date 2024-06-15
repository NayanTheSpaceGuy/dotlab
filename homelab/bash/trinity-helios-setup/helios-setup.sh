#!/bin/bash

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
        echo "$localetype"
    fi
}


if [ "$dtype" == "debian" ]; then
    echo "-------------"
    echo "Here we go..."
    echo "-------------"
    echo ""
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
    if [ "$localetype" == "UTF-8" ]; then
    ansible-playbook \
    -i ~/helios-setup/dotfiles-and-homelab/homelab/ansible/inventory/spacehlship.yml \
    ~/helios-setup/dotfiles-and-homelab/homelab/ansible/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml

    else
    LANG=en_IN.UTF_8 ansible-playbook \
    -i ~/helios-setup/dotfiles-and-homelab/homelab/ansible/inventory/spacehlship.yml \
    ~/helios-setup/dotfiles-and-homelab/homelab/ansible/playbooks/setup-proxmoxve/trinity-helios/helios-setup.yml
    fi

    echo "helios-setup bash script completed successfully!"
else
    echo "This script is only intended to run on Debian distributions currently."
fi
