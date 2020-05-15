#!/bin/bash
##
# Entrypoint
#
# Base entrypoint for kickstart-flavor containers
#
# This script will:
#
#


set -e
set -o pipefail
trap 'on_error $LINENO' ERR;
PROGNAME=$(basename $0)

function on_error () {
    echo "Error: ${PROGNAME} on line $1" 1>&2
    echo "(Run './kickstart.sh :debug-shell' or './kickstart.sh :debug' to investigate the error)" 1>&2
    exit 1
}

function run_dir () {
    local dir="$1/*.sh";
    for file in $dir
    do

        echo "Executing file $file"
        . $file
    done
}

# Only in production mode: callback for SIGTERM
function on_sigterm () {
    echo "Got SIGTERM - container shutdown initiated. Running stop.d/ scripts..."
    run_dir /kickstart/run/stop.d
    echo "Shutdown complete. Exiting container."
    exit 0
}


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


echo -e $COLOR_YELLOW
echo "[start.sh] +----------------------------------------------------+"
echo "[start.sh] | KICKSTART-CONTAINER STARTUP                        |"
echo "[start.sh] +----------------------------------------------------+"
echo "[start.sh] | Running start.sh inside container"
echo "[start.sh] | Parameters.: $@"
echo "[start.sh] | Dev UID....: $DEV_UID"
echo "[start.sh] | ProjectName: $DEV_CONTAINER_NAME"
echo "[start.sh] +----------------------------------------------------+"


if [ "$1" = "debug" ] || [ "$2" = "debug" ]
then
    echo "[start.sh] DEBUG MODE - DEBUG MODE - DEBUG MODE"
    echo "env:"
    env
    echo ""
    echo "pwd: "
    pwd
    echo ""
    echo "ls -la"
    ls -la

    echo "ls -la /opt"
    ls -laR /opt

    echo "End of debug output. Closing container."
    exit;
fi;

if [ "$1" = "debug-shell" ] || [ "$2" = "debug-shell" ]
then
    echo "[start.sh] DEBUG MODE - DEBUG MODE - DEBUG MODE"
    echo ""
    echo "running the bash"
    echo ""
    /bin/bash
    exit;
fi;

if [ -z "$(ls -A /opt)" ];
then
   echo "[start.sh] WARNING! /opt is empty!"
   echo "This normally means, your ci configuration is incorrect. Please see the manual."
   echo "To investigate this issue, you can run ./kickstart.sh :debug"
   echo ""
   echo "If this happens in gitlab-ci - builds, you should first verfiy the 'services:' section"
   echo "contains 'docker:dind'"
   echo ""
   exit 10
fi

## Set kickstart bin as path (otherwise kick isn't found)
PATH=/kickstart/bin:$PATH

echo "[start.sh] Running prepare.d/ scripts"
run_dir /kickstart/run/prepare.d

echo "[start.sh] Changing work dir to /opt"
cd /opt

if [ "$1" == "standalone" ]
then
    shift;

    echo "";
    echo "Starting container " `date`
    echo "+--------------------------------------------------------+"
    echo "| Production / Standalone mode                           |"
    echo "+--------------------------------------------------------+"

    echo "[start.sh] + kick write_config_file"
    sudo -E -s -u user kick write_config_file

    echo "[start.sh] + kick init"
    sudo -E -s -u user kick init

    echo "Running kickstart standalone mode..."
    run_dir /kickstart/run/start.d


    ## Registering SIGTERM trap to assure graceful container shutdown
    ## Will run
    trap 'on_sigterm' SIGTERM;


    if (( $# < 1 ))
    then
        echo "[start.sh] Running default action (no parameters found)"
        echo "[start.sh] + kick run"
        sudo -E -s -u user kick run
    else
        echo "[start.sh] + skipping default action (parameter found)"
        for cmd in $@; do
            if [ "$cmd" == "bash" ]
            then
                echo "[start.sh] command 'bash' found - starting bash"
                sudo -E -s -u user /bin/bash
                exit 0;
            fi;
            if [ "$cmd" == "exit" ]
            then
                echo "[start.sh] command 'exit' found - leaving container"
                exit 0;
            fi;
            echo "[start.sh] + kick $cmd"
            sudo -E -s -u user kick $cmd
        done
    fi;

    ## Keep the container running
    echo "Service running..."
    echo "[start.sh] + kick interval  (interval: 60sec)"
    while [ true ]
    do
        set +e
        sudo -E -s -u user kick interval
        sleep 60
    done
    exit 0
else
    echo "+--------------------------------------------------------+"
    echo "| DEVELOPMENT MODE - DEVELOPMENT MODE - DEVELOPMENT MODE |"
    echo "+--------------------------------------------------------+"

    if [ ! -f /etc/kick_build_done ]
    then
        echo "[start.sh] + kick build"
        sudo -E -s -u user kick build
        touch /etc/kick_build_done
    else
        echo "[start.sh][SKIP kick build]: /etc/kick_build_done exists - assuming wakeup action."
    fi

    if [ "$1" == "build" ]
    then
        echo "[BUILD MODE] Closing image after build"
        echo "Build successful."
        exit 0;
    fi;

    echo "running dev.d/ ..."
    run_dir /kickstart/run/dev.d

    echo "[start.sh] + kick write_config_file"
    sudo -E -s -u user kick write_config_file

    echo "[start.sh] + kick init"
    sudo -E -s -u user kick init

    echo "Running start.d/ ";
    run_dir /kickstart/run/start.d

    if [ "$1" == "" ]
    then
        echo "[start.sh] + kick dev (only development mode)"
        sudo -E -s -u user kick dev

        RUN_SHELL=1
    else
        echo "[start.sh] + skipping default action (parameter found)"
        for cmd in $@; do
            if [ "$cmd" == "exit" ]
            then
                echo "[start.sh] command 'exit' found - leaving container"
                exit 0;
            fi;
            echo "[start.sh] + kick $cmd"
            sudo -E -s -u user kick $cmd
        done
        RUN_SHELL=0
    fi;

    echo ""
    echo -e $COLOR_GREEN"Container ready..."
    echo -e $COLOR_NC

    if [ "$RUN_SHELL" == "1" ]
    then
        sudo -E -s -u user /bin/bash
    fi;
    echo "[start.sh] exit; You are now leaving the container. Goodbye."
    exit

fi;
