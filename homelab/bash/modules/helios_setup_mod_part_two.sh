#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy
# Author: NayanTheSpaceGuy (nayantsg@proton.me)
# License: GPLv3.0+
# https://github.com/NayanTheSpaceGuy/dotfiles-and-homelab/raw/main/LICENSE

source "$HELIOS_SETUP_BASE_PATH"/lib/detect_linux_distribution.sh

function helios_setup_part_two_header_info ()
{
    clear
    echo " _   _  _____  _      _____  _____  _____            _____  _____  _____  _   _ ______      ______   ___  ______  _____   _____   "
    echo "| | | ||  ___|| |    |_   _||  _  |/  ___|          /  ___||  ___||_   _|| | | || ___ \  _  | ___ \ / _ \ | ___ \|_   _| / __  \  "
    echo "| |_| || |__  | |      | |  | | | |\ '--.   ______  \ '--. | |__    | |  | | | || |_/ / (_) | |_/ // /_\ \| |_/ /  | |   '' / /'  "
    echo "|  _  ||  __| | |      | |  | | | | '--. \ |______|  '--. \|  __|   | |  | | | ||  __/      |  __/ |  _  ||    /   | |     / /    "
    echo "| | | || |___ | |____ _| |_ \ \_/ //\__/ /          /\__/ /| |___   | |  | |_| || |      _  | |    | | | || |\ \   | |   ./ /___  "
    echo "\_| |_/\____/ \_____/ \___/  \___/ \____/           \____/ \____/   \_/   \___/ \_|     (_) \_|    \_| |_/\_| \_|  \_/   \_____/  "
    echo ""
    echo "Loading..."
}

function helios_setup_mod_part_two ()
{
    set -eEuo pipefail
    if [ "$(detect_linux_distribution)" == "debian" ]; then
        helios_setup_part_two_header_info
        echo "Detected Debian distribution. Proceeding with the setup..."

        echo ""
        echo "'Helios-Setup : Part 2' bash script completed successfully!"
        echo "Reboot trinity-helios for some changes to take effect."
    else
        helios_setup_part_two_header_info
        echo ""
        echo "Uh-oh. Your distribution is currently not supported."
        echo "This script is only intended to run on Debian distributions currently."
    fi
}
