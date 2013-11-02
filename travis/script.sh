#!/bin/sh
set -e

echo "Build cannot complete - Travis does not support iOS 7 / Xcode 5 yet."
# xctool -workspace ObjectiveHAL.xcworkspace -scheme ObjectiveHAL -sdk iphonesimulator build test
