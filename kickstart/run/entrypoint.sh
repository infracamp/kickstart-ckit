#!/bin/bash
##
# Entrypoint
#
# Base entrypoint for kickstart-flavor containers
#
# This script will:
#
#

# Trigger errors on failure (see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/)
set -Eeo pipefail
trap 'on_error $LINENO' ERR;

PROGNAME=$(basename $0)
__DIR__=$(dirname $0)

## Include Libraries
. $__DIR__/_inc/logging.sh

info "Entrypoint location '$0'";

function on_error () {
    emergency "Error: ${PROGNAME} on line $1";
    echo "Error: ${PROGNAME} on line $1" 1>&2
    echo "(Run './kickstart.sh :debug-shell' or './kickstart.sh :debug' to investigate the error)" 1>&2
    exit 1
}

function run_dir () {
    local dir="$1/*.sh";
    local origLogname=$LOGNAME
    local origProgName=$PROGNAME

    for file in $dir
    do
        local LOGNAME=$origLogname

        debug " + Exec '$file'"

        local LOGNAME=$(basename $file)
        local PROGNAME=${LOGNAME}
        . $file
    done
    PROGNAME=${origProgName}
    LOGNAME=${origLogname}
}

# Only in production mode: callback for SIGTERM
function on_sigterm () {
    info "Got SIGTERM - container shutdown initiated. Running stop.d/ scripts..."
    run_dir /kickstart/run/stop.d
    info "Shutdown complete. Exiting container."
    exit 0
}

if [ "$WORKDIR" = "" ]
then
    WORKDIR="/opt"
fi;

colorText "   >>   KICKSTART FLAVOR CONTAINER :: infracamp.org   <<   " 97 104
info "Date: $(date), DevUID: '$DEV_UID', WorkDir: '$WORKDIR', ProjectName: '$DEV_CONTAINER_NAME', Parameters: '$@'"

## Set kickstart bin as path (otherwise kick isn't found)
PATH=/kickstart/bin:$PATH



if [ "$1" = "debug" ] || [ "$2" = "debug" ]
then
    warn "DEBUG MODE - DEBUG MODE - DEBUG MODE"
    echo -e "env:\n$(env)\n\npwd:\n$(pwd)\n\nls -la:\n$(ls -la)\n\nls -laR /opt:\n$(ls -laR /opt)"
    info "End of debug output. Closing container."
    exit;
fi;

if [ "$1" = "debug-shell" ] || [ "$2" = "debug-shell" ]
then
    warn "DEBUG MODE - DEBUG MODE - DEBUG MODE"
    warn "running root shell..."
    /bin/bash
    exit;
fi;

if [ -z "$(ls -A $WORKDIR)" ];
then
   emergency " ERROR! $WORKDIR is empty!"
   emergency "This normally means, your ci configuration is incorrect. Please see the manual."
   emergency "To investigate this issue, you can run ./kickstart.sh :debug"
   echo ""
   emergency "If this happens in gitlab-ci - builds, you should first verfiy the 'services:' section"
   emergency "contains 'docker:dind'"
   echo ""
   exit 10
fi



info "Running '$__DIR__/prepare.d/' scripts"
run_dir $__DIR__/prepare.d

info "Changing work dir to $WORKDIR"
cd $WORKDIR

if [ "$1" == "standalone" ]
then
    shift;

    colorText "     >> PRODUCTION MODE / STANDALONE <<    " 97 45

    info "Running 'kick write_config_file'"
    sudo -E -s -u user kick write_config_file

    info "Running 'kick init'"
    sudo -E -s -u user kick init

    info "Running '$__DIR__/start.d/'"
    run_dir $__DIR__/start.d


    ## Registering SIGTERM trap to assure graceful container shutdown
    ## Will run
    trap 'on_sigterm' SIGTERM;


    if (( $# < 1 ))
    then
        info "Running default action (no parameters found): 'kick run'"
        sudo -E -s -u user kick run
    else
        info "skipping default action (parameter found)"
        for cmd in $@; do
            if [ "$cmd" == "bash" ]
            then
                info "command 'bash' found - starting bash"
                sudo -E -s -u user /bin/bash
                exit 0;
            fi;
            if [ "$cmd" == "exit" ]
            then
                info "[start.sh] command 'exit' found - leaving container"
                exit 0;
            fi;
            info "Running 'kick $cmd'"
            sudo -E -s -u user kick $cmd
        done
    fi;

    ## Keep the container running
    info "Startup successful"
    debug "Running 'kick interval'  (interval: 60sec)"
    while [ true ]
    do
        set +e
        sudo -E -s -u user kick interval
        sleep 60
    done
    exit 0
else
    colorText "DEVELOPMENT MODE STARTUP" 97 46

    if [ ! -f /etc/kick_build_done ]
    then
        info "Running 'kick build'"
        sudo -E -s -u user kick build
        touch /etc/kick_build_done
    else
        debug "/etc/kick_build_done exists - assuming wakeup action."
    fi

    if [ "$1" == "build" ]
    then
        info "[BUILD MODE] Closing image after build"
        info "Build successful."
        exit 0;
    fi;

    info "Running '$__DIR__/dev.d/'"
    run_dir $__DIR__/dev.d

    info "Running 'kick write_config_file'"
    sudo -E -s -u user kick write_config_file

    info "Running 'kick init'"
    sudo -E -s -u user kick init

    info "Running '$__DIR__/start.d/'";
    run_dir $__DIR__/start.d

    if [ "$1" == "" ]
    then
        info "Running 'kick dev' (development mode)"
        sudo -E -s -u user kick dev

        RUN_SHELL=1
    else
        colorText "      [[--  KICKSTART RUNNER MODE  --]]      " 97 46
        debug "skipping default action (parameter found)"
        for cmd in $@; do
            if [ "$cmd" == "exit" ]
            then
                info "command 'exit' found - leaving container"
                exit 0;
            fi;
            info "Running 'kick $cmd' (command)"
            sudo -E -s -u user kick $cmd
        done
        RUN_SHELL=0
    fi;

    colorText "      [[--  KICKSTART DEVELOPMENT MODE  --]]      " 97 46
    colorText "                            happy developing      " 97 46
    echo "";


    if [ "$RUN_SHELL" == "1" ]
    then
        # RUN BASH
        # Ignore return code of bash (so last triggered error wont trigger kickstart error on exit)
        set +Eeo pipefail
        trap - ERR;
        sudo -E -s -u user /bin/bash
    fi;
    colorText "Leaving container. Goodbye..." 32
    exit
fi;
