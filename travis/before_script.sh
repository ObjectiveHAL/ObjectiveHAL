#!/bin/sh
set -e

echo "BEFORE BUILD (BEGIN)"

echo "Installing additional tools using homebrew."
brew update
brew install xctool
brew install lighttpd

# This hack is here to make sure that the xctool dividers fit.
stty columns 60

echo "BEFORE BUILD (END)"
