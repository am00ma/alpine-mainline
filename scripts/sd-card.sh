#!/bin/bash

export OUTPUT_DIR=../data/rg35xx
export OUTPUT_IMAGE_PATH="$OUTPUT_DIR/alpine-rg35xx.img"

./01_create_empty_image_file.sh vars
./01_create_empty_image_file.sh do
./01_create_empty_image_file.sh debug
