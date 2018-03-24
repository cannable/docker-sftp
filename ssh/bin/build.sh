#!/bin/sh

homedir=/ssh/home

# Install prereqs
echo Installing prerequisite packages...
apk update
apk add --no-cache \
    dumb-init \
    pwgen \
    openssh-sftp-server \
    openssh-server

echo Purging apk cache...
apk cache clean

echo Done

exit
