#!/usr/bin/env bash
COLS=$(tput cols)
LNS=$(tput lines)
echo $?
STARTP=$1
ITER=$2
DELAY=$3

if [ $STARTP == "list" ];
then
		sbcl --non-interactive --load mandel.lisp --eval "(progn (cls) (home))" --eval "(format t \"Try these nice Locations: ~%~%   ~{~a~^, ~}~%\" (mapcar #'car *mandel-travel-map*))" --noprint 2>/dev/null
		exit;
fi;

sbcl --non-interactive --eval "(compile-file #p\"mandel.lisp\")" \
		 --eval "(compile-file #p\"threading.lisp\")" \
		 --load mandel.fasl \
		 --load threading.fasl \
		 --eval "(setf *delay* ${DELAY:=0})" \
		 --eval "(setf *iterations* ${ITER:=1000})" \
		 --eval "(init-travel '${STARTP:=trunks} 0.95d0)" \
		 --eval "(defparameter *lastcolors* 2)" \
		 --eval "(loop while (and (> *pxs* 0) (> *lastcolors* 1)) do (setf *viewport* (next-vp)) (setf *lastcolors* (count-colors-ascii (asciipaint-mp $(( ${COLS} - 1)) $(( ${LNS} -1 ))))) (read-cmd))" \
		 --eval "(format t \"Last rendered Viewport was ~a~%Zoom (w): ~a~%\" *viewport* (current-w))" \
		 --eval "(format t \"Rendered ~,'0:d frames.  ~,2f fps~%~%\"  *frames* (getf (get-stats) :fps))"






