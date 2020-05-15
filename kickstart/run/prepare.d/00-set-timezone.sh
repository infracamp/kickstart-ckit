#!/bin/bash

echo "[flavor-start.sh] Setting timezone to $TIMEZONE..."
ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone
