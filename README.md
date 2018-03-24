# docker-sftp

An OpenSSH-based SFTP server.

# Before Running

Check out the section for AUTHORIZED_KEYS. If you don't set this environment
argument at run time, you will have a perfectly working SFTP container with no
way to get into it.

# Some Things to Know

Everything lives in /sftp; out of the box, this is a volume. Under this
directory are three subdirectories:

* bin
* etc
* home

** bin**

The bin directory contains scripts used to build and start this container.
Under normal circumstances, you shouldn't have to mess with these.

** etc**

The etc directory contains stuff that will get copied to /etc/ssh/ at startup.
During container startup, a number of things happen to this area. First, an
sshd_config is created to fit the container environment. Second, an
authorized_keys file is generated. Finally, just before starting sshd, the
contents of /etc/ssh/ are copied back to /ssh/etc/. This synced copy will
include any host keys created, so you shouldn't have any key weirdness
restarting containers.

Why did I just explain this? Well, a few reasons. While a volume is
automatically created to persist /ssh/, any live changes you make to the config
files under here will not do anything until you restart the container. If you
need to experiment with your config, you should short-circuit the CMD
Dockerfile directive to run /bin/sh, run /ssh/bin/init.sh by hand, then sync
your config changes back to /ssh/etc/sshd_config.

Another reason I brought this up is that config is synced back to /ssh/etc
once, at container startup. If you want to do so while sshd is running, you'll
have to do this by hand.

Could I have just launched sshd with -f and pointed straight at the config
file at /ssh/etc/sshd_config? Yes. This was a conscious decision - the standard
location was committed to muscle memory long ago and I'm lazy.

TL;DR version (which I really should have put above this wall of text): things
are the way they are because I'm lazy.

**home**

This directory stores the SFTP chroot FS. This directory is owned by root; the
SFTP user has no rights. Subdirectories will be created at container startup
that will be writable by the SFTP user.

# Changing Run-Time Configuration

**SSH_USER**

This sets the name of the user that you intend to use for SFTP services. The
default is 'cornelius' for reasons.

Oh, by the way, the user will be given a random password, just for kicks. This
password isn't stored, nor echoed, anywhere. With the shell set to nologin and
SSH configured to not do password authentication, setting a password is
probably redundant, but, whatever.

**SSH_UID**

Like SSH_USER, sets the uid of the SFTP user. The default is 1234 because I
lack imagination.

**AUTHORIZED_KEYS**

Unless you really mess with the config, this container will only accept SSH
keys for authentication. You need to pass a public key line in this argument.
The contents of this variable will get written to /etc/ssh/authorized_keys/%u
(which is referenced in sshd_config).

Technically speaking, you could pass multiple keys by popping some escaped
newlines in the variable. I'd recommend against this, as it could become an
unmaintainable mess. If you want to add more than one or two keys, you should
probably just replace /ssh/etc/authorized_keys/%u by hand.

**SSH_DIRS**

The init.sh script can (and will) create dropbox directories under the home
path. Stock config creates an in and out directory. Separate directories with
spaces. If you want to create a directory with a space in the name, have fun in
quoting hell. Seriously rethink what you're doing before attempting this. There
is no achievement for getting it to work.

**SSH_DIR_PERM**

Tunable to control what permissions are assigned to dropbox directories.
Default is 755 (the owner will be $SSH_USER:$SSH_USER).

**SSH_DIR_CONT_PERM**

This doesn't really do anything for a new container. If you have existing
dropboxes with contents, the init.sh script will change the permissions of the
contents. Mostly, this is to avoid bizarre permission issues for containers
that are brought up and down a lot. The default is 644 (ownership is the SFTP
user).

# Other Stuff

Poke around the git repo if you want more info. There's not much else to know -
it's OpenSSH. It should just keep on trucking until you break something.
