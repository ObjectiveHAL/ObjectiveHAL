#!/bin/sh
set -e

echo "BEFORE BUILD (BEGIN)"

echo "Ensure latest version of Cocoapods is used."
gem update cocoapods

echo "Installing additional tools using homebrew."
brew update
#brew install xctool
brew install lighttpd
brew install appledoc

# Launch Lighty in the background. It serves test fixtures at port 7100.
if [ -f /usr/local/sbin/lighttpd ]
then
    /usr/local/sbin/lighttpd -f lighttpd/lighttpd.conf
else
    ls -Rla /usr/local
fi

# This hack is here to make sure that the xctool dividers fit.
stty columns 60

echo "BEFORE BUILD (END)"
