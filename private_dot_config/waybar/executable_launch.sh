#!/bin/bash

# Quit all running waybar instances
killall waybar
sleep 0.2

# Default theme: /THEMEFOLDER;/VARIATION 
themestyle="/waybar-tspagen;/waybar-tspagen/black"

# Get current theme information from .cache/.themestyle.sh
if [ -f $XDG_CACHE_HOME/waybar/.themestyle.sh ]; then
    themestyle=$(cat $XDG_CACHE_HOME/waybar/.themestyle.sh)
else
    touch $XDG_CACHE_HOME/waybar/.themestyle.sh
    echo "$themestyle" > $XDG_CACHE_HOME/waybar/.themestyle.sh
fi

IFS=';' read -ra arrThemes <<< "$themestyle"
echo ${arrThemes[0]}

if [ ! -f $XDG_CONFIG_HOME/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle="/waybar-tspagen;/waybar-tspagen/black"
fi

# Loading the configuration
config_file="config"
style_file="style.css"

# Check used files
echo "Config: $config_file"
echo "Style: $style_file"

waybar -c $XDG_CONFIG_HOME/waybar/themes${arrThemes[0]}/$config_file -s $XDG_CONFIG_HOME/waybar/themes${arrThemes[1]}/$style_file &
