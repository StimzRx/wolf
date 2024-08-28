#!/bin/bash


## VARIABLES ##
TARGET_OVERLAY_DIR=/home/retro/.steam/debian-installation/steamapps
###############


# Include the gow bash utils library for logging
source /opt/gow/bash-lib/utils.sh

# Assign defaults if needed
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

gow_log  "[OverlayFS-Entrypoint] Permission UID:GID is ${PUID}:${PGID}"

# Make sure the overlayfs directorys and targeted overlay directory exist
mkdir -p /overlayfs/user/{upper,work}
mkdir -p $TARGET_OVERLAY_DIR

# Change permissions of the directories
chown $PUID:$PGID -R /overlayfs/user/{upper,work}
chown $PUID:$PGID -R /home/retro

gow_log  "[OverlayFS-Entrypoint] Creating overlay mount..."

# Create the overlay using:
# 'lowerdir' is the readonly steamapps directory we defined in /etc/wolf/cfg/config.toml
# 'upperdir' is the persistent "read & write" directory
# 'workdir' seems to be like a cache for files that are in a in-between state? Its required reguardless and needs to be not a subfolder of 'upperdir'
# finally, the final arg '/home/retro/.steam/debian-installation/steamapps' is the targeted overlay directory we want the overlay to exist at
mount -t overlay overlay -o lowerdir=/overlayfs/steam-ro/,upperdir=/overlayfs/user/upper/,workdir=/overlayfs/user/work/ $TARGET_OVERLAY_DIR

# Launch the base image's entrypoint.sh which will handle starting steam
gow_log  "[OverlayFS-Entrypoint] Launching base entrypoint.sh"
source /entrypoint.sh