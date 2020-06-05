#!/usr/bin/env bash

set -Eeo pipefail

dir="/kickstart/flavor/build.d/*.sh";
for file in $dir
do
    echo "Executing file $file"
    . $file
    mv $file $file.done
done

rm -rf /var/lib/apt/lists/*