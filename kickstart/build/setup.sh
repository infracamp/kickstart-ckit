#!/bin/bash

##
# Initialize the flavor on build time with the correct
# settings.
#
# Create the 'user' main user, setup sudo, etc.
#
# This should be called only once during build time of the
# flavor container


## set -e: Stop on error
set -e
set -o pipefail
trap 'on_error $LINENO' ERR;
PROGNAME=$(basename $0)

function on_error () {
    echo "Error: ${PROGNAME} on line $1" 1>&2
    exit 1
}

####################################################################
## Execute after .dockerfile-build.sh
####################################################################


useradd -s /bin/bash --create-home user
# Add user to admin group
gpasswd -a user adm
chown user:root /opt


## Remove secure_path (otherwise $PATH will be resetted with each sudo call)
echo "`cat /etc/sudoers | grep -v "secure_path"`" > /etc/sudoers

## Allow the user to execute commands as root with no password.
## If you need an unpriviledged user, it has to be created within the build stage
echo "user   ALL = (ALL) NOPASSWD:   ALL" >> /etc/sudoers

cat <<\EOF >> /home/user/.bashrc
##
## Added from kickstart-flavor-kit build.sh (user-section):
##
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export GIT_EDITOR=vim

. /kickstart/tools/select-console.sh default

## Change Dir to /opt
cd /opt

EOF

cat <<\EOF >> /root/.bashrc
##
## Added from kickstart-flavor-kit build.sh (root-section):
##
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export GIT_EDITOR=vim
export PATH="$PATH:/root/.composer/vendor/bin"

. /kickstart/tools/select-console.sh default_root
## Change Dir to /opt
cd /opt

EOF


echo "[setup.sh] Finished without errors"



