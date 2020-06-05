#!/usr/bin/env bash

set -Eeo pipefail

sudo apt-get update
sudo apt-get install -y php7.4-dev composer wget

wget -o /tmp/php.tar.gz https://github.com/php/php-src/archive/php-7.4.6.tar.gz
cd /tmp
tar -xzf php.tar.gz
cd php-7.4.6
./configure --enable-static --enable-json --enable-cli --enable-pcntl --disable-all
make

cp sapi/cli/php /kickstart/bin/_kick_php

rm -R /tmp/*
