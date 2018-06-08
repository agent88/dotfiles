#!/bin/bash

#########################################
## AWS EC2 Instance Install Script ##
#########################################
## by zer0Bytes##
#########################################

source ~/.dotfiles/bash.d/linkdot
linkdots all

if [ -d ~/.dotfiles/install.d ]; then
    for i in ~/.dotfiles/install.d/*; do
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
