#!/bin/bash

COLOR_RESET='\e[0m'
COLOR_RED='\e[0;31m'
COLOR_BLUE='\e[0;34m'
COLOR_BOLD_RED='\e[1;31m'

dbg() {
  printf "${COLOR_BLUE}${1}${COLOR_RESET}\n"
}

title() {
  printf "\n${COLOR_RED}${1}: ${2}${COLOR_RESET}\n"
}

confirm() {
  printf "\n${COLOR_BOLD_RED}: ${1}${COLOR_RESET}\n"
  read -p "Continue? " -n 1 -r
  echo # (optional) move to a new line
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    return 1
  else
    # do dangerous stuff
    return 0
  fi
}
