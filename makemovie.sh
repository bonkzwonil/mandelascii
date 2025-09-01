#!/usr/bin/env sh

# Movie example, you need quicklisp and mencoder for this to work
STARTP=$1

echo rendering movie....
sbcl --non-interactive --load mandel.fasl --load threading.fasl --load gfx.lisp \
		 --eval "(init-travel '${STARTP:=sun})" --eval "(setf *VIEWPORT* (next-vp))" --eval  "(MAKE-MOVIE-MP)"

mencoder mf://image*.png -mf fps=25 -ovc x264 -oac copy -o output.avi
rm image*.png
echo done!
echo rendered to output.avi
