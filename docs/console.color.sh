#!/usr/bin/env bash


COLOR_NC='\e[0m' # No Color
COLOR_WHITE='\e[1;37m'
COLOR_BLACK='\e[0;30m'
COLOR_BLUE='\e[0;34m'
COLOR_LIGHT_BLUE='\e[1;34m'
COLOR_GREEN='\e[0;32m'
COLOR_LIGHT_GREEN='\e[1;32m'
COLOR_CYAN='\e[0;36m'
COLOR_LIGHT_CYAN='\e[1;36m'
COLOR_RED='\e[0;31m'
COLOR_LIGHT_RED='\e[1;31m'
COLOR_PURPLE='\e[0;35m'
COLOR_LIGHT_PURPLE='\e[1;35m'
COLOR_BROWN='\e[0;33m'
COLOR_YELLOW='\e[1;33m'
COLOR_GRAY='\e[0;30m'
COLOR_LIGHT_GRAY='\e[0;37m'

LOGNAME=$(basename $0)

function colorText() {
    local msg=$1;
    local fg=$2
    local bg=$3
    local tp=1;
    echo -e "\e[$bg;$tp;${fg}m$msg\e[0m";
}

function header() {
    local msg=$1;
    local fg=97; local tp=1; bg=44;
    echo -e "\e[$bg;$tp;${fg}m$msg\e[0m";
}



function debug() {
    local msg=$1;
    local fg=37; local tp=0;
    echo -e "\e[$tp;${fg}m[$LOGNAME] $1\e[0m";
}

function info() {
    local msg=$1;
    local fg=34; local tp=2;
    echo -e "\e[$tp;${fg}m[$LOGNAME] $1\e[0m";
}
function warn() {
    local PROGNAME=$(basename $0)
    local msg=$1;
    local fg=33; local tp=2;
    echo -e "\e[$tp;${fg}m[$LOGNAME] $1\e[0m";
}
function emergency() {
    local msg=$1;
    local fg=101; local tp=1; bg=44;
    echo -e "\e[$bg;$tp;${fg}m\n$msg\e[0m";
}

header "header()"
debug "debug()"
info "info()"
warn "warn()"
emergency "emergency()"


colorText "colorText '' 32" 32
colorText "colorText '' 97 45" 97 45
colorText "colorText '' 97 104" 97 104
colorText "colorText '' 97 46" 97 46

logLine "hello world"