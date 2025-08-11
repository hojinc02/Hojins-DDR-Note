#!/bin/bash
source ~/.bashrc
shopt -s expand_aliases

if [ $# -ne 1 ]; then
    echo "Wrong number of arguments (should be 1)"
else
    ffmpeg -i "$1" -vf "crop=600:800:660:120" -ss 00:01:46 -t 00:00:08 -f yuv4mpegpipe - | gifski --fps 50 --width 400 -o ./out.gif -
    echo "-------------"
    du -sh ./out.gif
    echo "Done"
fi