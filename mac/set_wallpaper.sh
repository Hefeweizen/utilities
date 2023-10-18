#!/usr/bin/env bash
#
# Right now, we're just changing the current desktop.
# Potential future change: https://www.gabrieldougherty.com/posts/macos-change-desktop-background-image/
#

source_folder="${HOME}/Pictures/Wallpaper/catppuccin/gradients/"

image=$(find "${source_folder}" -type f -name '*.png' -o -name '*.jpg' -o -name '*.gif' | sort -R | head -1)

osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"${image}\" as POSIX file"
