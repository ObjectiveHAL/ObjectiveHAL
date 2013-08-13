#!/bin/bash

DIR=${SRCROOT-`pwd`}

echo "Stopping lighttp, if already present on system."
if [ -f ~/Library/LaunchAgents/objectivehal.lighttpd.plist ]; then
    launchctl unload ~/Library/LaunchAgents/objectivehal.lighttpd.plist
    rm ~/Library/LaunchAgents/objectivehal.lighttpd.plist
fi
