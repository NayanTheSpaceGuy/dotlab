#!/bin/bash

# Copyright (c) 2024 NayanTheSpaceGuy
# Author: NayanTheSpaceGuy (nayantsg@proton.me)
# License: GPLv3.0+
# https://github.com/NayanTheSpaceGuy/dotfiles-and-homelab/raw/main/LICENSE

source "$HELIOS_SETUP_BASE_PATH"/modules/helios_setup_mod_part_one.sh
source "$HELIOS_SETUP_BASE_PATH"/modules/helios_setup_mod_part_two.sh

function helios_setup_header_info ()
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
    echo "-------------"
    echo "Here we go..."
    echo "-------------"
}

function get_user_desired_automation ()
{
    echo "Please select which part of the automation to run:"
    echo "1) Part One"
    echo "2) Part Two"
    echo "3) Exit"
    read -r -p "Enter your choice (1-3): " desired_automation
    echo
}

function helios_setup_mod_main ()
{
    set -eEuo pipefail
    helios_setup_header_info

    while true; do
        get_user_desired_automation

        case $desired_automation in
            1)
                echo "Running Part One..."
                helios_setup_mod_part_one
                ;;
            2)
                echo "Running Part Two..."
                helios_setup_mod_part_two
                ;;
            3)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}
