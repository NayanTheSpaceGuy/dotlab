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
