#!/bin/bash

#########################################
## AWS EC2 Instance Install Script ##
#########################################
## by zer0Bytes##
#########################################

source ./bash.d/linkdot
linkdots all

if [ -d ./install.d ]; then
    for i in ./install.d/*; do
        [ -f "${i}" ] && source "${i}"
    done
fi



}
