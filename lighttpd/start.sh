#!/bin/bash

DIR=${SRCROOT-`pwd`}

echo "Stopping lighttp, if already present on system."
if [ -f ~/Library/LaunchAgents/objectivehal.lighttpd.plist ]; then
    launchctl unload ~/Library/LaunchAgents/objectivehal.lighttpd.plist
    rm ~/Library/LaunchAgents/objectivehal.lighttpd.plist
fi

echo "Configuring lighttpd for launchctl."
cp ${DIR}/lighttpd/objectivehal.lighttpd.plist ~/Library/LaunchAgents/objectivehal.lighttpd.plist
/usr/libexec/PlistBuddy -c "Set :ProgramArguments:2 ${DIR}/lighttpd/lighttpd.conf" ~/Library/LaunchAgents/objectivehal.lighttpd.plist

echo "Starting lighttp."
launchctl load ~/Library/LaunchAgents/objectivehal.lighttpd.plist
launchctl start objectivehal.lighttpd

