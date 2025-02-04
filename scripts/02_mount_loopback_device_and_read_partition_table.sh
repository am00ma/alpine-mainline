#!/bin/bash
source ./colors.sh
set -u
# ------------------------------------------------------------------------------
# 2. Mount as a loopback device and read partition table
#     - inputs: OUTPUT_IMAGE_PATH
#     - outputs: /dev/loopXX
#
# NEEDS SUDO
# ------------------------------------------------------------------------------
title "$(basename "$0")" "$1"

case "$1" in

vars)
  echo "OUTPUT_IMAGE_PATH: $OUTPUT_IMAGE_PATH"
  ;;

do)
  sudo losetup -fP "$OUTPUT_IMAGE_PATH"
  ;;

undo)
  loop="$(losetup --list | grep "$OUTPUT_IMAGE_PATH" | cut -d' ' -f1)"
  echo "losetup -d $loop"
  if confirm "Remove loopback device: $loop"; then
    sudo losetup -d "$loop"
  fi
  ;;

debug)
  dbg "Check loops"
  losetup --list | grep "$OUTPUT_IMAGE_PATH"
  ;;

*)
  echo "Error: $(basename "$0"): Invalid command: $1"
  ;;

esac
