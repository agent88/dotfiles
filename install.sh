#!/bin/bash

#########################################
## AWS EC2 Instance Install Script ##
#########################################
## by zer0Bytes##
#########################################

source "$HOME".dotfiles/user.d/bash.d/linkdots
linkdots all

if [ -d "$HOME".dotfiles/install.d ]; then
    for i in "$HOME".dotfiles/install.d/*; do
        [ -f "${i}" ] && source "${i}"
    done
fi

"$system-utils"
"$xtitle"
"$unclutter-xfixes"
"$i3-wm"
"$i3blocks-gaps"
"$betterscreenlock"
"$flash-focus"
"$rofi"

echo "Server customisation complete"
