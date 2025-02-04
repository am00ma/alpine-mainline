#!/bin/bash
source ./colors.sh
set -u
# ------------------------------------------------------------------------------
# 1. Create an empty image file (2GB for example)
#     - inputs: OUTPUT_IMAGE_PATH
#     - outputs: OUTPUT_IMAGE_PATH
# ------------------------------------------------------------------------------
title "$(basename "$0")" "$1"

case "$1" in

vars)
  echo "OUTPUT_IMAGE_PATH: $OUTPUT_IMAGE_PATH"
  ;;

do)
  dd if=/dev/zero of="$OUTPUT_IMAGE_PATH" bs=1M count=2048
  ;;

undo)
  if confirm "Delete image: $OUTPUT_IMAGE_PATH"; then
    rm "$OUTPUT_IMAGE_PATH"
  fi
  ;;

debug)
  dbg "Check with fdisk (image size, partitions)"
  fdisk -l "$OUTPUT_IMAGE_PATH"
  ;;

*)
  echo "Error: $(basename "$0"): Invalid command: $1"
  ;;

esac
