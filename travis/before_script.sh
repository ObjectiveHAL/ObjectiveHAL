#!/bin/sh
set -e

brew update
brew install xctool
brew install lighttpd

# This hack is here to make sure that the xctool dividers fit.
stty columns 60

# Dump the environment variables for reference
printenv


