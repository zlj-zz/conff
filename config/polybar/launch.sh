#!/usr/bin/bash

killall -q polybar

while pgrep -x >/dev/null;do sleep 1; done

polybar zz
