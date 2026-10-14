#!/usr/bin/env bash
# Streams the phone screen into the "Phone" virtual camera used by <PhoneMirror />.
# The phone's USB port is busy with OTG, so adb runs over Wi-Fi.
#
# Usage: ./phone.sh [ip:port]   (ip:port from Developer options -> Wireless debugging)
set -euo pipefail

DEV=/dev/video10
export ADB="${ADB:-$(command -v adb || echo "$HOME/Android/Sdk/platform-tools/adb")}"

if [ ! -e "$DEV" ]; then
    sudo modprobe v4l2loopback video_nr=10 card_label="Phone" exclusive_caps=1
fi

if [ $# -ge 1 ]; then
    "$ADB" connect "$1"
fi

exec scrcpy --v4l2-sink="$DEV" --no-video-playback --no-audio --max-size=1280 --stay-awake
