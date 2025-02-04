#!/bin/bash

COLOR_RESET='\e[0m'
COLOR_BLACK='\e[0;30m'
COLOR_GRAY='\e[1;30m'
COLOR_RED='\e[0;31m'
COLOR_BOLD_RED='\e[1;31m'
COLOR_GREEN='\e[0;32m'
COLOR_BOLD_GREEN='\e[1;32m'
COLOR_BROWN='\e[0;33m'
COLOR_YELLOW='\e[1;33m'
COLOR_BLUE='\e[0;34m'
COLOR_BOLD_BLUE='\e[1;34m'
COLOR_PURPLE='\e[0;35m'
COLOR_BOLD_PURPLE='\e[1;35m'
COLOR_CYAN='\e[0;36m'
COLOR_BOLD_CYAN='\e[1;36m'
COLOR_BOLD_GRAY='\e[0;37m'
COLOR_WHITE='\e[1;37m'

dbg() {
  printf "${COLOR_BLUE}${1}${COLOR_RESET}\n"
  $1
}

title() {
  printf "\n${COLOR_RED}${1}: ${2}${COLOR_RESET}\n"
}

# ------------------------------------------------------------------------------
# 1. Create an empty image file (2GB for example)
#     - inputs: OUTPUT_IMAGE_PATH
#     - outputs: `alpine-rg35xx.img`
#     - debug: `fdisk -l alpine-rg35xx.img`
#
# ------------------------------------------------------------------------------
create_empty_image_file() {
  title "create_empty_image_file" "$1"

  case "$1" in

  vars)
    echo "OUTPUT_IMAGE_PATH: $OUTPUT_IMAGE_PATH"
    ;;

  do)
    dd if=/dev/zero of="$OUTPUT_IMAGE_PATH" bs=1M count=2048
    ;;

  undo)
    rm "$OUTPUT_IMAGE_PATH"
    ;;

  debug)
    dbg "ls -lah "$OUTPUT_IMAGE_PATH""
    dbg "fdisk -l "$OUTPUT_IMAGE_PATH""
    ;;

  *)
    echo "Error: create_empty_image_file: Invalid command: $1"
    ;;
  esac
}

OUTPUT_DIR=./data/rg35xx
OUTPUT_IMAGE_PATH="$OUTPUT_DIR/alpine-rg35xx.img"

create_empty_image_file vars
create_empty_image_file do
create_empty_image_file debug
create_empty_image_file undo
create_empty_image_file debug
