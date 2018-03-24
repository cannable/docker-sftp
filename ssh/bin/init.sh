#!/bin/sh


homedir=/ssh/home


# ------------------------------------------------------------------------------
# Phase 1: Build Initial SSH Config
# ------------------------------------------------------------------------------

# Create an SSHD config from the template
cp /ssh/etc/sshd_config.template /etc/ssh/sshd_config
echo "Match User $SSH_USER" >> /etc/ssh/sshd_config
cat /ssh/etc/sftp_tail.template >> /etc/ssh/sshd_config

# Set up authorized_keys file(s)
mkdir /etc/ssh/authorized_keys/
chmod 755 /etc/ssh/authorized_keys/
echo "$AUTHORIZED_KEYS" > /etc/ssh/authorized_keys/$SSH_USER
chmod 644 /etc/ssh/authorized_keys/$SSH_USER

# Set up homedir FS
for d in $SSH_DIRS; do
    echo Creating $homedir/$d.
    mkdir $homedir/$d
done


# ------------------------------------------------------------------------------
# Phase 2: Override SSH Bits with Existing Copies
# ------------------------------------------------------------------------------

# Copy config & keys over
# (an existing sshd_config will clobber the template stuff we did)
cp -R /ssh/etc/* /etc/ssh/

# Generate keys if they don't exist
ssh-keygen -A


# ------------------------------------------------------------------------------
# Phase 3: User Configuration
# ------------------------------------------------------------------------------

# Set up user
echo Setting up user...
addgroup -g $SSH_UID $SSH_USER
adduser -h $homedir -u $SSH_UID -G $SSH_USER -S -s /sbin/nologin $SSH_USER
echo "$SSH_USER:$(pwgen -c -n -y -s -1 23)" | chpasswd


# ------------------------------------------------------------------------------
# Phase 4: Permission Cleanup
# ------------------------------------------------------------------------------

# Fix home & SSHD file permisions (just in case)
echo Fix home permisions...
chown root $homedir
chgrp root $homedir
chmod 0755 $homedir

# Set SSH directory permissions
for d in $SSH_DIRS; do
    echo Creating $homedir/$d.
    chown -R $SSH_USER:$SSH_USER $homedir/$d
    chmod $SSH_DIR_PERM $homedir/$d
    chmod -R $SSH_DIR_CONT_PERM $homedir/$d/*
done

echo Fix SSHD file permisions...
chown -R root:root /etc/ssh/
chmod 600 /etc/ssh/*_key
chmod 644 /etc/ssh/*_key.pub
chmod 644 /etc/ssh/sshd_config


# ------------------------------------------------------------------------------
# Phase 5: Sync Final Config With /ssh Directory
# ------------------------------------------------------------------------------

# Sync config & keys with volume
cp -R /etc/ssh/* /ssh/etc/


# ------------------------------------------------------------------------------
# Phase 6: The End
# ------------------------------------------------------------------------------

# Run sshd
/usr/sbin/sshd -D
