#!/usr/bin/env sh

# Movie example, you need quicklisp and mencoder for this to work
STARTP=$1
ITER=$2
W=$3
H=$4

if [ "$1" = "--help" ]; then
		echo "usage: $0 <startpoint> <iterations> <width> <height>";
		exit;
fi;

echo rendering movie....
sbcl --non-interactive --load mandel.fasl --load threading.fasl --load gfx.fasl \
		 --eval "(setf *iterations* ${ITER:=400})" \
		 --eval "(init-travel '${STARTP:=sun})" --eval "(setf *VIEWPORT* (next-vp))" --eval  "(MAKE-MOVIE-MP ${W:=768} ${H:=768})"

mencoder mf://image*.png -mf fps=25 -ovc x264 -oac copy -o output.avi
rm image*.png
echo done!
echo rendered to output.avi
