#!/bin/sh
(
echo "AFTER BUILD (BEGIN)"
killall lighttpd
echo "AFTER BUILD (END)"
) | tee -a travis/after.log
