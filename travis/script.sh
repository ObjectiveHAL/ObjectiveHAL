#!/bin/sh
set -e

xctool -workspace ObjectiveHAL.xcworkspace -scheme ObjectiveHAL -sdk iphonesimulator build test
