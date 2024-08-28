#!/bin/bash

function update_apt_packages ()
{
    apt-get update
    apt-get upgrade -y
}

function update_packages ()
{
    update_apt_packages
}
