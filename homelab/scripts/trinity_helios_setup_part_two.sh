#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy
# Author: NayanTheSpaceGuy (nayantsg@proton.me)
# License: GPLv3.0+
# https://github.com/NayanTheSpaceGuy/dotlab/raw/main/LICENSE

HELIOS_SETUP_BASE_PATH="$HOME/helios-setup"
GIT_REPO_RAW_URL="https://raw.githubusercontent.com/NayanTheSpaceGuy/dotlab/main"

# Download common scripts
wget -O "$HELIOS_SETUP_BASE_PATH/detect_linux_distribution.sh" "$GIT_REPO_RAW_URL/boilerplates/shell_scripts/detect_linux_distribution.sh"

# Source scripts
source "$HELIOS_SETUP_BASE_PATH/detect_linux_distribution.sh"
# source "../common/necronux_header_info.sh"

###############################
# Functions
##############################
function part_two_header_info ()
{
    echo "-------------------------------"
    echo "TRINITY-HELIOS SETUP : PART TWO"
    echo "-------------------------------"
    echo ""
    echo "Loading..."
}

#######
# Main
######
set -eEuo pipefail
if [ "$(detect_linux_distribution)" == "debian" ]; then
    # necronux_header_info
    part_two_header_info
    echo "Detected Debian distribution. Proceeding with the setup..."
    echo ""
    echo "'Trinity-Helios Setup : Part Two' script completed successfully!"
    echo "Reboot trinity-helios for some changes to take effect."
else
    # necronux_header_info
    part_two_header_info
    echo ""
    echo "Uh-oh. Your distribution is currently not supported."
    echo "This script is only intended to run on Debian distributions currently."
fi
