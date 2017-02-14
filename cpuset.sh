#!/bin/bash -f

# Create /user and /system
cset set -c 4-63 /system
cset set -c 4-63 /user

# Delete /system.slice and /user.slice
cset set -d --recurse --force /user.slice
cset set -d --recurse --force /system.slice

# Move all from /root to /system
cset proc --force  -m -f root system -k
cset shield -k on