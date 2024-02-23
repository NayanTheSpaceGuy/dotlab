#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Hyprland on login
if [[ "$(tty)" = "/dev/tty1" ]]; then
  Hyprland 
fi

# Defaults
VIM="nvim"

# Exporting env "variables
export DOTFILES=$HOME/personal/dotfiles
export GIT_EDITOR=$VIM

if [ -e /home/thespaceguy/.nix-profile/etc/profile.d/nix.sh ]; then . /home/thespaceguy/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
