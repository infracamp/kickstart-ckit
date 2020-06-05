#!/usr/bin/env bash

set -Eeo pipefail

sudo apt-get update
sudo apt-get install -y php7.4-dev composer

curl https://www.php.net/distributions/php-7.4.6.tar.gz --output /tmp/php.tar.gz
cd /tmp
tar -xzf php.tar.gz
cd php-7.4.6
./configure --enable-static --enable-json --enable-cli --enable-pcntl --disable-all
make

cp sapi/cli/php /kickstart/bin/_kick_php