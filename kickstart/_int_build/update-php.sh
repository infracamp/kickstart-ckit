#!/usr/bin/env bash

set -Eeo pipefail

sudo apt-get update
sudo apt-get install -y php7.4-dev composer bison re2c

curl -L https://github.com/php/php-src/archive/php-7.4.6.tar.gz --output /tmp/php.tar.gz
cd /tmp
tar -xzf php.tar.gz
cd  php-src-php-7.4.6/
./buildconf --force
./configure --enable-static --enable-json --enable-cli --enable-pcntl --disable-all
make

cp sapi/cli/php /kickstart/bin/_kick_php


## Clean up after build
rm -R /tmp/*
sudo apt-get remove -y --purge php7.4-dev bison re2c
sudo apt-get autoremove -y
