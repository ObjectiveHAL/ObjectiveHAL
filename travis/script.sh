#!/bin/sh
set -e

echo TRAVIS=$TRAVIS
xctool -workspace ObjectiveHAL.xcworkspace -scheme ObjectiveHAL -sdk iphonesimulator build test
