#!/bin/sh
set -e

xctool -workspace ObjectiveHAL.xcworkspace -scheme ObjectiveHAL build test

