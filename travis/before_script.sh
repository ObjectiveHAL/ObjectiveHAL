#!/bin/sh
set -e

echo "BEFORE BUILD (BEGIN)"

echo "Installing additional tools using homebrew."
brew update
brew install xctool
brew install lighttpd

# Add lighttpd to the list of allowed applications to accept incoming network connections.
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw -s /usr/local/sbin/lighttpd
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
/usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/sbin/lighttpd
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# This hack is here to make sure that the xctool dividers fit.
stty columns 60

echo "BEFORE BUILD (END)"
