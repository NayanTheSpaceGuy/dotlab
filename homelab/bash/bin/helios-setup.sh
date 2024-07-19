#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy. See accompanying modules for full copyright notice.

HELIOS_SETUP_BASE_PATH="$HOME/helios-setup"
GIT_REPO_RAW_URL="https://raw.githubusercontent.com/NayanTheSpaceGuy/dotfiles-and-homelab/main"

# Remove exisiting directory and create new directories
rm -rf "$HELIOS_SETUP_BASE_PATH"
mkdir -p "$HELIOS_SETUP_BASE_PATH"/{lib,modules}

# Download lib scripts
wget -O "$HELIOS_SETUP_BASE_PATH/lib/detect_linux_distribution.sh" "$GIT_REPO_RAW_URL/lib/detect_linux_distribution.sh"
wget -O "$HELIOS_SETUP_BASE_PATH/lib/update_packages.sh" "$GIT_REPO_RAW_URL/lib/update_packages.sh"
wget -O "$HELIOS_SETUP_BASE_PATH/lib/install_sops.sh" "$GIT_REPO_RAW_URL/lib/install_sops.sh"

# Download module scripts
wget -O "$HELIOS_SETUP_BASE_PATH/modules/helios_setup_mod_main.sh" "$GIT_REPO_RAW_URL/modules/helios_setup_mod_main.sh"
wget -O "$HELIOS_SETUP_BASE_PATH/modules/helios_setup_mod_part_one.sh" "$GIT_REPO_RAW_URL/modules/helios_setup_mod_part_one.sh"
wget -O "$HELIOS_SETUP_BASE_PATH/modules/helios_setup_mod_part_two.sh" "$GIT_REPO_RAW_URL/modules/helios_setup_mod_part_two.sh"

# Source module scripts
source "$HELIOS_SETUP_BASE_PATH/modules/helios_setup_mod_main.sh"

# Export the base path for use in modules
export HELIOS_SETUP_BASE_PATH

# Run module main function
helios_setup_mod_main
