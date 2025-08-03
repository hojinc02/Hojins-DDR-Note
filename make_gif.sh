#!/bin/bash
source ~/.bashrc
shopt -s expand_aliases

if [ $# -ne 1 ]; then
    echo "Wrong number of arguments (should be 1)"
else
    ffmpeg -i "$1" -vf "crop=640:945:640:135" -ss 00:01:22 -t 00:00:07 -f yuv4mpegpipe - | gifski --fps 50 --width 320 -o ./out.gif -
    du -sh ./out.gif
    echo "Done"
fi