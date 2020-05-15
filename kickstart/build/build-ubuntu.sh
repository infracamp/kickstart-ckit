#!/usr/bin/env bash

dir="/kickstart/build/ubuntu.d/*.sh";
for file in $dir
do
    echo "Executing file $file"
    . $file
done

rm -rf /var/lib/apt/lists/*

echo "Build done"