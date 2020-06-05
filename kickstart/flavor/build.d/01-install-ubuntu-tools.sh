#!/usr/bin/env bash

set -e

# Packages that have less recommends
apt-get install -y curl zip whois bash-completion locales netcat

# Install raw packages (reduce size)
apt-get install -y --no-install-recommends vim nano pwgen

locale-gen en_US.UTF-8