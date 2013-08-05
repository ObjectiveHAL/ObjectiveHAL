#!/bin/sh
set -e

brew install lighttpd
cp lighttpd.conf /usr/local/etc/lighttpd.conf
cp homebrew.mxcl.lighttpd.plist ~/Library/LaunchAgents

