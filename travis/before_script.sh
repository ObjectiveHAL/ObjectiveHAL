#!/bin/sh
set -e

brew update
brew install xctool

# This hack is here to make sure that the xctool dividers fit.
stty columns 60
