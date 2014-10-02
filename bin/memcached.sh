#!/bin/sh
# `chpst` is part of running. `chpst -u memcache` runs the given command
# as the user `memcache`. If you omit this, the command will be run as root.
#
exec chpst -u memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1
