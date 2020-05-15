#!/bin/bash


case "$1" in

    "old")
        export PS1="\u@\[$(tput sgr0)\]\[\033[38;5;42m\]$DEV_CONTAINER_NAME\[$(tput sgr0)\]\[\033[38;5;8m\]:\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;21m\]\w\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;8m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
        ;;

    "default")
        export PS1='\[\033[01;32m\]\[\033[0m\033[0;32m\]\[\033[01;97;44m\][\u@$DEV_CONTAINER_NAME]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1)$ '
        ;;

    "default_root")
        export PS1='\[\033[01;32m\]\[\033[0m\033[0;32m\]\[\033[01;97;41m\][\u@$DEV_CONTAINER_NAME]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ '
        ;;

    *)
        echo "unknown"
        exit 1
esac;

