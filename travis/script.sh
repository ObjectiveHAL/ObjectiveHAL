#!/bin/sh
set -e

xctool -workspace ObjectiveHAL -scheme ObjectiveHAL build test

