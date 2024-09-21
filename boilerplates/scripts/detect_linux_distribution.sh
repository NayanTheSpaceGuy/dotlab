#!/bin/bash

function detect_linux_distribution ()
{
        local linux_distribution_type="unknown"  # Default to unknown

        # Use /etc/os-release for modern distro identification
        if [ -r /etc/os-release ]; then
            source /etc/os-release
            case $ID in
                fedora|rhel|centos)
                    linux_distribution_type="redhat"
                    ;;
                sles|opensuse*)
                    linux_distribution_type="suse"
                    ;;
                ubuntu|debian)
                    linux_distribution_type="debian"
                    ;;
                gentoo)
                    linux_distribution_type="gentoo"
                    ;;
                arch)
                    linux_distribution_type="arch"
                    ;;
                slackware)
                    linux_distribution_type="slackware"
                    ;;
                *)
                    # If ID is not recognized, keep dtype as unknown
                    ;;
            esac
        fi

        echo "$linux_distribution_type"
}
