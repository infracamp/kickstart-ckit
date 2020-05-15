#!/usr/bin/env bash

set -e

apt-get install -y  curl zip vim nano git sudo whois bash-completion pwgen netcat locales
locale-gen en_US.UTF-8